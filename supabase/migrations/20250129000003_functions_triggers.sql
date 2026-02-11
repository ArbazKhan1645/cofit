-- ============================================
-- CoFit Collective - Database Functions & Triggers
-- Handles automatic updates and notifications
-- ============================================

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at trigger to all tables with updated_at column
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_trainers_updated_at
    BEFORE UPDATE ON public.trainers
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_workouts_updated_at
    BEFORE UPDATE ON public.workouts
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_posts_updated_at
    BEFORE UPDATE ON public.posts
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_comments_updated_at
    BEFORE UPDATE ON public.comments
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_recipes_updated_at
    BEFORE UPDATE ON public.recipes
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_challenges_updated_at
    BEFORE UPDATE ON public.challenges
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_user_plans_updated_at
    BEFORE UPDATE ON public.user_plans
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_journal_entries_updated_at
    BEFORE UPDATE ON public.journal_entries
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at
    BEFORE UPDATE ON public.subscriptions
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ============================================
-- USER PROFILE CREATION ON SIGNUP
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, created_at, updated_at)
    VALUES (
        NEW.id,
        NEW.email,
        NOW(),
        NOW()
    );

    -- Create default notification settings
    INSERT INTO public.user_notification_settings (user_id, created_at, updated_at)
    VALUES (NEW.id, NOW(), NOW());

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on auth.users insert
CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================
-- LIKES COUNT MANAGEMENT
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_like_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.like_type = 'post' AND NEW.post_id IS NOT NULL THEN
        UPDATE public.posts
        SET likes_count = likes_count + 1
        WHERE id = NEW.post_id;

        -- Create notification for post owner
        INSERT INTO public.notifications (
            user_id,
            title,
            body,
            notification_type,
            action_type,
            screen_reference,
            priority,
            scheduled_for
        )
        SELECT
            posts.user_id,
            'New Like',
            users.full_name || ' liked your post',
            'post_liked',
            'navigate',
            jsonb_build_object('route', '/post-detail', 'resource_id', NEW.post_id),
            'normal',
            NOW()
        FROM public.posts
        JOIN public.users ON users.id = NEW.user_id
        WHERE posts.id = NEW.post_id
        AND posts.user_id != NEW.user_id; -- Don't notify self-likes

    ELSIF NEW.like_type = 'comment' AND NEW.comment_id IS NOT NULL THEN
        UPDATE public.comments
        SET likes_count = likes_count + 1
        WHERE id = NEW.comment_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.handle_like_delete()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.like_type = 'post' AND OLD.post_id IS NOT NULL THEN
        UPDATE public.posts
        SET likes_count = GREATEST(likes_count - 1, 0)
        WHERE id = OLD.post_id;
    ELSIF OLD.like_type = 'comment' AND OLD.comment_id IS NOT NULL THEN
        UPDATE public.comments
        SET likes_count = GREATEST(likes_count - 1, 0)
        WHERE id = OLD.comment_id;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_like_insert
    AFTER INSERT ON public.likes
    FOR EACH ROW EXECUTE FUNCTION public.handle_like_insert();

CREATE TRIGGER on_like_delete
    AFTER DELETE ON public.likes
    FOR EACH ROW EXECUTE FUNCTION public.handle_like_delete();

-- ============================================
-- COMMENTS COUNT MANAGEMENT
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_comment_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Update post comments count
    UPDATE public.posts
    SET comments_count = comments_count + 1
    WHERE id = NEW.post_id;

    -- Update parent comment replies count if this is a reply
    IF NEW.parent_comment_id IS NOT NULL THEN
        UPDATE public.comments
        SET replies_count = replies_count + 1
        WHERE id = NEW.parent_comment_id;
    END IF;

    -- Create notification for post owner
    INSERT INTO public.notifications (
        user_id,
        title,
        body,
        notification_type,
        action_type,
        screen_reference,
        priority,
        scheduled_for
    )
    SELECT
        posts.user_id,
        'New Comment',
        users.full_name || ' commented on your post',
        'post_commented',
        'navigate',
        jsonb_build_object('route', '/post-detail', 'resource_id', NEW.post_id),
        'normal',
        NOW()
    FROM public.posts
    JOIN public.users ON users.id = NEW.user_id
    WHERE posts.id = NEW.post_id
    AND posts.user_id != NEW.user_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.handle_comment_delete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.posts
    SET comments_count = GREATEST(comments_count - 1, 0)
    WHERE id = OLD.post_id;

    IF OLD.parent_comment_id IS NOT NULL THEN
        UPDATE public.comments
        SET replies_count = GREATEST(replies_count - 1, 0)
        WHERE id = OLD.parent_comment_id;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_comment_insert
    AFTER INSERT ON public.comments
    FOR EACH ROW EXECUTE FUNCTION public.handle_comment_insert();

