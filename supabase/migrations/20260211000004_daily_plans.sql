-- ============================================
-- CoFit Collective - Daily Workout Plans
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. CREATE daily_plans TABLE
CREATE TABLE IF NOT EXISTS public.daily_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL DEFAULT '',
    total_days INTEGER NOT NULL DEFAULT 0,
    start_date DATE NOT NULL DEFAULT CURRENT_DATE,
    is_active BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_daily_plans_active
    ON public.daily_plans(is_active) WHERE is_active = true;

-- 2. CREATE daily_plan_items TABLE
CREATE TABLE IF NOT EXISTS public.daily_plan_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_id UUID NOT NULL REFERENCES public.daily_plans(id) ON DELETE CASCADE,
    day_number INTEGER NOT NULL CHECK (day_number >= 1),
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(plan_id, day_number, workout_id)
);

CREATE INDEX IF NOT EXISTS idx_daily_plan_items_plan
    ON public.daily_plan_items(plan_id);

CREATE INDEX IF NOT EXISTS idx_daily_plan_items_day
    ON public.daily_plan_items(plan_id, day_number);

-- 3. RLS on daily_plans
ALTER TABLE public.daily_plans ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active daily plans"
    ON public.daily_plans FOR SELECT
    USING (is_active = true);

CREATE POLICY "Admin can view all daily plans"
    ON public.daily_plans FOR SELECT
    USING (public.is_admin());

CREATE POLICY "Admin can insert daily plans"
    ON public.daily_plans FOR INSERT
    WITH CHECK (public.is_admin());

CREATE POLICY "Admin can update daily plans"
    ON public.daily_plans FOR UPDATE
    USING (public.is_admin());

CREATE POLICY "Admin can delete daily plans"
    ON public.daily_plans FOR DELETE
    USING (public.is_admin());

-- 4. RLS on daily_plan_items
ALTER TABLE public.daily_plan_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active plan items"
    ON public.daily_plan_items FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.daily_plans
            WHERE daily_plans.id = plan_id
            AND daily_plans.is_active = true
        )
    );

CREATE POLICY "Admin can view all plan items"
    ON public.daily_plan_items FOR SELECT
    USING (public.is_admin());

CREATE POLICY "Admin can insert plan items"
    ON public.daily_plan_items FOR INSERT
    WITH CHECK (public.is_admin());

CREATE POLICY "Admin can update plan items"
    ON public.daily_plan_items FOR UPDATE
    USING (public.is_admin());

CREATE POLICY "Admin can delete plan items"
    ON public.daily_plan_items FOR DELETE
    USING (public.is_admin());
