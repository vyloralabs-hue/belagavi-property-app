-- ================================================================
-- BELAGAVI PROPERTY LLP
-- MIGRATION 00026: PROPERTY LEGAL NOTICE & DISPUTE ASSISTANCE MODULE
-- ADDITIVE MIGRATION — PRESERVES ALL EXISTING TABLES & SCHEMAS
-- ================================================================

-- Create legal_matter_status Enum if not exists
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'legal_matter_status') THEN
        CREATE TYPE public.legal_matter_status AS ENUM (
            'draft',
            'information_required',
            'draft_ready',
            'review_requested',
            'under_review',
            'changes_requested',
            'reviewed',
            'final_ready',
            'finalized',
            'service_pending',
            'served',
            'response_received',
            'follow_up_due',
            'closed',
            'archived'
        );
    END IF;
END $$;

-- 1. Legal Matters Table
CREATE TABLE IF NOT EXISTS public.legal_matters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    property_id UUID REFERENCES public.properties(id) ON DELETE SET NULL,
    matter_reference TEXT UNIQUE NOT NULL,
    title TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'General Contract Breach',
    notice_type TEXT NOT NULL DEFAULT 'otherPropertyLegalNotice',
    status public.legal_matter_status NOT NULL DEFAULT 'draft',
    is_high_risk BOOLEAN NOT NULL DEFAULT false,
    requires_advocate_review BOOLEAN NOT NULL DEFAULT false,
    assigned_advocate_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- Location & Property Snapshot
    country TEXT NOT NULL DEFAULT 'India',
    state TEXT NOT NULL DEFAULT 'Karnataka',
    district TEXT DEFAULT 'Belagavi',
    city TEXT NOT NULL DEFAULT 'Belagavi',
    locality TEXT NOT NULL DEFAULT 'Belagavi',
    full_address TEXT,
    survey_cts_number TEXT,
    khata_number TEXT,
    plot_flat_number TEXT,
    
    -- Financial Arrears / Amounts
    financial_claim_amount NUMERIC(15, 2) DEFAULT 0.00,
    agreed_total_consideration NUMERIC(15, 2) DEFAULT 0.00,
    amount_paid_so_far NUMERIC(15, 2) DEFAULT 0.00,
    interest_rate_claimed NUMERIC(5, 2) DEFAULT 0.00,
    
    -- Key Dates & Milestones
    agreement_date DATE,
    breach_default_date DATE,
    notice_sent_date DATE,
    response_due_date DATE,
    
    -- Desired Relief Summary
    desired_remedy TEXT,
    
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Legal Parties Table
CREATE TABLE IF NOT EXISTS public.legal_parties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matter_id UUID NOT NULL REFERENCES public.legal_matters(id) ON DELETE CASCADE,
    party_type TEXT NOT NULL DEFAULT 'Individual', -- Individual, Company, LLP, Partnership, Promoter/Builder, Landlord, Tenant, Buyer, Seller
    role TEXT NOT NULL DEFAULT 'Recipient', -- Claimant/Sender, Recipient/Opposite Party, Co-Sender, Advocate
    name TEXT NOT NULL,
    address TEXT,
    phone TEXT,
    email TEXT,
    advocate_name TEXT,
    advocate_bar_enrollment TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Legal Notice Drafts Table
CREATE TABLE IF NOT EXISTS public.legal_notice_drafts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matter_id UUID NOT NULL REFERENCES public.legal_matters(id) ON DELETE CASCADE,
    current_version INT NOT NULL DEFAULT 1,
    subject_heading TEXT NOT NULL,
    chronology_text TEXT NOT NULL,
    legal_grounds_text TEXT NOT NULL,
    demand_clauses_text TEXT NOT NULL,
    full_draft_markdown TEXT NOT NULL,
    is_finalized BOOLEAN NOT NULL DEFAULT false,
    finalized_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Legal Notice Versions Table (Immutable Version History)
CREATE TABLE IF NOT EXISTS public.legal_notice_versions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matter_id UUID NOT NULL REFERENCES public.legal_matters(id) ON DELETE CASCADE,
    version_number INT NOT NULL,
    content_markdown TEXT NOT NULL,
    generated_by TEXT NOT NULL DEFAULT 'USER_STATED', -- USER_STATED, SYSTEM_DERIVED, ADVOCATE_REVIEWED
    reason_for_change TEXT,
    created_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Legal Documents & Evidence Table (BSA 2023 Compliant)
