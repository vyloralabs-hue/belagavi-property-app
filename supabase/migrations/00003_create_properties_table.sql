-- ==========================================
-- Migration 00003: Create Properties Table & RLS
-- Project: Belagavi Property (PropertyHub)
-- ==========================================

CREATE TABLE public.properties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    category property_category NOT NULL,
    type property_type NOT NULL,
    status listing_status NOT NULL DEFAULT 'draft',
    verification_status verification_status NOT NULL DEFAULT 'unverified',
    
    -- Pricing
    price NUMERIC(15, 2) NOT NULL,
    is_negotiable BOOLEAN NOT NULL DEFAULT TRUE,
    
    -- Dimensions & Specifications
    super_built_up_area NUMERIC(10, 2),
    carpet_area NUMERIC(10, 2),
    plot_area NUMERIC(10, 2),
    area_unit TEXT NOT NULL DEFAULT 'sqft', -- sqft, acre, gunta
    bedrooms INT,
    bathrooms INT,
    balconies INT,
    floor_number INT,
    total_floors INT,
    furnishing_status TEXT, -- un-furnished, semi-furnished, fully-furnished
    
    -- Indian Geography Hierarchy
    state TEXT NOT NULL DEFAULT 'Karnataka',
    district TEXT NOT NULL DEFAULT 'Belagavi',
    taluk TEXT NOT NULL DEFAULT 'Belagavi',
    city TEXT NOT NULL DEFAULT 'Belagavi',
    locality TEXT NOT NULL,
    address TEXT NOT NULL,
    pincode VARCHAR(6) NOT NULL,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    
    -- Metadata
    views_count INT NOT NULL DEFAULT 0,
    features JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for high performance search queries
CREATE INDEX idx_properties_category_type ON public.properties(category, type);
CREATE INDEX idx_properties_status ON public.properties(status);
CREATE INDEX idx_properties_price ON public.properties(price);
CREATE INDEX idx_properties_location ON public.properties(state, district, taluk, city, locality);
CREATE INDEX idx_properties_owner ON public.properties(owner_id);

-- Enable RLS
ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Public read active verified properties" 
    ON public.properties FOR SELECT 
    USING (status = 'active' OR auth.uid() = owner_id);

CREATE POLICY "Owners can insert their properties" 
    ON public.properties FOR INSERT 
    WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Owners can update their properties" 
    ON public.properties FOR UPDATE 
    USING (auth.uid() = owner_id);

CREATE POLICY "Owners can delete their properties" 
    ON public.properties FOR DELETE 
    USING (auth.uid() = owner_id);

-- Automatic updated_at trigger
CREATE TRIGGER update_properties_updated_at
    BEFORE UPDATE ON public.properties
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();
