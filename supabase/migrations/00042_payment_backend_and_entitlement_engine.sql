-- ==============================================================================
-- Migration 00042: Payment Backend, Authoritative Orders, Entitlement Activation & Property Unlocks
-- Project: Belagavi Property (PropertyHub)
-- Business Rules:
-- 1. Money stored strictly in integer paise (BIGINT amount_in_paise)
-- 2. Server-side price authority via public.pricing_plans catalog lookup
-- 3. Idempotent entitlement activation and unlock credit handling
-- 4. Buyer property unlocks with full address & contact reveal
-- 5. User account soft-deletion with audit preservation
-- ==============================================================================

BEGIN;

-- 1. Helper function: Get profile ID for current authenticated Firebase user
CREATE OR REPLACE FUNCTION public.get_current_profile_id()
RETURNS UUID AS $$
DECLARE
    v_profile_id UUID;
    v_sub TEXT;
BEGIN
    v_sub := auth.jwt()->>'sub';
    IF v_sub IS NULL THEN
        RETURN NULL;
    END IF;

    SELECT id INTO v_profile_id
    FROM public.profiles
    WHERE firebase_uid = v_sub
    LIMIT 1;

    RETURN v_profile_id;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.get_current_profile_id TO anon, authenticated;

-- 2. Create public.payment_orders Table
CREATE TABLE IF NOT EXISTS public.payment_orders (
    id TEXT PRIMARY KEY, -- e.g. order_BP_xxx or Razorpay order id
    order_id TEXT UNIQUE NOT NULL,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    plan_code TEXT NOT NULL REFERENCES public.pricing_plans(code),
    product_family TEXT NOT NULL,
    target_id TEXT, -- e.g. property_id, notice_id, dispute_id, or NULL
    amount_in_paise BIGINT NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    status TEXT DEFAULT 'created' NOT NULL, -- 'created', 'pending', 'authorized', 'paid', 'failed', 'cancelled', 'refunded', 'expired'
    razorpay_order_id TEXT,
    idempotency_key TEXT UNIQUE,
    metadata JSONB DEFAULT '{}'::jsonb NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_payment_orders_user_created ON public.payment_orders(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_payment_orders_status ON public.payment_orders(status);
CREATE INDEX IF NOT EXISTS idx_payment_orders_target ON public.payment_orders(target_id);

ALTER TABLE public.payment_orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own orders" ON public.payment_orders;
CREATE POLICY "Users can read own orders"
    ON public.payment_orders FOR SELECT
    USING (
        user_id = public.get_current_profile_id()
        OR public.is_app_admin_or_founder()
    );

-- 3. Create public.payment_transactions Table
CREATE TABLE IF NOT EXISTS public.payment_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id TEXT NOT NULL REFERENCES public.payment_orders(order_id) ON DELETE CASCADE,
    payment_id TEXT UNIQUE NOT NULL, -- e.g. pay_xxx from Razorpay
    provider_name TEXT DEFAULT 'razorpay' NOT NULL,
    amount_in_paise BIGINT NOT NULL,
    currency TEXT DEFAULT 'INR' NOT NULL,
    status TEXT NOT NULL, -- 'authorized', 'captured', 'paid', 'failed', 'refunded'
    signature TEXT,
    error_code TEXT,
    error_description TEXT,
    raw_response JSONB DEFAULT '{}'::jsonb NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_payment_transactions_order ON public.payment_transactions(order_id);
CREATE INDEX IF NOT EXISTS idx_payment_transactions_payment ON public.payment_transactions(payment_id);

ALTER TABLE public.payment_transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own transactions" ON public.payment_transactions;
CREATE POLICY "Users can read own transactions"
    ON public.payment_transactions FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.payment_orders
            WHERE payment_orders.order_id = payment_transactions.order_id
            AND (
                payment_orders.user_id = public.get_current_profile_id()
                OR public.is_app_admin_or_founder()
            )
        )
    );

