-- ==============================================================================
-- Migration 00030: Harden Property Media DB & Storage RLS for Firebase Third-Party Auth
-- Project: Belagavi Property (PropertyHub)
-- Target Identity Architecture:
--   Firebase UID (auth.jwt()->>'sub') -> profiles.firebase_uid (TEXT UNIQUE)
--   profiles.id (UUID) -> properties.owner_id (UUID FK)
--   properties.id (UUID) -> property_media.property_id (UUID FK)
--   storage.objects.name -> {ownerId}/{propertyId}/images/{fileName}
--
-- Rationale:
--   1. Database: Legacy policies on public.property_media relied on `auth.uid()`,
--      which casts the JWT 'sub' claim to UUID. In Firebase Third-Party Auth,
--      'sub' is an arbitrary alphanumeric string, causing PostgreSQL error `22P02`.
--      Furthermore, properties.owner_id stores public.profiles.id (UUID), not the
--      Firebase UID string.
--   2. Storage: The legacy storage.objects INSERT policy for bucket 'property-media'
--      only checked `auth.role() = 'authenticated'`, allowing any logged-in user
--      to upload arbitrary objects or overwrite paths. This migration drops the broad
--      permissive policy and enforces owner-only storage paths matching the caller's
--      Firebase UID / profile identity and parent property.
-- ==============================================================================

BEGIN;

-- ==============================================================================
-- PART 1: public.property_media Table Hardening
-- ==============================================================================

-- 1. Drop all legacy / obsolete / auth.uid()-based policies on public.property_media
DROP POLICY IF EXISTS "Property owners can insert media" ON public.property_media;
DROP POLICY IF EXISTS "Property owners can delete media" ON public.property_media;
DROP POLICY IF EXISTS "Property owners can update media" ON public.property_media;
DROP POLICY IF EXISTS "Public read property media" ON public.property_media;
DROP POLICY IF EXISTS "Public read active property media or owner" ON public.property_media;

-- 2. INSERT Policy:
-- Authenticated user must own the parent property (bridged via profiles.firebase_uid)
-- or possess admin/founder governance privileges.
CREATE POLICY "Property owners can insert media" 
    ON public.property_media FOR INSERT 
    WITH CHECK (
        auth.jwt()->>'sub' IS NOT NULL AND (
            EXISTS (
                SELECT 1 FROM public.properties p
                JOIN public.profiles pr ON pr.id = p.owner_id
                WHERE p.id = property_media.property_id
                AND pr.firebase_uid = (auth.jwt()->>'sub')
            )
            OR public.is_app_admin_or_founder()
        )
    );

-- 3. UPDATE Policy:
-- Authenticated user must own the parent property or be admin/founder.
CREATE POLICY "Property owners can update media" 
    ON public.property_media FOR UPDATE 
    USING (
        auth.jwt()->>'sub' IS NOT NULL AND (
            EXISTS (
                SELECT 1 FROM public.properties p
                JOIN public.profiles pr ON pr.id = p.owner_id
                WHERE p.id = property_media.property_id
                AND pr.firebase_uid = (auth.jwt()->>'sub')
            )
            OR public.is_app_admin_or_founder()
        )
    )
    WITH CHECK (
        auth.jwt()->>'sub' IS NOT NULL AND (
            EXISTS (
                SELECT 1 FROM public.properties p
                JOIN public.profiles pr ON pr.id = p.owner_id
                WHERE p.id = property_media.property_id
                AND pr.firebase_uid = (auth.jwt()->>'sub')
            )
            OR public.is_app_admin_or_founder()
        )
    );

-- 4. DELETE Policy:
-- Authenticated user must own the parent property or be admin/founder.
CREATE POLICY "Property owners can delete media" 
    ON public.property_media FOR DELETE 
    USING (
        auth.jwt()->>'sub' IS NOT NULL AND (
            EXISTS (
                SELECT 1 FROM public.properties p
                JOIN public.profiles pr ON pr.id = p.owner_id
                WHERE p.id = property_media.property_id
                AND pr.firebase_uid = (auth.jwt()->>'sub')
            )
            OR public.is_app_admin_or_founder()
        )
    );

-- 5. SELECT Policy:
-- Public can read media for 'active' properties; owners can read media for their own
-- properties regardless of status (e.g., drafts, pending review); admins can read all.
CREATE POLICY "Public read active property media or owner" 
    ON public.property_media FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM public.properties p
            WHERE p.id = property_media.property_id
            AND (
                p.status = 'active'
                OR (
                    auth.jwt()->>'sub' IS NOT NULL AND EXISTS (
                        SELECT 1 FROM public.profiles pr
                        WHERE pr.id = p.owner_id
                        AND pr.firebase_uid = (auth.jwt()->>'sub')
                    )
                )
                OR public.is_app_admin_or_founder()
            )
        )
    );

-- ==============================================================================
-- PART 2: storage.objects Bucket 'property-media' Hardening
-- ==============================================================================

-- 6. Drop legacy broad permissive INSERT policy and any prior custom write policies
DROP POLICY IF EXISTS "Authenticated upload for property media" ON storage.objects;
DROP POLICY IF EXISTS "Property owners can upload media objects" ON storage.objects;
DROP POLICY IF EXISTS "Property owners can update media objects" ON storage.objects;
DROP POLICY IF EXISTS "Property owners can delete media objects" ON storage.objects;

