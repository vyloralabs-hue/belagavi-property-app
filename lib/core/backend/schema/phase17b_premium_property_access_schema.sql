-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 17B PREMIUM PROPERTY PRIORITY & ACCESS SCHEMAS
-- Target Schema Version: 1.17.2
-- Created: 2026-08-10
-- =============================================================================

-- 1. Property Promotion Entitlements Table (Separated from core transactions)
CREATE TABLE IF NOT EXISTS public.property_promotion_entitlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id TEXT NOT NULL,
    owner_id TEXT NOT NULL,
    plan_id TEXT NOT NULL,
    tier TEXT NOT NULL, -- 'free', 'featured', 'priority', 'premium'
    priority_boost_score INT DEFAULT 0 NOT NULL,
    amount_in_paise BIGINT DEFAULT 0 NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    status TEXT DEFAULT 'active' NOT NULL, -- 'active', 'expired', 'cancelled', 'refunded'
    granted_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 2. Property Promotion Analytics Events (Privacy-Safe Aggregate Analytics)
CREATE TABLE IF NOT EXISTS public.property_promotion_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id TEXT NOT NULL,
    event_type TEXT NOT NULL, -- 'IMPRESSION', 'CLICK', 'CONTACT_CLICK', 'CALL_CLICK', 'WHATSAPP_CLICK'
    tier TEXT DEFAULT 'free' NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Composite B-Tree Indexes for Performance
CREATE INDEX IF NOT EXISTS idx_property_promotion_entitlements_prop_status
ON public.property_promotion_entitlements(property_id, status, expires_at);

CREATE INDEX IF NOT EXISTS idx_property_promotion_entitlements_owner
ON public.property_promotion_entitlements(owner_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_property_promotion_events_prop_time
ON public.property_promotion_events(property_id, timestamp DESC);

-- Enable RLS
ALTER TABLE public.property_promotion_entitlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.property_promotion_events ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Owner read own promotion entitlements"
ON public.property_promotion_entitlements FOR SELECT
USING (owner_id = auth.uid()::text);

CREATE POLICY "Public read active promotion entitlements"
ON public.property_promotion_entitlements FOR SELECT
USING (status = 'active' AND expires_at > NOW());
