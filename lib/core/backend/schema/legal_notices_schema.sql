-- ============================================================================
-- BELAGAVI PROPERTY LLP â€” PURCHASE / SALE / LEGAL NOTICES SCHEMA
-- High-scale, structured legal transaction and notice records
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.property_legal_notices (
    id TEXT PRIMARY KEY,
    property_id TEXT NOT NULL,
    title TEXT NOT NULL,
    category TEXT NOT NULL DEFAULT 'Residential',
    property_type TEXT NOT NULL DEFAULT 'Apartment',
    city TEXT NOT NULL DEFAULT 'Belagavi',
    locality TEXT NOT NULL,
    village_taluk TEXT,
    survey_cts_number TEXT,
    buyer_name TEXT,
    buyer_address TEXT,
    buyer_advocate TEXT,
    seller_name TEXT,
    seller_address TEXT,
    contact_name TEXT NOT NULL,
    contact_phone TEXT NOT NULL,
    contact_email TEXT,
    contact_role TEXT NOT NULL DEFAULT 'Buyer / Purchaser',
    transaction_type TEXT NOT NULL DEFAULT 'Purchase',
    agreed_value TEXT,
    agreement_date TEXT,
    execution_date TEXT,
    transaction_status TEXT NOT NULL DEFAULT 'Under Negotiation / Proposed',
    transaction_description TEXT,
    notice_type TEXT NOT NULL DEFAULT 'purchaseLegalNotice',
    issuing_authority TEXT,
    reference_number TEXT,
    notice_date TEXT,
    public_notice_summary TEXT,
    due_diligence_notes TEXT,
    photo_urls JSONB NOT NULL DEFAULT '[]'::jsonb,
    document_urls JSONB NOT NULL DEFAULT '[]'::jsonb,
    is_document_private BOOLEAN NOT NULL DEFAULT true,
    can_add_documents_later BOOLEAN NOT NULL DEFAULT true,
    verification_status TEXT NOT NULL DEFAULT 'underReview',
    recorded_by TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for rapid query filtering
CREATE INDEX IF NOT EXISTS idx_legal_notices_locality ON public.property_legal_notices (locality);
CREATE INDEX IF NOT EXISTS idx_legal_notices_type ON public.property_legal_notices (notice_type);
CREATE INDEX IF NOT EXISTS idx_legal_notices_tx_type ON public.property_legal_notices (transaction_type);
CREATE INDEX IF NOT EXISTS idx_legal_notices_property_id ON public.property_legal_notices (property_id);
CREATE INDEX IF NOT EXISTS idx_legal_notices_status ON public.property_legal_notices (verification_status);

-- Enable Row Level Security
ALTER TABLE public.property_legal_notices ENABLE ROW LEVEL SECURITY;

-- 1. Public Read Policy: Public can read published/recorded legal notice disclosures
CREATE POLICY legal_notices_public_select ON public.property_legal_notices
    FOR SELECT
    USING (verification_status != 'rejected');

-- 2. Authenticated Creator Insert Policy: Authenticated users can submit legal notice records
CREATE POLICY legal_notices_auth_insert ON public.property_legal_notices
    FOR INSERT
    WITH CHECK (auth.uid() IS NOT NULL);

-- 3. Owner/Reporter Update Policy: Creators can update or attach documents later
CREATE POLICY legal_notices_owner_update ON public.property_legal_notices
    FOR UPDATE
    USING (auth.uid() = recorded_by OR auth.jwt() ->> 'role' IN ('admin', 'founder', 'moderator'));