-- 7. STORAGE INSERT Policy:
-- Restricts object insertion into bucket 'property-media' to:
--   (a) The caller whose Firebase UID matches Segment 1 of the path (or whose Profile UUID matches),
--       guaranteeing that if the target property in Segment 2 already exists, it belongs to the caller.
--   (b) Strict resolution where Segment 1 is Profile UUID and Segment 2 is caller's Property UUID.
--   (c) Admin / Founder governance authority.
-- Safe against 22P02: Does NOT cast path segments to UUID; uses safe text comparisons (p.id::text).
CREATE POLICY "Property owners can upload media objects"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'property-media'
        AND auth.jwt()->>'sub' IS NOT NULL
        AND (
            -- Branch A: Segment 1 matches caller's Firebase UID (production wizard upload)
            (
                split_part(name, '/', 1) = (auth.jwt()->>'sub')
                AND NOT EXISTS (
                    SELECT 1 FROM public.properties p
                    WHERE p.id::text = split_part(name, '/', 2)
                    AND p.owner_id NOT IN (
                        SELECT pr.id FROM public.profiles pr
                        WHERE pr.firebase_uid = (auth.jwt()->>'sub')
                    )
                )
            )
            -- Branch B: Segment 1 matches caller's Profile UUID (canonical profile path)
            OR (
                EXISTS (
                    SELECT 1 FROM public.profiles pr
                    WHERE pr.id::text = split_part(name, '/', 1)
                    AND pr.firebase_uid = (auth.jwt()->>'sub')
                    AND NOT EXISTS (
                        SELECT 1 FROM public.properties p
                        WHERE p.id::text = split_part(name, '/', 2)
                        AND p.owner_id != pr.id
                    )
                )
            )
            -- Branch C: Admin / Founder authority
            OR public.is_app_admin_or_founder()
        )
    );

-- 8. STORAGE UPDATE Policy:
-- Ensures only the legitimate owner or admin can update/overwrite an existing object in 'property-media'.
CREATE POLICY "Property owners can update media objects"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'property-media'
        AND auth.jwt()->>'sub' IS NOT NULL
        AND (
            (
                split_part(name, '/', 1) = (auth.jwt()->>'sub')
                AND NOT EXISTS (
                    SELECT 1 FROM public.properties p
                    WHERE p.id::text = split_part(name, '/', 2)
                    AND p.owner_id NOT IN (
                        SELECT pr.id FROM public.profiles pr
                        WHERE pr.firebase_uid = (auth.jwt()->>'sub')
                    )
                )
            )
            OR (
                EXISTS (
                    SELECT 1 FROM public.profiles pr
                    WHERE pr.id::text = split_part(name, '/', 1)
                    AND pr.firebase_uid = (auth.jwt()->>'sub')
                    AND NOT EXISTS (
                        SELECT 1 FROM public.properties p
                        WHERE p.id::text = split_part(name, '/', 2)
                        AND p.owner_id != pr.id
                    )
                )
            )
            OR public.is_app_admin_or_founder()
        )
    )
    WITH CHECK (
        bucket_id = 'property-media'
        AND auth.jwt()->>'sub' IS NOT NULL
        AND (
            (
                split_part(name, '/', 1) = (auth.jwt()->>'sub')
                AND NOT EXISTS (
                    SELECT 1 FROM public.properties p
                    WHERE p.id::text = split_part(name, '/', 2)
                    AND p.owner_id NOT IN (
                        SELECT pr.id FROM public.profiles pr
                        WHERE pr.firebase_uid = (auth.jwt()->>'sub')
                    )
                )
            )
            OR (
                EXISTS (
                    SELECT 1 FROM public.profiles pr
                    WHERE pr.id::text = split_part(name, '/', 1)
                    AND pr.firebase_uid = (auth.jwt()->>'sub')
                    AND NOT EXISTS (
                        SELECT 1 FROM public.properties p
                        WHERE p.id::text = split_part(name, '/', 2)
                        AND p.owner_id != pr.id
                    )
                )
            )
            OR public.is_app_admin_or_founder()
        )
    );

-- 9. STORAGE DELETE Policy:
-- Prevents User B from deleting objects belonging to Seller / User A.
CREATE POLICY "Property owners can delete media objects"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'property-media'
        AND auth.jwt()->>'sub' IS NOT NULL
        AND (
            (
                split_part(name, '/', 1) = (auth.jwt()->>'sub')
                AND NOT EXISTS (
                    SELECT 1 FROM public.properties p
                    WHERE p.id::text = split_part(name, '/', 2)
                    AND p.owner_id NOT IN (
                        SELECT pr.id FROM public.profiles pr
                        WHERE pr.firebase_uid = (auth.jwt()->>'sub')
                    )
                )
            )
            OR (
                EXISTS (
                    SELECT 1 FROM public.profiles pr
                    WHERE pr.id::text = split_part(name, '/', 1)
                    AND pr.firebase_uid = (auth.jwt()->>'sub')
                    AND NOT EXISTS (
                        SELECT 1 FROM public.properties p
                        WHERE p.id::text = split_part(name, '/', 2)
                        AND p.owner_id != pr.id
                    )
                )
            )
            OR public.is_app_admin_or_founder()
        )
    );

-- Note on SELECT:
-- The existing policy "Public read for property media" (bucket_id = 'property-media')
-- is preserved to ensure high-performance public marketplace image delivery.

COMMIT;
