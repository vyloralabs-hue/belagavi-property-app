-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 3 SUPABASE STORAGE ROW LEVEL SECURITY (RLS)
-- Target Schema Version: 1.3.0
-- Created: 2026-08-07
-- =============================================================================

-- Ensure storage buckets exist
INSERT INTO storage.buckets (id, name, public)
VALUES ('property-media', 'property-media', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('property-documents', 'property-documents', false)
ON CONFLICT (id) DO NOTHING;

-- Enable RLS on storage objects
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- 1. PROPERTY MEDIA BUCKET RLS POLICIES
-- -----------------------------------------------------------------------------

-- Public SELECT Policy: Anyone can view public property media (photos/videos)
CREATE POLICY "Public property media select policy"
ON storage.objects FOR SELECT
USING (bucket_id = 'property-media');

-- INSERT Policy: Authenticated users can upload ONLY to their own folder path ({ownerId}/{propertyId}/...)
CREATE POLICY "Property media owner insert policy"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'property-media'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- UPDATE Policy: Owner only
CREATE POLICY "Property media owner update policy"
ON storage.objects FOR UPDATE
USING (
    bucket_id = 'property-media'
    AND (storage.foldername(name))[1] = auth.uid()::text
)
WITH CHECK (
    bucket_id = 'property-media'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- DELETE Policy: Owner only
CREATE POLICY "Property media owner delete policy"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'property-media'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- -----------------------------------------------------------------------------
-- 2. PROPERTY DOCUMENTS BUCKET RLS POLICIES (PRIVATE LEGAL PDFS)
-- -----------------------------------------------------------------------------

-- SELECT Policy: Owner OR Authenticated user with an active PropertyUnlock record
CREATE POLICY "Property documents restricted select policy"
ON storage.objects FOR SELECT
USING (
    bucket_id = 'property-documents'
    AND (
        (storage.foldername(name))[1] = auth.uid()::text
        OR EXISTS (
            SELECT 1 FROM public.property_unlocks pu
            WHERE pu.property_id = (storage.foldername(name))[2]
            AND pu.user_id = auth.uid()::text
            AND pu.status = 'active'
            AND (pu.expires_at IS NULL OR pu.expires_at > NOW())
        )
    )
);

-- INSERT Policy: Document owner only
CREATE POLICY "Property documents owner insert policy"
ON storage.objects FOR INSERT
WITH CHECK (
    bucket_id = 'property-documents'
    AND auth.role() = 'authenticated'
    AND (storage.foldername(name))[1] = auth.uid()::text
);

-- UPDATE/DELETE Policy: Document owner only
CREATE POLICY "Property documents owner delete policy"
ON storage.objects FOR DELETE
USING (
    bucket_id = 'property-documents'
    AND (storage.foldername(name))[1] = auth.uid()::text
);
