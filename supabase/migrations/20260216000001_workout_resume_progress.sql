-- Workout Resume Progress
-- Tracks mid-workout progress for resume across devices

CREATE TABLE IF NOT EXISTS workout_resume_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  workout_id UUID NOT NULL REFERENCES workouts(id) ON DELETE CASCADE,
  current_exercise_index INT NOT NULL DEFAULT 0,
  completed_exercise_count INT NOT NULL DEFAULT 0,
  elapsed_seconds INT NOT NULL DEFAULT 0,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, workout_id, date)
);

-- RLS
ALTER TABLE workout_resume_progress ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own resume progress"
  ON workout_resume_progress FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own resume progress"
  ON workout_resume_progress FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own resume progress"
  ON workout_resume_progress FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own resume progress"
  ON workout_resume_progress FOR DELETE
  USING (auth.uid() = user_id);

-- Index for fast lookups
CREATE INDEX idx_workout_resume_user_date
  ON workout_resume_progress(user_id, date);
