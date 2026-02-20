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

-- 5. Admin: delete user account entirely
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
