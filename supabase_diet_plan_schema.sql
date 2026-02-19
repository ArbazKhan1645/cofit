-- ============================================
-- DIET PLAN / RECIPE MODULE - SUPABASE SCHEMA
-- ============================================

-- 1. Main diet plans table
CREATE TABLE diet_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  cover_image_url TEXT,
  plan_type TEXT NOT NULL DEFAULT 'custom',          -- weekly, monthly, custom
  duration_days INT NOT NULL DEFAULT 7,
  category TEXT NOT NULL DEFAULT 'general',           -- weight_loss, muscle_gain, maintenance, general, keto, vegan, high_protein
  difficulty_level TEXT NOT NULL DEFAULT 'beginner',  -- beginner, intermediate, advanced
  calories_per_day INT,
  tags TEXT[] DEFAULT '{}',
  is_published BOOLEAN DEFAULT false,
  is_featured BOOLEAN DEFAULT false,
  created_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- 2. Day-by-day structure for each plan
CREATE TABLE diet_plan_days (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  plan_id UUID NOT NULL REFERENCES diet_plans(id) ON DELETE CASCADE,
  day_number INT NOT NULL,                           -- 1-indexed (Day 1, Day 2, ...)
  title TEXT,                                         -- e.g. "Day 1 - High Protein", optional
  notes TEXT,
  total_calories INT DEFAULT 0,
  total_protein_g DECIMAL DEFAULT 0,
  total_carbs_g DECIMAL DEFAULT 0,
  total_fat_g DECIMAL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(plan_id, day_number)
);

-- 3. Individual meals within each day
CREATE TABLE diet_plan_meals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  day_id UUID NOT NULL REFERENCES diet_plan_days(id) ON DELETE CASCADE,
  meal_type TEXT NOT NULL DEFAULT 'breakfast',        -- breakfast, morning_snack, lunch, afternoon_snack, dinner, evening_snack
  title TEXT NOT NULL,
  description TEXT,
  calories INT DEFAULT 0,
  protein_g DECIMAL DEFAULT 0,
  carbs_g DECIMAL DEFAULT 0,
  fat_g DECIMAL DEFAULT 0,
  fiber_g DECIMAL DEFAULT 0,
  image_url TEXT,
  recipe_instructions TEXT,
  prep_time_minutes INT,
  ingredients JSONB DEFAULT '[]'::jsonb,             -- [{name, quantity, unit}]
  sort_order INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================
-- INDEXES
-- ============================================

CREATE INDEX idx_diet_plans_published ON diet_plans(is_published) WHERE is_published = true;
CREATE INDEX idx_diet_plans_category ON diet_plans(category);
CREATE INDEX idx_diet_plans_plan_type ON diet_plans(plan_type);
CREATE INDEX idx_diet_plans_featured ON diet_plans(is_featured) WHERE is_featured = true;
CREATE INDEX idx_diet_plan_days_plan_id ON diet_plan_days(plan_id);
CREATE INDEX idx_diet_plan_days_plan_day ON diet_plan_days(plan_id, day_number);
CREATE INDEX idx_diet_plan_meals_day_id ON diet_plan_meals(day_id);
CREATE INDEX idx_diet_plan_meals_type ON diet_plan_meals(meal_type);

-- ============================================
-- RLS (Row Level Security)
-- ============================================

ALTER TABLE diet_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE diet_plan_days ENABLE ROW LEVEL SECURITY;
ALTER TABLE diet_plan_meals ENABLE ROW LEVEL SECURITY;

-- Public read for published plans
CREATE POLICY "Anyone can read published diet plans"
  ON diet_plans FOR SELECT
  USING (is_published = true);

-- Admins can do everything
CREATE POLICY "Admins can manage diet plans"
  ON diet_plans FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND user_type = 'admin'
    )
  );

-- Public read for days of published plans
CREATE POLICY "Anyone can read days of published plans"
  ON diet_plan_days FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM diet_plans WHERE id = plan_id AND is_published = true
    )
  );

-- Admins can manage days
CREATE POLICY "Admins can manage diet plan days"
  ON diet_plan_days FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND user_type = 'admin'
    )
  );

-- Public read for meals of published plans
CREATE POLICY "Anyone can read meals of published plans"
  ON diet_plan_meals FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM diet_plan_days d
      JOIN diet_plans p ON p.id = d.plan_id
      WHERE d.id = day_id AND p.is_published = true
    )
  );

-- Admins can manage meals
CREATE POLICY "Admins can manage diet plan meals"
  ON diet_plan_meals FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM users WHERE id = auth.uid() AND user_type = 'admin'
    )
  );

-- ============================================
-- FUNCTION: Copy meals from one day to another
-- ============================================

CREATE OR REPLACE FUNCTION copy_diet_plan_day_meals(
  source_day_id UUID,
  target_day_id UUID
) RETURNS void AS $$
BEGIN
  -- Delete existing meals in target day
  DELETE FROM diet_plan_meals WHERE day_id = target_day_id;

  -- Copy meals from source to target
  INSERT INTO diet_plan_meals (day_id, meal_type, title, description, calories, protein_g, carbs_g, fat_g, fiber_g, image_url, recipe_instructions, prep_time_minutes, ingredients, sort_order)
  SELECT target_day_id, meal_type, title, description, calories, protein_g, carbs_g, fat_g, fiber_g, image_url, recipe_instructions, prep_time_minutes, ingredients, sort_order
  FROM diet_plan_meals
  WHERE day_id = source_day_id;

  -- Update target day totals
  UPDATE diet_plan_days
  SET
    total_calories = (SELECT COALESCE(SUM(calories), 0) FROM diet_plan_meals WHERE day_id = target_day_id),
    total_protein_g = (SELECT COALESCE(SUM(protein_g), 0) FROM diet_plan_meals WHERE day_id = target_day_id),
    total_carbs_g = (SELECT COALESCE(SUM(carbs_g), 0) FROM diet_plan_meals WHERE day_id = target_day_id),
    total_fat_g = (SELECT COALESCE(SUM(fat_g), 0) FROM diet_plan_meals WHERE day_id = target_day_id),
    updated_at = now()
  WHERE id = target_day_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
