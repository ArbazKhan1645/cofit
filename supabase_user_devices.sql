-- ============================================================
-- user_devices table — multi-device FCM token tracking
-- Run this in Supabase SQL Editor
-- ============================================================

CREATE TABLE IF NOT EXISTS public.user_devices (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  device_id TEXT NOT NULL,
  fcm_token TEXT NOT NULL,
  platform TEXT,
  device_model TEXT,
  last_active TIMESTAMPTZ DEFAULT now(),
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, device_id)
);

-- RLS
ALTER TABLE public.user_devices ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own devices"
  ON public.user_devices FOR ALL
  USING (auth.uid() = user_id);

-- Index for fast token lookup by user
CREATE INDEX IF NOT EXISTS idx_user_devices_user_id
  ON public.user_devices(user_id);
