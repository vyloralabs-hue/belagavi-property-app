-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 19 CENTRAL MONETIZATION & PAYMENT SCHEMAS
-- Registered Business Identity: BELAGAVI PROPERTY LLP
-- Target Schema Version: 1.19.0
-- Created: 2026-08-10
-- =============================================================================

-- 1. Subscriptions Table
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    product_type TEXT NOT NULL, -- 'PROPERTY', 'SHOP', 'BUILDER', 'BROKER'
    plan_id TEXT NOT NULL,
    reference_entity_id TEXT NOT NULL,
    start_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    end_at TIMESTAMPTZ NOT NULL,
    status TEXT DEFAULT 'ACTIVE' NOT NULL, -- 'ACTIVE', 'EXPIRED', 'CANCELLED', 'PAYMENT_FAILED'
    auto_renew BOOLEAN DEFAULT false NOT NULL,
    gateway_subscription_reference TEXT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 2. Invoices Table
CREATE TABLE IF NOT EXISTS public.invoices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    invoice_number TEXT NOT NULL UNIQUE,
    user_id TEXT NOT NULL,
    payment_id TEXT NOT NULL,
    product_type TEXT NOT NULL,
    plan_id TEXT NOT NULL,
    amount_in_paise INT NOT NULL,
    tax_amount_in_paise INT DEFAULT 0 NOT NULL,
    final_amount_in_paise INT NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    payment_method TEXT DEFAULT 'SANDBOX_GATEWAY' NOT NULL,
    status TEXT DEFAULT 'PAID' NOT NULL,
    issued_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 3. Refunds Table
CREATE TABLE IF NOT EXISTS public.refunds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    refund_id TEXT NOT NULL UNIQUE,
    payment_id TEXT NOT NULL,
    user_id TEXT NOT NULL,
    amount_in_paise INT NOT NULL,
    refund_type TEXT DEFAULT 'FULL' NOT NULL, -- 'FULL', 'PARTIAL'
    state TEXT DEFAULT 'REQUESTED' NOT NULL, -- 'REQUESTED', 'PROCESSING', 'SUCCESS', 'FAILED', 'REJECTED'
    reason TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- 4. Financial Audit Logs Table
CREATE TABLE IF NOT EXISTS public.financial_audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id TEXT NOT NULL,
    actor_role TEXT NOT NULL,
    action TEXT NOT NULL, -- 'PLAN_CREATED', 'ORDER_CREATED', 'PAYMENT_SUCCESS', 'ENTITLEMENT_ACTIVATED', 'REFUND_REQUESTED'
    entity_type TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    previous_state TEXT NULL,
    new_state TEXT NOT NULL,
    amount_in_paise INT DEFAULT 0 NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    reason TEXT NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- B-Tree Indexes
CREATE INDEX IF NOT EXISTS idx_subscriptions_user_status
ON public.subscriptions(user_id, status, end_at DESC);

CREATE INDEX IF NOT EXISTS idx_invoices_user_number
ON public.invoices(user_id, invoice_number);

CREATE INDEX IF NOT EXISTS idx_refunds_user_payment
ON public.refunds(user_id, payment_id);

CREATE INDEX IF NOT EXISTS idx_financial_audit_logs_actor
ON public.financial_audit_logs(actor_id, timestamp DESC);

-- Enable RLS
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.refunds ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_audit_logs ENABLE ROW LEVEL SECURITY;

-- Strict RLS Policies
CREATE POLICY "User read own subscriptions"
ON public.subscriptions FOR SELECT
USING (user_id = auth.uid()::text);

CREATE POLICY "User read own invoices"
ON public.invoices FOR SELECT
USING (user_id = auth.uid()::text);

CREATE POLICY "User read own refunds"
ON public.refunds FOR SELECT
USING (user_id = auth.uid()::text);
