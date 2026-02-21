-- ============================================
-- CoFit Collective - Admin User Operations (RPC)
-- Run this in Supabase SQL Editor
-- These SECURITY DEFINER functions bypass RLS
-- so admin can update/delete other users' data.
-- ============================================

-- 1. Admin: toggle ban status
CREATE OR REPLACE FUNCTION public.admin_update_user_ban(
  p_user_id UUID,
  p_is_banned BOOLEAN
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  UPDATE public.users
  SET is_banned = p_is_banned, updated_at = NOW()
  WHERE id = p_user_id;
END;
$$;

-- 2. Admin: toggle user role
CREATE OR REPLACE FUNCTION public.admin_update_user_role(
  p_user_id UUID,
  p_user_type TEXT
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  IF p_user_type NOT IN ('user', 'admin') THEN
    RAISE EXCEPTION 'Invalid user type';
  END IF;

  UPDATE public.users
  SET user_type = p_user_type, updated_at = NOW()
  WHERE id = p_user_id;
END;
$$;

-- 3. Admin: delete all user data (called on ban)
CREATE OR REPLACE FUNCTION public.admin_delete_user_data(
  p_user_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  -- Batch 1: user-specific data
  DELETE FROM public.user_progress WHERE user_id = p_user_id;
  DELETE FROM public.month_progress WHERE user_id = p_user_id;
  DELETE FROM public.user_challenges WHERE user_id = p_user_id;
  DELETE FROM public.user_notification_settings WHERE user_id = p_user_id;
  DELETE FROM public.notifications WHERE user_id = p_user_id;
  DELETE FROM public.achievement_progress WHERE user_id = p_user_id;
  DELETE FROM public.saved_workouts WHERE user_id = p_user_id;
  DELETE FROM public.saved_recipes WHERE user_id = p_user_id;
  DELETE FROM public.saved_posts WHERE user_id = p_user_id;
  DELETE FROM public.journal_entries WHERE user_id = p_user_id;
  DELETE FROM public.onboarding_responses WHERE user_id = p_user_id;
  DELETE FROM public.user_devices WHERE user_id = p_user_id;

  -- Batch 2: social content
  DELETE FROM public.likes WHERE user_id = p_user_id;
  DELETE FROM public.comments WHERE user_id = p_user_id;
  DELETE FROM public.shares WHERE user_id = p_user_id;
  DELETE FROM public.follows WHERE follower_id = p_user_id;
  DELETE FROM public.follows WHERE following_id = p_user_id;
  DELETE FROM public.posts WHERE user_id = p_user_id;
END;
$$;

-- 4. User: delete own account (self-service)
CREATE OR REPLACE FUNCTION public.delete_own_account()
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_uid UUID := auth.uid();
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- Delete all user data
  DELETE FROM public.user_progress WHERE user_id = v_uid;
  DELETE FROM public.month_progress WHERE user_id = v_uid;
  DELETE FROM public.user_challenges WHERE user_id = v_uid;
  DELETE FROM public.user_notification_settings WHERE user_id = v_uid;
  DELETE FROM public.notifications WHERE user_id = v_uid;
  DELETE FROM public.achievement_progress WHERE user_id = v_uid;
  DELETE FROM public.saved_workouts WHERE user_id = v_uid;
  DELETE FROM public.saved_recipes WHERE user_id = v_uid;
  DELETE FROM public.saved_posts WHERE user_id = v_uid;
  DELETE FROM public.journal_entries WHERE user_id = v_uid;
  DELETE FROM public.onboarding_responses WHERE user_id = v_uid;
  DELETE FROM public.user_devices WHERE user_id = v_uid;

  -- Social content
  DELETE FROM public.likes WHERE user_id = v_uid;
  DELETE FROM public.comments WHERE user_id = v_uid;
  DELETE FROM public.shares WHERE user_id = v_uid;
  DELETE FROM public.follows WHERE follower_id = v_uid;
  DELETE FROM public.follows WHERE following_id = v_uid;
  DELETE FROM public.posts WHERE user_id = v_uid;

  -- Delete user row
  DELETE FROM public.users WHERE id = v_uid;
END;
$$;

-- ============================================
-- FIX: handle_new_user — extract full_name from
-- Google/Apple auth metadata on signup
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, full_name, username, avatar_url, created_at, updated_at)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            NEW.raw_user_meta_data->>'name'
        ),
        COALESCE(
            NEW.raw_user_meta_data->>'preferred_username',
            LOWER(REPLACE(
                COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', SPLIT_PART(NEW.email, '@', 1)),
                ' ', '_'
            )) || '_' || SUBSTRING(NEW.id::TEXT FROM 1 FOR 4)
        ),
        COALESCE(
            NEW.raw_user_meta_data->>'avatar_url',
            NEW.raw_user_meta_data->>'picture'
        ),
        NOW(),
        NOW()
    );

    -- Create default notification settings
    INSERT INTO public.user_notification_settings (user_id, created_at, updated_at)
    VALUES (NEW.id, NOW(), NOW());

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- FIX: Null full_name causing PostgresException
-- in notification triggers (body NOT NULL violation)
-- ============================================

-- 5. Fix: handle_like_insert — null full_name
CREATE OR REPLACE FUNCTION public.handle_like_insert()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.like_type = 'post' THEN
        UPDATE public.posts
        SET likes_count = likes_count + 1
        WHERE id = NEW.post_id;

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
            COALESCE(users.full_name, users.username, 'Someone') || ' liked your post',
            'post_liked',
            'navigate',
            jsonb_build_object('route', '/post-detail', 'resource_id', NEW.post_id),
            'low',
            NOW()
        FROM public.posts
        JOIN public.users ON users.id = NEW.user_id
        WHERE posts.id = NEW.post_id
        AND posts.user_id != NEW.user_id;

    ELSIF NEW.like_type = 'comment' THEN
        UPDATE public.comments
        SET likes_count = likes_count + 1
        WHERE id = NEW.comment_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Fix: handle_comment_insert — null full_name
CREATE OR REPLACE FUNCTION public.handle_comment_insert()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.posts
    SET comments_count = comments_count + 1
    WHERE id = NEW.post_id;

    IF NEW.parent_comment_id IS NOT NULL THEN
        UPDATE public.comments
        SET replies_count = replies_count + 1
        WHERE id = NEW.parent_comment_id;
    END IF;

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
        COALESCE(users.full_name, users.username, 'Someone') || ' commented on your post',
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

-- 7. Fix: handle_share_insert — null full_name
CREATE OR REPLACE FUNCTION public.handle_share_insert()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.posts
    SET shares_count = shares_count + 1
    WHERE id = NEW.post_id;

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
        COALESCE(users.full_name, users.username, 'Someone') || ' shared your post',
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

-- 8. Fix: handle_follow_insert — null full_name
CREATE OR REPLACE FUNCTION public.handle_follow_insert()
RETURNS TRIGGER AS $$
BEGIN
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
        COALESCE(users.full_name, users.username, 'Someone') || ' started following you',
        'new_follower',
        'navigate',
        jsonb_build_object('route', '/profile', 'resource_id', NEW.follower_id),
        'normal',
        NOW()
    FROM public.users
    WHERE users.id = NEW.follower_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 9. Admin: delete user account entirely
CREATE OR REPLACE FUNCTION public.admin_delete_user(
  p_user_id UUID
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'Not authorized';
  END IF;

  -- Delete all related data first
  PERFORM public.admin_delete_user_data(p_user_id);

  -- Delete the user row
  DELETE FROM public.users WHERE id = p_user_id;
END;
$$;