CREATE TRIGGER on_comment_delete
    AFTER DELETE ON public.comments
    FOR EACH ROW EXECUTE FUNCTION public.handle_comment_delete();

-- ============================================
-- SHARES COUNT MANAGEMENT
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_share_insert()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.posts
    SET shares_count = shares_count + 1
    WHERE id = NEW.post_id;

    -- Create notification for post owner
    INSERT INTO public.notifications (
        user_id,
        title,
        body,
        notification_type,
        action_type,
        screen_reference,
        priority,
        scheduled_for
    )
    SELECT
        posts.user_id,
        'Post Shared',
        users.full_name || ' shared your post',
        'post_shared',
        'navigate',
        jsonb_build_object('route', '/post-detail', 'resource_id', NEW.post_id),
        'normal',
        NOW()
    FROM public.posts
    JOIN public.users ON users.id = NEW.user_id
    WHERE posts.id = NEW.post_id
    AND posts.user_id != NEW.user_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_share_insert
    AFTER INSERT ON public.shares
    FOR EACH ROW EXECUTE FUNCTION public.handle_share_insert();

-- ============================================
-- FOLLOWS COUNT MANAGEMENT
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_follow_insert()
RETURNS TRIGGER AS $$
BEGIN
    -- Increment follower count for the followed user
    UPDATE public.users
    SET followers_count = followers_count + 1
    WHERE id = NEW.following_id;

    -- Increment following count for the follower
    UPDATE public.users
    SET following_count = following_count + 1
    WHERE id = NEW.follower_id;

    -- Create notification for followed user
    INSERT INTO public.notifications (
        user_id,
        title,
        body,
        notification_type,
        action_type,
        screen_reference,
        priority,
        scheduled_for
    )
    SELECT
        NEW.following_id,
        'New Follower',
        users.full_name || ' started following you',
        'new_follower',
        'navigate',
        jsonb_build_object('route', '/user-profile', 'resource_id', NEW.follower_id),
        'normal',
        NOW()
    FROM public.users
    WHERE users.id = NEW.follower_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.handle_follow_delete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.users
    SET followers_count = GREATEST(followers_count - 1, 0)
    WHERE id = OLD.following_id;

    UPDATE public.users
    SET following_count = GREATEST(following_count - 1, 0)
    WHERE id = OLD.follower_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_follow_insert
    AFTER INSERT ON public.follows
    FOR EACH ROW EXECUTE FUNCTION public.handle_follow_insert();

CREATE TRIGGER on_follow_delete
    AFTER DELETE ON public.follows
    FOR EACH ROW EXECUTE FUNCTION public.handle_follow_delete();

-- ============================================
-- CHALLENGE PARTICIPANT COUNT
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_user_challenge_insert()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.challenges
    SET participant_count = participant_count + 1
    WHERE id = NEW.challenge_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.handle_user_challenge_delete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.challenges
    SET participant_count = GREATEST(participant_count - 1, 0)
    WHERE id = OLD.challenge_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_user_challenge_insert
    AFTER INSERT ON public.user_challenges
    FOR EACH ROW EXECUTE FUNCTION public.handle_user_challenge_insert();

CREATE TRIGGER on_user_challenge_delete
    AFTER DELETE ON public.user_challenges
    FOR EACH ROW EXECUTE FUNCTION public.handle_user_challenge_delete();

-- ============================================
-- RECIPE SAVES COUNT
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_saved_recipe_insert()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.recipes
    SET saves_count = saves_count + 1
    WHERE id = NEW.recipe_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.handle_saved_recipe_delete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.recipes
    SET saves_count = GREATEST(saves_count - 1, 0)
    WHERE id = OLD.recipe_id;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_saved_recipe_insert
    AFTER INSERT ON public.saved_recipes
    FOR EACH ROW EXECUTE FUNCTION public.handle_saved_recipe_insert();

CREATE TRIGGER on_saved_recipe_delete
    AFTER DELETE ON public.saved_recipes
    FOR EACH ROW EXECUTE FUNCTION public.handle_saved_recipe_delete();

