-- ==============================================================================
-- Migration 00041: Privacy Protection, Commercial Day-1 Enforcement & Residential Lifecycle
-- Project: Belagavi Property (PropertyHub)
-- PostgreSQL DB enum listing_status: ('draft', 'pending_verification', 'active', 'rejected', 'sold', 'archived')
-- PostgreSQL DB enum property_type: corresponds to the column "type" in properties
-- ==============================================================================

-- 1. SERVER-AUTHORITATIVE RESIDENTIAL & COMMERCIAL LIFECYCLE TRIGGER
CREATE OR REPLACE FUNCTION public.enforce_property_lifecycle_and_commercial_guard()
RETURNS TRIGGER AS $$
DECLARE
    v_is_commercial BOOLEAN;
    v_has_entitlement BOOLEAN := FALSE;
BEGIN
    -- Super admins and founders bypass commercial entitlement checks
    IF public.is_app_admin_or_founder() THEN
        RETURN NEW;
    END IF;

    -- Existing grandfathered listings remain completely immune
    IF OLD IS NOT NULL AND OLD.is_grandfathered IS TRUE THEN
        NEW.is_grandfathered := TRUE;
        NEW.listing_access_type := 'grandfathered';
        RETURN NEW;
    END IF;

    -- Detect if property is commercial/industrial
    v_is_commercial := (
        NEW.category::text IN ('commercial', 'industrial') OR
        NEW.type::text IN (
            'commercial_plot', 'commercial_office', 'commercial_shop', 
            'commercial_showroom', 'warehouse', 'warehouse_godown', 'industrial_land'
        )
    );

    -- On INSERT of a new listing
    IF TG_OP = 'INSERT' THEN
        -- All newly created listings must NOT be grandfathered
        NEW.is_grandfathered := FALSE;

        IF v_is_commercial THEN
            NEW.listing_access_type := 'commercial_paid';
            NEW.free_listing_expires_at := NULL;
            -- If user attempts to create directly as active without payment, reject
            IF NEW.status::text = 'active' THEN
                -- Check if owner has active commercial entitlement
                SELECT EXISTS (
                    SELECT 1 FROM public.user_entitlements
                    WHERE user_id = NEW.owner_id::text
                    AND entitlement_key IN ('commercial_listing', 'commercial_30d', 'commercial_90d', 'commercial_365d')
                    AND (expires_at IS NULL OR expires_at > NOW())
                    AND total_quota > used_quota
                ) INTO v_has_entitlement;

                IF NOT v_has_entitlement THEN
                    RAISE EXCEPTION 'Active commercial listing plan required to publish commercial properties. Listing cannot be published without entitlement.'
                        USING ERRCODE = 'P0002';
                END IF;
            END IF;
        ELSE
            -- Residential / Non-commercial: 15 days free
            NEW.listing_access_type := 'free_residential';
            NEW.listing_access_started_at := NOW();
            NEW.free_listing_expires_at := NOW() + INTERVAL '15 days';
            IF NEW.listing_expires_at IS NULL THEN
                NEW.listing_expires_at := NEW.free_listing_expires_at;
            END IF;
        END IF;

    -- On UPDATE of an existing listing
    ELSIF TG_OP = 'UPDATE' THEN
        -- Prevent tampering with grandfathered status
        IF OLD.is_grandfathered IS FALSE THEN
            NEW.is_grandfathered := FALSE;
        END IF;

        -- If attempting to transition commercial listing to active
        IF v_is_commercial AND (NEW.status::text = 'active') AND (OLD.status::text != 'active') THEN
            
            -- Check if owner has active commercial entitlement
            SELECT EXISTS (
                SELECT 1 FROM public.user_entitlements
                WHERE user_id = NEW.owner_id::text
                AND entitlement_key IN ('commercial_listing', 'commercial_30d', 'commercial_90d', 'commercial_365d')
                AND (expires_at IS NULL OR expires_at > NOW())
                AND total_quota > used_quota
            ) INTO v_has_entitlement;

            IF NOT v_has_entitlement THEN
                RAISE EXCEPTION 'Commercial properties require an active paid commercial plan from day 1. Direct publish denied.'
                    USING ERRCODE = 'P0002';
            END IF;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS trg_enforce_property_lifecycle_and_commercial ON public.properties;
