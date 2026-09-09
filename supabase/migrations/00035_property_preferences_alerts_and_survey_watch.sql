-- ==============================================================================
-- Migration 00035: Property Preferences, Saved Requirements, Alert Matches & Paid Property Watches
-- Project: Belagavi Property (PropertyHub)
-- Description:
--   1. Property Preferences Profile & Personalization table
--   2. Saved Property Requirements & Deterministic Match Alerts table
--   3. Property Alert Matches table with unique constraint duplicate prevention
--   4. Paid Property / Survey Monitoring table with Contextual Hierarchy & Subdivision preservation
--   5. Server-Authoritative Database Guard Trigger: Enforces active paid entitlement from user_entitlements
--   6. Property Watch Events table with public-only records & neutral phrasing
--   7. Canonical Survey Normalization and Match Score Evaluation functions
--   8. Hardened RLS policies linked via Firebase UID (auth.jwt()->>'sub')
-- ==============================================================================

BEGIN;

-- 1. Helper function for Survey Normalization
CREATE OR REPLACE FUNCTION public.normalize_survey_identity(
    p_country TEXT,
    p_state TEXT,
    p_district TEXT,
    p_taluk TEXT,
    p_city_village TEXT,
    p_locality TEXT,
    p_survey_number TEXT,
    p_subdivision TEXT
)
RETURNS TEXT AS $$
DECLARE
    v_c TEXT := UPPER(TRIM(COALESCE(p_country, 'IND')));
    v_s TEXT := UPPER(TRIM(COALESCE(p_state, 'KA')));
    v_d TEXT := UPPER(TRIM(COALESCE(p_district, 'BELAGAVI')));
    v_t TEXT := UPPER(TRIM(COALESCE(p_taluk, 'BELAGAVI')));
    v_cv TEXT := UPPER(TRIM(COALESCE(p_city_village, 'BELAGAVI')));
    v_loc TEXT := UPPER(TRIM(COALESCE(p_locality, 'GENERAL')));
    v_surv TEXT := UPPER(REGEXP_REPLACE(TRIM(COALESCE(p_survey_number, '')), '\s+', '', 'g'));
    v_sub TEXT := UPPER(REGEXP_REPLACE(TRIM(COALESCE(p_subdivision, '')), '\s+', '', 'g'));
    v_combined_survey TEXT;
BEGIN
    IF v_surv = '' THEN
        v_surv := 'UNSPECIFIED';
    END IF;

    IF v_sub != '' AND v_sub IS NOT NULL THEN
        -- Preserve subdivision with forward slash
        IF v_surv LIKE '%/%' THEN
            v_combined_survey := v_surv;
        ELSE
            v_combined_survey := v_surv || '/' || v_sub;
        END IF;
    ELSE
        v_combined_survey := v_surv;
    END IF;

    RETURN v_c || ':' || v_s || ':' || v_d || ':' || v_t || ':' || v_cv || ':' || v_loc || ':' || v_combined_survey;
END;
$$ LANGUAGE plpgsql IMMUTABLE;


-- 2. Property Preferences Profile Table
CREATE TABLE IF NOT EXISTS public.property_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    purpose TEXT NOT NULL DEFAULT 'buy', -- 'buy', 'rent', 'lease', 'investment'
    category TEXT NOT NULL DEFAULT 'residential', -- 'residential', 'commercial', 'plotLand', 'land'
    state TEXT NOT NULL DEFAULT 'Karnataka',
    district TEXT NOT NULL DEFAULT 'Belagavi',
    taluk TEXT NOT NULL DEFAULT 'Belagavi',
    preferred_localities TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    min_budget NUMERIC(15, 2),
    max_budget NUMERIC(15, 2),
    min_bedrooms INT,
    max_bedrooms INT,
    min_area NUMERIC(10, 2),
    max_area NUMERIC(10, 2),
    area_unit TEXT NOT NULL DEFAULT 'sqft',
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_profile_preference UNIQUE (profile_id)
);

CREATE INDEX IF NOT EXISTS idx_property_preferences_profile ON public.property_preferences(profile_id);
CREATE INDEX IF NOT EXISTS idx_property_preferences_active ON public.property_preferences(is_active);