CREATE TABLE IF NOT EXISTS public.legal_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matter_id UUID NOT NULL REFERENCES public.legal_matters(id) ON DELETE CASCADE,
    file_name TEXT NOT NULL,
    storage_path TEXT NOT NULL,
    document_type TEXT NOT NULL DEFAULT 'Agreement', -- Sale Deed, Lease Agreement, Payment Receipt, Photo, Postal Receipt, Tracking Screenshot, etc.
    file_size_bytes BIGINT NOT NULL DEFAULT 0,
    file_sha256_hash TEXT NOT NULL, -- Bharatiya Sakshya Adhiniyam Sec 63 digital hash
    uploaded_by UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 6. Legal Reviews Table
CREATE TABLE IF NOT EXISTS public.legal_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matter_id UUID NOT NULL REFERENCES public.legal_matters(id) ON DELETE CASCADE,
    reviewer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reviewer_name TEXT NOT NULL,
    reviewer_enrollment TEXT,
    review_status TEXT NOT NULL DEFAULT 'under_review', -- under_review, changes_requested, approved, declined
    comments TEXT,
    suggested_changes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. Legal Service Attempts Table (RPAD / Speed Post / Personal)
CREATE TABLE IF NOT EXISTS public.legal_service_attempts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matter_id UUID NOT NULL REFERENCES public.legal_matters(id) ON DELETE CASCADE,
    service_method TEXT NOT NULL DEFAULT 'Registered Post AD', -- Registered Post AD, Speed Post, Personal Delivery, Email, WhatsApp (Supplementary)
    courier_postal_provider TEXT NOT NULL DEFAULT 'India Post',
    tracking_number TEXT,
    dispatch_date DATE NOT NULL DEFAULT CURRENT_DATE,
    delivery_date DATE,
    service_status TEXT NOT NULL DEFAULT 'Dispatched', -- Dispatched, Delivered, Returned Unclaimed, Refused, Pending
    proof_document_id UUID REFERENCES public.legal_documents(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 8. Legal Responses Table
CREATE TABLE IF NOT EXISTS public.legal_responses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matter_id UUID NOT NULL REFERENCES public.legal_matters(id) ON DELETE CASCADE,
    response_type TEXT NOT NULL DEFAULT 'Reply Notice', -- Reply Notice, Settlement Offer, Rejection, Counter Demand
    sender_name TEXT NOT NULL,
    response_date DATE NOT NULL DEFAULT CURRENT_DATE,
    summary_text TEXT NOT NULL,
    document_id UUID REFERENCES public.legal_documents(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 9. Legal Audit Events Table
CREATE TABLE IF NOT EXISTS public.legal_audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    matter_id UUID NOT NULL REFERENCES public.legal_matters(id) ON DELETE CASCADE,
    actor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL, -- MATTER_CREATED, DRAFT_GENERATED, VERSION_SAVED, REVIEW_REQUESTED, ADVOCATE_APPROVED, FINALIZED, SERVED, RESPONSE_RECORDED
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- INDEXES FOR PERFORMANCE
CREATE INDEX IF NOT EXISTS idx_legal_matters_user_id ON public.legal_matters(user_id);
CREATE INDEX IF NOT EXISTS idx_legal_matters_property_id ON public.legal_matters(property_id);
CREATE INDEX IF NOT EXISTS idx_legal_matters_status ON public.legal_matters(status);
CREATE INDEX IF NOT EXISTS idx_legal_parties_matter_id ON public.legal_parties(matter_id);
CREATE INDEX IF NOT EXISTS idx_legal_documents_matter_id ON public.legal_documents(matter_id);
CREATE INDEX IF NOT EXISTS idx_legal_notice_versions_matter_id ON public.legal_notice_versions(matter_id);
CREATE INDEX IF NOT EXISTS idx_legal_service_attempts_matter_id ON public.legal_service_attempts(matter_id);

-- ENABLE ROW LEVEL SECURITY (RLS) ON ALL LEGAL TABLES
ALTER TABLE public.legal_matters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_parties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_notice_drafts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_notice_versions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_service_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.legal_audit_events ENABLE ROW LEVEL SECURITY;

-- RLS POLICIES FOR OWNER & ASSIGNED ADVOCATE
DO $$ 
BEGIN
    -- legal_matters Owner Policy
    DROP POLICY IF EXISTS legal_matters_owner_policy ON public.legal_matters;
    CREATE POLICY legal_matters_owner_policy ON public.legal_matters
        FOR ALL TO authenticated
        USING (user_id = auth.uid() OR assigned_advocate_id = auth.uid());

    -- legal_parties Policy
    DROP POLICY IF EXISTS legal_parties_owner_policy ON public.legal_parties;
    CREATE POLICY legal_parties_owner_policy ON public.legal_parties
        FOR ALL TO authenticated
        USING (EXISTS (
            SELECT 1 FROM public.legal_matters m 
            WHERE m.id = legal_parties.matter_id 
            AND (m.user_id = auth.uid() OR m.assigned_advocate_id = auth.uid())
        ));

    -- legal_notice_drafts Policy
    DROP POLICY IF EXISTS legal_notice_drafts_owner_policy ON public.legal_notice_drafts;
    CREATE POLICY legal_notice_drafts_owner_policy ON public.legal_notice_drafts
        FOR ALL TO authenticated
        USING (EXISTS (
            SELECT 1 FROM public.legal_matters m 
            WHERE m.id = legal_notice_drafts.matter_id 
            AND (m.user_id = auth.uid() OR m.assigned_advocate_id = auth.uid())
        ));

    -- legal_notice_versions Policy
    DROP POLICY IF EXISTS legal_notice_versions_owner_policy ON public.legal_notice_versions;
    CREATE POLICY legal_notice_versions_owner_policy ON public.legal_notice_versions
        FOR ALL TO authenticated
        USING (EXISTS (
            SELECT 1 FROM public.legal_matters m 
            WHERE m.id = legal_notice_versions.matter_id 
            AND (m.user_id = auth.uid() OR m.assigned_advocate_id = auth.uid())
        ));

    -- legal_documents Policy
    DROP POLICY IF EXISTS legal_documents_owner_policy ON public.legal_documents;
    CREATE POLICY legal_documents_owner_policy ON public.legal_documents
        FOR ALL TO authenticated
        USING (EXISTS (
            SELECT 1 FROM public.legal_matters m 
            WHERE m.id = legal_documents.matter_id 
            AND (m.user_id = auth.uid() OR m.assigned_advocate_id = auth.uid())
        ));

    -- legal_reviews Policy
    DROP POLICY IF EXISTS legal_reviews_owner_policy ON public.legal_reviews;
    CREATE POLICY legal_reviews_owner_policy ON public.legal_reviews
        FOR ALL TO authenticated
        USING (EXISTS (
            SELECT 1 FROM public.legal_matters m 
            WHERE m.id = legal_reviews.matter_id 
            AND (m.user_id = auth.uid() OR m.assigned_advocate_id = auth.uid() OR reviewer_id = auth.uid())
        ));

    -- legal_service_attempts Policy
    DROP POLICY IF EXISTS legal_service_attempts_owner_policy ON public.legal_service_attempts;
    CREATE POLICY legal_service_attempts_owner_policy ON public.legal_service_attempts
        FOR ALL TO authenticated
        USING (EXISTS (
            SELECT 1 FROM public.legal_matters m 
            WHERE m.id = legal_service_attempts.matter_id 
            AND (m.user_id = auth.uid() OR m.assigned_advocate_id = auth.uid())
        ));

    -- legal_responses Policy
    DROP POLICY IF EXISTS legal_responses_owner_policy ON public.legal_responses;
    CREATE POLICY legal_responses_owner_policy ON public.legal_responses
        FOR ALL TO authenticated
        USING (EXISTS (
            SELECT 1 FROM public.legal_matters m 
            WHERE m.id = legal_responses.matter_id 
            AND (m.user_id = auth.uid() OR m.assigned_advocate_id = auth.uid())
        ));

    -- legal_audit_events Policy
    DROP POLICY IF EXISTS legal_audit_events_owner_policy ON public.legal_audit_events;
    CREATE POLICY legal_audit_events_owner_policy ON public.legal_audit_events
        FOR ALL TO authenticated
        USING (EXISTS (
            SELECT 1 FROM public.legal_matters m 
            WHERE m.id = legal_audit_events.matter_id 
            AND (m.user_id = auth.uid() OR m.assigned_advocate_id = auth.uid())
        ));
END $$;

-- PRIVATE STORAGE BUCKET FOR LEGAL DOCUMENTS
INSERT INTO storage.buckets (id, name, public)
VALUES ('legal_notice_documents', 'legal_notice_documents', false)
ON CONFLICT (id) DO NOTHING;

-- STORAGE POLICIES
DO $$ 
BEGIN
    DROP POLICY IF EXISTS legal_documents_storage_policy ON storage.objects;
    CREATE POLICY legal_documents_storage_policy ON storage.objects
        FOR ALL TO authenticated
        USING (bucket_id = 'legal_notice_documents' AND (storage.foldername(name))[1] = auth.uid()::text);
END $$;