CREATE TRIGGER trg_enforce_property_lifecycle_and_commercial
    BEFORE INSERT OR UPDATE ON public.properties
    FOR EACH ROW
    EXECUTE FUNCTION public.enforce_property_lifecycle_and_commercial_guard();


-- 2. PUBLIC SAFE VIEW (Eliminates raw address, house number, and private phone/email for public buyers)
CREATE OR REPLACE VIEW public.properties_public AS
SELECT 
    p.id,
    p.owner_id,
    p.title,
    p.description,
    p.category,
    p.type,
    p.status,
    p.verification_status,
    p.price,
    p.is_negotiable,
    p.super_built_up_area,
    p.carpet_area,
    p.plot_area,
    p.area_unit,
    p.bedrooms,
    p.bathrooms,
    p.balconies,
    p.floor_number,
    p.total_floors,
    p.furnishing_status,
    p.state,
    p.district,
    p.taluk,
    p.city,
    p.locality,
    -- PROTECTED LOCATION: Exact address & pincode masked
    ''::text AS address,
    ''::character varying AS pincode,
    -- Approximate coordinates (rounded to 2 decimals)
    CASE 
        WHEN p.latitude IS NOT NULL THEN ROUND(p.latitude::numeric, 2)::double precision
        ELSE NULL 
    END AS latitude,
    CASE 
        WHEN p.longitude IS NOT NULL THEN ROUND(p.longitude::numeric, 2)::double precision
        ELSE NULL 
    END AS longitude,
    p.views_count,
    -- SANITIZED FEATURES: Remove phone, whatsapp, email, exact address
    (p.features - 'ownerPhone' - 'ownerEmail' - 'ownerWhatsApp' - 'exactAddress' - 'privateDocuments') AS features,
    p.created_at,
    p.updated_at,
    p.is_paused,
    p.is_featured,
    p.promotion_active,
    p.promotion_ends_at,
    p.promotion_tier,
    p.listing_access_type,
    p.listing_access_started_at,
    p.free_listing_expires_at,
    p.is_grandfathered,
    p.listing_expires_at,
    p.active_plan_id
FROM public.properties p
WHERE (
    -- Public visibility rule: active, not paused, and not expired (unless grandfathered)
    p.status = 'active'
    AND p.is_paused = FALSE
    AND (
        p.is_grandfathered IS TRUE 
        OR p.listing_expires_at IS NULL 
        OR p.listing_expires_at > NOW()
    )
);

-- Grant select on public-safe view to anon and authenticated
GRANT SELECT ON public.properties_public TO anon, authenticated;


-- 3. SECURE AUTHORITATIVE FUNCTION: get_public_properties
CREATE OR REPLACE FUNCTION public.get_public_properties(
    p_category TEXT DEFAULT NULL,
    p_type TEXT DEFAULT NULL,
    p_city TEXT DEFAULT NULL,
    p_locality TEXT DEFAULT NULL,
    p_min_price NUMERIC DEFAULT NULL,
    p_max_price NUMERIC DEFAULT NULL,
    p_limit INT DEFAULT 20,
    p_offset INT DEFAULT 0
)
RETURNS SETOF public.properties_public AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM public.properties_public
    WHERE (p_category IS NULL OR category::text = p_category)
      AND (p_type IS NULL OR type::text = p_type)
      AND (p_city IS NULL OR LOWER(city) = LOWER(p_city))
      AND (p_locality IS NULL OR LOWER(locality) = LOWER(p_locality))
      AND (p_min_price IS NULL OR price >= p_min_price)
      AND (p_max_price IS NULL OR price <= p_max_price)
    ORDER BY is_featured DESC, updated_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;

GRANT EXECUTE ON FUNCTION public.get_public_properties TO anon, authenticated;


-- 4. SECURE AUTHORITATIVE FUNCTION: get_property_by_id_safe
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
    v_is_owner BOOLEAN := FALSE;
    v_is_admin BOOLEAN := FALSE;
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

    -- Check if owner
    IF v_caller_sub IS NOT NULL THEN
        SELECT EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = v_prop.owner_id
            AND profiles.firebase_uid = v_caller_sub
        ) INTO v_is_owner;
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

    -- If owner or admin, return FULL details
    IF v_is_owner OR v_is_admin THEN
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
