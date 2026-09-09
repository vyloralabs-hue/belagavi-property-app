-- ==============================================================================
-- 00039_business_access_and_privacy_structure.sql
-- ADDITIVE BUSINESS ACCESS, LISTING LIFECYCLE & PRIVACY STRUCTURE
-- Belagavi Property Production Architecture
-- ==============================================================================

-- 1. Add listing lifecycle & access columns to public.properties
ALTER TABLE public.properties
    ADD COLUMN IF NOT EXISTS listing_access_type TEXT NOT NULL DEFAULT 'free_residential',
    ADD COLUMN IF NOT EXISTS listing_access_started_at TIMESTAMPTZ DEFAULT NOW(),
    ADD COLUMN IF NOT EXISTS free_listing_expires_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS is_grandfathered BOOLEAN NOT NULL DEFAULT true;

-- 2. Ensure all existing historical properties are safely grandfathered so no existing
-- listings are locked or disrupted by the new business access rules.
UPDATE public.properties
SET is_grandfathered = true,
    listing_access_type = 'grandfathered'
WHERE is_grandfathered IS TRUE OR is_grandfathered IS NULL;

-- 3. Add constraint on listing_access_type values
ALTER TABLE public.properties
    DROP CONSTRAINT IF EXISTS chk_properties_listing_access_type;

ALTER TABLE public.properties
    ADD CONSTRAINT chk_properties_listing_access_type
    CHECK (listing_access_type IN ('free_residential', 'commercial_paid', 'grandfathered'));

-- 4. Create performance index for listing access lifecycle checks
CREATE INDEX IF NOT EXISTS idx_properties_access_lifecycle
    ON public.properties(listing_access_type, free_listing_expires_at)
    WHERE status = 'active';

-- 5. Comment on columns for schema documentation
COMMENT ON COLUMN public.properties.listing_access_type IS 'Access classification: free_residential (15 days free window), commercial_paid (paid from day 1), or grandfathered (prior to policy)';
COMMENT ON COLUMN public.properties.listing_access_started_at IS 'Timestamp when the listing access cycle began';
COMMENT ON COLUMN public.properties.free_listing_expires_at IS 'Expiration timestamp for the 15-day free residential listing window';
COMMENT ON COLUMN public.properties.is_grandfathered IS 'Flag indicating historical listings created before business access rules were enacted';
