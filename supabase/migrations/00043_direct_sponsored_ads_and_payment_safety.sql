-- ==============================================================================
-- MIGRATION 00043: DIRECT SPONSORED ADS & PAYMENT SAFETY HARDENING
-- Belagavi Property Marketplace
-- ==============================================================================

-- 1. Create Advertisers Table
CREATE TABLE IF NOT EXISTS public.advertisers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    business_name TEXT NOT NULL,
    contact_person TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT NOT NULL,
    website_url TEXT,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 2. Create Ad Campaigns Table
CREATE TABLE IF NOT EXISTS public.ad_campaigns (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    advertiser_id UUID NOT NULL REFERENCES public.advertisers(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    placement TEXT NOT NULL CHECK (placement IN (
        'HOME_NATIVE_SPONSORED',
        'SEARCH_NATIVE_SPONSORED',
        'LOCALITY_BANNER',
        'CATEGORY_BANNER',
        'FEATURED_BUSINESS'
    )),
    target_city TEXT NOT NULL DEFAULT 'Belagavi',
    target_locality TEXT,
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    status TEXT NOT NULL DEFAULT 'SUBMITTED' CHECK (status IN (
        'DRAFT',
        'SUBMITTED',
        'APPROVED',
        'SCHEDULED',
        'ACTIVE',
        'PAUSED',
        'EXPIRED',
        'REJECTED',
        'ARCHIVED'
    )),
    rejection_reason TEXT,
    pricing_confirmed BOOLEAN NOT NULL DEFAULT FALSE,
    reviewed_by UUID REFERENCES public.profiles(id),
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 3. Create Ad Creatives Table
CREATE TABLE IF NOT EXISTS public.ad_creatives (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    campaign_id UUID NOT NULL REFERENCES public.ad_campaigns(id) ON DELETE CASCADE,
    headline TEXT NOT NULL,
    body_text TEXT,
    image_url TEXT NOT NULL,
    cta_text TEXT NOT NULL DEFAULT 'Contact Business',
    action_type TEXT NOT NULL DEFAULT 'URL' CHECK (action_type IN ('URL', 'CALL', 'WHATSAPP')),
    action_value TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 4. Create Ad Impressions Table
CREATE TABLE IF NOT EXISTS public.ad_impressions (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campaign_id UUID NOT NULL REFERENCES public.ad_campaigns(id) ON DELETE CASCADE,
    placement TEXT NOT NULL,
    user_id UUID REFERENCES public.profiles(id),
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 5. Create Ad Clicks Table
CREATE TABLE IF NOT EXISTS public.ad_clicks (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    campaign_id UUID NOT NULL REFERENCES public.ad_campaigns(id) ON DELETE CASCADE,
    placement TEXT NOT NULL,
    user_id UUID REFERENCES public.profiles(id),
    recorded_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for fast ad serving & reporting
CREATE INDEX IF NOT EXISTS idx_ad_campaigns_serving 
    ON public.ad_campaigns(placement, status, start_date, end_date);

CREATE INDEX IF NOT EXISTS idx_ad_campaigns_user 
    ON public.ad_campaigns(user_id);

CREATE INDEX IF NOT EXISTS idx_ad_impressions_campaign 
    ON public.ad_impressions(campaign_id, recorded_at);

CREATE INDEX IF NOT EXISTS idx_ad_clicks_campaign 
    ON public.ad_clicks(campaign_id, recorded_at);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS)
-- ==============================================================================

ALTER TABLE public.advertisers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ad_campaigns ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ad_creatives ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ad_impressions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ad_clicks ENABLE ROW LEVEL SECURITY;

-- Advertisers RLS
DROP POLICY IF EXISTS "advertisers_select_owner_or_admin" ON public.advertisers;
CREATE POLICY "advertisers_select_owner_or_admin" ON public.advertisers
    FOR SELECT TO authenticated
    USING (user_id = public.get_current_profile_id() OR public.is_app_admin_or_founder());

DROP POLICY IF EXISTS "advertisers_insert_owner" ON public.advertisers;
CREATE POLICY "advertisers_insert_owner" ON public.advertisers
    FOR INSERT TO authenticated
    WITH CHECK (user_id = public.get_current_profile_id());

DROP POLICY IF EXISTS "advertisers_update_owner_or_admin" ON public.advertisers;
CREATE POLICY "advertisers_update_owner_or_admin" ON public.advertisers
    FOR UPDATE TO authenticated
    USING (user_id = public.get_current_profile_id() OR public.is_app_admin_or_founder());

-- Ad Campaigns RLS
DROP POLICY IF EXISTS "ad_campaigns_public_active_select" ON public.ad_campaigns;
CREATE POLICY "ad_campaigns_public_active_select" ON public.ad_campaigns
    FOR SELECT TO anon, authenticated
    USING (
        (status = 'ACTIVE' AND start_date <= NOW() AND end_date >= NOW())
        OR user_id = public.get_current_profile_id()
        OR public.is_app_admin_or_founder()
    );

DROP POLICY IF EXISTS "ad_campaigns_insert_owner" ON public.ad_campaigns;
CREATE POLICY "ad_campaigns_insert_owner" ON public.ad_campaigns
    FOR INSERT TO authenticated
    WITH CHECK (
        user_id = public.get_current_profile_id() 
        AND status IN ('DRAFT', 'SUBMITTED')
    );

DROP POLICY IF EXISTS "ad_campaigns_update_owner" ON public.ad_campaigns;
CREATE POLICY "ad_campaigns_update_owner" ON public.ad_campaigns
    FOR UPDATE TO authenticated
    USING (
        user_id = public.get_current_profile_id() 
        OR public.is_app_admin_or_founder()
    )
    WITH CHECK (
        public.is_app_admin_or_founder()
        OR (
            user_id = public.get_current_profile_id()
            AND status IN ('DRAFT', 'SUBMITTED', 'PAUSED')
        )
    );

-- Ad Creatives RLS
DROP POLICY IF EXISTS "ad_creatives_public_select" ON public.ad_creatives;
CREATE POLICY "ad_creatives_public_select" ON public.ad_creatives
    FOR SELECT TO anon, authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.ad_campaigns c
            WHERE c.id = campaign_id
            AND (
                (c.status = 'ACTIVE' AND c.start_date <= NOW() AND c.end_date >= NOW())
                OR c.user_id = public.get_current_profile_id()
                OR public.is_app_admin_or_founder()
            )
        )
    );

DROP POLICY IF EXISTS "ad_creatives_insert_owner" ON public.ad_creatives;
CREATE POLICY "ad_creatives_insert_owner" ON public.ad_creatives
    FOR INSERT TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.ad_campaigns c
            WHERE c.id = campaign_id
            AND (c.user_id = public.get_current_profile_id() OR public.is_app_admin_or_founder())
        )
    );

