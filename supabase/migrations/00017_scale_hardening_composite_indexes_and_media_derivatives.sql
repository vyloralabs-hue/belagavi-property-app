-- ==============================================================================
-- PROPERTYHUB CRORE-SCALE HARDENING MIGRATION: COMPOSITE INDEXES & MEDIA DERIVATIVES
-- Migration: 00017_scale_hardening_composite_indexes_and_media_derivatives.sql
-- ==============================================================================

-- 1. Extend property_media table with CDN derivative columns & processing lifecycle
ALTER TABLE IF EXISTS property_media
  ADD COLUMN IF NOT EXISTS thumbnail_url TEXT,
  ADD COLUMN IF NOT EXISTS medium_url TEXT,
  ADD COLUMN IF NOT EXISTS full_url TEXT,
  ADD COLUMN IF NOT EXISTS width INT,
  ADD COLUMN IF NOT EXISTS height INT,
  ADD COLUMN IF NOT EXISTS file_size INT,
  ADD COLUMN IF NOT EXISTS mime_type VARCHAR(100),
  ADD COLUMN IF NOT EXISTS processing_status VARCHAR(30) DEFAULT 'ready';

-- 2. Hot query composite index for Public Feed & Status filtering
CREATE INDEX IF NOT EXISTS idx_properties_status_created_at
  ON properties (status, created_at DESC);

-- 3. Hot query composite index for Category Discovery
CREATE INDEX IF NOT EXISTS idx_properties_category_status_created_at
  ON properties (category, status, created_at DESC);

-- 4. Hot query composite index for City & Locality Public Search
CREATE INDEX IF NOT EXISTS idx_properties_city_category_status
  ON properties (city, category, status);

-- 5. Hot query composite index for Seller Dashboard "My Properties" filtering
CREATE INDEX IF NOT EXISTS idx_properties_owner_status_updated_at
  ON properties (owner_id, status, updated_at DESC);

-- 6. Hot query composite index for Price range & Purpose queries
CREATE INDEX IF NOT EXISTS idx_properties_purpose_city_price
  ON properties (listing_purpose, city, price);

-- 7. Media cover photo retrieval index
CREATE INDEX IF NOT EXISTS idx_property_media_cover_lookup
  ON property_media (property_id, is_cover, display_order);

-- 8. Saved Searches user lookup index
CREATE INDEX IF NOT EXISTS idx_saved_searches_user_active
  ON saved_property_searches (user_id, is_active);
