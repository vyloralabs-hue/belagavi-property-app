-- ==============================================================================
-- Migration 00020: High-Scale Disputed Properties & Property Legal Notices Schema
-- Project: Belagavi Property (PropertyHub)
-- Authenticated Identity: Firebase JWT Subject (auth.jwt()->>'sub') -> profiles.firebase_uid
-- Role Authorization: profiles.role::text IN ('admin', 'founder')
-- ==============================================================================

-- 1. Disputed Property Listings Table
CREATE TABLE IF NOT EXISTS public.dispute_listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID REFERENCES public.properties(id) ON DELETE SET NULL,
    creator_id TEXT NOT NULL, -- Firebase UID (auth.jwt()->>'sub')
    title TEXT NOT NULL,
    property_type TEXT NOT NULL DEFAULT 'Residential',
    
    -- Indian Geography Hierarchy
    state TEXT NOT NULL DEFAULT 'Karnataka',
    district TEXT NOT NULL DEFAULT 'Belagavi',
    taluk TEXT NOT NULL DEFAULT 'Belagavi',
    city TEXT NOT NULL DEFAULT 'Belagavi',
    locality TEXT NOT NULL,
    village TEXT,
    
    -- Property Identifiers
    survey_number TEXT,
    property_number TEXT,
    plot_flat_shop_number TEXT,
    registration_reference TEXT,
    property_area NUMERIC(15, 2),
    area_unit TEXT NOT NULL DEFAULT 'sqft',
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    ownership_type TEXT,
    possession_status TEXT,
    
    -- Dispute Categorization & Information
    dispute_category TEXT NOT NULL, -- Ownership / Title, Boundary, Partition / Family, etc.
    factual_summary TEXT NOT NULL,
    claimed_dispute_nature TEXT,
    claiming_party_role TEXT NOT NULL DEFAULT 'owner',
    responding_party_role TEXT,
    dispute_start_date DATE,
    current_stage TEXT DEFAULT 'Pending Review',
    
    -- Court / Authority Case Reference
    case_number TEXT,
    court_authority_name TEXT,
    case_filing_date DATE,
    next_hearing_date DATE,
    case_orders_notes TEXT,
    
    -- Lifecycle Status
    status TEXT NOT NULL DEFAULT 'submitted', -- draft, submitted, under_review, published, rejected, paused, updated, resolved, withdrawn, archived
    is_redacted BOOLEAN NOT NULL DEFAULT FALSE,
    has_documents BOOLEAN NOT NULL DEFAULT FALSE,
    views_count INT NOT NULL DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Dispute Documents Table (with privacy/redaction metadata)
