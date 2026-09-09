-- ==============================================================================
-- Migration 00034: Harden Legal & Dispute Storage Paths & Object RLS
-- Project: Belagavi Property (PropertyHub)
-- Target Storage Architecture:
--   Bucket: 'property-documents' & 'property-media'
--   Dispute path: disputes/{firebase_uid}/{dispute_uuid}/{filename}
--   Notice path:  legal_notices/{firebase_uid}/{notice_uuid}/{filename}
-- ==============================================================================

BEGIN;

-- 1. Drop overly permissive 00033 policies on storage.objects
DROP POLICY IF EXISTS "Authenticated users upload legal documents" ON storage.objects;
DROP POLICY IF EXISTS "Users can delete own legal documents from storage" ON storage.objects;
DROP POLICY IF EXISTS "Restricted read for property documents" ON storage.objects;

-- 2. Hardened INSERT policy for Legal & Dispute documents
CREATE POLICY "Strict ownership upload for legal and dispute documents"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id IN ('property-documents', 'property-media')
        AND (auth.jwt()->>'sub') IS NOT NULL
        AND (
            -- Dispute storage path: disputes/{firebase_uid}/{dispute_uuid}/{filename}
            (
                split_part(name, '/', 1) = 'disputes'
                AND split_part(name, '/', 2) = (auth.jwt()->>'sub')
                AND NOT EXISTS (
                    SELECT 1 FROM public.dispute_listings d
                    WHERE d.id::text = split_part(name, '/', 3)
                    AND d.creator_id != (auth.jwt()->>'sub')
                )
            )
            -- Legal notice storage path: legal_notices/{firebase_uid}/{notice_uuid}/{filename}
            OR (
                split_part(name, '/', 1) = 'legal_notices'
                AND split_part(name, '/', 2) = (auth.jwt()->>'sub')
                AND NOT EXISTS (
                    SELECT 1 FROM public.legal_notices n
                    WHERE n.id::text = split_part(name, '/', 3)
                    AND n.publisher_id != (auth.jwt()->>'sub')
                )
            )
            -- Admin / Founder override
            OR EXISTS (
                SELECT 1 FROM public.profiles
                WHERE profiles.firebase_uid = (auth.jwt()->>'sub')
                AND profiles.role::text IN ('admin', 'founder')
            )
        )
    );

-- 3. Hardened UPDATE policy for Legal & Dispute documents
CREATE POLICY "Strict ownership update for legal and dispute documents"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id IN ('property-documents', 'property-media')
        AND (auth.jwt()->>'sub') IS NOT NULL
        AND (
            (split_part(name, '/', 1) = 'disputes' AND split_part(name, '/', 2) = (auth.jwt()->>'sub'))
            OR (split_part(name, '/', 1) = 'legal_notices' AND split_part(name, '/', 2) = (auth.jwt()->>'sub'))
            OR EXISTS (
                SELECT 1 FROM public.profiles
                WHERE profiles.firebase_uid = (auth.jwt()->>'sub')
                AND profiles.role::text IN ('admin', 'founder')
            )
        )
    )
    WITH CHECK (
        bucket_id IN ('property-documents', 'property-media')
        AND (auth.jwt()->>'sub') IS NOT NULL
        AND (
            (split_part(name, '/', 1) = 'disputes' AND split_part(name, '/', 2) = (auth.jwt()->>'sub'))
            OR (split_part(name, '/', 1) = 'legal_notices' AND split_part(name, '/', 2) = (auth.jwt()->>'sub'))
            OR EXISTS (
                SELECT 1 FROM public.profiles
                WHERE profiles.firebase_uid = (auth.jwt()->>'sub')
                AND profiles.role::text IN ('admin', 'founder')
            )
        )
    );

-- 4. Hardened DELETE policy for Legal & Dispute documents
CREATE POLICY "Strict ownership delete for legal and dispute documents"
    ON storage.objects FOR DELETE
    USING (
        bucket_id IN ('property-documents', 'property-media')
        AND (auth.jwt()->>'sub') IS NOT NULL
        AND (
            (split_part(name, '/', 1) = 'disputes' AND split_part(name, '/', 2) = (auth.jwt()->>'sub'))
            OR (split_part(name, '/', 1) = 'legal_notices' AND split_part(name, '/', 2) = (auth.jwt()->>'sub'))
            OR EXISTS (
                SELECT 1 FROM public.profiles
                WHERE profiles.firebase_uid = (auth.jwt()->>'sub')
                AND profiles.role::text IN ('admin', 'founder')
            )
        )
    );

-- 5. Hardened SELECT policy for 'property-documents' (Private Documents)
CREATE POLICY "Restricted read for property documents"
    ON storage.objects FOR SELECT
    USING (
        bucket_id = 'property-documents'
        AND (
            -- Owner of the dispute/notice document
            (
                (auth.jwt()->>'sub') IS NOT NULL
                AND (
                    (split_part(name, '/', 1) = 'disputes' AND split_part(name, '/', 2) = (auth.jwt()->>'sub'))
                    OR (split_part(name, '/', 1) = 'legal_notices' AND split_part(name, '/', 2) = (auth.jwt()->>'sub'))
                )
            )
            -- Admin / Founder / Moderator
            OR EXISTS (
                SELECT 1 FROM public.profiles
                WHERE profiles.firebase_uid = (auth.jwt()->>'sub')
                AND profiles.role::text IN ('admin', 'founder', 'moderator')
            )
            -- Redacted public copy intentionally placed in public_redacted/
            OR (name LIKE '%/public_redacted/%')
        )
    );

COMMIT;