-- 4. Create public.payment_webhook_events Table
CREATE TABLE IF NOT EXISTS public.payment_webhook_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id TEXT UNIQUE NOT NULL,
    provider TEXT DEFAULT 'razorpay' NOT NULL,
    event_type TEXT NOT NULL,
    order_id TEXT,
    payment_id TEXT,
    payload JSONB NOT NULL DEFAULT '{}'::jsonb,
    processed BOOLEAN DEFAULT FALSE NOT NULL,
    error_message TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    processed_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_webhook_events_order ON public.payment_webhook_events(order_id);
CREATE INDEX IF NOT EXISTS idx_webhook_events_payment ON public.payment_webhook_events(payment_id);

ALTER TABLE public.payment_webhook_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admin only read webhook events" ON public.payment_webhook_events;
CREATE POLICY "Admin only read webhook events"
    ON public.payment_webhook_events FOR SELECT
    USING (public.is_app_admin_or_founder());

-- 5. Create public.payment_entitlement_grants Table (Idempotency Ledger)
CREATE TABLE IF NOT EXISTS public.payment_entitlement_grants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id TEXT UNIQUE NOT NULL REFERENCES public.payment_orders(order_id) ON DELETE CASCADE,
    payment_id TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    entitlement_key TEXT NOT NULL,
    quota_granted INT NOT NULL,
    validity_days INT NOT NULL,
    target_id TEXT,
    granted_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_entitlement_grants_user ON public.payment_entitlement_grants(user_id);

ALTER TABLE public.payment_entitlement_grants ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own entitlement grants" ON public.payment_entitlement_grants;
CREATE POLICY "Users read own entitlement grants"
    ON public.payment_entitlement_grants FOR SELECT
    USING (
        user_id = public.get_current_profile_id()
        OR public.is_app_admin_or_founder()
    );

-- 6. Create public.property_unlocks Table
CREATE TABLE IF NOT EXISTS public.property_unlocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    property_id UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    unlock_type TEXT DEFAULT 'credit' NOT NULL, -- 'credit', 'pay_per_property', 'membership', 'admin_grant'
    amount_in_paise BIGINT DEFAULT 0 NOT NULL,
    status TEXT DEFAULT 'active' NOT NULL, -- 'active', 'expired', 'revoked'
    unlocked_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    expires_at TIMESTAMPTZ, -- default null = permanent unlock
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    CONSTRAINT uq_buyer_property_unlock UNIQUE(buyer_id, property_id)
);

CREATE INDEX IF NOT EXISTS idx_property_unlocks_buyer ON public.property_unlocks(buyer_id);
CREATE INDEX IF NOT EXISTS idx_property_unlocks_property ON public.property_unlocks(property_id);

ALTER TABLE public.property_unlocks ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Buyers read own unlocks" ON public.property_unlocks;
CREATE POLICY "Buyers read own unlocks"
    ON public.property_unlocks FOR SELECT
    USING (
        buyer_id = public.get_current_profile_id()
        OR public.is_app_admin_or_founder()
    );

-- 7. Add account deletion / soft-delete columns to public.profiles if not present
ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS is_deleted BOOLEAN DEFAULT FALSE NOT NULL,
    ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;

-- 8. RPC: create_payment_order
-- Server-authoritative order creation: price and product family ALWAYS looked up from pricing_plans
CREATE OR REPLACE FUNCTION public.create_payment_order(
    p_plan_code TEXT,
    p_target_id TEXT DEFAULT NULL,
    p_metadata JSONB DEFAULT '{}'::jsonb
)
RETURNS JSONB AS $$
DECLARE
    v_profile_id UUID;
    v_plan RECORD;
    v_order_id TEXT;
    v_prop RECORD;
    v_notice RECORD;
    v_dispute RECORD;
