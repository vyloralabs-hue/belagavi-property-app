-- ==========================================
-- Migration 00004: Create Property Media Table & RLS
-- Project: Belagavi Property (PropertyHub)
-- ==========================================

CREATE TABLE public.property_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    property_id UUID NOT NULL REFERENCES public.properties(id) ON DELETE CASCADE,
    media_url TEXT NOT NULL,
    type media_type NOT NULL DEFAULT 'image',
    display_order INT NOT NULL DEFAULT 0,
    is_cover BOOLEAN NOT NULL DEFAULT FALSE,
    caption TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index
CREATE INDEX idx_property_media_property ON public.property_media(property_id);

-- Enable RLS
ALTER TABLE public.property_media ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Public read property media" 
    ON public.property_media FOR SELECT 
    USING (true);

CREATE POLICY "Property owners can insert media" 
    ON public.property_media FOR INSERT 
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.properties 
            WHERE id = property_id AND owner_id = auth.uid()
        )
    );

CREATE POLICY "Property owners can delete media" 
    ON public.property_media FOR DELETE 
    USING (
        EXISTS (
            SELECT 1 FROM public.properties 
            WHERE id = property_id AND owner_id = auth.uid()
        )
    );
