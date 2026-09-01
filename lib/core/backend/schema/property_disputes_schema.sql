-- ==============================================================================
-- BELAGAVI PROPERTY LLP â€” DISPUTED PROPERTIES SCHEMA & RLS POLICIES (PHASE 2)
-- ==============================================================================

-- 1. Table: property_disputes
CREATE TABLE IF NOT EXISTS public.property_disputes (
    id TEXT PRIMARY KEY,
    property_id TEXT NOT NULL,
    title TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'Residential',
    property_type TEXT NOT NULL DEFAULT 'Apartment',
    city TEXT NOT NULL DEFAULT 'Belagavi',
    locality TEXT NOT NULL,
    village_taluk TEXT,
    survey_cts_number TEXT,
    relationship TEXT NOT NULL DEFAULT 'I am reporting a dispute',
    dispute_type TEXT NOT NULL,
    verification_status TEXT NOT NULL DEFAULT 'underReview',
    court_authority TEXT,
    case_number TEXT,
    case_year TEXT,
    case_status TEXT DEFAULT 'Pending in Court',
    litigating_parties TEXT,
    description TEXT NOT NULL,
    contact_name TEXT,
    contact_phone TEXT,
    contact_email TEXT,
    photo_urls JSONB DEFAULT '[]'::jsonb,
    document_urls JSONB DEFAULT '[]'::jsonb,
    is_document_private BOOLEAN DEFAULT TRUE,
    reported_by TEXT NOT NULL,
    report_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    relevant_notes TEXT,
    last_updated TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Indexes for High-Speed Locality, Dispute Type, and Case Searches
CREATE INDEX IF NOT EXISTS idx_property_disputes_dispute_type ON public.property_disputes(dispute_type);
CREATE INDEX IF NOT EXISTS idx_property_disputes_locality ON public.property_disputes(locality);
CREATE INDEX IF NOT EXISTS idx_property_disputes_property_id ON public.property_disputes(property_id);
CREATE INDEX IF NOT EXISTS idx_property_disputes_verification_status ON public.property_disputes(verification_status);
CREATE INDEX IF NOT EXISTS idx_property_disputes_case_number ON public.property_disputes(case_number);

-- 3. Enable Row Level Security (RLS)
ALTER TABLE public.property_disputes ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies
CREATE POLICY "Public users can view published property disputes"
    ON public.property_disputes
    FOR SELECT
    USING (verification_status != 'rejected');

CREATE POLICY "Authenticated users can submit property disputes"
    ON public.property_disputes
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Reporters can view and edit their own submitted disputes"
    ON public.property_disputes
    FOR ALL
    USING (reported_by = auth.uid()::text);

CREATE POLICY "Admins and moderators have full access to dispute records"
    ON public.property_disputes
    FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.user_roles
            WHERE user_id = auth.uid()::text
            AND role IN ('admin', 'founder', 'employee', 'moderator')
        )
    );