-- ============================================
-- CoFit Collective - Admin User Management
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. ADD is_banned COLUMN to users table
ALTER TABLE public.users ADD COLUMN IF NOT EXISTS is_banned BOOLEAN NOT NULL DEFAULT false;

-- 2. INDEX for quick banned filter
CREATE INDEX IF NOT EXISTS idx_users_is_banned
    ON public.users(is_banned) WHERE is_banned = true;

-- 3. INDEX for quick user_type filter
CREATE INDEX IF NOT EXISTS idx_users_user_type
    ON public.users(user_type);

-- 4. ADMIN RLS - allow admin to view all users
CREATE POLICY "Admin can view all users"
    ON public.users FOR SELECT
    USING (public.is_admin());

-- 5. ADMIN RLS - allow admin to update any user (ban, change type, etc.)
CREATE POLICY "Admin can update all users"
    ON public.users FOR UPDATE
    USING (public.is_admin());

-- 6. ADMIN RLS - allow admin to delete any user
CREATE POLICY "Admin can delete users"
    ON public.users FOR DELETE
    USING (public.is_admin());
