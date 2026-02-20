-- ============================================
-- CRASHLYTICS TABLE
-- App crash/exception logs for admin monitoring
-- ============================================

CREATE TABLE IF NOT EXISTS crash_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,

    -- User info (nullable — crash can happen before auth)
    user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,

    -- Exception details
    error_type TEXT NOT NULL,           -- e.g. 'FormatException', 'SocketException'
    error_message TEXT NOT NULL,        -- The exception message
    stack_trace TEXT,                   -- Full stack trace string

    -- Context
    fatal BOOLEAN DEFAULT false,        -- true = crash, false = caught exception
    source TEXT DEFAULT 'dart',         -- 'dart', 'flutter', 'platform'
    screen_route TEXT,                  -- Which screen/route was active

    -- Device info
    platform TEXT,                      -- 'android', 'ios'
    os_version TEXT,                    -- e.g. 'Android 14', 'iOS 17.2'
    app_version TEXT,                   -- e.g. '1.0.0+1'
    device_model TEXT,                  -- e.g. 'Pixel 8', 'iPhone 15'

    -- Extra context
    extra_data JSONB DEFAULT '{}',      -- Any additional metadata

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Index for fast admin queries
CREATE INDEX idx_crash_logs_created ON crash_logs(created_at DESC);
CREATE INDEX idx_crash_logs_user ON crash_logs(user_id);
CREATE INDEX idx_crash_logs_fatal ON crash_logs(fatal);
CREATE INDEX idx_crash_logs_error_type ON crash_logs(error_type);

-- RLS Policies
ALTER TABLE crash_logs ENABLE ROW LEVEL SECURITY;

-- Authenticated users can insert their own crash logs
CREATE POLICY "Users can insert crash logs"
    ON crash_logs FOR INSERT
    TO authenticated
    WITH CHECK (true);

-- Only admin can read all crash logs
CREATE POLICY "Admin can read all crash logs"
    ON crash_logs FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.id = auth.uid()
            AND users.user_type = 'admin'
        )
    );

-- Admin can delete crash logs
CREATE POLICY "Admin can delete crash logs"
    ON crash_logs FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM users
            WHERE users.id = auth.uid()
            AND users.user_type = 'admin'
        )
    );