ALTER TABLE public.property_preferences ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own preferences" ON public.property_preferences;
CREATE POLICY "Users can read own preferences"
    ON public.property_preferences FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = property_preferences.profile_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

DROP POLICY IF EXISTS "Users can insert own preferences" ON public.property_preferences;
CREATE POLICY "Users can insert own preferences"
    ON public.property_preferences FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = property_preferences.profile_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

DROP POLICY IF EXISTS "Users can update own preferences" ON public.property_preferences;
CREATE POLICY "Users can update own preferences"
    ON public.property_preferences FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = property_preferences.profile_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = property_preferences.profile_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

DROP POLICY IF EXISTS "Users can delete own preferences" ON public.property_preferences;
CREATE POLICY "Users can delete own preferences"
    ON public.property_preferences FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = property_preferences.profile_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );


-- 3. Saved Property Requirements Table
CREATE TABLE IF NOT EXISTS public.saved_property_requirements (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    purpose TEXT NOT NULL DEFAULT 'buy', -- 'buy', 'rent', 'lease'
    category TEXT NOT NULL DEFAULT 'residential', -- 'residential', 'commercial', 'plotLand', 'land'
    state TEXT NOT NULL DEFAULT 'Karnataka',
    district TEXT NOT NULL DEFAULT 'Belagavi',
    taluk TEXT NOT NULL DEFAULT 'Belagavi',
    preferred_localities TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
    min_budget NUMERIC(15, 2) NOT NULL,
    max_budget NUMERIC(15, 2) NOT NULL,
    price_tolerance_percent NUMERIC(5, 2) NOT NULL DEFAULT 10.00, -- e.g. 5.00, 10.00, 20.00
    min_bedrooms INT,
    max_bedrooms INT,
    min_area NUMERIC(10, 2),
    max_area NUMERIC(10, 2),
    alert_frequency TEXT NOT NULL DEFAULT 'instant', -- 'instant', 'daily', 'weekly'
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_saved_requirements_profile ON public.saved_property_requirements(profile_id);
CREATE INDEX IF NOT EXISTS idx_saved_requirements_active ON public.saved_property_requirements(is_active);

ALTER TABLE public.saved_property_requirements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own requirements" ON public.saved_property_requirements;
CREATE POLICY "Users can read own requirements"
    ON public.saved_property_requirements FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = saved_property_requirements.profile_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

DROP POLICY IF EXISTS "Users can insert own requirements" ON public.saved_property_requirements;
CREATE POLICY "Users can insert own requirements"
    ON public.saved_property_requirements FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = saved_property_requirements.profile_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

DROP POLICY IF EXISTS "Users can update own requirements" ON public.saved_property_requirements;
CREATE POLICY "Users can update own requirements"
    ON public.saved_property_requirements FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = saved_property_requirements.profile_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = saved_property_requirements.profile_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

DROP POLICY IF EXISTS "Users can delete own requirements" ON public.saved_property_requirements;
CREATE POLICY "Users can delete own requirements"
    ON public.saved_property_requirements FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = saved_property_requirements.profile_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );


-- 4. Property Alert Matches Table (with unique constraint for duplicate prevention)
CREATE TABLE IF NOT EXISTS public.property_alert_matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    saved_requirement_id UUID NOT NULL REFERENCES public.saved_property_requirements(id) ON DELETE CASCADE,
    property_id UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    match_score INT NOT NULL DEFAULT 100, -- 0 to 100
    match_reasons JSONB NOT NULL DEFAULT '[]'::jsonb,
    is_viewed BOOLEAN NOT NULL DEFAULT false,
    notified_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_saved_req_property UNIQUE (saved_requirement_id, property_id)
);

CREATE INDEX IF NOT EXISTS idx_alert_matches_req ON public.property_alert_matches(saved_requirement_id);
CREATE INDEX IF NOT EXISTS idx_alert_matches_prop ON public.property_alert_matches(property_id);
CREATE INDEX IF NOT EXISTS idx_alert_matches_score ON public.property_alert_matches(match_score DESC);

ALTER TABLE public.property_alert_matches ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own alert matches" ON public.property_alert_matches;
CREATE POLICY "Users can read own alert matches"
    ON public.property_alert_matches FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.saved_property_requirements req
            JOIN public.profiles prof ON prof.id = req.profile_id
            WHERE req.id = property_alert_matches.saved_requirement_id
            AND prof.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

