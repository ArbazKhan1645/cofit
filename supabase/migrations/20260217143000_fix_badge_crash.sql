-- Fix: Disable badge checks in workout completion trigger to prevent crashes
-- The user_achievements table seems to be missing badge_id column in production,
-- which causes "column badge_id does not exist" error.

CREATE OR REPLACE FUNCTION public.handle_workout_completion()
RETURNS TRIGGER AS $$
DECLARE
    v_last_workout_date DATE;
    v_current_streak INTEGER;
    v_longest_streak INTEGER;
BEGIN
    -- Get user's current streak info
    SELECT last_workout_date, current_streak, longest_streak
    INTO v_last_workout_date, v_current_streak, v_longest_streak
    FROM public.users
    WHERE id = NEW.user_id;

    -- Calculate new streak
    IF v_last_workout_date IS NULL OR v_last_workout_date < (CURRENT_DATE - INTERVAL '1 day') THEN
        -- Streak broken or first workout
        v_current_streak := 1;
    ELSIF v_last_workout_date = CURRENT_DATE - INTERVAL '1 day' THEN
        -- Consecutive day
        v_current_streak := v_current_streak + 1;
    END IF;
    -- If same day, keep current streak

    -- Update longest streak if needed
    IF v_current_streak > v_longest_streak THEN
        v_longest_streak := v_current_streak;
    END IF;

    -- Update user stats
    UPDATE public.users
    SET
        total_workouts_completed = total_workouts_completed + 1,
        total_minutes_worked_out = total_minutes_worked_out + NEW.duration_minutes,
        total_calories_burned = total_calories_burned + NEW.calories_burned,
        current_streak = v_current_streak,
        longest_streak = v_longest_streak,
        last_workout_date = CURRENT_DATE,
        updated_at = NOW()
    WHERE id = NEW.user_id;

    -- Update workout total completions
    UPDATE public.workouts
    SET total_completions = total_completions + 1
    WHERE id = NEW.workout_id;

    -- Update challenge progress if user is in any active challenges
    UPDATE public.user_challenges uc
    SET
        current_progress = current_progress + 1,
        last_updated = NOW()
    FROM public.challenges c
    WHERE uc.challenge_id = c.id
    AND uc.user_id = NEW.user_id
    AND c.status = 'active'
    AND c.start_date <= CURRENT_DATE
    AND c.end_date >= CURRENT_DATE
    AND (
        c.challenge_type = 'workout_count'
        OR (c.challenge_type = 'specific_category' AND c.target_category = (
            SELECT category FROM public.workouts WHERE id = NEW.workout_id
        ))
    );

    -- Check for streak milestone badges
    -- TEMPORARILY DISABLED due to schema mismatch
    -- PERFORM public.check_streak_badges(NEW.user_id, v_current_streak);

    -- Check for workout count badges
    -- TEMPORARILY DISABLED due to schema mismatch
    -- PERFORM public.check_workout_badges(NEW.user_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
