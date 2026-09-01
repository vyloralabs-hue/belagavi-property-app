-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 16 CENTRALIZED MONETIZATION & PAYMENT SCHEMA
-- Target Schema Version: 1.16.0
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

-- Seed Confirmed Local Shop Listing Pricing Plans
INSERT INTO public.pricing_plans (plan_id, product_type, plan_name, billing_cycle, amount, discount_amount, final_amount, duration_days, effective_from)
VALUES 
  ('plan_shop_monthly', 'shop', 'Local Shop Monthly Plan', 'monthly', 500.00, 0.00, 500.00, 30, NOW()),
  ('plan_shop_yearly', 'shop', 'Local Shop Yearly Plan (Save ₹1,000)', 'yearly', 5000.00, 1000.00, 5000.00, 365, NOW())
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
    reference_entity_id TEXT NOT NULL,
    plan_id TEXT NOT NULL REFERENCES public.pricing_plans(plan_id),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    granted_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 4. Invoices and Refunds
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

-- Indexes for Fast Payment History and Entitlement Lookups
CREATE INDEX IF NOT EXISTS idx_entitlements_user_entity 
ON public.entitlements(user_id, reference_entity_id, is_active);

CREATE INDEX IF NOT EXISTS idx_payment_orders_user 
ON public.payment_orders(user_id, created_at DESC);

-- Enable RLS
ALTER TABLE public.pricing_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entitlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.refunds ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read active pricing plans"
ON public.pricing_plans FOR SELECT USING (is_active = true);

CREATE POLICY "User read own entitlements"
ON public.entitlements FOR SELECT USING (user_id = auth.uid()::text);

CREATE POLICY "User read own invoices"
ON public.invoices FOR SELECT USING (user_id = auth.uid()::text);