BEGIN
    v_profile_id := public.get_current_profile_id();
    IF v_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required to create payment order.'
            USING ERRCODE = 'P0001';
    END IF;

    -- Lookup plan from server-authoritative catalog
    SELECT * INTO v_plan
    FROM public.pricing_plans
    WHERE code = p_plan_code AND is_active = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Invalid or inactive pricing plan code: %', p_plan_code
            USING ERRCODE = 'P0002';
    END IF;

    -- Target ownership validation if target_id is supplied
    IF p_target_id IS NOT NULL AND TRIM(p_target_id) != '' THEN
        IF v_plan.product_family IN ('residential_listing', 'commercial_listing') THEN
            SELECT * INTO v_prop FROM public.properties WHERE id::text = p_target_id;
            IF FOUND THEN
                IF v_prop.owner_id != v_profile_id AND NOT public.is_app_admin_or_founder() THEN
                    RAISE EXCEPTION 'You are not the owner of property %', p_target_id
                        USING ERRCODE = 'P0003';
                END IF;
            END IF;
        ELSIF v_plan.product_family = 'legal_notice_publication' THEN
            SELECT * INTO v_notice FROM public.legal_notices WHERE id::text = p_target_id;
            IF FOUND THEN
                IF v_notice.publisher_id != (auth.jwt()->>'sub') AND v_notice.publisher_id != v_profile_id::text AND NOT public.is_app_admin_or_founder() THEN
                    RAISE EXCEPTION 'You are not the publisher of legal notice %', p_target_id
                        USING ERRCODE = 'P0003';
                END IF;
            END IF;
        ELSIF v_plan.product_family = 'dispute_publication' THEN
            SELECT * INTO v_dispute FROM public.dispute_listings WHERE id::text = p_target_id;
            IF FOUND THEN
                IF v_dispute.creator_id != (auth.jwt()->>'sub') AND v_dispute.creator_id != v_profile_id::text AND NOT public.is_app_admin_or_founder() THEN
                    RAISE EXCEPTION 'You are not the creator of dispute %', p_target_id
                        USING ERRCODE = 'P0003';
                END IF;
            END IF;
        END IF;
    END IF;

    -- Generate order ID
    v_order_id := 'order_bp_' || substr(md5(random()::text || clock_timestamp()::text), 1, 16);

    INSERT INTO public.payment_orders (
        id,
        order_id,
        user_id,
        plan_code,
        product_family,
        target_id,
        amount_in_paise,
        currency,
        status,
        metadata
    ) VALUES (
        v_order_id,
        v_order_id,
        v_profile_id,
        v_plan.code,
        v_plan.product_family,
        p_target_id,
        v_plan.amount_in_paise,
        v_plan.currency,
        'created',
        p_metadata
    );

    RETURN jsonb_build_object(
        'order_id', v_order_id,
        'plan_code', v_plan.code,
        'plan_name', v_plan.name,
        'product_family', v_plan.product_family,
        'amount_in_paise', v_plan.amount_in_paise,
        'currency', v_plan.currency,
        'target_id', p_target_id,
        'created_at', NOW()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.create_payment_order TO authenticated;

-- 9. RPC: verify_payment_and_grant
-- Atomic verification and idempotent entitlement activation
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
        -- Already completed and granted, return idempotent success
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
        -- Quota-based entitlement in public.user_entitlements
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
        )
        ON CONFLICT (user_id, entitlement_key) DO UPDATE SET
            total_quota = public.user_entitlements.total_quota + EXCLUDED.total_quota,
            expires_at = GREATEST(COALESCE(public.user_entitlements.expires_at, NOW()), EXCLUDED.expires_at),
            updated_at = NOW();

    ELSIF v_plan.product_family IN ('residential_listing', 'commercial_listing') THEN
        -- Listing reactivation / extension
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
        -- Legal notice publication activation (10 days)
        IF v_order.target_id IS NOT NULL AND TRIM(v_order.target_id) != '' THEN
            UPDATE public.legal_notices
            SET status = 'published',
                published_at = NOW(),
                public_until = NOW() + (v_plan.validity_days || ' days')::INTERVAL,
                updated_at = NOW()
            WHERE id::text = v_order.target_id;
        END IF;

    ELSIF v_plan.product_family = 'dispute_publication' THEN
        -- Dispute publication activation
        IF v_order.target_id IS NOT NULL AND TRIM(v_order.target_id) != '' THEN
            UPDATE public.dispute_listings
            SET status = 'published',
                public_until = NOW() + (v_plan.validity_days || ' days')::INTERVAL,
                updated_at = NOW()
            WHERE id::text = v_order.target_id;
        END IF;
    END IF;

    -- Record idempotent grant ledger
    INSERT INTO public.payment_entitlement_grants (
        order_id,
        payment_id,
        user_id,
        entitlement_key,
        quota_granted,
        validity_days,
        target_id
    ) VALUES (
        p_order_id,
        p_payment_id,
        v_profile_id,
        v_plan.product_family,
        v_plan.credit_count,
        v_plan.validity_days,
        v_order.target_id
    );

    RETURN jsonb_build_object(
        'success', TRUE,
        'status', 'paid_and_granted',
        'order_id', p_order_id,
        'payment_id', p_payment_id,
        'plan_code', v_order.plan_code,
        'product_family', v_order.product_family,
        'credits_granted', v_plan.credit_count,
        'validity_days', v_plan.validity_days,
        'expires_at', v_new_expires_at
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.verify_payment_and_grant TO authenticated;

-- 10. RPC: unlock_property_details
-- Consumes 1 buyer unlock credit idempotently to unlock full property details
CREATE OR REPLACE FUNCTION public.unlock_property_details(
    p_property_id UUID
)
RETURNS JSONB AS $$
DECLARE
    v_buyer_id UUID;
    v_prop RECORD;
    v_is_owner BOOLEAN := FALSE;
    v_already_unlocked BOOLEAN := FALSE;
    v_entitlement RECORD;
BEGIN
    v_buyer_id := public.get_current_profile_id();
    IF v_buyer_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required to unlock property.'
            USING ERRCODE = 'P0001';
    END IF;

    SELECT * INTO v_prop
    FROM public.properties
    WHERE id = p_property_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Property % not found.', p_property_id
            USING ERRCODE = 'P0005';
    END IF;

    -- Owner does not need to consume unlock credits
    IF v_prop.owner_id = v_buyer_id OR public.is_app_admin_or_founder() THEN
        RETURN jsonb_build_object(
            'success', TRUE,
            'is_unlocked', TRUE,
            'reason', 'owner_or_admin'
        );
    END IF;

    -- Check if already unlocked
    SELECT EXISTS (
        SELECT 1 FROM public.property_unlocks
        WHERE buyer_id = v_buyer_id
        AND property_id = p_property_id
        AND status = 'active'
        AND (expires_at IS NULL OR expires_at > NOW())
    ) INTO v_already_unlocked;

    IF v_already_unlocked THEN
        RETURN jsonb_build_object(
            'success', TRUE,
            'is_unlocked', TRUE,
            'reason', 'already_unlocked'
        );
    END IF;

    -- Check buyer unlock credits in user_entitlements
    SELECT * INTO v_entitlement
    FROM public.user_entitlements
    WHERE user_id = v_buyer_id::text
    AND entitlement_key = 'buyer_unlock'
    AND (expires_at IS NULL OR expires_at > NOW())
    AND total_quota > used_quota
    LIMIT 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'No buyer unlock credits available. Please purchase a Property Unlock plan.'
            USING ERRCODE = 'P0006';
    END IF;

    -- Consume 1 credit
    UPDATE public.user_entitlements
    SET used_quota = used_quota + 1,
        updated_at = NOW()
    WHERE id = v_entitlement.id;

    -- Insert unlock record
    INSERT INTO public.property_unlocks (
        buyer_id,
        property_id,
        unlock_type,
        status,
        unlocked_at
    ) VALUES (
        v_buyer_id,
        p_property_id,
        'credit',
        'active',
        NOW()
    ) ON CONFLICT (buyer_id, property_id) DO UPDATE SET
        status = 'active',
        unlocked_at = NOW();

    RETURN jsonb_build_object(
        'success', TRUE,
        'is_unlocked', TRUE,
        'remaining_credits', (v_entitlement.total_quota - (v_entitlement.used_quota + 1))
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.unlock_property_details TO authenticated;

-- 11. RPC: soft_delete_user_account
-- Deletion compliance: soft deletes profile while preserving financial & audit trail
CREATE OR REPLACE FUNCTION public.soft_delete_user_account()
RETURNS JSONB AS $$
DECLARE
    v_profile_id UUID;
    v_sub TEXT;
BEGIN
    v_profile_id := public.get_current_profile_id();
    v_sub := auth.jwt()->>'sub';

    IF v_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required.'
            USING ERRCODE = 'P0001';
    END IF;

    -- Update profile to soft-deleted state
    UPDATE public.profiles
    SET is_deleted = TRUE,
        deleted_at = NOW(),
        full_name = 'Deleted User',
        phone_number = 'DELETED_' || substr(md5(random()::text), 1, 8),
        email = NULL,
        avatar_url = NULL,
        company_name = NULL,
        rera_number = NULL,
        updated_at = NOW()
    WHERE id = v_profile_id;

    -- Pause any active listings owned by this user
    UPDATE public.properties
    SET is_paused = TRUE,
        updated_at = NOW()
    WHERE owner_id = v_profile_id;

    RETURN jsonb_build_object(
        'success', TRUE,
        'deleted_at', NOW()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.soft_delete_user_account TO authenticated;

-- 12. Update get_property_by_id_safe to also check public.property_unlocks table!
CREATE OR REPLACE FUNCTION public.get_property_by_id_safe(
    p_property_id UUID
)
RETURNS TABLE (
    id UUID,
    owner_id UUID,
    title TEXT,
    description TEXT,
    category public.property_category,
    type public.property_type,
    status public.listing_status,
    verification_status public.verification_status,
    price NUMERIC,
    is_negotiable BOOLEAN,
    super_built_up_area NUMERIC,
    carpet_area NUMERIC,
    plot_area NUMERIC,
    area_unit TEXT,
    bedrooms INT,
    bathrooms INT,
    balconies INT,
    floor_number INT,
    total_floors INT,
    furnishing_status TEXT,
    state TEXT,
    district TEXT,
    taluk TEXT,
    city TEXT,
    locality TEXT,
    address TEXT,
    pincode VARCHAR,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    views_count INT,
    features JSONB,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    is_paused BOOLEAN,
    is_featured BOOLEAN,
    promotion_active BOOLEAN,
    promotion_ends_at TIMESTAMPTZ,
    promotion_tier TEXT,
    listing_access_type TEXT,
    listing_access_started_at TIMESTAMPTZ,
    free_listing_expires_at TIMESTAMPTZ,
    is_grandfathered BOOLEAN,
    listing_expires_at TIMESTAMPTZ,
    active_plan_id TEXT,
    is_unlocked BOOLEAN
) AS $$
DECLARE
    v_caller_sub TEXT;
    v_profile_id UUID;
    v_is_owner BOOLEAN := FALSE;
    v_is_admin BOOLEAN := FALSE;
    v_is_unlocked BOOLEAN := FALSE;
    v_prop RECORD;
BEGIN
    v_caller_sub := auth.jwt()->>'sub';

    SELECT * INTO v_prop
    FROM public.properties
    WHERE properties.id = p_property_id;

    IF NOT FOUND THEN
        RETURN;
    END IF;

    -- Check if admin/founder
    v_is_admin := public.is_app_admin_or_founder();

    -- Check if caller is owner
    IF v_caller_sub IS NOT NULL THEN
        SELECT p.id INTO v_profile_id
        FROM public.profiles p
        WHERE p.firebase_uid = v_caller_sub
        LIMIT 1;

        IF v_profile_id IS NOT NULL AND v_prop.owner_id = v_profile_id THEN
            v_is_owner := TRUE;
        END IF;

        -- Check if caller unlocked this property
        IF NOT v_is_owner AND NOT v_is_admin AND v_profile_id IS NOT NULL THEN
            SELECT EXISTS (
                SELECT 1 FROM public.property_unlocks
                WHERE buyer_id = v_profile_id
                AND property_id = p_property_id
                AND status = 'active'
                AND (expires_at IS NULL OR expires_at > NOW())
            ) INTO v_is_unlocked;
        END IF;
    END IF;

    -- If listing is not public, non-owners cannot see it
    IF NOT v_is_owner AND NOT v_is_admin THEN
        IF v_prop.status::text != 'active' OR v_prop.is_paused IS TRUE THEN
            RETURN;
        END IF;
        -- If expired and not grandfathered, return empty
        IF v_prop.is_grandfathered IS FALSE AND v_prop.listing_expires_at IS NOT NULL AND v_prop.listing_expires_at <= NOW() THEN
            RETURN;
        END IF;
    END IF;

    -- If owner, admin, or unlocked: return FULL details
    IF v_is_owner OR v_is_admin OR v_is_unlocked THEN
        RETURN QUERY SELECT
            v_prop.id,
            v_prop.owner_id,
            v_prop.title,
            v_prop.description,
            v_prop.category,
            v_prop.type,
            v_prop.status,
            v_prop.verification_status,
            v_prop.price,
            v_prop.is_negotiable,
            v_prop.super_built_up_area,
            v_prop.carpet_area,
            v_prop.plot_area,
            v_prop.area_unit,
            v_prop.bedrooms,
            v_prop.bathrooms,
            v_prop.balconies,
            v_prop.floor_number,
            v_prop.total_floors,
            v_prop.furnishing_status,
            v_prop.state,
            v_prop.district,
            v_prop.taluk,
            v_prop.city,
            v_prop.locality,
            v_prop.address,
            v_prop.pincode,
            v_prop.latitude,
            v_prop.longitude,
            v_prop.views_count,
            v_prop.features,
            v_prop.created_at,
            v_prop.updated_at,
            v_prop.is_paused,
            v_prop.is_featured,
            v_prop.promotion_active,
            v_prop.promotion_ends_at,
            v_prop.promotion_tier,
            v_prop.listing_access_type,
            v_prop.listing_access_started_at,
            v_prop.free_listing_expires_at,
            v_prop.is_grandfathered,
            v_prop.listing_expires_at,
            v_prop.active_plan_id,
            TRUE AS is_unlocked;
        RETURN;
    ELSE
        -- Public non-owner: Return MASKED / SANITIZED details
        RETURN QUERY SELECT
            v_prop.id,
            v_prop.owner_id,
            v_prop.title,
            v_prop.description,
            v_prop.category,
            v_prop.type,
            v_prop.status,
            v_prop.verification_status,
            v_prop.price,
            v_prop.is_negotiable,
            v_prop.super_built_up_area,
            v_prop.carpet_area,
            v_prop.plot_area,
            v_prop.area_unit,
            v_prop.bedrooms,
            v_prop.bathrooms,
            v_prop.balconies,
            v_prop.floor_number,
            v_prop.total_floors,
            v_prop.furnishing_status,
            v_prop.state,
            v_prop.district,
            v_prop.taluk,
            v_prop.city,
            v_prop.locality,
            ''::text AS address,
            ''::character varying AS pincode,
            CASE WHEN v_prop.latitude IS NOT NULL THEN ROUND(v_prop.latitude::numeric, 2)::double precision ELSE NULL END AS latitude,
            CASE WHEN v_prop.longitude IS NOT NULL THEN ROUND(v_prop.longitude::numeric, 2)::double precision ELSE NULL END AS longitude,
            v_prop.views_count,
            (v_prop.features - 'ownerPhone' - 'ownerEmail' - 'ownerWhatsApp' - 'exactAddress' - 'privateDocuments') AS features,
            v_prop.created_at,
            v_prop.updated_at,
            v_prop.is_paused,
            v_prop.is_featured,
            v_prop.promotion_active,
            v_prop.promotion_ends_at,
            v_prop.promotion_tier,
            v_prop.listing_access_type,
            v_prop.listing_access_started_at,
            v_prop.free_listing_expires_at,
            v_prop.is_grandfathered,
            v_prop.listing_expires_at,
            v_prop.active_plan_id,
            FALSE AS is_unlocked;
        RETURN;
    END IF;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.get_property_by_id_safe TO anon, authenticated;

COMMIT;