-- Impressions & Clicks Logging RLS
DROP POLICY IF EXISTS "ad_impressions_insert_open" ON public.ad_impressions;
CREATE POLICY "ad_impressions_insert_open" ON public.ad_impressions
    FOR INSERT TO anon, authenticated
    WITH CHECK (TRUE);

DROP POLICY IF EXISTS "ad_impressions_select_owner_or_admin" ON public.ad_impressions;
CREATE POLICY "ad_impressions_select_owner_or_admin" ON public.ad_impressions
    FOR SELECT TO authenticated
    USING (
        public.is_app_admin_or_founder()
        OR EXISTS (
            SELECT 1 FROM public.ad_campaigns c
            WHERE c.id = campaign_id AND c.user_id = public.get_current_profile_id()
        )
    );

DROP POLICY IF EXISTS "ad_clicks_insert_open" ON public.ad_clicks;
CREATE POLICY "ad_clicks_insert_open" ON public.ad_clicks
    FOR INSERT TO anon, authenticated
    WITH CHECK (TRUE);

DROP POLICY IF EXISTS "ad_clicks_select_owner_or_admin" ON public.ad_clicks;
CREATE POLICY "ad_clicks_select_owner_or_admin" ON public.ad_clicks
    FOR SELECT TO authenticated
    USING (
        public.is_app_admin_or_founder()
        OR EXISTS (
            SELECT 1 FROM public.ad_campaigns c
            WHERE c.id = campaign_id AND c.user_id = public.get_current_profile_id()
        )
    );

