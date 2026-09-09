-- ==============================================================================
-- Migration 00032: Enforce Database-Layer Protection on Promotion & Feature Fields
-- Project: Belagavi Property (PropertyHub)
-- Target:
--   1. Protect server-authoritative monetization columns:
--      is_featured, promotion_active, promotion_ends_at, promotion_tier
--   2. Enforce via a BEFORE UPDATE trigger on public.properties
--   3. Reject mutations by regular owners/users unless executed by admin, founder,
--      or service_role / backend billing worker.
-- ==============================================================================

BEGIN;

CREATE OR REPLACE FUNCTION public.check_property_promotion_fields_security()
RETURNS TRIGGER AS $$
DECLARE
    v_role TEXT;
    v_claims JSONB;
BEGIN
    -- Check if any server-authoritative promotion or featured flags are modified
    IF (NEW.is_featured IS DISTINCT FROM OLD.is_featured OR
        NEW.promotion_active IS DISTINCT FROM OLD.promotion_active OR
        NEW.promotion_ends_at IS DISTINCT FROM OLD.promotion_ends_at OR
        NEW.promotion_tier IS DISTINCT FROM OLD.promotion_tier) THEN
        
        -- Inspect PostgREST request claims
        BEGIN
            v_claims := current_setting('request.jwt.claims', true)::jsonb;
        EXCEPTION WHEN OTHERS THEN
            v_claims := NULL;
        END;

        -- 1. Direct DB maintenance (CLI / migration) outside of HTTP PostgREST JWT context
        IF session_user = 'postgres' AND v_claims IS NULL THEN
            RETURN NEW;
        END IF;

        -- 2. Service role authorization (backend webhook / billing worker)
        BEGIN
            v_role := auth.role();
        EXCEPTION WHEN OTHERS THEN
            v_role := NULL;
        END;

        IF v_role = 'service_role' OR (v_claims->>'role') = 'service_role' THEN
            RETURN NEW;
        END IF;

        -- 3. App Admin or Founder authorization
        IF public.is_app_admin_or_founder() THEN
            RETURN NEW;
        END IF;

        -- 4. Reject all other callers
        RAISE EXCEPTION 'Access Denied: Only administrators or billing services may alter property promotion attributes (is_featured, promotion_active, promotion_ends_at, promotion_tier).';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_protect_property_promotion_fields ON public.properties;

CREATE TRIGGER trg_protect_property_promotion_fields
    BEFORE UPDATE ON public.properties
    FOR EACH ROW
    EXECUTE FUNCTION public.check_property_promotion_fields_security();

COMMIT;
