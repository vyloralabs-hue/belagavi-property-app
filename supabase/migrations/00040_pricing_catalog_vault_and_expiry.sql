-- ==============================================================================
-- Migration 00040: Pricing Catalog, Plan Entitlements, Permanent Owner Vault & Expiry
-- Project: Belagavi Property (PropertyHub)
-- Business Rules:
-- 1. Server-authoritative pricing_plans catalog with integer minor units (paise)
-- 2. 7 distinct product families with strict capability separation
-- 3. Additive columns for properties and dispute_listings for server-time expiry
-- 4. High-performance indexes for public visibility and owner vault filtering
-- 5. Full support for permanent owner vault: expired items leave public view but remain in owner vault
-- ==============================================================================

-- 1. Create Canonical pricing_plans Table
CREATE TABLE IF NOT EXISTS public.pricing_plans (
    id TEXT PRIMARY KEY,
    code TEXT UNIQUE NOT NULL,
    plan_id TEXT NOT NULL,
    name TEXT NOT NULL,
    product_family TEXT NOT NULL,
    price_minor_units BIGINT NOT NULL,
    amount_in_paise BIGINT NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    validity_days INT NOT NULL,
    duration_days INT NOT NULL,
    credit_count INT DEFAULT 1 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    sort_order INT DEFAULT 0 NOT NULL,
    metadata JSONB DEFAULT '{}'::jsonb NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Index for product family and active state
CREATE INDEX IF NOT EXISTS idx_pricing_plans_family_active 
    ON public.pricing_plans(product_family, is_active, sort_order);

-- Enable RLS
ALTER TABLE public.pricing_plans ENABLE ROW LEVEL SECURITY;

-- Drop existing policy if re-running
DROP POLICY IF EXISTS "Public read active pricing plans" ON public.pricing_plans;
CREATE POLICY "Public read active pricing plans"
    ON public.pricing_plans FOR SELECT
    USING (is_active = TRUE);

-- 2. Seed All Approved V1 Pricing Plans (Integer Paise Precision)
INSERT INTO public.pricing_plans (
    id, code, plan_id, name, product_family,
    price_minor_units, amount_in_paise, currency,
    validity_days, duration_days, credit_count, is_active, sort_order
) VALUES
  -- Residential Property Listing (After 15-day free period)
  ('RESIDENTIAL_30D', 'RESIDENTIAL_30D', 'RESIDENTIAL_30D', 'Residential Listing - 30 Days', 'residential_listing', 14900, 14900, 'INR', 30, 30, 1, TRUE, 10),
  ('RESIDENTIAL_90D', 'RESIDENTIAL_90D', 'RESIDENTIAL_90D', 'Residential Listing - 90 Days', 'residential_listing', 34900, 34900, 'INR', 90, 90, 1, TRUE, 20),
  ('RESIDENTIAL_365D', 'RESIDENTIAL_365D', 'RESIDENTIAL_365D', 'Residential Listing - 1 Year', 'residential_listing', 99900, 99900, 'INR', 365, 365, 1, TRUE, 30),

  -- Commercial / Industrial Property Listing (Paid from Day 1)
  ('COMMERCIAL_30D', 'COMMERCIAL_30D', 'COMMERCIAL_30D', 'Commercial Listing - 30 Days', 'commercial_listing', 69900, 69900, 'INR', 30, 30, 1, TRUE, 40),
  ('COMMERCIAL_90D', 'COMMERCIAL_90D', 'COMMERCIAL_90D', 'Commercial Listing - 90 Days', 'commercial_listing', 149900, 149900, 'INR', 90, 90, 1, TRUE, 50),
  ('COMMERCIAL_365D', 'COMMERCIAL_365D', 'COMMERCIAL_365D', 'Commercial Listing - 1 Year', 'commercial_listing', 399900, 399900, 'INR', 365, 365, 1, TRUE, 60),

  -- Property Legal Notice Publication (10 Days per publication)
  ('LEGAL_NOTICE_10D', 'LEGAL_NOTICE_10D', 'LEGAL_NOTICE_10D', 'Legal Notice Publication - 10 Days', 'legal_notice_publication', 99900, 99900, 'INR', 10, 10, 1, TRUE, 70),

  -- Disputed Property Publication
  ('DISPUTE_30D', 'DISPUTE_30D', 'DISPUTE_30D', 'Disputed Property Publication - 30 Days', 'dispute_publication', 29900, 29900, 'INR', 30, 30, 1, TRUE, 80),
  ('DISPUTE_90D', 'DISPUTE_90D', 'DISPUTE_90D', 'Disputed Property Publication - 90 Days', 'dispute_publication', 69900, 69900, 'INR', 90, 90, 1, TRUE, 90),
  ('DISPUTE_365D', 'DISPUTE_365D', 'DISPUTE_365D', 'Disputed Property Publication - 1 Year', 'dispute_publication', 179900, 179900, 'INR', 365, 365, 1, TRUE, 100),

  -- Normal Property Watch (Paid from 1st watch)
  ('PROPERTY_WATCH_30D', 'PROPERTY_WATCH_30D', 'PROPERTY_WATCH_30D', 'Property Watch - 30 Days', 'property_watch', 19900, 19900, 'INR', 30, 30, 1, TRUE, 110),
  ('PROPERTY_WATCH_90D', 'PROPERTY_WATCH_90D', 'PROPERTY_WATCH_90D', 'Property Watch - 90 Days', 'property_watch', 49900, 49900, 'INR', 90, 90, 1, TRUE, 120),
  ('PROPERTY_WATCH_365D', 'PROPERTY_WATCH_365D', 'PROPERTY_WATCH_365D', 'Property Watch - 1 Year', 'property_watch', 149900, 149900, 'INR', 365, 365, 1, TRUE, 130),

  -- Survey Monitoring (Paid from 1st watch)
  ('SURVEY_MONITORING_30D', 'SURVEY_MONITORING_30D', 'SURVEY_MONITORING_30D', 'Survey Monitoring - 30 Days', 'survey_monitoring', 19900, 19900, 'INR', 30, 30, 1, TRUE, 140),
  ('SURVEY_MONITORING_90D', 'SURVEY_MONITORING_90D', 'SURVEY_MONITORING_90D', 'Survey Monitoring - 90 Days', 'survey_monitoring', 49900, 49900, 'INR', 90, 90, 1, TRUE, 150),
  ('SURVEY_MONITORING_365D', 'SURVEY_MONITORING_365D', 'SURVEY_MONITORING_365D', 'Survey Monitoring - 1 Year', 'survey_monitoring', 149900, 149900, 'INR', 365, 365, 1, TRUE, 160),

  -- Buyer Full Property Details Unlock
  ('PROPERTY_UNLOCK_SINGLE', 'PROPERTY_UNLOCK_SINGLE', 'PROPERTY_UNLOCK_SINGLE', 'Property Unlock - 1 Property', 'buyer_unlock', 9900, 9900, 'INR', 365, 365, 1, TRUE, 170),
  ('PROPERTY_UNLOCK_5', 'PROPERTY_UNLOCK_5', 'PROPERTY_UNLOCK_5', 'Property Unlock - 5 Properties', 'buyer_unlock', 34900, 34900, 'INR', 365, 365, 5, TRUE, 180),
  ('PROPERTY_UNLOCK_15', 'PROPERTY_UNLOCK_15', 'PROPERTY_UNLOCK_15', 'Property Unlock - 15 Properties', 'buyer_unlock', 79900, 79900, 'INR', 365, 365, 15, TRUE, 190)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    product_family = EXCLUDED.product_family,
    price_minor_units = EXCLUDED.price_minor_units,
    amount_in_paise = EXCLUDED.amount_in_paise,
    validity_days = EXCLUDED.validity_days,
    duration_days = EXCLUDED.duration_days,
    credit_count = EXCLUDED.credit_count,
    is_active = EXCLUDED.is_active,
    sort_order = EXCLUDED.sort_order,
    updated_at = NOW();

-- 3. Add Additive Expiry & Plan Columns to public.properties
ALTER TABLE public.properties
    ADD COLUMN IF NOT EXISTS listing_expires_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS active_plan_id TEXT;

-- Index for public marketplace discovery with unexpired filter
CREATE INDEX IF NOT EXISTS idx_properties_listing_expires 
    ON public.properties(listing_expires_at);

CREATE INDEX IF NOT EXISTS idx_properties_public_unexpired 
    ON public.properties(status, is_paused, listing_expires_at) 
    WHERE status = 'active' AND is_paused = false;

-- 4. Add Additive Expiry & Plan Columns to public.dispute_listings
ALTER TABLE public.dispute_listings
    ADD COLUMN IF NOT EXISTS published_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS public_until TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS expired_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS active_plan_id TEXT;

CREATE INDEX IF NOT EXISTS idx_dispute_listings_public_lifecycle
    ON public.dispute_listings(status, published_at, public_until)
    WHERE status = 'published';

-- 5. Add active_plan_id to legal_notices
ALTER TABLE public.legal_notices
    ADD COLUMN IF NOT EXISTS active_plan_id TEXT;