-- ============================================
-- RECIPE RATING UPDATE
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_recipe_rating_change()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.recipes
    SET
        average_rating = (
            SELECT COALESCE(AVG(rating), 0)
            FROM public.recipe_ratings
            WHERE recipe_id = COALESCE(NEW.recipe_id, OLD.recipe_id)
        ),
        ratings_count = (
            SELECT COUNT(*)
            FROM public.recipe_ratings
            WHERE recipe_id = COALESCE(NEW.recipe_id, OLD.recipe_id)
        )
    WHERE id = COALESCE(NEW.recipe_id, OLD.recipe_id);

    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_recipe_rating_insert
    AFTER INSERT ON public.recipe_ratings
    FOR EACH ROW EXECUTE FUNCTION public.handle_recipe_rating_change();

CREATE TRIGGER on_recipe_rating_update
    AFTER UPDATE ON public.recipe_ratings
    FOR EACH ROW EXECUTE FUNCTION public.handle_recipe_rating_change();

CREATE TRIGGER on_recipe_rating_delete
    AFTER DELETE ON public.recipe_ratings
    FOR EACH ROW EXECUTE FUNCTION public.handle_recipe_rating_change();

-- ============================================
-- WORKOUT COMPLETION - UPDATE USER STATS
-- ============================================
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
    PERFORM public.check_streak_badges(NEW.user_id, v_current_streak);

    -- Check for workout count badges
    PERFORM public.check_workout_badges(NEW.user_id);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_workout_completion
    AFTER INSERT ON public.user_progress
    FOR EACH ROW EXECUTE FUNCTION public.handle_workout_completion();

-- ============================================
-- BADGE CHECKING FUNCTIONS
-- ============================================
CREATE OR REPLACE FUNCTION public.check_streak_badges(p_user_id UUID, p_streak INTEGER)
RETURNS VOID AS $$
DECLARE
    v_badge RECORD;
