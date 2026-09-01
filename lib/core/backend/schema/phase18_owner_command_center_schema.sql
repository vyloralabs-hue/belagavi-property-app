-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 18 OWNER COMMAND CENTER SCHEMAS
-- Registered Business Identity: BELAGAVI PROPERTY LLP
-- Target Schema Version: 1.18.0
-- Created: 2026-08-10
-- =============================================================================

-- 1. Property Enquiries Table (Private to listing owner)
CREATE TABLE IF NOT EXISTS public.property_enquiries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id TEXT NOT NULL,
    owner_id TEXT NOT NULL,
    lead_type TEXT DEFAULT 'INQUIRY' NOT NULL, -- 'BUYER', 'SELLER', 'CALL', 'WHATSAPP', 'INQUIRY'
    actor_role TEXT DEFAULT 'BUYER' NOT NULL,
    name TEXT NOT NULL,
    contact_method TEXT NOT NULL,
    phone_number TEXT NULL,
    email TEXT NULL,
    property_title TEXT NOT NULL,
    location TEXT NOT NULL,
    status TEXT DEFAULT 'NEW' NOT NULL, -- 'NEW', 'CONTACTED', 'FOLLOW_UP', 'INTERESTED', 'CLOSED', 'NOT_INTERESTED'
    notes TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 2. Property Contact Requests Table
CREATE TABLE IF NOT EXISTS public.property_contact_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id TEXT NOT NULL,
    owner_id TEXT NOT NULL,
    request_type TEXT NOT NULL, -- 'CALL', 'WHATSAPP', 'MESSAGE'
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 3. Owner Daily Metrics Aggregation Table
CREATE TABLE IF NOT EXISTS public.owner_daily_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id TEXT NOT NULL,
    property_id TEXT NOT NULL,
    metric_date DATE NOT NULL,
    views_count INT DEFAULT 0 NOT NULL,
    search_appearances INT DEFAULT 0 NOT NULL,
    detail_opens INT DEFAULT 0 NOT NULL,
    enquiries_count INT DEFAULT 0 NOT NULL,
    call_clicks INT DEFAULT 0 NOT NULL,
    whatsapp_clicks INT DEFAULT 0 NOT NULL,
    favorites_count INT DEFAULT 0 NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT uq_owner_daily_metrics UNIQUE(owner_id, property_id, metric_date)
);

-- Composite B-Tree Indexes for Fast Owner Queries
CREATE INDEX IF NOT EXISTS idx_property_enquiries_owner_status
ON public.property_enquiries(owner_id, status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_property_contact_requests_owner
ON public.property_contact_requests(owner_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_owner_daily_metrics_owner_date
ON public.owner_daily_metrics(owner_id, metric_date DESC);

-- Enable RLS
ALTER TABLE public.property_enquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.property_contact_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.owner_daily_metrics ENABLE ROW LEVEL SECURITY;

-- Strict RLS Policies: Owner can access ONLY records where owner_id = auth.uid()
CREATE POLICY "Owner read own property enquiries"
ON public.property_enquiries FOR SELECT
USING (owner_id = auth.uid()::text);

CREATE POLICY "Owner update own property enquiries"
ON public.property_enquiries FOR UPDATE
USING (owner_id = auth.uid()::text);

CREATE POLICY "Owner read own contact requests"
ON public.property_contact_requests FOR SELECT
USING (owner_id = auth.uid()::text);

CREATE POLICY "Owner read own daily metrics"
ON public.owner_daily_metrics FOR SELECT
USING (owner_id = auth.uid()::text);