-- ==============================================================================
-- DATABASE FUNCTIONS & RPCS
-- ==============================================================================

-- Submit Advertiser & Campaign flow atomically
CREATE OR REPLACE FUNCTION public.submit_direct_ad_campaign(
    p_business_name TEXT,
    p_contact_person TEXT,
    p_email TEXT,
    p_phone TEXT,
    p_website_url TEXT,
    p_title TEXT,
    p_description TEXT,
    p_placement TEXT,
    p_target_locality TEXT,
    p_start_date TIMESTAMPTZ,
    p_end_date TIMESTAMPTZ,
    p_headline TEXT,
    p_body_text TEXT,
    p_image_url TEXT,
    p_cta_text TEXT,
    p_action_type TEXT,
    p_action_value TEXT
)
RETURNS JSONB AS $$
DECLARE
    v_profile_id UUID;
    v_advertiser_id UUID;
    v_campaign_id UUID;
BEGIN
    v_profile_id := public.get_current_profile_id();
    IF v_profile_id IS NULL THEN
        RAISE EXCEPTION 'Authentication required to submit advertising campaign.'
            USING ERRCODE = 'P0001';
    END IF;

    -- Upsert advertiser record for this profile
    SELECT id INTO v_advertiser_id
    FROM public.advertisers
    WHERE user_id = v_profile_id
    LIMIT 1;

    IF v_advertiser_id IS NULL THEN
        INSERT INTO public.advertisers (
            user_id,
            business_name,
            contact_person,
            email,
            phone,
            website_url
        ) VALUES (
            v_profile_id,
            p_business_name,
            p_contact_person,
            p_email,
            p_phone,
            p_website_url
        ) RETURNING id INTO v_advertiser_id;
    ELSE
        UPDATE public.advertisers
        SET business_name = p_business_name,
            contact_person = p_contact_person,
            email = p_email,
            phone = p_phone,
            website_url = p_website_url,
            updated_at = NOW()
        WHERE id = v_advertiser_id;
    END IF;

    -- Create Campaign in SUBMITTED status (never self-approved)
    INSERT INTO public.ad_campaigns (
        advertiser_id,
        user_id,
        title,
        description,
        placement,
        target_city,
        target_locality,
        start_date,
        end_date,
        status
    ) VALUES (
        v_advertiser_id,
        v_profile_id,
        p_title,
        p_description,
        p_placement,
        'Belagavi',
        p_target_locality,
        p_start_date,
        p_end_date,
        'SUBMITTED'
    ) RETURNING id INTO v_campaign_id;

    -- Create Creative
    INSERT INTO public.ad_creatives (
        campaign_id,
        headline,
        body_text,
        image_url,
        cta_text,
        action_type,
        action_value
    ) VALUES (
        v_campaign_id,
        p_headline,
        p_body_text,
        p_image_url,
        p_cta_text,
        p_action_type,
        p_action_value
    );

    RETURN jsonb_build_object(
        'success', TRUE,
        'campaign_id', v_campaign_id,
        'status', 'SUBMITTED',
        'message', 'Campaign submitted for admin review successfully.'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Admin Moderation of Ad Campaign
CREATE OR REPLACE FUNCTION public.admin_moderate_ad_campaign(
    p_campaign_id UUID,
    p_action TEXT, -- 'APPROVE', 'REJECT', 'PAUSE', 'RESUME', 'ARCHIVE'
    p_reason TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_profile_id UUID;
    v_target_status TEXT;
BEGIN
    IF NOT public.is_app_admin_or_founder() THEN
        RAISE EXCEPTION 'Unauthorized: Only administrator or founder can moderate campaigns.'
            USING ERRCODE = 'P0003';
    END IF;

    v_profile_id := public.get_current_profile_id();

    CASE p_action
        WHEN 'APPROVE' THEN
            v_target_status := 'ACTIVE';
        WHEN 'REJECT' THEN
            v_target_status := 'REJECTED';
        WHEN 'PAUSE' THEN
            v_target_status := 'PAUSED';
        WHEN 'RESUME' THEN
            v_target_status := 'ACTIVE';
        WHEN 'ARCHIVE' THEN
            v_target_status := 'ARCHIVED';
        ELSE
            RAISE EXCEPTION 'Invalid moderation action: %', p_action
                USING ERRCODE = 'P0002';
    END CASE;

    UPDATE public.ad_campaigns
    SET status = v_target_status,
        rejection_reason = CASE WHEN p_action = 'REJECT' THEN p_reason ELSE rejection_reason END,
        reviewed_by = v_profile_id,
        reviewed_at = NOW(),
        updated_at = NOW()
    WHERE id = p_campaign_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Campaign % not found.', p_campaign_id
            USING ERRCODE = 'P0004';
    END IF;

    RETURN jsonb_build_object(
        'success', TRUE,
        'campaign_id', p_campaign_id,
        'status', v_target_status,
        'action', p_action
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Record Impression
CREATE OR REPLACE FUNCTION public.record_ad_impression(
    p_campaign_id UUID,
    p_placement TEXT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.ad_impressions (campaign_id, placement, user_id)
    VALUES (p_campaign_id, p_placement, public.get_current_profile_id());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Record Click
CREATE OR REPLACE FUNCTION public.record_ad_click(
    p_campaign_id UUID,
    p_placement TEXT
)
RETURNS VOID AS $$
BEGIN
    INSERT INTO public.ad_clicks (campaign_id, placement, user_id)
    VALUES (p_campaign_id, p_placement, public.get_current_profile_id());
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Get Active Direct Ads for a Placement
CREATE OR REPLACE FUNCTION public.get_active_direct_ads(
    p_placement TEXT,
    p_locality TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_ads JSONB;
BEGIN
    SELECT jsonb_agg(
        jsonb_build_object(
            'id', c.id,
            'title', c.title,
            'description', c.description,
            'placement', c.placement,
            'target_city', c.target_city,
            'target_locality', c.target_locality,
            'start_date', c.start_date,
            'end_date', c.end_date,
            'status', c.status,
            'business_name', a.business_name,
            'contact_phone', a.phone,
            'website_url', a.website_url,
            'headline', cr.headline,
            'body_text', cr.body_text,
            'image_url', cr.image_url,
            'cta_text', cr.cta_text,
            'action_type', cr.action_type,
            'action_value', cr.action_value
        )
    ) INTO v_ads
    FROM public.ad_campaigns c
    JOIN public.advertisers a ON a.id = c.advertiser_id
    JOIN public.ad_creatives cr ON cr.campaign_id = c.id
    WHERE c.placement = p_placement
      AND c.status = 'ACTIVE'
      AND c.start_date <= NOW()
      AND c.end_date >= NOW()
      AND (
          p_locality IS NULL 
          OR c.target_locality IS NULL 
          OR LOWER(c.target_locality) = LOWER(p_locality)
      )
    ORDER BY c.created_at DESC
    LIMIT 5;

    RETURN COALESCE(v_ads, '[]'::jsonb);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Get Admin Ad Campaigns with Metrics
CREATE OR REPLACE FUNCTION public.get_admin_ad_campaigns(
    p_filter_status TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    v_result JSONB;
BEGIN
    IF NOT public.is_app_admin_or_founder() THEN
        RAISE EXCEPTION 'Unauthorized.' USING ERRCODE = 'P0003';
    END IF;

    SELECT jsonb_agg(
        jsonb_build_object(
            'id', c.id,
            'title', c.title,
            'description', c.description,
            'placement', c.placement,
            'target_locality', c.target_locality,
            'start_date', c.start_date,
            'end_date', c.end_date,
            'status', c.status,
            'rejection_reason', c.rejection_reason,
            'created_at', c.created_at,
            'business_name', a.business_name,
            'contact_person', a.contact_person,
            'email', a.email,
            'phone', a.phone,
            'headline', cr.headline,
            'image_url', cr.image_url,
            'cta_text', cr.cta_text,
            'action_type', cr.action_type,
            'action_value', cr.action_value,
            'impressions', COALESCE(imp.total_impressions, 0),
            'clicks', COALESCE(clk.total_clicks, 0),
            'ctr', CASE 
                WHEN COALESCE(imp.total_impressions, 0) > 0 
                THEN ROUND((COALESCE(clk.total_clicks, 0)::NUMERIC / imp.total_impressions::NUMERIC) * 100, 2)
                ELSE 0.0
            END
        )
    ) INTO v_result
    FROM public.ad_campaigns c
    JOIN public.advertisers a ON a.id = c.advertiser_id
    LEFT JOIN public.ad_creatives cr ON cr.campaign_id = c.id
    LEFT JOIN (
        SELECT campaign_id, COUNT(*) AS total_impressions 
        FROM public.ad_impressions 
        GROUP BY campaign_id
    ) imp ON imp.campaign_id = c.id
    LEFT JOIN (
        SELECT campaign_id, COUNT(*) AS total_clicks 
        FROM public.ad_clicks 
        GROUP BY campaign_id
    ) clk ON clk.campaign_id = c.id
    WHERE (p_filter_status IS NULL OR c.status = p_filter_status)
    ORDER BY c.created_at DESC;

    RETURN COALESCE(v_result, '[]'::jsonb);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- ==============================================================================
-- PAYMENT SAFETY HARDENING
-- Update verify_payment_and_grant to strictly reject mock/fake payments in production
-- ==============================================================================

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
            quota_limit,
            quota_used,
            expires_at
        ) VALUES (
            v_profile_id,
            v_plan.product_family,
            v_plan.credit_count,
            0,
            v_new_expires_at
        ) ON CONFLICT (user_id, entitlement_key) DO UPDATE
        SET quota_limit = public.user_entitlements.quota_limit + EXCLUDED.quota_limit,
            expires_at = GREATEST(public.user_entitlements.expires_at, EXCLUDED.expires_at),
            updated_at = NOW();

    ELSIF v_plan.product_family IN ('residential_listing', 'commercial_listing') THEN
        IF v_order.target_id IS NOT NULL THEN
            UPDATE public.properties
            SET status = 'active',
                listing_access_type = 'paid',
                listing_access_started_at = NOW(),
                expires_at = v_new_expires_at,
                updated_at = NOW()
            WHERE id = v_order.target_id::UUID;
        END IF;

    ELSIF v_plan.product_family = 'legal_notice_publication' THEN
        IF v_order.target_id IS NOT NULL THEN
            UPDATE public.property_legal_notices
            SET status = 'active',
                is_published = TRUE,
                published_at = NOW(),
                expires_at = v_new_expires_at,
                updated_at = NOW()
            WHERE id = v_order.target_id::UUID;
        END IF;

    ELSIF v_plan.product_family = 'dispute_publication' THEN
        IF v_order.target_id IS NOT NULL THEN
            UPDATE public.disputed_properties
            SET status = 'active',
                is_verified = TRUE,
                expires_at = v_new_expires_at,
                updated_at = NOW()
            WHERE id = v_order.target_id::UUID;
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

-- Grant permissions on new RPCs
GRANT EXECUTE ON FUNCTION public.submit_direct_ad_campaign TO authenticated;
GRANT EXECUTE ON FUNCTION public.admin_moderate_ad_campaign TO authenticated;
GRANT EXECUTE ON FUNCTION public.record_ad_impression TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.record_ad_click TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_active_direct_ads TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.get_admin_ad_campaigns TO authenticated;
GRANT EXECUTE ON FUNCTION public.verify_payment_and_grant TO authenticated;
