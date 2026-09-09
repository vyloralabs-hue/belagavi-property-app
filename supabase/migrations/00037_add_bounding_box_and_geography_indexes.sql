-- Migration: 00037_add_bounding_box_and_geography_indexes.sql
-- Description: Composite and single B-tree indexes for high-speed bounding-box and administrative location queries.
-- Note: Does NOT modify tables or enable PostGIS. Purely additive index acceleration.

-- 1. Composite bounding-box search index: (latitude, longitude, status, is_paused)
CREATE INDEX IF NOT EXISTS idx_properties_geo_bounds_active
ON public.properties (latitude, longitude)
WHERE status = 'active' AND is_paused = false;

-- 2. State + District + City hierarchy index
CREATE INDEX IF NOT EXISTS idx_properties_hierarchy_active
ON public.properties (state, district, city, locality)
WHERE status = 'active' AND is_paused = false;

-- 3. Pincode search index
CREATE INDEX IF NOT EXISTS idx_properties_pincode_active
ON public.properties (pincode)
WHERE status = 'active' AND is_paused = false;