BEGIN
    FOR v_badge IN
        SELECT id, name, required_count
        FROM public.badges
        WHERE requirement_type = 'streak_days'
        AND required_count <= p_streak
        AND is_active = true
        AND id NOT IN (
            SELECT badge_id FROM public.user_achievements
            WHERE user_id = p_user_id
        )
    LOOP
        -- Award badge
        INSERT INTO public.user_achievements (user_id, badge_id, earned_at, current_progress)
        VALUES (p_user_id, v_badge.id, NOW(), p_streak);

        -- Create notification
        INSERT INTO public.notifications (
            user_id, title, body, notification_type, action_type,
            screen_reference, priority, scheduled_for
        )
        VALUES (
            p_user_id,
            'Badge Unlocked!',
            'You earned the "' || v_badge.name || '" badge!',
            'badge_unlocked',
            'navigate',
            jsonb_build_object('route', '/badges', 'resource_id', v_badge.id),
            'high',
            NOW()
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.check_workout_badges(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
    v_badge RECORD;
    v_total_workouts INTEGER;
BEGIN
    SELECT total_workouts_completed INTO v_total_workouts
    FROM public.users WHERE id = p_user_id;

    FOR v_badge IN
        SELECT id, name, required_count
        FROM public.badges
        WHERE requirement_type = 'workouts_completed'
        AND required_count <= v_total_workouts
        AND is_active = true
        AND id NOT IN (
            SELECT badge_id FROM public.user_achievements
            WHERE user_id = p_user_id
        )
    LOOP
        INSERT INTO public.user_achievements (user_id, badge_id, earned_at, current_progress)
        VALUES (p_user_id, v_badge.id, NOW(), v_total_workouts);

        INSERT INTO public.notifications (
            user_id, title, body, notification_type, action_type,
            screen_reference, priority, scheduled_for
        )
        VALUES (
            p_user_id,
            'Badge Unlocked!',
            'You earned the "' || v_badge.name || '" badge!',
            'badge_unlocked',
            'navigate',
            jsonb_build_object('route', '/badges', 'resource_id', v_badge.id),
            'high',
            NOW()
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- GET FEED POSTS WITH USER INTERACTION STATUS
-- ============================================
CREATE OR REPLACE FUNCTION public.get_feed_posts(p_user_id UUID, p_limit INTEGER DEFAULT 20, p_offset INTEGER DEFAULT 0)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    content TEXT,
    image_urls TEXT[],
    video_url TEXT,
    post_type TEXT,
    likes_count INTEGER,
    comments_count INTEGER,
    shares_count INTEGER,
    tags TEXT[],
    is_pinned BOOLEAN,
    created_at TIMESTAMPTZ,
    author_id UUID,
    author_full_name TEXT,
    author_username TEXT,
    author_avatar_url TEXT,
    is_liked_by_me BOOLEAN,
    is_saved_by_me BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.user_id,
        p.content,
        p.image_urls,
        p.video_url,
        p.post_type,
        p.likes_count,
        p.comments_count,
        p.shares_count,
        p.tags,
        p.is_pinned,
        p.created_at,
        u.id AS author_id,
        u.full_name AS author_full_name,
        u.username AS author_username,
        u.avatar_url AS author_avatar_url,
        EXISTS (
            SELECT 1 FROM public.likes l
            WHERE l.post_id = p.id AND l.user_id = p_user_id
        ) AS is_liked_by_me,
        EXISTS (
            SELECT 1 FROM public.saved_posts sp
            WHERE sp.post_id = p.id AND sp.user_id = p_user_id
        ) AS is_saved_by_me
    FROM public.posts p
    JOIN public.users u ON p.user_id = u.id
    WHERE p.is_public = true
    ORDER BY p.is_pinned DESC, p.created_at DESC
    LIMIT p_limit
    OFFSET p_offset;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================
-- GET CHALLENGE LEADERBOARD
-- ============================================
CREATE OR REPLACE FUNCTION public.get_challenge_leaderboard(p_challenge_id UUID, p_limit INTEGER DEFAULT 50)
RETURNS TABLE (
    rank BIGINT,
    user_id UUID,
    full_name TEXT,
    username TEXT,
    avatar_url TEXT,
    progress INTEGER,
    progress_percentage INTEGER
) AS $$
DECLARE
    v_target_value INTEGER;
BEGIN
    SELECT target_value INTO v_target_value
    FROM public.challenges WHERE id = p_challenge_id;

    RETURN QUERY
    SELECT
        ROW_NUMBER() OVER (ORDER BY uc.current_progress DESC) AS rank,
        u.id AS user_id,
        u.full_name,
        u.username,
        u.avatar_url,
        uc.current_progress AS progress,
        LEAST((uc.current_progress * 100 / NULLIF(v_target_value, 0)), 100)::INTEGER AS progress_percentage
    FROM public.user_challenges uc
    JOIN public.users u ON uc.user_id = u.id
    WHERE uc.challenge_id = p_challenge_id
    ORDER BY uc.current_progress DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================
-- UPDATE MONTH PROGRESS (Call daily or on workout completion)
-- ============================================
CREATE OR REPLACE FUNCTION public.update_month_progress(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
    v_year INTEGER := EXTRACT(YEAR FROM CURRENT_DATE);
    v_month INTEGER := EXTRACT(MONTH FROM CURRENT_DATE);
    v_stats RECORD;
BEGIN
    -- Calculate stats for current month
    SELECT
        COUNT(*) AS total_workouts,
        COALESCE(SUM(duration_minutes), 0) AS total_minutes,
        COALESCE(SUM(calories_burned), 0) AS total_calories,
        COALESCE(AVG(rating), 0) AS avg_rating,
        COALESCE(AVG(completion_percentage), 0) AS avg_completion,
        COUNT(DISTINCT DATE(completed_at)) AS days_active
    INTO v_stats
    FROM public.user_progress
    WHERE user_id = p_user_id
    AND EXTRACT(YEAR FROM completed_at) = v_year
    AND EXTRACT(MONTH FROM completed_at) = v_month;

    -- Upsert month progress
    INSERT INTO public.month_progress (
        user_id, year, month, total_workouts, total_minutes,
        total_calories, days_active, average_rating, average_completion
    )
    VALUES (
        p_user_id, v_year, v_month, v_stats.total_workouts,
        v_stats.total_minutes, v_stats.total_calories, v_stats.days_active,
        v_stats.avg_rating, v_stats.avg_completion
    )
    ON CONFLICT (user_id, year, month)
    DO UPDATE SET
        total_workouts = EXCLUDED.total_workouts,
        total_minutes = EXCLUDED.total_minutes,
        total_calories = EXCLUDED.total_calories,
        days_active = EXCLUDED.days_active,
        average_rating = EXCLUDED.average_rating,
        average_completion = EXCLUDED.average_completion,
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- MARK NOTIFICATION AS READ
-- ============================================
CREATE OR REPLACE FUNCTION public.mark_notification_read(p_notification_id UUID, p_user_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.notifications
    SET is_read = true, read_at = NOW()
    WHERE id = p_notification_id AND user_id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Mark all notifications as read
CREATE OR REPLACE FUNCTION public.mark_all_notifications_read(p_user_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE public.notifications
    SET is_read = true, read_at = NOW()
    WHERE user_id = p_user_id AND is_read = false;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- GET UNREAD NOTIFICATION COUNT
-- ============================================
CREATE OR REPLACE FUNCTION public.get_unread_notification_count(p_user_id UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)::INTEGER
        FROM public.notifications
        WHERE user_id = p_user_id AND is_read = false
    );
END;
$$ LANGUAGE plpgsql STABLE;

COMMIT;
