-- =============================================================================
-- Migration 00015: Server-Authoritative Payment Orders, Transactions & Webhooks
-- Project: Belagavi Property (PropertyHub)
-- Description: Establishes server-authoritative financial schema, integer paise precision,
--              idempotency constraints, immutable audit logs, and atomic entitlement activation
-- =============================================================================

-- 1. Canonical Pricing Plans (Integer Paise Precision)
CREATE TABLE IF NOT EXISTS public.pricing_plans (
    plan_id TEXT PRIMARY KEY,
    product_type TEXT NOT NULL, -- 'property', 'shop', 'builder', 'broker', 'subscription'
    plan_name TEXT NOT NULL,
    billing_cycle TEXT NOT NULL, -- 'free', 'one_time', 'monthly', 'quarterly', 'yearly'
    amount_in_paise BIGINT NOT NULL DEFAULT 0,
    currency TEXT DEFAULT 'INR' NOT NULL,
    discount_amount_in_paise BIGINT DEFAULT 0 NOT NULL,
    tax_amount_in_paise BIGINT DEFAULT 0 NOT NULL,
    final_amount_in_paise BIGINT NOT NULL DEFAULT 0,
    duration_days INT NOT NULL DEFAULT 30,
    listing_limit INT DEFAULT 1 NOT NULL,
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    effective_from TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    effective_until TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seed Standard Canonical Pricing Plans
INSERT INTO public.pricing_plans (
    plan_id, product_type, plan_name, billing_cycle,
    amount_in_paise, discount_amount_in_paise, final_amount_in_paise,
    duration_days, listing_limit, is_active, effective_from
) VALUES
  ('plan_prop_free', 'property', 'Property Basic Free Listing', 'free', 0, 0, 0, 3650, 5, TRUE, NOW()),
  ('plan_prop_featured_7d', 'property', 'Property 7-Day Featured Boost', 'one_time', 29900, 0, 29900, 7, 1, TRUE, NOW()),
  ('plan_prop_featured_30d', 'property', 'Property 30-Day Featured Showcase', 'one_time', 99900, 0, 99900, 30, 1, TRUE, NOW()),
  ('plan_prop_top_placement', 'property', 'Property Top Search Placement', 'one_time', 49900, 0, 49900, 15, 1, TRUE, NOW()),
  ('plan_shop_free', 'shop', 'Local Shop Basic Free Listing', 'free', 0, 0, 0, 3650, 1, TRUE, NOW()),
  ('plan_shop_monthly', 'shop', 'Local Shop Monthly Premium', 'monthly', 50000, 0, 50000, 30, 1, TRUE, NOW()),
  ('plan_shop_yearly', 'shop', 'Local Shop Yearly Premium (Save ₹1,000)', 'yearly', 500000, 100000, 500000, 365, 1, TRUE, NOW()),
  ('plan_broker_pro', 'broker', 'Broker Pro Agent Tier', 'monthly', 150000, 0, 150000, 30, 50, TRUE, NOW()),
  ('plan_builder_pro', 'builder', 'Builder Pro Enterprise Tier', 'yearly', 2500000, 0, 2500000, 365, 200, TRUE, NOW())
ON CONFLICT (plan_id) DO UPDATE SET
    plan_name = EXCLUDED.plan_name,
    amount_in_paise = EXCLUDED.amount_in_paise,
    discount_amount_in_paise = EXCLUDED.discount_amount_in_paise,
    final_amount_in_paise = EXCLUDED.final_amount_in_paise,
    duration_days = EXCLUDED.duration_days,
    updated_at = NOW();

-- 2. Server-Authoritative Payment Orders
CREATE TABLE IF NOT EXISTS public.payment_orders (
    order_id TEXT PRIMARY KEY, -- e.g. 'order_rzp_123456789'
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    plan_id TEXT NOT NULL REFERENCES public.pricing_plans(plan_id),
    product_type TEXT NOT NULL,
    reference_entity_id TEXT NOT NULL, -- e.g. property_id, shop_id, user_id
    amount_in_paise BIGINT NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    status TEXT DEFAULT 'initiated' NOT NULL, -- 'initiated', 'pending', 'authorized', 'captured', 'failed', 'refunded', 'cancelled'
    idempotency_key TEXT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indices for rapid order queries
CREATE INDEX IF NOT EXISTS idx_payment_orders_user ON public.payment_orders(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_payment_orders_status ON public.payment_orders(status);
CREATE INDEX IF NOT EXISTS idx_payment_orders_reference ON public.payment_orders(reference_entity_id);

-- 3. Immutable Payment Transactions
CREATE TABLE IF NOT EXISTS public.payment_transactions (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id TEXT NOT NULL REFERENCES public.payment_orders(order_id) ON DELETE CASCADE,
    payment_id TEXT UNIQUE NOT NULL, -- e.g. 'pay_rzp_987654321'
    provider_name TEXT DEFAULT 'razorpay' NOT NULL,
    amount_in_paise BIGINT NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    status TEXT NOT NULL, -- 'authorized', 'captured', 'failed', 'refunded'
    signature TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_payment_transactions_order ON public.payment_transactions(order_id);
CREATE INDEX IF NOT EXISTS idx_payment_transactions_payment ON public.payment_transactions(payment_id);

-- 4. Idempotent Webhook Events Ledger
CREATE TABLE IF NOT EXISTS public.webhook_events (
    event_id TEXT PRIMARY KEY, -- e.g. 'evt_rzp_123456'
    provider TEXT DEFAULT 'razorpay' NOT NULL,
    event_type TEXT NOT NULL, -- 'payment.captured', 'order.paid', 'payment.failed', etc.
    order_id TEXT,
    payment_id TEXT,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    processed BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_webhook_events_order ON public.webhook_events(order_id);
CREATE INDEX IF NOT EXISTS idx_webhook_events_payment ON public.webhook_events(payment_id);

-- 5. Financial Audit Logs (Append-Only)
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

CREATE INDEX IF NOT EXISTS idx_financial_audit_actor ON public.financial_audit_logs(actor_id, timestamp DESC);

-- 6. Generated Invoices
CREATE TABLE IF NOT EXISTS public.invoices (
    invoice_number TEXT PRIMARY KEY,
    user_id TEXT NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    order_id TEXT NOT NULL REFERENCES public.payment_orders(order_id) ON DELETE CASCADE,
    subtotal_amount_in_paise BIGINT NOT NULL,
    discount_amount_in_paise BIGINT DEFAULT 0 NOT NULL,
    tax_amount_gst_in_paise BIGINT DEFAULT 0 NOT NULL,
    total_paid_amount_in_paise BIGINT NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    paid_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_invoices_user ON public.invoices(user_id, paid_at DESC);
CREATE INDEX IF NOT EXISTS idx_invoices_order ON public.invoices(order_id);

-- 7. Enable RLS on Financial Tables
ALTER TABLE public.pricing_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.webhook_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;

-- 8. Row Level Security Policies

-- Pricing Plans: Public Read Access
CREATE POLICY "Public read active pricing plans"
    ON public.pricing_plans FOR SELECT
    USING (is_active = TRUE);

-- Payment Orders: Users can read own orders; Admin global access
CREATE POLICY "Users read own payment orders"
    ON public.payment_orders FOR SELECT
    TO authenticated
    USING (
        user_id = (SELECT auth.uid())::text
        OR public.is_app_admin_or_founder()
    );

-- Invoices: Users can read own invoices; Admin global access
CREATE POLICY "Users read own invoices"
    ON public.invoices FOR SELECT
    TO authenticated
    USING (
        user_id = (SELECT auth.uid())::text
        OR public.is_app_admin_or_founder()
    );

-- Payment Transactions: Users can read transactions for their own orders
CREATE POLICY "Users read own payment transactions"
    ON public.payment_transactions FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.payment_orders po
            WHERE po.order_id = payment_transactions.order_id
            AND (po.user_id = (SELECT auth.uid())::text OR public.is_app_admin_or_founder())
        )
    );

-- Webhook Events & Financial Audit Logs: Admin/Founder Read Access Only
CREATE POLICY "Admin read webhook events"
    ON public.webhook_events FOR SELECT
    TO authenticated
    USING (public.is_app_admin_or_founder());

CREATE POLICY "Admin read financial audit logs"
    ON public.financial_audit_logs FOR SELECT
    TO authenticated
    USING (public.is_app_admin_or_founder());

-- 9. Atomic Server-Side Function: Grant Entitlement & Promotion on Authoritative Capture
CREATE OR REPLACE FUNCTION public.fn_authoritative_grant_entitlement_and_promotion(
    p_order_id TEXT,
    p_payment_id TEXT,
    p_signature TEXT,
    p_actor_id TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    v_order RECORD;
    v_plan RECORD;
    v_now TIMESTAMPTZ := NOW();
    v_end_at TIMESTAMPTZ;
    v_promo_type TEXT;
    v_promo_id TEXT;
    v_invoice_num TEXT;
    v_tax_paise BIGINT;
    v_subtotal_paise BIGINT;
BEGIN
    -- 1. Lock and fetch order
    SELECT * INTO v_order 
    FROM public.payment_orders 
    WHERE order_id = p_order_id 
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order % not found', p_order_id;
    END IF;

    -- Idempotent check: if already captured, return success immediately
    IF v_order.status = 'captured' THEN
        RETURN jsonb_build_object(
            'success', true,
            'order_id', p_order_id,
            'payment_id', p_payment_id,
            'status', 'already_captured',
            'message', 'Order was already authoritatively captured.'
        );
    END IF;

    -- State Machine Guard: Cannot capture from terminal failed or cancelled status
    IF v_order.status IN ('failed', 'cancelled', 'refunded') THEN
        RAISE EXCEPTION 'Cannot capture payment for order in terminal status %', v_order.status;
    END IF;

    -- 2. Fetch canonical plan
    SELECT * INTO v_plan 
    FROM public.pricing_plans 
    WHERE plan_id = v_order.plan_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Pricing plan % not found', v_order.plan_id;
    END IF;

    v_end_at := v_now + (v_plan.duration_days || ' days')::INTERVAL;

    -- 3. Record transaction
    INSERT INTO public.payment_transactions (
        transaction_id, order_id, payment_id, provider_name,
        amount_in_paise, currency, status, signature, created_at
    ) VALUES (
        gen_random_uuid(), p_order_id, p_payment_id, 'razorpay',
        v_order.amount_in_paise, v_order.currency, 'captured', p_signature, v_now
    ) ON CONFLICT (payment_id) DO NOTHING;

    -- 4. Update order status
    UPDATE public.payment_orders 
    SET status = 'captured', updated_at = v_now 
    WHERE order_id = p_order_id;

    -- 5. Activate Entitlement / Promotion based on product type
    IF v_order.product_type = 'property' THEN
        -- Determine promotion type
        IF v_order.plan_id LIKE '%top%' THEN
            v_promo_type := 'TOP_PLACEMENT';
        ELSIF v_order.plan_id LIKE '%featured%' THEN
            v_promo_type := 'FEATURED';
        ELSE
            v_promo_type := 'BOOST';
        END IF;

        v_promo_id := 'promo_' || v_order.reference_entity_id || '_' || LOWER(v_promo_type) || '_' || EXTRACT(EPOCH FROM v_now)::BIGINT;

        -- Insert or refresh active promotion
        INSERT INTO public.property_promotions (
            id, property_id, owner_id, promotion_type, priority_level,
            status, start_at, end_at, created_at, updated_at
        ) VALUES (
            v_promo_id, v_order.reference_entity_id, v_order.user_id, v_promo_type,
            CASE WHEN v_promo_type = 'TOP_PLACEMENT' THEN 3 WHEN v_promo_type = 'FEATURED' THEN 2 ELSE 1 END,
            'ACTIVE', v_now, v_end_at, v_now, v_now
        );

        -- Update user entitlement quota
        INSERT INTO public.user_entitlements (
            id, user_id, entitlement_key, total_quota, used_quota, expires_at, created_at, updated_at
        ) VALUES (
            'ent_' || v_order.user_id || '_promote', v_order.user_id, 'PROMOTE_LISTING', 1, 1, v_end_at, v_now, v_now
        ) ON CONFLICT (user_id, entitlement_key) DO UPDATE SET
            total_quota = public.user_entitlements.total_quota + 1,
            used_quota = public.user_entitlements.used_quota + 1,
            expires_at = GREATEST(public.user_entitlements.expires_at, v_end_at),
            updated_at = v_now;
    END IF;

    -- 6. Generate Invoice
    v_invoice_num := 'INV-' || TO_CHAR(v_now, 'YYYYMMDD') || '-' || LPAD((FLOOR(RANDOM() * 9000) + 1000)::TEXT, 4, '0');
    v_subtotal_paise := v_order.amount_in_paise;
    v_tax_paise := ROUND(v_subtotal_paise * 0.18); -- 18% GST

    INSERT INTO public.invoices (
        invoice_number, user_id, order_id, subtotal_amount_in_paise,
        discount_amount_in_paise, tax_amount_gst_in_paise, total_paid_amount_in_paise,
        currency, paid_at
    ) VALUES (
        v_invoice_num, v_order.user_id, p_order_id, v_subtotal_paise,
        0, v_tax_paise, v_subtotal_paise, v_order.currency, v_now
    ) ON CONFLICT (invoice_number) DO NOTHING;

    -- 7. Audit Log
    INSERT INTO public.financial_audit_logs (
        actor_id, actor_role, action, entity_type, entity_id,
        previous_state, new_state, amount_in_paise, currency, reason, timestamp
    ) VALUES (
        COALESCE(p_actor_id, v_order.user_id), 'system', 'PAYMENT_CAPTURE_AND_ENTITLEMENT_GRANT',
        v_order.product_type, v_order.reference_entity_id, v_order.status, 'captured',
        v_order.amount_in_paise, v_order.currency, 'Verified Razorpay Payment & Activation', v_now
    );

    RETURN jsonb_build_object(
        'success', true,
        'order_id', p_order_id,
        'payment_id', p_payment_id,
        'status', 'captured',
        'invoice_number', v_invoice_num,
        'expires_at', v_end_at
    );
END;
$$;

