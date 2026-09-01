-- ==============================================================================
-- CTO PHASE 4 ADDENDUM: FUTURE-SCALE PROPERTY SEARCH DATABASE INDEXES
-- Belagavi Property Application Database Optimization Script
-- ==============================================================================

-- 1. Location Hierarchy Indexes
-- Accelerates location filtering across Country -> State -> District -> City -> Locality -> Area
CREATE INDEX IF NOT EXISTS idx_properties_location_hierarchy 
ON public.properties(country, state, district, city, locality);

-- 2. Public Search & Status Isolation Index
-- Accelerates public discovery queries filtering for PUBLISHED / APPROVED listings sorted by price
CREATE INDEX IF NOT EXISTS idx_properties_public_status_price 
ON public.properties(status, verification_status, price);

-- 3. Property Taxonomy & Category Index
-- Accelerates category & property subtype queries (Residential, Commercial, Land, Plot)
CREATE INDEX IF NOT EXISTS idx_properties_category_type 
ON public.properties(category, type);

-- 4. Builder & Project Inventory Link Index
-- Accelerates builder and project property discovery
CREATE INDEX IF NOT EXISTS idx_properties_builder_project 
ON public.properties(builder_id, project_id);

-- 5. Owner Management Listing Index
-- Accelerates My Properties queries for authenticated property owners
CREATE INDEX IF NOT EXISTS idx_properties_owner_status 
ON public.properties(owner_id, status);

-- 6. Recency Sorting Index
-- Accelerates default listing queries sorted by creation timestamp
CREATE INDEX IF NOT EXISTS idx_properties_created_at_desc 
ON public.properties(created_at DESC);

-- 7. Internal Notifications User & Read Status Index
-- Accelerates in-app user notification queries
CREATE INDEX IF NOT EXISTS idx_notifications_user_read 
ON public.internal_notifications(user_id, is_read, created_at DESC);