DROP POLICY IF EXISTS "Users can update own alert matches read status" ON public.property_alert_matches;
CREATE POLICY "Users can update own alert matches read status"
    ON public.property_alert_matches FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.saved_property_requirements req
            JOIN public.profiles prof ON prof.id = req.profile_id
            WHERE req.id = property_alert_matches.saved_requirement_id
            AND prof.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.saved_property_requirements req
            JOIN public.profiles prof ON prof.id = req.profile_id
            WHERE req.id = property_alert_matches.saved_requirement_id
            AND prof.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

DROP POLICY IF EXISTS "Authenticated users or system can insert alert matches" ON public.property_alert_matches;
CREATE POLICY "Authenticated users or system can insert alert matches"
    ON public.property_alert_matches FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.saved_property_requirements req
            JOIN public.profiles prof ON prof.id = req.profile_id
            WHERE req.id = property_alert_matches.saved_requirement_id
            AND prof.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );


-- 5. Paid Property / Survey Monitoring Table
CREATE TABLE IF NOT EXISTS public.property_watches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    watch_name TEXT NOT NULL,
    relationship_type TEXT NOT NULL DEFAULT 'prospective_buyer', -- 'owner', 'prospective_buyer', 'neighbor', 'investor', 'legal_counsel'
    
    -- Contextual Identity Hierarchy
    country TEXT NOT NULL DEFAULT 'India',
    state TEXT NOT NULL DEFAULT 'Karnataka',
    district TEXT NOT NULL DEFAULT 'Belagavi',
    taluk TEXT NOT NULL DEFAULT 'Belagavi',
    city_or_village TEXT NOT NULL DEFAULT 'Belagavi',
    locality TEXT NOT NULL,
    survey_number TEXT NOT NULL,
    subdivision_number TEXT,
    normalized_identity TEXT NOT NULL,
    
    property_id UUID REFERENCES public.properties(id) ON DELETE SET NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_profile_watch_identity UNIQUE (profile_id, normalized_identity)
);

CREATE INDEX IF NOT EXISTS idx_property_watches_profile ON public.property_watches(profile_id);
CREATE INDEX IF NOT EXISTS idx_property_watches_norm_id ON public.property_watches(normalized_identity);
CREATE INDEX IF NOT EXISTS idx_property_watches_active ON public.property_watches(is_active);

ALTER TABLE public.property_watches ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own property watches" ON public.property_watches;
CREATE POLICY "Users can read own property watches"
    ON public.property_watches FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = property_watches.profile_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

DROP POLICY IF EXISTS "Users can insert own property watches" ON public.property_watches;
CREATE POLICY "Users can insert own property watches"
    ON public.property_watches FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = property_watches.profile_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

DROP POLICY IF EXISTS "Users can update own property watches" ON public.property_watches;
CREATE POLICY "Users can update own property watches"
    ON public.property_watches FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = property_watches.profile_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = property_watches.profile_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

DROP POLICY IF EXISTS "Users can delete own property watches" ON public.property_watches;
CREATE POLICY "Users can delete own property watches"
    ON public.property_watches FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = property_watches.profile_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );


-- 5b. User Entitlements Table (Authoritative Quota Storage)
CREATE TABLE IF NOT EXISTS public.user_entitlements (
    id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::text,
    user_id TEXT NOT NULL,
    entitlement_key TEXT NOT NULL,
    total_quota INT NOT NULL DEFAULT 0,
    used_quota INT NOT NULL DEFAULT 0,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_user_entitlement UNIQUE(user_id, entitlement_key)
);

CREATE INDEX IF NOT EXISTS idx_entitlements_user_key ON public.user_entitlements(user_id, entitlement_key);

ALTER TABLE public.user_entitlements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users read own entitlements" ON public.user_entitlements;
CREATE POLICY "Users read own entitlements"
    ON public.user_entitlements FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id::text = user_entitlements.user_id
            AND profiles.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

DROP POLICY IF EXISTS "Admin only modify entitlements" ON public.user_entitlements;
CREATE POLICY "Admin only modify entitlements"
    ON public.user_entitlements FOR ALL
    USING (
        public.is_app_admin_or_founder()
    )
    WITH CHECK (
        public.is_app_admin_or_founder()
    );


