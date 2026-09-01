-- Migration: 00013_create_property_and_seller_reviews_trust_score.sql
-- Description: Create property_reviews, seller_reviews, and review_reports tables with strict RLS and anti-manipulation constraints

-- 1. Create Property Reviews Table
CREATE TABLE IF NOT EXISTS public.property_reviews (
    id TEXT PRIMARY KEY,
    property_id TEXT NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    reviewer_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    seller_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    rating NUMERIC(2,1) NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    title TEXT NOT NULL,
    review_text TEXT NOT NULL,
    verification_source TEXT NOT NULL, -- 'inquiry', 'site_visit', 'chat', 'deal_closed'
    verification_reference_id TEXT NOT NULL,
    is_verified_interaction BOOLEAN NOT NULL DEFAULT true,
    status TEXT NOT NULL DEFAULT 'PUBLISHED', -- 'PUBLISHED', 'PENDING', 'HIDDEN', 'REPORTED', 'REMOVED', 'DISPUTED'
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_property_reviewer_review UNIQUE(property_id, reviewer_id)
);

CREATE INDEX IF NOT EXISTS idx_prop_reviews_property_status ON public.property_reviews(property_id, status);
CREATE INDEX IF NOT EXISTS idx_prop_reviews_reviewer ON public.property_reviews(reviewer_id);
CREATE INDEX IF NOT EXISTS idx_prop_reviews_seller ON public.property_reviews(seller_id);

ALTER TABLE public.property_reviews ENABLE ROW LEVEL SECURITY;

-- Property Reviews RLS
CREATE POLICY "Public read published property reviews"
ON public.property_reviews
FOR SELECT
USING (
    status = 'PUBLISHED'
    OR reviewer_id = (SELECT auth.uid())::text
    OR seller_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
);

CREATE POLICY "Insert property review as eligible reviewer"
ON public.property_reviews
FOR INSERT
TO authenticated
WITH CHECK (
    reviewer_id = (SELECT auth.uid())::text
    AND reviewer_id != seller_id
    AND seller_id = (SELECT owner_id::text FROM public.properties WHERE id = property_id)
);

CREATE POLICY "Reviewer update own review content"
ON public.property_reviews
FOR UPDATE
TO authenticated
USING (
    reviewer_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
)
WITH CHECK (
    reviewer_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
);

CREATE POLICY "Admin delete fraudulent property review"
ON public.property_reviews
FOR DELETE
TO authenticated
USING (
    reviewer_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
);

-- 2. Create Seller Reviews Table
CREATE TABLE IF NOT EXISTS public.seller_reviews (
    id TEXT PRIMARY KEY,
    seller_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reviewer_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    property_id TEXT REFERENCES public.properties(id) ON DELETE SET NULL,
    rating NUMERIC(2,1) NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    review_text TEXT NOT NULL,
    verification_source TEXT NOT NULL,
    verification_reference_id TEXT NOT NULL,
    is_verified_interaction BOOLEAN NOT NULL DEFAULT true,
    status TEXT NOT NULL DEFAULT 'PUBLISHED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_seller_reviewer_review UNIQUE(seller_id, reviewer_id)
);

CREATE INDEX IF NOT EXISTS idx_seller_reviews_seller_status ON public.seller_reviews(seller_id, status);
CREATE INDEX IF NOT EXISTS idx_seller_reviews_reviewer ON public.seller_reviews(reviewer_id);

ALTER TABLE public.seller_reviews ENABLE ROW LEVEL SECURITY;

-- Seller Reviews RLS
CREATE POLICY "Public read published seller reviews"
ON public.seller_reviews
FOR SELECT
USING (
    status = 'PUBLISHED'
    OR reviewer_id = (SELECT auth.uid())::text
    OR seller_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
);

CREATE POLICY "Insert seller review as eligible reviewer"
ON public.seller_reviews
FOR INSERT
TO authenticated
WITH CHECK (
    reviewer_id = (SELECT auth.uid())::text
    AND reviewer_id != seller_id
);

CREATE POLICY "Reviewer update own seller review"
ON public.seller_reviews
FOR UPDATE
TO authenticated
USING (
    reviewer_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
)
WITH CHECK (
    reviewer_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
);

CREATE POLICY "Admin delete fraudulent seller review"
ON public.seller_reviews
FOR DELETE
TO authenticated
USING (
    reviewer_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
);

-- 3. Create Review Reports / Disputes Table
CREATE TABLE IF NOT EXISTS public.review_reports (
    id TEXT PRIMARY KEY,
    review_id TEXT NOT NULL,
    review_type TEXT NOT NULL, -- 'PROPERTY', 'SELLER'
    reporter_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reason TEXT NOT NULL, -- 'SPAM', 'FAKE_REVIEW', 'ABUSE', 'HARASSMENT', 'FALSE_INFORMATION', 'OTHER'
    details TEXT,
    status TEXT NOT NULL DEFAULT 'PENDING', -- 'PENDING', 'INVESTIGATING', 'RESOLVED', 'DISMISSED'
    moderator_notes TEXT,
    moderated_by TEXT REFERENCES public.profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_review_reports_status ON public.review_reports(status);
CREATE INDEX IF NOT EXISTS idx_review_reports_review_id ON public.review_reports(review_id);

ALTER TABLE public.review_reports ENABLE ROW LEVEL SECURITY;

-- Review Reports RLS
CREATE POLICY "Users create review report"
ON public.review_reports
FOR INSERT
TO authenticated
WITH CHECK (
    reporter_id = (SELECT auth.uid())::text
);

CREATE POLICY "Users read own reports or Admin read all"
ON public.review_reports
FOR SELECT
TO authenticated
USING (
    reporter_id = (SELECT auth.uid())::text
    OR public.is_app_admin_or_founder()
);

CREATE POLICY "Admin update review report moderation"
ON public.review_reports
FOR UPDATE
TO authenticated
USING (
    public.is_app_admin_or_founder()
)
WITH CHECK (
    public.is_app_admin_or_founder()
);
