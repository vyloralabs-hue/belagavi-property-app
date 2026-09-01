-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 17 PRODUCTION MONETIZATION & REVENUE GOVERNANCE SCHEMA
-- Target Schema Version: 1.17.0
-- Created: 2026-08-10
-- =============================================================================

-- 1. Configuration-Driven Pricing Plans with Integer Paise Precision
CREATE TABLE IF NOT EXISTS public.pricing_plans (
    plan_id TEXT PRIMARY KEY,
    product_type TEXT NOT NULL,
    plan_name TEXT NOT NULL,
    billing_cycle TEXT NOT NULL,
    amount_in_paise BIGINT NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    discount_amount_in_paise BIGINT DEFAULT 0 NOT NULL,
    tax_amount_in_paise BIGINT DEFAULT 0 NOT NULL,
    final_amount_in_paise BIGINT NOT NULL,
    duration_days INT NOT NULL,
    listing_limit INT DEFAULT 1 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    effective_from TIMESTAMPTZ NOT NULL,
    effective_until TIMESTAMPTZ
);

-- Seed Confirmed Plans with Exact Integer Paise
INSERT INTO public.pricing_plans (plan_id, product_type, plan_name, billing_cycle, amount_in_paise, discount_amount_in_paise, final_amount_in_paise, duration_days, effective_from)
VALUES 
  ('plan_prop_free', 'property', 'Property Basic Free Listing', 'free', 0, 0, 0, 3650, NOW()),
  ('plan_shop_free', 'shop', 'Local Shop Basic Free Listing', 'free', 0, 0, 0, 3650, NOW()),
  ('plan_shop_monthly', 'shop', 'Local Shop Monthly Premium', 'monthly', 50000, 0, 50000, 30, NOW()),
  ('plan_shop_yearly', 'shop', 'Local Shop Yearly Premium (Save ₹1,000)', 'yearly', 500000, 100000, 500000, 365, NOW()),
  ('plan_builder_pro', 'builder', 'Builder Pro Enterprise Tier', 'yearly', 2500000, 0, 2500000, 365, NOW()),
  ('plan_broker_pro', 'broker', 'Broker Pro Agent Tier', 'monthly', 150000, 0, 150000, 30, NOW())
ON CONFLICT (plan_id) DO NOTHING;

-- 2. Server Orders & Transactions with Idempotency Constraints
CREATE TABLE IF NOT EXISTS public.payment_orders (
    order_id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    plan_id TEXT NOT NULL REFERENCES public.pricing_plans(plan_id),
    product_type TEXT NOT NULL,
    reference_entity_id TEXT NOT NULL,
    amount_in_paise BIGINT NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    status TEXT DEFAULT 'initiated' NOT NULL,
    idempotency_key TEXT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.payment_transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id TEXT NOT NULL REFERENCES public.payment_orders(order_id),
    payment_id TEXT UNIQUE NOT NULL,
    provider_name TEXT DEFAULT 'razorpay' NOT NULL,
    amount_in_paise BIGINT NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    status TEXT NOT NULL,
    signature TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 3. Entitlements Table (Separated from Financial Transactions)
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

-- 4. Financial Audit Logs (Append-Only)
CREATE TABLE IF NOT EXISTS public.financial_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id TEXT NOT NULL,
    actor_role TEXT NOT NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    previous_state TEXT NOT NULL,
    new_state TEXT NOT NULL,
    amount_in_paise BIGINT DEFAULT 0 NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    reason TEXT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 5. Invoices and Refunds
CREATE TABLE IF NOT EXISTS public.invoices (
    invoice_number TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    order_id TEXT NOT NULL REFERENCES public.payment_orders(order_id),
    subtotal_amount_in_paise BIGINT NOT NULL,
    discount_amount_in_paise BIGINT DEFAULT 0 NOT NULL,
    tax_amount_gst_in_paise BIGINT DEFAULT 0 NOT NULL,
    total_paid_amount_in_paise BIGINT NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    paid_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE TABLE IF NOT EXISTS public.refunds (
    refund_id TEXT PRIMARY KEY,
    payment_id TEXT NOT NULL,
    amount_in_paise BIGINT NOT NULL,
    refund_type TEXT NOT NULL,
    state TEXT DEFAULT 'requested' NOT NULL,
    reason TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- B-Tree Indexes
CREATE INDEX IF NOT EXISTS idx_entitlements_user_entity 
ON public.entitlements(user_id, reference_entity_id, is_active);

CREATE INDEX IF NOT EXISTS idx_payment_orders_user 
ON public.payment_orders(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_financial_audit_logs_actor 
ON public.financial_audit_logs(actor_id, timestamp DESC);

-- Enable RLS & Policies
ALTER TABLE public.pricing_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entitlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.refunds ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read active pricing plans"
ON public.pricing_plans FOR SELECT USING (is_active = true);

CREATE POLICY "User read own entitlements"
ON public.entitlements FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY "User read own invoices"
ON public.invoices FOR SELECT USING (user_id = auth.uid()::text);
