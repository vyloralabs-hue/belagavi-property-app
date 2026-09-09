-- ==============================================================================
-- Migration 00031: Add is_paused & Promotion Columns, Composite Indexes & Update Properties RLS
-- Project: Belagavi Property (PropertyHub)
-- Target:
--   1. Add is_paused BOOLEAN NOT NULL DEFAULT false to public.properties
--   2. Add is_featured BOOLEAN NOT NULL DEFAULT false to public.properties
--   3. Add server-authoritative promotion columns (promotion_active, promotion_ends_at, promotion_tier)
--   4. Add composite indexes for high-performance public marketplace feeds
--   5. Update public SELECT RLS policy to enforce: status = 'active' AND is_paused = false
-- ==============================================================================

BEGIN;

-- 1. Add is_paused to public.properties
ALTER TABLE public.properties 
    ADD COLUMN IF NOT EXISTS is_paused BOOLEAN NOT NULL DEFAULT false;

-- 2. Add is_featured to public.properties (if not present)
ALTER TABLE public.properties 
    ADD COLUMN IF NOT EXISTS is_featured BOOLEAN NOT NULL DEFAULT false;

-- 3. Add server-authoritative promotion metadata columns
ALTER TABLE public.properties 
    ADD COLUMN IF NOT EXISTS promotion_active BOOLEAN NOT NULL DEFAULT false,
    ADD COLUMN IF NOT EXISTS promotion_ends_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS promotion_tier TEXT;

-- 4. Create composite indexes for public marketplace feeds and owner listings
CREATE INDEX IF NOT EXISTS idx_properties_public_feed 
    ON public.properties (status, is_paused, is_featured DESC, updated_at DESC);

CREATE INDEX IF NOT EXISTS idx_properties_owner_lookup 
    ON public.properties (owner_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_properties_category_status 
    ON public.properties (category, status, is_paused);

CREATE INDEX IF NOT EXISTS idx_properties_city_status 
    ON public.properties (city, status, is_paused);

-- 5. Update public SELECT RLS policy on public.properties:
-- Public can read properties where status = 'active' AND is_paused = false.
-- Property owners can read their own properties regardless of status or pause state.
-- Admins/founders can read all properties.
DROP POLICY IF EXISTS "Public read active properties or owner" ON public.properties;

CREATE POLICY "Public read active properties or owner" 
    ON public.properties FOR SELECT 
    USING (
        (status = 'active'::listing_status AND is_paused = false)
        OR (
            auth.jwt()->>'sub' IS NOT NULL AND EXISTS (
                SELECT 1 FROM public.profiles
                WHERE profiles.id = properties.owner_id
                AND profiles.firebase_uid = (auth.jwt()->>'sub')
            )
        )
        OR public.is_app_admin_or_founder()
    );

COMMIT;
