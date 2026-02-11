-- ============================================
-- CoFit Collective - Workout Variants & Medical Conditions
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. CREATE workout_variants TABLE
CREATE TABLE IF NOT EXISTS public.workout_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    variant_tag TEXT NOT NULL,   -- 'knee_safe', 'beginner', 'senior_safe'
    label TEXT NOT NULL,          -- 'Knee Safe Version'
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(workout_id, variant_tag)
);

CREATE INDEX IF NOT EXISTS idx_workout_variants_workout
    ON public.workout_variants(workout_id);

-- 2. ALTER workout_exercises: add variant_id and alternatives
ALTER TABLE public.workout_exercises
    ADD COLUMN IF NOT EXISTS variant_id UUID REFERENCES public.workout_variants(id) ON DELETE CASCADE;

ALTER TABLE public.workout_exercises
    ADD COLUMN IF NOT EXISTS alternatives JSONB DEFAULT '{}';

CREATE INDEX IF NOT EXISTS idx_workout_exercises_variant
    ON public.workout_exercises(variant_id);

-- 3. ALTER users: add medical_conditions column
ALTER TABLE public.users
    ADD COLUMN IF NOT EXISTS medical_conditions TEXT[] DEFAULT '{}';

-- 4. RLS on workout_variants
ALTER TABLE public.workout_variants ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view workout variants"
    ON public.workout_variants FOR SELECT
    USING (true);

CREATE POLICY "Admin can insert workout variants"
    ON public.workout_variants FOR INSERT
    WITH CHECK (public.is_admin());

CREATE POLICY "Admin can update workout variants"
    ON public.workout_variants FOR UPDATE
    USING (public.is_admin());

CREATE POLICY "Admin can delete workout variants"
    ON public.workout_variants FOR DELETE
    USING (public.is_admin());
