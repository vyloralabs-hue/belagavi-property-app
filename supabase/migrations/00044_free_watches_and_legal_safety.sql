-- ==============================================================================
-- MIGRATION 00044: FREE DISPUTE & LEGAL NOTICE WATCH PERSISTENCE & LEGAL SAFETY
-- Belagavi Property Marketplace
-- ==============================================================================

-- 1. Free Dispute Watch Table
CREATE TABLE IF NOT EXISTS public.dispute_watches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    dispute_id UUID NOT NULL REFERENCES public.dispute_listings(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_profile_dispute_watch UNIQUE (profile_id, dispute_id)
);

CREATE INDEX IF NOT EXISTS idx_dispute_watches_profile ON public.dispute_watches(profile_id);
CREATE INDEX IF NOT EXISTS idx_dispute_watches_dispute ON public.dispute_watches(dispute_id);

ALTER TABLE public.dispute_watches ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "dispute_watches_select_owner" ON public.dispute_watches;
CREATE POLICY "dispute_watches_select_owner" ON public.dispute_watches
    FOR SELECT TO authenticated
    USING (profile_id = public.get_current_profile_id() OR public.is_app_admin_or_founder());

DROP POLICY IF EXISTS "dispute_watches_insert_owner" ON public.dispute_watches;
CREATE POLICY "dispute_watches_insert_owner" ON public.dispute_watches
    FOR INSERT TO authenticated
    WITH CHECK (profile_id = public.get_current_profile_id());

DROP POLICY IF EXISTS "dispute_watches_delete_owner" ON public.dispute_watches;
CREATE POLICY "dispute_watches_delete_owner" ON public.dispute_watches
    FOR DELETE TO authenticated
    USING (profile_id = public.get_current_profile_id() OR public.is_app_admin_or_founder());


-- 2. Free Legal Notice Watch Table
CREATE TABLE IF NOT EXISTS public.legal_notice_watches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    notice_id UUID NOT NULL REFERENCES public.legal_notices(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_profile_notice_watch UNIQUE (profile_id, notice_id)
);

CREATE INDEX IF NOT EXISTS idx_legal_notice_watches_profile ON public.legal_notice_watches(profile_id);
CREATE INDEX IF NOT EXISTS idx_legal_notice_watches_notice ON public.legal_notice_watches(notice_id);

ALTER TABLE public.legal_notice_watches ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "legal_notice_watches_select_owner" ON public.legal_notice_watches;
CREATE POLICY "legal_notice_watches_select_owner" ON public.legal_notice_watches
    FOR SELECT TO authenticated
    USING (profile_id = public.get_current_profile_id() OR public.is_app_admin_or_founder());

DROP POLICY IF EXISTS "legal_notice_watches_insert_owner" ON public.legal_notice_watches;
CREATE POLICY "legal_notice_watches_insert_owner" ON public.legal_notice_watches
    FOR INSERT TO authenticated
    WITH CHECK (profile_id = public.get_current_profile_id());

DROP POLICY IF EXISTS "legal_notice_watches_delete_owner" ON public.legal_notice_watches;
CREATE POLICY "legal_notice_watches_delete_owner" ON public.legal_notice_watches
    FOR DELETE TO authenticated
    USING (profile_id = public.get_current_profile_id() OR public.is_app_admin_or_founder());

GRANT SELECT, INSERT, DELETE ON public.dispute_watches TO authenticated;
GRANT SELECT, INSERT, DELETE ON public.legal_notice_watches TO authenticated;


