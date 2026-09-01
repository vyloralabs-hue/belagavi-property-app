-- ============================================================================
-- BELAGAVI PROPERTY PLATFORM - PHASE 7 ADVANCED SEARCH, FAVORITES & SAVED SEARCH
-- ============================================================================
-- Safe, non-destructive incremental schema script for:
-- 1. Property listing_purpose & amenities GIN indexes
-- 2. Saved Searches table & RLS policies
-- 3. User Favorites table & RLS policies
-- ============================================================================

-- 1. Ensure listing_purpose column exists on properties
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'properties' AND column_name = 'listing_purpose'
    ) THEN
        ALTER TABLE properties ADD COLUMN listing_purpose VARCHAR(20) DEFAULT 'SALE';
    END IF;
END $$;

-- 2. Ensure amenities column exists on properties as text array
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'properties' AND column_name = 'amenities'
    ) THEN
        ALTER TABLE properties ADD COLUMN amenities TEXT[] DEFAULT '{}';
    END IF;
END $$;

-- 3. Composite & GIN Indexes for Advanced Search
CREATE INDEX IF NOT EXISTS idx_properties_listing_purpose ON properties(listing_purpose);
CREATE INDEX IF NOT EXISTS idx_properties_amenities_gin ON properties USING GIN(amenities);

-- 4. Saved Searches Table (Cloud-sync ready)
CREATE TABLE IF NOT EXISTS saved_searches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    title VARCHAR(255) NOT NULL,
    filters JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for user's saved searches
CREATE INDEX IF NOT EXISTS idx_saved_searches_user_id ON saved_searches(user_id);

-- RLS for saved_searches
ALTER TABLE saved_searches ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own saved searches"
    ON saved_searches FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create own saved searches"
    ON saved_searches FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own saved searches"
    ON saved_searches FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own saved searches"
    ON saved_searches FOR DELETE
    USING (auth.uid() = user_id);

-- 5. User Favorites Table (Cloud-sync ready)
CREATE TABLE IF NOT EXISTS user_favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    property_id UUID REFERENCES properties(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, property_id)
);

-- Index for user's favorites lookup
CREATE INDEX IF NOT EXISTS idx_user_favorites_user ON user_favorites(user_id, property_id);

-- RLS for user_favorites
ALTER TABLE user_favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own favorites"
    ON user_favorites FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own favorites"
    ON user_favorites FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own favorites"
    ON user_favorites FOR DELETE
    USING (auth.uid() = user_id);
