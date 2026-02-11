-- ============================================
-- CoFit Collective - Admin Community Management
-- Run this in Supabase SQL Editor
-- ============================================

-- 1. ADMIN RLS on posts (view all, update approval, delete)
CREATE POLICY "Admin can view all posts"
    ON public.posts FOR SELECT
    USING (public.is_admin());

CREATE POLICY "Admin can update any post"
    ON public.posts FOR UPDATE
    USING (public.is_admin());

CREATE POLICY "Admin can delete any post"
    ON public.posts FOR DELETE
    USING (public.is_admin());

-- 2. ADMIN RLS on comments (view all, delete)
CREATE POLICY "Admin can view all comments"
    ON public.comments FOR SELECT
    USING (public.is_admin());

CREATE POLICY "Admin can delete any comment"
    ON public.comments FOR DELETE
    USING (public.is_admin());

-- 3. INDEX for fast pending posts lookup
CREATE INDEX IF NOT EXISTS idx_posts_approval_status
    ON public.posts(approval_status);

CREATE INDEX IF NOT EXISTS idx_posts_user_id
    ON public.posts(user_id);

CREATE INDEX IF NOT EXISTS idx_posts_post_type
    ON public.posts(post_type);
