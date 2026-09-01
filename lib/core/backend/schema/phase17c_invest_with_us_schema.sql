-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 17C INVEST WITH US SCHEMAS
-- Registered Business Identity: BELAGAVI PROPERTY LLP
-- Target Schema Version: 1.17.3
-- Created: 2026-08-10
-- =============================================================================

-- 1. Investment Interest Leads Table
CREATE TABLE IF NOT EXISTS public.investment_interest_leads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NULL,
    name TEXT NOT NULL,
    phone TEXT NOT NULL,
    email TEXT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    interest_region TEXT NULL,
    indicative_interest_amount NUMERIC NULL,
    preferred_contact_method TEXT DEFAULT 'WhatsApp' NOT NULL,
    message TEXT NULL,
    consent_version TEXT DEFAULT 'v1.0_2026' NOT NULL,
    consent_timestamp TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    status TEXT DEFAULT 'NEW' NOT NULL, -- 'NEW', 'CONTACTED', 'IN_DISCUSSION', 'DOCUMENTS_SHARED', 'CLOSED', 'WITHDRAWN'
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 2. Land Development Projects Table
CREATE TABLE IF NOT EXISTS public.investment_projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    property_type TEXT NOT NULL,
    project_status TEXT DEFAULT 'In Development' NOT NULL,
    description TEXT NOT NULL,
    development_status TEXT NOT NULL,
    disclosable_documents JSONB DEFAULT '[]'::jsonb NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 3. Approved Investment Documents Table
CREATE TABLE IF NOT EXISTS public.investment_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    document_type TEXT NOT NULL,
    file_url TEXT NOT NULL,
    is_public BOOLEAN DEFAULT true NOT NULL,
    approved_by TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 4. Compliance Content Configuration Table
CREATE TABLE IF NOT EXISTS public.investment_content_config (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    legal_entity_name TEXT DEFAULT 'BELAGAVI PROPERTY LLP' NOT NULL,
    module_status TEXT DEFAULT 'INFORMATION_ONLY' NOT NULL, -- 'DISABLED', 'INFORMATION_ONLY', 'INTEREST_COLLECTION', 'COMPLIANCE_APPROVED', 'PRODUCTION_ENABLED'
    indicative_profit_sharing_range TEXT DEFAULT '10%–30%' NOT NULL,
    legal_disclaimer TEXT NOT NULL,
    whatsapp_number TEXT DEFAULT '+919845012345' NOT NULL,
    company_phone_number TEXT DEFAULT '+919845012345' NOT NULL,
    company_email TEXT DEFAULT 'invest@belagaviproperty.com' NOT NULL,
    is_production_payment_enabled BOOLEAN DEFAULT false NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 5. Investment Audit Logs Table
CREATE TABLE IF NOT EXISTS public.investment_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id TEXT NOT NULL,
    actor_role TEXT NOT NULL,
    action TEXT NOT NULL,
    lead_id TEXT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Composite B-Tree Indexes
CREATE INDEX IF NOT EXISTS idx_investment_interest_leads_status_time
ON public.investment_interest_leads(status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_investment_audit_logs_actor_time
ON public.investment_audit_logs(actor_id, timestamp DESC);

-- Enable RLS
ALTER TABLE public.investment_interest_leads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investment_projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investment_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.investment_content_config ENABLE ROW LEVEL SECURITY;

-- Public can submit interest leads
CREATE POLICY "Public insert investment interest leads"
ON public.investment_interest_leads FOR INSERT
WITH CHECK (true);

-- Public can read public projects and documents
CREATE POLICY "Public read investment projects"
ON public.investment_projects FOR SELECT
USING (true);

CREATE POLICY "Public read public investment documents"
ON public.investment_documents FOR SELECT
USING (is_public = true);

CREATE POLICY "Public read investment compliance config"
ON public.investment_content_config FOR SELECT
USING (true);