CREATE TABLE IF NOT EXISTS public.dispute_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dispute_id UUID NOT NULL REFERENCES public.dispute_listings(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL, -- Sale Deed, RTC / 7-12, Property Card, Mutation, Court Order, etc.
    document_date DATE,
    issuing_authority TEXT,
    reference_number TEXT,
    description TEXT,
    storage_path TEXT NOT NULL,
    public_redacted_url TEXT,
    visibility TEXT NOT NULL DEFAULT 'public_redacted', -- public_redacted, private, moderator_only
    is_redacted BOOLEAN NOT NULL DEFAULT TRUE,
    badge_label TEXT NOT NULL DEFAULT 'DOCUMENT UPLOADED',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Dispute Events & History Table
CREATE TABLE IF NOT EXISTS public.dispute_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dispute_id UUID NOT NULL REFERENCES public.dispute_listings(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL, -- created, status_changed, document_added, response_submitted, resolved
    actor_id TEXT NOT NULL, -- Firebase UID (auth.jwt()->>'sub')
    actor_role TEXT NOT NULL DEFAULT 'user',
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Dispute Responses & Counterparty Submissions
CREATE TABLE IF NOT EXISTS public.dispute_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dispute_id UUID NOT NULL REFERENCES public.dispute_listings(id) ON DELETE CASCADE,
    respondent_id TEXT NOT NULL, -- Firebase UID (auth.jwt()->>'sub')
    respondent_name TEXT NOT NULL,
    respondent_role TEXT NOT NULL,
    response_type TEXT NOT NULL DEFAULT 'response', -- response, correction_request, claim_record
    statement TEXT NOT NULL,
    supporting_document_urls JSONB DEFAULT '[]'::jsonb,
    status TEXT NOT NULL DEFAULT 'under_review', -- submitted, under_review, published, rejected
    moderator_notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Property Legal Notices Table
CREATE TABLE IF NOT EXISTS public.legal_notices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID REFERENCES public.properties(id) ON DELETE SET NULL,
    publisher_id TEXT NOT NULL, -- Firebase UID (auth.jwt()->>'sub')
    publisher_type TEXT NOT NULL DEFAULT 'Individual', -- Individual, Advocate, Law Firm, Company, LLP, Builder, Developer, etc.
    publisher_name TEXT NOT NULL,
    publisher_contact_phone TEXT,
    publisher_contact_email TEXT,
    publisher_address TEXT,
    advocate_firm_details TEXT,
    
    notice_title TEXT NOT NULL,
    notice_type TEXT NOT NULL, -- proposed_purchase, proposed_sale, title_verification, objection_invitation, etc.
    notice_date DATE NOT NULL DEFAULT CURRENT_DATE,
    effective_date DATE,
    objection_deadline DATE,
    reference_number TEXT,
    
    -- Property Identity
    state TEXT NOT NULL DEFAULT 'Karnataka',
    district TEXT NOT NULL DEFAULT 'Belagavi',
    taluk TEXT NOT NULL DEFAULT 'Belagavi',
    city TEXT NOT NULL DEFAULT 'Belagavi',
    locality TEXT NOT NULL,
    village TEXT,
    survey_property_number TEXT,
    plot_flat_shop_number TEXT,
    property_area NUMERIC(15, 2),
    area_unit TEXT DEFAULT 'sqft',
    registration_details TEXT,
    
    -- Notice Content
    short_summary TEXT NOT NULL,
    full_notice_text TEXT,
    response_contact_channel TEXT,
    
    -- Lifecycle & Badges
    status TEXT NOT NULL DEFAULT 'submitted', -- draft, submitted, under_review, published, updated, superseded, withdrawn, expired, archived
    is_identity_verified BOOLEAN NOT NULL DEFAULT FALSE,
    has_documents BOOLEAN NOT NULL DEFAULT FALSE,
    badge_labels JSONB DEFAULT '["DOCUMENT UPLOADED"]'::jsonb,
    views_count INT NOT NULL DEFAULT 0,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Legal Notice Documents Table
CREATE TABLE IF NOT EXISTS public.legal_notice_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notice_id UUID NOT NULL REFERENCES public.legal_notices(id) ON DELETE CASCADE,
    document_type TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    public_url TEXT,
    is_redacted BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. Legal Notice Events & History Table
CREATE TABLE IF NOT EXISTS public.legal_notice_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notice_id UUID NOT NULL REFERENCES public.legal_notices(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL, -- created, status_changed, document_added, notice_expired, superseded
    actor_id TEXT, -- Firebase UID (auth.jwt()->>'sub')
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. Moderation Reports & Action Audits Table
CREATE TABLE IF NOT EXISTS public.record_moderation_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    record_type TEXT NOT NULL, -- dispute, legal_notice
    record_id UUID NOT NULL,
    reporter_id TEXT NOT NULL, -- Firebase UID (auth.jwt()->>'sub')
    report_reason TEXT NOT NULL, -- defamation_flag, inaccurate_data, privacy_violation, spam, resolved_dispute, other
    details TEXT,
    status TEXT NOT NULL DEFAULT 'pending', -- pending, reviewing, action_taken, dismissed
    action_taken TEXT,
    moderator_id TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- ==============================================================================
-- INDEXES FOR HIGH SCALE (MILLIONS OF RECORDS)
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_dispute_listings_status ON public.dispute_listings(status);
CREATE INDEX IF NOT EXISTS idx_dispute_listings_location ON public.dispute_listings(state, district, taluk, city, locality);
CREATE INDEX IF NOT EXISTS idx_dispute_listings_survey_no ON public.dispute_listings(survey_number);
CREATE INDEX IF NOT EXISTS idx_dispute_listings_category ON public.dispute_listings(dispute_category);
CREATE INDEX IF NOT EXISTS idx_dispute_listings_case_no ON public.dispute_listings(case_number);
CREATE INDEX IF NOT EXISTS idx_dispute_listings_creator ON public.dispute_listings(creator_id);
CREATE INDEX IF NOT EXISTS idx_dispute_listings_created_at ON public.dispute_listings(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_legal_notices_status ON public.legal_notices(status);
CREATE INDEX IF NOT EXISTS idx_legal_notices_location ON public.legal_notices(state, district, taluk, city, locality);
CREATE INDEX IF NOT EXISTS idx_legal_notices_survey_no ON public.legal_notices(survey_property_number);
CREATE INDEX IF NOT EXISTS idx_legal_notices_type ON public.legal_notices(notice_type);
CREATE INDEX IF NOT EXISTS idx_legal_notices_publisher ON public.legal_notices(publisher_id);
CREATE INDEX IF NOT EXISTS idx_legal_notices_created_at ON public.legal_notices(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_legal_notice_events_notice_id ON public.legal_notice_events(notice_id);
CREATE INDEX IF NOT EXISTS idx_record_moderation_reports_record ON public.record_moderation_reports(record_type, record_id);
CREATE INDEX IF NOT EXISTS idx_record_moderation_reports_status ON public.record_moderation_reports(status);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
ALTER TABLE public.dispute_listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dispute_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dispute_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dispute_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_notices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_notice_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_notice_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.record_moderation_reports ENABLE ROW LEVEL SECURITY;

-- 1. Dispute Listings Policies
DROP POLICY IF EXISTS "Public read published dispute listings" ON public.dispute_listings;
CREATE POLICY "Public read published dispute listings"
    ON public.dispute_listings FOR SELECT
    USING (
        status = 'published'
        OR (creator_id IS NOT NULL AND creator_id = (auth.jwt()->>'sub'))
        OR EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    );

DROP POLICY IF EXISTS "Authenticated user create dispute listing" ON public.dispute_listings;
CREATE POLICY "Authenticated user create dispute listing"
    ON public.dispute_listings FOR INSERT
    WITH CHECK (
        auth.jwt()->>'sub' IS NOT NULL 
        AND creator_id = (auth.jwt()->>'sub')
    );

DROP POLICY IF EXISTS "Creator update own draft or pending dispute listing" ON public.dispute_listings;
CREATE POLICY "Creator update own draft or pending dispute listing"
    ON public.dispute_listings FOR UPDATE
    USING (
        (creator_id = (auth.jwt()->>'sub') AND status IN ('draft', 'submitted', 'under_review'))
        OR EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    )
    WITH CHECK (
        (creator_id = (auth.jwt()->>'sub') AND status IN ('draft', 'submitted', 'under_review'))
        OR EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    );

-- 2. Dispute Documents Policies
DROP POLICY IF EXISTS "Read dispute documents" ON public.dispute_documents;
CREATE POLICY "Read dispute documents"
    ON public.dispute_documents FOR SELECT
    USING (
        visibility = 'public_redacted'
        OR EXISTS (
            SELECT 1 FROM public.dispute_listings 
            WHERE dispute_listings.id = dispute_documents.dispute_id 
            AND dispute_listings.creator_id = (auth.jwt()->>'sub')
        )
        OR EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    );

DROP POLICY IF EXISTS "Insert dispute documents" ON public.dispute_documents;
CREATE POLICY "Insert dispute documents"
    ON public.dispute_documents FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.dispute_listings 
            WHERE dispute_listings.id = dispute_documents.dispute_id 
            AND (
                dispute_listings.creator_id = (auth.jwt()->>'sub')
                OR EXISTS (
                    SELECT 1 FROM public.profiles 
                    WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
                    AND profiles.role::text IN ('admin', 'founder')
                )
            )
        )
    );

-- 3. Dispute Events Policies
DROP POLICY IF EXISTS "Read dispute events" ON public.dispute_events;
CREATE POLICY "Read dispute events"
    ON public.dispute_events FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.dispute_listings 
            WHERE dispute_listings.id = dispute_events.dispute_id 
            AND (
                dispute_listings.status = 'published'
                OR dispute_listings.creator_id = (auth.jwt()->>'sub')
                OR EXISTS (
                    SELECT 1 FROM public.profiles 
                    WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
                    AND profiles.role::text IN ('admin', 'founder')
                )
            )
        )
    );

DROP POLICY IF EXISTS "Insert dispute events" ON public.dispute_events;
CREATE POLICY "Insert dispute events"
    ON public.dispute_events FOR INSERT
    WITH CHECK (
        auth.jwt()->>'sub' IS NOT NULL
        AND actor_id = (auth.jwt()->>'sub')
    );

-- 4. Dispute Responses Policies
DROP POLICY IF EXISTS "Read dispute responses" ON public.dispute_responses;
CREATE POLICY "Read dispute responses"
    ON public.dispute_responses FOR SELECT
    USING (
        status = 'published'
        OR (respondent_id IS NOT NULL AND respondent_id = (auth.jwt()->>'sub'))
        OR EXISTS (
            SELECT 1 FROM public.dispute_listings 
            WHERE dispute_listings.id = dispute_responses.dispute_id 
            AND dispute_listings.creator_id = (auth.jwt()->>'sub')
        )
        OR EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    );

DROP POLICY IF EXISTS "Insert dispute response" ON public.dispute_responses;
CREATE POLICY "Insert dispute response"
    ON public.dispute_responses FOR INSERT
    WITH CHECK (
        auth.jwt()->>'sub' IS NOT NULL
        AND respondent_id = (auth.jwt()->>'sub')
    );

-- 5. Legal Notices Policies
DROP POLICY IF EXISTS "Public read published legal notices" ON public.legal_notices;
CREATE POLICY "Public read published legal notices"
    ON public.legal_notices FOR SELECT
    USING (
        status = 'published'
        OR (publisher_id IS NOT NULL AND publisher_id = (auth.jwt()->>'sub'))
        OR EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    );

DROP POLICY IF EXISTS "Authenticated user create legal notice" ON public.legal_notices;
CREATE POLICY "Authenticated user create legal notice"
    ON public.legal_notices FOR INSERT
    WITH CHECK (
        auth.jwt()->>'sub' IS NOT NULL 
        AND publisher_id = (auth.jwt()->>'sub')
    );

DROP POLICY IF EXISTS "Publisher update own legal notice" ON public.legal_notices;
CREATE POLICY "Publisher update own legal notice"
    ON public.legal_notices FOR UPDATE
    USING (
        (publisher_id = (auth.jwt()->>'sub') AND status IN ('draft', 'submitted', 'under_review'))
        OR EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    )
    WITH CHECK (
        (publisher_id = (auth.jwt()->>'sub') AND status IN ('draft', 'submitted', 'under_review'))
        OR EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    );

-- 6. Legal Notice Documents Policies
DROP POLICY IF EXISTS "Read legal notice documents" ON public.legal_notice_documents;
CREATE POLICY "Read legal notice documents"
    ON public.legal_notice_documents FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.legal_notices 
            WHERE legal_notices.id = legal_notice_documents.notice_id 
            AND (
                legal_notices.status = 'published'
                OR legal_notices.publisher_id = (auth.jwt()->>'sub')
                OR EXISTS (
                    SELECT 1 FROM public.profiles 
                    WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
                    AND profiles.role::text IN ('admin', 'founder')
                )
            )
        )
    );