-- 6. Server-Authoritative Paid Entitlement Guard Trigger for Property Watches
CREATE OR REPLACE FUNCTION public.check_property_watch_entitlement_trigger()
RETURNS TRIGGER AS $$
DECLARE
    v_entitlement_id TEXT;
    v_total_quota INT;
    v_used_quota INT;
    v_expires_at TIMESTAMPTZ;
BEGIN
    -- Super admins / founders bypass quota
    IF public.is_app_admin_or_founder() THEN
        -- Normalize identity before save
        NEW.normalized_identity := public.normalize_survey_identity(
            NEW.country, NEW.state, NEW.district, NEW.taluk, 
            NEW.city_or_village, NEW.locality, NEW.survey_number, NEW.subdivision_number
        );
        RETURN NEW;
    END IF;

    -- Look up active unexpired entitlement with remaining quota
    SELECT id, total_quota, used_quota, expires_at
    INTO v_entitlement_id, v_total_quota, v_used_quota, v_expires_at
    FROM public.user_entitlements
    WHERE user_id = NEW.profile_id::text
    AND entitlement_key IN ('property_watch', 'survey_monitoring')
    AND (expires_at IS NULL OR expires_at > NOW())
    AND total_quota > used_quota
    LIMIT 1;

    IF v_entitlement_id IS NULL THEN
        RAISE EXCEPTION 'Active paid entitlement required for property or survey monitoring. Please upgrade to a monitoring pack.'
            USING ERRCODE = 'P0001';
    END IF;

    -- Consume one quota slot
    UPDATE public.user_entitlements
    SET used_quota = used_quota + 1,
        updated_at = NOW()
    WHERE id = v_entitlement_id;

    -- Calculate normalized identity
    NEW.normalized_identity := public.normalize_survey_identity(
        NEW.country, NEW.state, NEW.district, NEW.taluk, 
        NEW.city_or_village, NEW.locality, NEW.survey_number, NEW.subdivision_number
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS trg_check_property_watch_entitlement ON public.property_watches;
CREATE TRIGGER trg_check_property_watch_entitlement
    BEFORE INSERT ON public.property_watches
    FOR EACH ROW
    EXECUTE FUNCTION public.check_property_watch_entitlement_trigger();


-- Trigger to restore entitlement quota upon watch deletion
CREATE OR REPLACE FUNCTION public.restore_property_watch_entitlement_trigger()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.user_entitlements
    SET used_quota = GREATEST(0, used_quota - 1),
        updated_at = NOW()
    WHERE user_id = OLD.profile_id::text
    AND entitlement_key IN ('property_watch', 'survey_monitoring')
    AND used_quota > 0;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS trg_restore_property_watch_entitlement ON public.property_watches;
CREATE TRIGGER trg_restore_property_watch_entitlement
    AFTER DELETE ON public.property_watches
    FOR EACH ROW
    EXECUTE FUNCTION public.restore_property_watch_entitlement_trigger();


-- 7. Property Watch Events Table (Strictly Neutral Language, Public Records Only)
CREATE TABLE IF NOT EXISTS public.property_watch_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    watch_id UUID NOT NULL REFERENCES public.property_watches(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL, -- 'public_listing_created', 'public_notice_published', 'public_dispute_published', 'status_changed', 'price_updated'
    title TEXT NOT NULL, -- Neutral: "Public record update observed for monitored property"
    description TEXT NOT NULL, -- Neutral factual note
    source_type TEXT NOT NULL, -- 'property', 'legal_notice', 'dispute_listing'
    source_id TEXT,
    visibility TEXT NOT NULL DEFAULT 'public_record',
    event_time TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_watch_events_watch ON public.property_watch_events(watch_id);
CREATE INDEX IF NOT EXISTS idx_watch_events_time ON public.property_watch_events(event_time DESC);

ALTER TABLE public.property_watch_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can read own watch events" ON public.property_watch_events;
CREATE POLICY "Users can read own watch events"
    ON public.property_watch_events FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.property_watches pw
            JOIN public.profiles prof ON prof.id = pw.profile_id
            WHERE pw.id = property_watch_events.watch_id
            AND prof.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );

DROP POLICY IF EXISTS "System or admin can create watch events" ON public.property_watch_events;
CREATE POLICY "System or admin can create watch events"
    ON public.property_watch_events FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.property_watches pw
            JOIN public.profiles prof ON prof.id = pw.profile_id
            WHERE pw.id = property_watch_events.watch_id
            AND prof.firebase_uid = (auth.jwt()->>'sub')
        )
        OR public.is_app_admin_or_founder()
    );


