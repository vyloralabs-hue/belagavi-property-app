-- ==============================================================================
-- Migration 00038: 10-Day Public Notice Lifecycle & Server-Time Expiry
-- Project: Belagavi Property (PropertyHub)
-- Business Rules:
-- 1. published_at, public_until, expired_at lifecycle columns on public.legal_notices
-- 2. Default duration: 10 days (NOW() + INTERVAL '10 days')
-- 3. High-performance composite indexes for public discovery & expiry queries
-- 4. Server-time authoritative RLS for public read on legal_notices & documents
-- 5. Permanent creator/owner access via (auth.jwt()->>'sub')
-- ==============================================================================

BEGIN;

-- 1. Add Lifecycle Timestamp Columns
ALTER TABLE public.legal_notices
    ADD COLUMN IF NOT EXISTS published_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS public_until TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS expired_at TIMESTAMPTZ;

-- 2. Backfill existing published records
UPDATE public.legal_notices
SET 
    published_at = COALESCE(published_at, created_at, NOW()),
    public_until = COALESCE(public_until, created_at + INTERVAL '10 days', NOW() + INTERVAL '10 days')
WHERE status = 'published' AND (published_at IS NULL OR public_until IS NULL);

-- 3. Composite Indexes for Public Discovery, Sorting, and Expiry Check
CREATE INDEX IF NOT EXISTS idx_legal_notices_public_lifecycle
    ON public.legal_notices (status, published_at, public_until)
    WHERE status = 'published';

CREATE INDEX IF NOT EXISTS idx_legal_notices_public_until
    ON public.legal_notices (public_until DESC);

CREATE INDEX IF NOT EXISTS idx_legal_notices_publisher_status
    ON public.legal_notices (publisher_id, status, created_at DESC);

-- 4. Update RLS Policy on public.legal_notices
DROP POLICY IF EXISTS "Public read published legal notices" ON public.legal_notices;
CREATE POLICY "Public read published legal notices"
    ON public.legal_notices FOR SELECT
    USING (
        (
            status = 'published'
            AND published_at IS NOT NULL
            AND published_at <= NOW()
            AND (public_until IS NULL OR public_until > NOW())
        )
        OR (publisher_id IS NOT NULL AND publisher_id = (auth.jwt()->>'sub'))
        OR EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub')
            AND profiles.role::text IN ('admin', 'founder')
        )
    );

-- 5. Update RLS Policy on public.legal_notice_documents
DROP POLICY IF EXISTS "Read legal notice documents" ON public.legal_notice_documents;
CREATE POLICY "Read legal notice documents"
    ON public.legal_notice_documents FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.legal_notices
            WHERE legal_notices.id = legal_notice_documents.notice_id
            AND (
                (
                    legal_notices.status = 'published'
                    AND legal_notices.published_at IS NOT NULL
                    AND legal_notices.published_at <= NOW()
                    AND (legal_notices.public_until IS NULL OR legal_notices.public_until > NOW())
                )
                OR legal_notices.publisher_id = (auth.jwt()->>'sub')
                OR EXISTS (
                    SELECT 1 FROM public.profiles
                    WHERE profiles.firebase_uid = (auth.jwt()->>'sub')
                    AND profiles.role::text IN ('admin', 'founder')
                )
            )
        )
    );

COMMIT;
