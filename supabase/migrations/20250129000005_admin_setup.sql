-- ============================================
-- CoFit Collective - Admin Setup Migration
-- Run this in Supabase SQL Editor
-- ============================================

-- ============================================
-- 1. ADD user_type COLUMN TO USERS TABLE
-- ============================================
ALTER TABLE public.users
ADD COLUMN IF NOT EXISTS user_type text NOT NULL DEFAULT 'user';

-- ============================================
-- 2. HELPER FUNCTION: is_admin()
-- Returns TRUE if the current authenticated user is an admin
-- ============================================
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users
    WHERE id = auth.uid()
    AND user_type = 'admin'
  );
$$;

-- ============================================
-- 3. STORAGE BUCKETS
-- ============================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
  ('trainer-images', 'trainer-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
  ('workout-media', 'workout-media', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
  ('challenge-images', 'challenge-images', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 4. STORAGE POLICIES — trainer-images
-- ============================================
CREATE POLICY "Public read trainer-images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'trainer-images');

CREATE POLICY "Authenticated upload trainer-images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'trainer-images' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated update trainer-images"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'trainer-images' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated delete trainer-images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'trainer-images' AND auth.role() = 'authenticated');

-- ============================================
-- 5. STORAGE POLICIES — workout-media
-- ============================================
CREATE POLICY "Public read workout-media"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'workout-media');

CREATE POLICY "Authenticated upload workout-media"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'workout-media' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated update workout-media"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'workout-media' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated delete workout-media"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'workout-media' AND auth.role() = 'authenticated');

-- ============================================
-- 6. STORAGE POLICIES — challenge-images
-- ============================================
CREATE POLICY "Public read challenge-images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'challenge-images');

CREATE POLICY "Authenticated upload challenge-images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'challenge-images' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated update challenge-images"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'challenge-images' AND auth.role() = 'authenticated');

CREATE POLICY "Authenticated delete challenge-images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'challenge-images' AND auth.role() = 'authenticated');

-- ============================================
-- 7. RLS POLICIES — Admin CRUD on trainers
-- ============================================
-- Admin can view ALL trainers (including inactive)
CREATE POLICY "Admin can view all trainers"
  ON public.trainers FOR SELECT
  USING (public.is_admin());

CREATE POLICY "Admin can insert trainers"
  ON public.trainers FOR INSERT
  WITH CHECK (public.is_admin());

CREATE POLICY "Admin can update trainers"
  ON public.trainers FOR UPDATE
  USING (public.is_admin());

CREATE POLICY "Admin can delete trainers"
  ON public.trainers FOR DELETE
  USING (public.is_admin());

-- ============================================
-- 8. RLS POLICIES — Admin CRUD on workouts
-- ============================================
CREATE POLICY "Admin can view all workouts"
  ON public.workouts FOR SELECT
  USING (public.is_admin());

CREATE POLICY "Admin can insert workouts"
  ON public.workouts FOR INSERT
  WITH CHECK (public.is_admin());

CREATE POLICY "Admin can update workouts"
  ON public.workouts FOR UPDATE
  USING (public.is_admin());

CREATE POLICY "Admin can delete workouts"
  ON public.workouts FOR DELETE
  USING (public.is_admin());

-- ============================================
-- 9. RLS POLICIES — Admin CRUD on workout_exercises
-- ============================================
CREATE POLICY "Admin can insert workout exercises"
  ON public.workout_exercises FOR INSERT
  WITH CHECK (public.is_admin());

CREATE POLICY "Admin can update workout exercises"
  ON public.workout_exercises FOR UPDATE
  USING (public.is_admin());

CREATE POLICY "Admin can delete workout exercises"
  ON public.workout_exercises FOR DELETE
  USING (public.is_admin());

-- ============================================
-- 10. RLS POLICIES — Admin CRUD on challenges
-- ============================================
CREATE POLICY "Admin can view all challenges"
  ON public.challenges FOR SELECT
  USING (public.is_admin());

CREATE POLICY "Admin can insert challenges"
  ON public.challenges FOR INSERT
  WITH CHECK (public.is_admin());

CREATE POLICY "Admin can update challenges"
  ON public.challenges FOR UPDATE
  USING (public.is_admin());

CREATE POLICY "Admin can delete challenges"
  ON public.challenges FOR DELETE
  USING (public.is_admin());

-- ============================================
-- 11. CREATE ADMIN USER
-- Replace email and password below with your actual values
-- ============================================
DO $$
DECLARE
  new_user_id uuid;
BEGIN
  new_user_id := extensions.uuid_generate_v4();

  -- Create user in auth.users
  INSERT INTO auth.users (
    id, instance_id, email, encrypted_password,
    email_confirmed_at, created_at, updated_at,
    raw_app_meta_data, raw_user_meta_data,
    aud, role
  ) VALUES (
    new_user_id,
    '00000000-0000-0000-0000-000000000000',
    'admin@cofit.app',                          -- ← CHANGE THIS
    crypt('Admin@12345', gen_salt('bf')),        -- ← CHANGE THIS
    now(), now(), now(),
    '{"provider":"email","providers":["email"]}',
    '{"full_name":"CoFit Admin"}',
    'authenticated', 'authenticated'
  );

  -- Create identity record
  INSERT INTO auth.identities (
    id, user_id, provider_id, provider,
    identity_data, last_sign_in_at, created_at, updated_at
  ) VALUES (
    new_user_id, new_user_id, new_user_id, 'email',
    jsonb_build_object('sub', new_user_id, 'email', 'admin@cofit.app'),
    now(), now(), now()
  );

  -- Create user row in public.users table
  INSERT INTO public.users (id, email, full_name, user_type, onboarding_completed)
  VALUES (new_user_id, 'admin@cofit.app', 'CoFit Admin', 'admin', true);
END $$;

COMMIT;
