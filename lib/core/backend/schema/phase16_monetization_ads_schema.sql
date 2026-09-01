-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 16 MONETIZATION, FREE LISTING, PREMIUM & ADS SCHEMA
-- Target Schema Version: 1.16.1
-- Created: 2026-08-10
-- =============================================================================

-- 1. Configuration-Driven Pricing Plans
CREATE TABLE IF NOT EXISTS public.pricing_plans (
    plan_id TEXT PRIMARY KEY,
    product_type TEXT NOT NULL,
    plan_name TEXT NOT NULL,
    billing_cycle TEXT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    discount_amount NUMERIC(10, 2) DEFAULT 0.0 NOT NULL,
    tax_amount NUMERIC(10, 2) DEFAULT 0.0 NOT NULL,
    final_amount NUMERIC(10, 2) NOT NULL,
    duration_days INT NOT NULL,
    listing_limit INT DEFAULT 1 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    effective_from TIMESTAMPTZ NOT NULL,
    effective_until TIMESTAMPTZ
);

-- Seed Confirmed Property & Shop Free/Paid Pricing Plans
INSERT INTO public.pricing_plans (plan_id, product_type, plan_name, billing_cycle, amount, discount_amount, final_amount, duration_days, effective_from)
VALUES 
  ('plan_prop_free', 'property', 'Property Basic Free Listing', 'free', 0.00, 0.00, 0.00, 3650, NOW()),
  ('plan_shop_free', 'shop', 'Local Shop Basic Free Listing', 'free', 0.00, 0.00, 0.00, 3650, NOW()),
  ('plan_shop_monthly', 'shop', 'Local Shop Monthly Premium', 'monthly', 500.00, 0.00, 500.00, 30, NOW()),
  ('plan_shop_yearly', 'shop', 'Local Shop Yearly Premium (Save ₹1,000)', 'yearly', 5000.00, 1000.00, 5000.00, 365, NOW()),
  ('plan_builder_pro', 'builder', 'Builder Pro Enterprise Tier', 'yearly', 25000.00, 0.00, 25000.00, 365, NOW()),
  ('plan_broker_pro', 'broker', 'Broker Pro Agent Tier', 'monthly', 1500.00, 0.00, 1500.00, 30, NOW())
ON CONFLICT (plan_id) DO NOTHING;

-- 2. Server Orders & Immutable Payment Transactions
CREATE TABLE IF NOT EXISTS public.payment_orders (
    order_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    plan_id TEXT NOT NULL REFERENCES public.pricing_plans(plan_id),
    product_type TEXT NOT NULL,
    reference_entity_id TEXT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    status TEXT DEFAULT 'initiated' NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.payment_transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id TEXT NOT NULL REFERENCES public.payment_orders(order_id),
    payment_id TEXT NOT NULL,
    provider_name TEXT DEFAULT 'razorpay' NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    status TEXT NOT NULL,
    signature TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 3. Entitlements Table (Separated from Transactions)
CREATE TABLE IF NOT EXISTS public.entitlements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    product_type TEXT NOT NULL,
    boost_type TEXT DEFAULT 'freeListing' NOT NULL,
    reference_entity_id TEXT NOT NULL,
    plan_id TEXT NOT NULL REFERENCES public.pricing_plans(plan_id),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    priority_score INT DEFAULT 0 NOT NULL,
    granted_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 4. Advertising Placements & Configurations
CREATE TABLE IF NOT EXISTS public.advertising_placements (
    id TEXT PRIMARY KEY,
    placement_type TEXT NOT NULL,
    provider_type TEXT DEFAULT 'adMob' NOT NULL,
    is_enabled BOOLEAN DEFAULT TRUE NOT NULL,
    refresh_rate_seconds INT DEFAULT 30 NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

INSERT INTO public.advertising_placements (id, placement_type, provider_type, is_enabled)
VALUES
  ('place_home_feed', 'homeFeed', 'adMob', true),
  ('place_prop_search', 'propertySearch', 'adMob', true),
  ('place_shop_search', 'shopSearch', 'adMob', true),
  ('place_unified_search', 'unifiedSearch', 'adMob', true)
ON CONFLICT (id) DO NOTHING;

CREATE TABLE IF NOT EXISTS public.ad_revenue_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    placement_type TEXT NOT NULL,
    provider_type TEXT NOT NULL,
    event_type TEXT NOT NULL, -- 'IMPRESSION', 'CLICK'
    estimated_revenue_inr NUMERIC(10, 4) DEFAULT 0.0000 NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 5. Invoices and Refunds
CREATE TABLE IF NOT EXISTS public.invoices (
    invoice_number TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    order_id TEXT NOT NULL REFERENCES public.payment_orders(order_id),
    subtotal_amount NUMERIC(10, 2) NOT NULL,
    discount_amount NUMERIC(10, 2) DEFAULT 0.0 NOT NULL,
    tax_amount_gst NUMERIC(10, 2) DEFAULT 0.0 NOT NULL,
    total_paid_amount NUMERIC(10, 2) NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    paid_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.refunds (
    refund_id TEXT PRIMARY KEY,
    payment_id TEXT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL,
    refund_type TEXT NOT NULL,
    reason TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Enable RLS
ALTER TABLE public.pricing_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entitlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.advertising_placements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ad_revenue_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.refunds ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read active pricing plans"
ON public.pricing_plans FOR SELECT USING (is_active = true);

CREATE POLICY "User read own entitlements"
ON public.entitlements FOR SELECT USING (user_id = auth.uid()::text);
