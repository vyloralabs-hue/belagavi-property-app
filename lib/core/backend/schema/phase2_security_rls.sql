-- =============================================================================
-- BELAGAVI PROPERTY RE-OS: PHASE 2 SUPABASE ROW LEVEL SECURITY (RLS) POLICIES
-- Target Schema Version: 1.2.0
-- Created: 2026-08-07
-- =============================================================================

-- Enable RLS on all Phase 1 and core tables
ALTER TABLE public.properties ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.property_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.property_unlocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.towers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.unit_inventory ENABLE ROW LEVEL SECURITY;

-- -----------------------------------------------------------------------------
-- 1. PROPERTIES RLS POLICIES
-- -----------------------------------------------------------------------------

-- Public SELECT: Anyone can view active/published property cards (Public fields only)
CREATE POLICY "Public properties select policy"
ON public.properties FOR SELECT
USING (status NOT IN ('draft', 'archived') OR auth.uid()::text = owner_id);

-- INSERT: Authenticated users can insert their own properties
CREATE POLICY "Users property insert policy"
ON public.properties FOR INSERT
WITH CHECK (auth.uid()::text = owner_id);

-- UPDATE: Only owner can update property
CREATE POLICY "Owners property update policy"
ON public.properties FOR UPDATE
USING (auth.uid()::text = owner_id)
WITH CHECK (auth.uid()::text = owner_id);

-- DELETE: Only owner can delete property
CREATE POLICY "Owners property delete policy"
ON public.properties FOR DELETE
USING (auth.uid()::text = owner_id);

-- -----------------------------------------------------------------------------
-- 2. PROPERTY DOCUMENTS RLS POLICIES
-- -----------------------------------------------------------------------------

-- SELECT: Only document uploader OR users with an active property unlock
CREATE POLICY "Property documents select policy"
ON public.property_documents FOR SELECT
USING (
    auth.uid()::text = uploaded_by 
    OR EXISTS (
        SELECT 1 FROM public.property_unlocks pu
        WHERE pu.property_id = property_documents.property_id
        AND pu.user_id = auth.uid()::text
        AND pu.status = 'active'
        AND (pu.expires_at IS NULL OR pu.expires_at > NOW())
    )
);

-- INSERT/UPDATE/DELETE: Only document uploader
CREATE POLICY "Property documents modification policy"
ON public.property_documents FOR ALL
USING (auth.uid()::text = uploaded_by)
WITH CHECK (auth.uid()::text = uploaded_by);

-- -----------------------------------------------------------------------------
-- 3. PROPERTY UNLOCKS RLS POLICIES
-- -----------------------------------------------------------------------------

-- Users can view and manage only their own unlock records
CREATE POLICY "Property unlocks user policy"
ON public.property_unlocks FOR ALL
USING (auth.uid()::text = user_id)
WITH CHECK (auth.uid()::text = user_id);

-- -----------------------------------------------------------------------------
-- 4. BUILDER PROJECTS RLS POLICIES
-- -----------------------------------------------------------------------------

-- Public SELECT: Anyone can view builder projects
CREATE POLICY "Projects public select policy"
ON public.projects FOR SELECT
USING (true);

-- Modification: Only builder can insert, update, or delete project
CREATE POLICY "Builder projects modification policy"
ON public.projects FOR ALL
USING (auth.uid()::text = builder_id)
WITH CHECK (auth.uid()::text = builder_id);

-- -----------------------------------------------------------------------------
-- 5. TOWERS & UNIT INVENTORY RLS POLICIES
-- -----------------------------------------------------------------------------

-- Public SELECT: Anyone can view towers and unit inventory
CREATE POLICY "Towers public select policy" ON public.towers FOR SELECT USING (true);
CREATE POLICY "Unit inventory public select policy" ON public.unit_inventory FOR SELECT USING (true);

-- Modification: Only project builder can modify towers or units
CREATE POLICY "Towers builder modification policy"
ON public.towers FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.projects p
        WHERE p.id = towers.project_id AND p.builder_id = auth.uid()::text
    )
);

CREATE POLICY "Unit inventory builder modification policy"
ON public.unit_inventory FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM public.projects p
        WHERE p.id = unit_inventory.project_id AND p.builder_id = auth.uid()::text
    )
);