-- 8. Deterministic Property Match Score Evaluator Function
CREATE OR REPLACE FUNCTION public.calculate_property_match_score(
    p_requirement_id UUID,
    p_property_id UUID
)
RETURNS INT AS $$
DECLARE
    v_req RECORD;
    v_prop RECORD;
    v_score INT := 0;
    v_min_budget NUMERIC;
    v_max_budget NUMERIC;
    v_tol NUMERIC;
    v_tol_min NUMERIC;
    v_tol_max NUMERIC;
BEGIN
    SELECT * INTO v_req FROM public.saved_property_requirements WHERE id = p_requirement_id;
    IF NOT FOUND THEN RETURN 0; END IF;

    SELECT * INTO v_prop FROM public.properties WHERE id = p_property_id;
    IF NOT FOUND THEN RETURN 0; END IF;

    -- Only active properties can match
    IF v_prop.status::text NOT IN ('active', 'published') THEN
        RETURN 0;
    END IF;

    -- Category check
    IF LOWER(v_req.category) != LOWER(v_prop.category::text) THEN
        RETURN 0;
    END IF;

    -- District check
    IF LOWER(TRIM(v_req.district)) != LOWER(TRIM(v_prop.district)) THEN
        RETURN 0;
    END IF;

    -- Pricing Score with Tolerance
    v_min_budget := v_req.min_budget;
    v_max_budget := v_req.max_budget;
    v_tol := COALESCE(v_req.price_tolerance_percent, 10.00) / 100.00;
    v_tol_min := v_min_budget * (1.00 - v_tol);
    v_tol_max := v_max_budget * (1.00 + v_tol);

    IF v_prop.price >= v_min_budget AND v_prop.price <= v_max_budget THEN
        v_score := v_score + 40; -- Perfect budget match
    ELSIF v_prop.price >= v_tol_min AND v_prop.price <= v_tol_max THEN
        v_score := v_score + 25; -- Within tolerance
    ELSE
        RETURN 0; -- Outside allowable tolerance band
    END IF;

    -- Locality Score
    IF v_req.preferred_localities IS NOT NULL AND array_length(v_req.preferred_localities, 1) > 0 THEN
        IF v_prop.locality = ANY(v_req.preferred_localities) THEN
            v_score := v_score + 30; -- Exact preferred locality
        ELSIF LOWER(TRIM(v_req.taluk)) = LOWER(TRIM(v_prop.taluk)) THEN
            v_score := v_score + 15; -- Same taluk
        END IF;
    ELSE
        v_score := v_score + 30; -- No locality restriction
    END IF;

    -- Bedrooms Match (if specified)
    IF v_req.min_bedrooms IS NOT NULL AND v_prop.bedrooms IS NOT NULL THEN
        IF v_prop.bedrooms >= v_req.min_bedrooms AND (v_req.max_bedrooms IS NULL OR v_prop.bedrooms <= v_req.max_bedrooms) THEN
            v_score := v_score + 15;
        END IF;
    ELSE
        v_score := v_score + 15;
    END IF;

    -- Area Match (if specified)
    IF v_req.min_area IS NOT NULL THEN
        DECLARE
            v_prop_area NUMERIC := COALESCE(v_prop.carpet_area, v_prop.super_built_up_area, v_prop.plot_area);
        BEGIN
            IF v_prop_area IS NOT NULL AND v_prop_area >= v_req.min_area AND (v_req.max_area IS NULL OR v_prop_area <= v_req.max_area) THEN
                v_score := v_score + 15;
            END IF;
        END;
    ELSE
        v_score := v_score + 15;
    END IF;

    RETURN LEAST(100, v_score);
END;
$$ LANGUAGE plpgsql STABLE;

COMMIT;