DROP POLICY IF EXISTS "Insert legal notice documents" ON public.legal_notice_documents;
CREATE POLICY "Insert legal notice documents"
    ON public.legal_notice_documents FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.legal_notices 
            WHERE legal_notices.id = legal_notice_documents.notice_id 
            AND (
                legal_notices.publisher_id = (auth.jwt()->>'sub')
                OR EXISTS (
                    SELECT 1 FROM public.profiles 
                    WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
                    AND profiles.role::text IN ('admin', 'founder')
                )
            )
        )
    );

-- 7. Legal Notice Events Policies
DROP POLICY IF EXISTS "Read legal notice events" ON public.legal_notice_events;
CREATE POLICY "Read legal notice events"
    ON public.legal_notice_events FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.legal_notices 
            WHERE legal_notices.id = legal_notice_events.notice_id 
            AND (
                legal_notices.status = 'published'
                OR legal_notices.publisher_id = (auth.jwt()->>'sub')
                OR EXISTS (
                    SELECT 1 FROM public.profiles 
                    WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
                    AND profiles.role::text IN ('admin', 'founder')
                )
            )
        )
    );

DROP POLICY IF EXISTS "Insert legal notice events" ON public.legal_notice_events;
CREATE POLICY "Insert legal notice events"
    ON public.legal_notice_events FOR INSERT
    WITH CHECK (
        auth.jwt()->>'sub' IS NOT NULL
        AND (actor_id IS NULL OR actor_id = (auth.jwt()->>'sub'))
    );

-- 8. Moderation Reports Policies (Hardened Reporter vs Admin Separation)
DROP POLICY IF EXISTS "Authenticated user submit report" ON public.record_moderation_reports;
DROP POLICY IF EXISTS "Anyone can report record" ON public.record_moderation_reports;
CREATE POLICY "Authenticated user submit report"
    ON public.record_moderation_reports FOR INSERT
    WITH CHECK (
        auth.jwt()->>'sub' IS NOT NULL
        AND reporter_id = (auth.jwt()->>'sub')
    );

DROP POLICY IF EXISTS "Reporter view own report" ON public.record_moderation_reports;
CREATE POLICY "Reporter view own report"
    ON public.record_moderation_reports FOR SELECT
    USING (
        (reporter_id IS NOT NULL AND reporter_id = (auth.jwt()->>'sub'))
        OR EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    );

DROP POLICY IF EXISTS "Admin manage moderation reports" ON public.record_moderation_reports;
CREATE POLICY "Admin manage moderation reports"
    ON public.record_moderation_reports FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles 
            WHERE profiles.firebase_uid = (auth.jwt()->>'sub') 
            AND profiles.role::text IN ('admin', 'founder')
        )
    );
