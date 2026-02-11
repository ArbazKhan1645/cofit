-- ============================================
-- CoFit Collective - Weekly Schedules
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. CREATE weekly_schedules TABLE
CREATE TABLE IF NOT EXISTS public.weekly_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL DEFAULT '',
    disabled_days INTEGER[] NOT NULL DEFAULT '{}',
    is_active BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_weekly_schedules_active
    ON public.weekly_schedules(is_active) WHERE is_active = true;

-- 2. CREATE weekly_schedule_items TABLE
CREATE TABLE IF NOT EXISTS public.weekly_schedule_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    schedule_id UUID NOT NULL REFERENCES public.weekly_schedules(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(schedule_id, day_of_week, workout_id)
);

CREATE INDEX IF NOT EXISTS idx_schedule_items_schedule
    ON public.weekly_schedule_items(schedule_id);

CREATE INDEX IF NOT EXISTS idx_schedule_items_day
    ON public.weekly_schedule_items(schedule_id, day_of_week);

-- 3. RLS on weekly_schedules
ALTER TABLE public.weekly_schedules ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active schedules"
    ON public.weekly_schedules FOR SELECT
    USING (is_active = true);

CREATE POLICY "Admin can view all schedules"
    ON public.weekly_schedules FOR SELECT
    USING (public.is_admin());

CREATE POLICY "Admin can insert schedules"
    ON public.weekly_schedules FOR INSERT
    WITH CHECK (public.is_admin());

CREATE POLICY "Admin can update schedules"
    ON public.weekly_schedules FOR UPDATE
    USING (public.is_admin());

CREATE POLICY "Admin can delete schedules"
    ON public.weekly_schedules FOR DELETE
    USING (public.is_admin());

-- 4. RLS on weekly_schedule_items
ALTER TABLE public.weekly_schedule_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active schedule items"
    ON public.weekly_schedule_items FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.weekly_schedules
            WHERE weekly_schedules.id = schedule_id
            AND weekly_schedules.is_active = true
        )
    );

CREATE POLICY "Admin can view all schedule items"
    ON public.weekly_schedule_items FOR SELECT
    USING (public.is_admin());

CREATE POLICY "Admin can insert schedule items"
    ON public.weekly_schedule_items FOR INSERT
    WITH CHECK (public.is_admin());

CREATE POLICY "Admin can update schedule items"
    ON public.weekly_schedule_items FOR UPDATE
    USING (public.is_admin());

CREATE POLICY "Admin can delete schedule items"
    ON public.weekly_schedule_items FOR DELETE
    USING (public.is_admin());

-- 5. Helper function: activate a schedule (deactivates all others)
CREATE OR REPLACE FUNCTION public.activate_weekly_schedule(target_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.weekly_schedules SET is_active = false, updated_at = NOW();
    UPDATE public.weekly_schedules SET is_active = true, updated_at = NOW() WHERE id = target_id;
END;
$$;
