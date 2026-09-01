-- ==========================================
-- Migration 00005: Create Storage Buckets & Policies
-- Project: Belagavi Property (PropertyHub)
-- ==========================================

-- Insert Buckets if they do not exist
INSERT INTO storage.buckets (id, name, public) 
VALUES ('property-media', 'property-media', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public) 
VALUES ('user-avatars', 'user-avatars', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public) 
VALUES ('property-documents', 'property-documents', false)
ON CONFLICT (id) DO NOTHING;

-- Public Storage Access Policies
CREATE POLICY "Public read for property media"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'property-media');

CREATE POLICY "Public read for user avatars"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'user-avatars');

CREATE POLICY "Authenticated upload for property media"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'property-media' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated upload for user avatars"
    ON storage.objects FOR INSERT
    WITH CHECK (bucket_id = 'user-avatars' AND auth.role() = 'authenticated');

CREATE POLICY "Restricted read for property documents"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'property-documents' AND auth.role() = 'authenticated');
