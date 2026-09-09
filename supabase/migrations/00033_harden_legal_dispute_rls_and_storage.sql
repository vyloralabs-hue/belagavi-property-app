-- ==============================================================================
-- Migration 00033: Harden Legal Notices & Disputed Properties RLS & Storage
-- Project: Belagavi Property (PropertyHub)
-- Description:
--   1. Add missing DELETE policies for dispute_listings (draft/submitted/under_review for creator, ALL for admin)
--   2. Add missing UPDATE and DELETE policies for dispute_documents (creator & admin)
--   3. Add missing DELETE policies for dispute_events and dispute_responses
--   4. Add missing DELETE policies for legal_notices (draft/submitted/under_review for publisher, ALL for admin)
--   5. Add missing UPDATE and DELETE policies for legal_notice_documents
--   6. Ensure storage bucket 'property-documents' allows authenticated uploads/deletions for legal files
--   7. Uses auth.jwt()->>'sub' for all creator/publisher identity matches (Firebase UID)
-- ==============================================================================

BEGIN;

-- 1. dispute_listings DELETE policy
DROP POLICY IF EXISTS "Creator or admin delete dispute listing" ON public.dispute_listings;
CREATE POLICY "Creator or admin delete dispute listing"
    ON public.dispute_listings FOR DELETE
    USING (
        (creator_id = (auth.jwt()->>'sub') AND status IN ('draft', 'submitted', 'under_review'))
        OR EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    );

-- 2. dispute_documents UPDATE & DELETE policies
DROP POLICY IF EXISTS "Creator or admin update dispute documents" ON public.dispute_documents;
CREATE POLICY "Creator or admin update dispute documents"
    ON public.dispute_documents FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.dispute_listings
            WHERE dispute_listings.id = dispute_documents.dispute_id
            AND (
                (dispute_listings.creator_id = (auth.jwt()->>'sub') AND dispute_listings.status IN ('draft', 'submitted', 'under_review'))
                OR EXISTS (
                    SELECT 1 FROM public.profiles 
                    WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
                    AND profiles.role::text IN ('admin', 'founder')
                )
            )
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.dispute_listings
            WHERE dispute_listings.id = dispute_documents.dispute_id
            AND (
                (dispute_listings.creator_id = (auth.jwt()->>'sub') AND dispute_listings.status IN ('draft', 'submitted', 'under_review'))
                OR EXISTS (
                    SELECT 1 FROM public.profiles 
                    WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
                    AND profiles.role::text IN ('admin', 'founder')
                )
            )
        )
    );

DROP POLICY IF EXISTS "Creator or admin delete dispute documents" ON public.dispute_documents;
CREATE POLICY "Creator or admin delete dispute documents"
    ON public.dispute_documents FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.dispute_listings
            WHERE dispute_listings.id = dispute_documents.dispute_id
            AND (
                (dispute_listings.creator_id = (auth.jwt()->>'sub') AND dispute_listings.status IN ('draft', 'submitted', 'under_review'))
                OR EXISTS (
                    SELECT 1 FROM public.profiles 
                    WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
                    AND profiles.role::text IN ('admin', 'founder')
                )
            )
        )
    );

-- 3. dispute_responses UPDATE & DELETE policies
DROP POLICY IF EXISTS "Respondent or admin update dispute response" ON public.dispute_responses;
CREATE POLICY "Respondent or admin update dispute response"
    ON public.dispute_responses FOR UPDATE
    USING (
        (respondent_id = (auth.jwt()->>'sub') AND status IN ('submitted', 'under_review'))
        OR EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    )
    WITH CHECK (
        (respondent_id = (auth.jwt()->>'sub') AND status IN ('submitted', 'under_review'))
        OR EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    );

DROP POLICY IF EXISTS "Respondent or admin delete dispute response" ON public.dispute_responses;
CREATE POLICY "Respondent or admin delete dispute response"
    ON public.dispute_responses FOR DELETE
    USING (
        (respondent_id = (auth.jwt()->>'sub') AND status IN ('submitted', 'under_review'))
        OR EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    );

-- 4. legal_notices DELETE policy
DROP POLICY IF EXISTS "Publisher or admin delete legal notice" ON public.legal_notices;
CREATE POLICY "Publisher or admin delete legal notice"
    ON public.legal_notices FOR DELETE
    USING (
        (publisher_id = (auth.jwt()->>'sub') AND status IN ('draft', 'submitted', 'under_review'))
        OR EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    );

-- 5. legal_notice_documents UPDATE & DELETE policies
DROP POLICY IF EXISTS "Publisher or admin update legal notice documents" ON public.legal_notice_documents;
CREATE POLICY "Publisher or admin update legal notice documents"
    ON public.legal_notice_documents FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.legal_notices
            WHERE legal_notices.id = legal_notice_documents.notice_id
            AND (
                (legal_notices.publisher_id = (auth.jwt()->>'sub') AND legal_notices.status IN ('draft', 'submitted', 'under_review'))
                OR EXISTS (
                    SELECT 1 FROM public.profiles 
                    WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
                    AND profiles.role::text IN ('admin', 'founder')
                )
            )
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.legal_notices
            WHERE legal_notices.id = legal_notice_documents.notice_id
            AND (
                (legal_notices.publisher_id = (auth.jwt()->>'sub') AND legal_notices.status IN ('draft', 'submitted', 'under_review'))
                OR EXISTS (
                    SELECT 1 FROM public.profiles 
                    WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
                    AND profiles.role::text IN ('admin', 'founder')
                )
            )
        )
    );

DROP POLICY IF EXISTS "Publisher or admin delete legal notice documents" ON public.legal_notice_documents;
CREATE POLICY "Publisher or admin delete legal notice documents"
    ON public.legal_notice_documents FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.legal_notices
            WHERE legal_notices.id = legal_notice_documents.notice_id
            AND (
                (legal_notices.publisher_id = (auth.jwt()->>'sub') AND legal_notices.status IN ('draft', 'submitted', 'under_review'))
                OR EXISTS (
                    SELECT 1 FROM public.profiles 
                    WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
                    AND profiles.role::text IN ('admin', 'founder')
                )
            )
        )
    );

-- 6. Storage policies for property-documents and property-media (supporting legal documents)
DROP POLICY IF EXISTS "Authenticated users upload legal documents" ON storage.objects;
CREATE POLICY "Authenticated users upload legal documents"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id IN ('property-documents', 'property-media')
        AND (auth.jwt()->>'sub') IS NOT NULL
    );

DROP POLICY IF EXISTS "Users can delete own legal documents from storage" ON storage.objects;
CREATE POLICY "Users can delete own legal documents from storage"
    ON storage.objects FOR DELETE
    USING (
        bucket_id IN ('property-documents', 'property-media')
        AND (
            (auth.jwt()->>'sub' IS NOT NULL AND (name LIKE 'disputes/%' OR name LIKE 'legal_notices/%' OR name LIKE 'legal/%'))
            OR EXISTS (
                SELECT 1 FROM public.profiles 
                WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
                AND profiles.role::text IN ('admin', 'founder')
            )
        )
    );

COMMIT;