-- 3. Toggle Dispute Watch RPC (Free, Persistent, Safe)
CREATE OR REPLACE FUNCTION public.toggle_dispute_watch(
    p_dispute_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_profile_id UUID;
    v_exists BOOLEAN;
BEGIN
    v_profile_id := public.get_current_profile_id();
    IF v_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required.' USING ERRCODE = 'P0001';
    END IF;

    -- Ensure dispute exists and is published (or user is creator/admin)
    IF NOT EXISTS (
        SELECT 1 FROM public.dispute_listings
        WHERE id = p_dispute_id
        AND (status = 'published' OR creator_id = (auth.jwt()->>'sub') OR public.is_app_admin_or_founder())
    ) THEN
        RAISE EXCEPTION 'Dispute listing not accessible.' USING ERRCODE = 'P0004';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM public.dispute_watches
        WHERE profile_id = v_profile_id AND dispute_id = p_dispute_id
    ) INTO v_exists;

    IF v_exists THEN
        DELETE FROM public.dispute_watches
        WHERE profile_id = v_profile_id AND dispute_id = p_dispute_id;
        RETURN jsonb_build_object('success', TRUE, 'is_watching', FALSE, 'dispute_id', p_dispute_id);
    ELSE
        INSERT INTO public.dispute_watches (profile_id, dispute_id)
        VALUES (v_profile_id, p_dispute_id)
        ON CONFLICT (profile_id, dispute_id) DO NOTHING;
        RETURN jsonb_build_object('success', TRUE, 'is_watching', TRUE, 'dispute_id', p_dispute_id);
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- 4. Toggle Legal Notice Watch RPC (Free, Persistent, Safe)
CREATE OR REPLACE FUNCTION public.toggle_legal_notice_watch(
    p_notice_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_profile_id UUID;
    v_exists BOOLEAN;
BEGIN
    v_profile_id := public.get_current_profile_id();
    IF v_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required.' USING ERRCODE = 'P0001';
    END IF;

    -- Ensure notice exists and is published (or user is publisher/admin)
    IF NOT EXISTS (
        SELECT 1 FROM public.legal_notices
        WHERE id = p_notice_id
        AND (status = 'published' OR publisher_id = (auth.jwt()->>'sub') OR public.is_app_admin_or_founder())
    ) THEN
        RAISE EXCEPTION 'Legal notice not accessible.' USING ERRCODE = 'P0004';
    END IF;

    SELECT EXISTS (
        SELECT 1 FROM public.legal_notice_watches
        WHERE profile_id = v_profile_id AND notice_id = p_notice_id
    ) INTO v_exists;

    IF v_exists THEN
        DELETE FROM public.legal_notice_watches
        WHERE profile_id = v_profile_id AND notice_id = p_notice_id;
        RETURN jsonb_build_object('success', TRUE, 'is_watching', FALSE, 'notice_id', p_notice_id);
    ELSE
        INSERT INTO public.legal_notice_watches (profile_id, notice_id)
        VALUES (v_profile_id, p_notice_id)
        ON CONFLICT (profile_id, notice_id) DO NOTHING;
        RETURN jsonb_build_object('success', TRUE, 'is_watching', TRUE, 'notice_id', p_notice_id);
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.toggle_dispute_watch TO authenticated;
GRANT EXECUTE ON FUNCTION public.toggle_legal_notice_watch TO authenticated;


-- 5. Hardened verify_payment_and_grant
-- TASK 7 Fix: Payment MUST NOT set dispute is_verified = TRUE or claim proven.
-- It grants publication access only.
CREATE OR REPLACE FUNCTION public.verify_payment_and_grant(
    p_order_id TEXT,
    p_payment_id TEXT,
    p_signature TEXT DEFAULT NULL,
    p_raw_response JSONB DEFAULT '{}'::jsonb
)
RETURNS JSONB AS $$
DECLARE
    v_profile_id UUID;
    v_order RECORD;
    v_plan RECORD;
    v_grant_exists BOOLEAN;
    v_new_expires_at TIMESTAMPTZ;
BEGIN
    v_profile_id := public.get_current_profile_id();
    IF v_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required.'
            USING ERRCODE = 'P0001';
    END IF;

    -- HARDENED PRODUCTION SAFETY INVARIANT:
    -- Reject mock/fake payment signatures and synthetic mock payment IDs
    IF p_payment_id LIKE 'pay_mock_%' 
       OR p_signature = 'mock_signature' 
       OR p_payment_id IS NULL 
       OR trim(p_payment_id) = '' THEN
        RAISE EXCEPTION 'Test/Mock payment verification is strictly prohibited in production.'
            USING ERRCODE = 'P0009';
    END IF;

    -- Retrieve order
    SELECT * INTO v_order
    FROM public.payment_orders
    WHERE order_id = p_order_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Payment order % not found.', p_order_id
            USING ERRCODE = 'P0004';
    END IF;

    IF v_order.user_id != v_profile_id AND NOT public.is_app_admin_or_founder() THEN
        RAISE EXCEPTION 'Unauthorized order verification.'
            USING ERRCODE = 'P0003';
    END IF;

    -- Lookup plan
    SELECT * INTO v_plan
    FROM public.pricing_plans
    WHERE code = v_order.plan_code;

    -- Idempotency check: Already granted?
    SELECT EXISTS (
        SELECT 1 FROM public.payment_entitlement_grants
        WHERE order_id = p_order_id
    ) INTO v_grant_exists;

    IF v_grant_exists THEN
        RETURN jsonb_build_object(
            'success', TRUE,
            'status', 'already_granted',
            'order_id', p_order_id,
            'payment_id', p_payment_id,
            'plan_code', v_order.plan_code,
            'product_family', v_order.product_family
        );
    END IF;

    -- Record transaction
    INSERT INTO public.payment_transactions (
        order_id,
        payment_id,
        provider_name,
        amount_in_paise,
        currency,
        status,
        signature,
        raw_response
    ) VALUES (
        p_order_id,
        p_payment_id,
        'razorpay',
        v_order.amount_in_paise,
        v_order.currency,
        'paid',
        p_signature,
        p_raw_response
    ) ON CONFLICT (payment_id) DO NOTHING;

    -- Update order status
    UPDATE public.payment_orders
    SET status = 'paid',
        updated_at = NOW()
    WHERE order_id = p_order_id;

    -- Calculate expiry timestamp based on validity days
    v_new_expires_at := NOW() + (v_plan.validity_days || ' days')::INTERVAL;

    -- Activate product family capability
    IF v_plan.product_family IN ('property_watch', 'survey_monitoring', 'buyer_unlock') THEN
        INSERT INTO public.user_entitlements (
            user_id,
            entitlement_key,
            total_quota,
            used_quota,
            expires_at,
            updated_at
        ) VALUES (
            v_profile_id::text,
            v_plan.product_family,
            v_plan.credit_count,
            0,
            v_new_expires_at,
            NOW()
        ) ON CONFLICT (user_id, entitlement_key) DO UPDATE
        SET total_quota = public.user_entitlements.total_quota + EXCLUDED.total_quota,
            expires_at = GREATEST(public.user_entitlements.expires_at, EXCLUDED.expires_at),
            updated_at = NOW();

    ELSIF v_plan.product_family IN ('residential_listing', 'commercial_listing') THEN
        IF v_order.target_id IS NOT NULL AND TRIM(v_order.target_id) != '' THEN
            UPDATE public.properties
            SET status = 'active',
                is_paused = FALSE,
                listing_access_type = CASE WHEN v_plan.product_family = 'commercial_listing' THEN 'commercial_paid' ELSE 'residential_paid' END,
                listing_expires_at = GREATEST(COALESCE(listing_expires_at, NOW()), NOW()) + (v_plan.validity_days || ' days')::INTERVAL,
                active_plan_id = v_plan.code,
                updated_at = NOW()
            WHERE id::text = v_order.target_id;
        END IF;

    ELSIF v_plan.product_family = 'legal_notice_publication' THEN
        IF v_order.target_id IS NOT NULL AND TRIM(v_order.target_id) != '' THEN
            UPDATE public.legal_notices
            SET status = 'published',
                published_at = NOW(),
                public_until = NOW() + (v_plan.validity_days || ' days')::INTERVAL,
                active_plan_id = v_plan.code,
                updated_at = NOW()
            WHERE id::text = v_order.target_id;
        END IF;

    ELSIF v_plan.product_family = 'dispute_publication' THEN
        -- Task 7 Compliance: Payment grants publication access, NOT legal verification or court truth
        IF v_order.target_id IS NOT NULL AND TRIM(v_order.target_id) != '' THEN
            UPDATE public.dispute_listings
            SET status = 'published',
                published_at = NOW(),
                public_until = NOW() + (v_plan.validity_days || ' days')::INTERVAL,
                active_plan_id = v_plan.code,
                updated_at = NOW()
            WHERE id::text = v_order.target_id;
        END IF;
    END IF;

    -- Insert immutable entitlement grant record
    INSERT INTO public.payment_entitlement_grants (
        order_id,
        user_id,
        plan_code,
        target_id,
        valid_from,
        valid_until,
        granted_capabilities
    ) VALUES (
        p_order_id,
        v_profile_id,
        v_order.plan_code,
        v_order.target_id,
        NOW(),
        v_new_expires_at,
        v_plan.capabilities
    );

    RETURN jsonb_build_object(
        'success', TRUE,
        'status', 'granted',
        'order_id', p_order_id,
        'payment_id', p_payment_id,
        'plan_code', v_order.plan_code,
        'product_family', v_order.product_family,
        'expires_at', v_new_expires_at
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.verify_payment_and_grant TO authenticated;
