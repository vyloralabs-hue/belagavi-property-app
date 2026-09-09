CREATE OR REPLACE FUNCTION public.check_property_watch_entitlement_trigger()
RETURNS TRIGGER AS $$
DECLARE
    v_entitlement_id TEXT;
    v_total_quota INT;
    v_used_quota INT;
    v_expires_at TIMESTAMPTZ;
    v_caller_jwt_sub TEXT;
    v_profile_owner_fb TEXT;
BEGIN
    -- 1. Caller verification: Malicious client defense
    -- Ensure current caller is either super admin OR owns the profile_id
    v_caller_jwt_sub := auth.jwt()->>'sub';
    
    IF v_caller_jwt_sub IS NOT NULL AND NOT public.is_app_admin_or_founder() THEN
        SELECT firebase_uid INTO v_profile_owner_fb 
        FROM public.profiles 
        WHERE id = NEW.profile_id;

        IF v_profile_owner_fb IS NULL OR v_profile_owner_fb != v_caller_jwt_sub THEN
            RAISE EXCEPTION 'Authorization failure: You cannot create a property watch for another profile.'
                USING ERRCODE = '42501';
        END IF;
    END IF;

    -- 2. Super admins / founders bypass quota
    IF public.is_app_admin_or_founder() THEN
        NEW.normalized_identity := public.normalize_survey_identity(
            NEW.country, NEW.state, NEW.district, NEW.taluk, 
            NEW.city_or_village, NEW.locality, NEW.survey_number, NEW.subdivision_number
        );
        RETURN NEW;
    END IF;

    -- 3. Look up active unexpired entitlement with remaining quota
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

    -- 4. Consume one quota slot
    UPDATE public.user_entitlements
    SET used_quota = used_quota + 1,
        updated_at = NOW()
    WHERE id = v_entitlement_id;

    -- 5. Calculate normalized identity
    NEW.normalized_identity := public.normalize_survey_identity(
        NEW.country, NEW.state, NEW.district, NEW.taluk, 
        NEW.city_or_village, NEW.locality, NEW.survey_number, NEW.subdivision_number
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
