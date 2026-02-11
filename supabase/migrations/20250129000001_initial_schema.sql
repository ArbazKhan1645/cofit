-- ============================================
-- CoFit Collective - Supabase Database Schema
-- Run this in Supabase SQL Editor
-- ============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search

-- ============================================
-- 1. USERS TABLE (extends Supabase Auth)
-- ============================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    full_name TEXT,
    username TEXT UNIQUE,
    avatar_url TEXT,
    bio TEXT,
    date_of_birth DATE,
    gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
    height_cm DECIMAL(5,2),
    weight_kg DECIMAL(5,2),
    fitness_level TEXT CHECK (fitness_level IN ('beginner', 'intermediate', 'advanced')),
    fitness_goals TEXT[] DEFAULT '{}',
    workout_days_per_week INTEGER DEFAULT 3 CHECK (workout_days_per_week BETWEEN 1 AND 7),
    preferred_workout_time TEXT CHECK (preferred_workout_time IN ('morning', 'afternoon', 'evening')),
    preferred_session_duration INTEGER,
    preferred_workout_types TEXT[] DEFAULT '{}',
    physical_limitations TEXT[] DEFAULT '{}',
    available_equipment TEXT[] DEFAULT '{}',
    subscription_status TEXT DEFAULT 'free' CHECK (subscription_status IN ('free', 'active', 'cancelled', 'expired')),
    subscription_plan TEXT CHECK (subscription_plan IN ('monthly', 'annual')),
    subscription_start_date TIMESTAMPTZ,
    subscription_end_date TIMESTAMPTZ,
    total_workouts_completed INTEGER DEFAULT 0,
    total_minutes_worked_out INTEGER DEFAULT 0,
    total_calories_burned INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_workout_date DATE,
    onboarding_completed BOOLEAN DEFAULT FALSE,
    notifications_enabled BOOLEAN DEFAULT TRUE,
    fcm_token TEXT,
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for username search
CREATE INDEX IF NOT EXISTS idx_users_username ON public.users(username);
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);

-- ============================================
-- 2. TRAINERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.trainers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name TEXT NOT NULL,
    email TEXT,
    avatar_url TEXT,
    bio TEXT,
    specialties TEXT[] DEFAULT '{}',
    certifications TEXT[] DEFAULT '{}',
    years_experience INTEGER DEFAULT 0,
    instagram_handle TEXT,
    website_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    total_workouts INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 3. WORKOUTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.workouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trainer_id UUID REFERENCES public.trainers(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    thumbnail_url TEXT NOT NULL,
    video_url TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL,
    difficulty TEXT NOT NULL CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
    category TEXT NOT NULL CHECK (category IN ('full_body', 'upper_body', 'lower_body', 'core', 'cardio', 'hiit', 'yoga', 'pilates')),
    calories_burned INTEGER DEFAULT 0,
    equipment TEXT[] DEFAULT '{}',
    target_muscles TEXT[] DEFAULT '{}',
    tags TEXT[] DEFAULT '{}',
    week_number INTEGER DEFAULT 1 CHECK (week_number BETWEEN 1 AND 4),
    sort_order INTEGER DEFAULT 0,
    is_premium BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    total_completions INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.0,
    published_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workouts_category ON public.workouts(category);
CREATE INDEX IF NOT EXISTS idx_workouts_difficulty ON public.workouts(difficulty);
CREATE INDEX IF NOT EXISTS idx_workouts_trainer ON public.workouts(trainer_id);
CREATE INDEX IF NOT EXISTS idx_workouts_week ON public.workouts(week_number);

-- ============================================
-- 4. WORKOUT EXERCISES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.workout_exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    thumbnail_url TEXT,
    video_url TEXT,
    order_index INTEGER NOT NULL,
    duration_seconds INTEGER NOT NULL,
    reps INTEGER,
    sets INTEGER,
    rest_seconds INTEGER,
    exercise_type TEXT NOT NULL CHECK (exercise_type IN ('timed', 'reps', 'rest')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_workout_exercises_workout ON public.workout_exercises(workout_id);

-- ============================================
-- 5. SAVED WORKOUTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.saved_workouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    saved_at TIMESTAMPTZ DEFAULT NOW(),
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, workout_id)
);

CREATE INDEX IF NOT EXISTS idx_saved_workouts_user ON public.saved_workouts(user_id);

-- ============================================
-- 6. BADGES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.badges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    icon_url TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('streak', 'workout', 'community', 'milestone', 'special')),
    requirement_type TEXT NOT NULL,
    required_count INTEGER DEFAULT 1,
    xp_reward INTEGER DEFAULT 0,
    rarity TEXT DEFAULT 'common' CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 7. USER ACHIEVEMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_achievements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES public.badges(id) ON DELETE CASCADE,
    earned_at TIMESTAMPTZ DEFAULT NOW(),
    current_progress INTEGER DEFAULT 0,
    is_new BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, badge_id)
);

CREATE INDEX IF NOT EXISTS idx_user_achievements_user ON public.user_achievements(user_id);

-- ============================================
-- 8. ACHIEVEMENT PROGRESS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.achievement_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    badge_id UUID NOT NULL REFERENCES public.badges(id) ON DELETE CASCADE,
    current_progress INTEGER DEFAULT 0,
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, badge_id)
);

CREATE INDEX IF NOT EXISTS idx_achievement_progress_user ON public.achievement_progress(user_id);

-- ============================================
-- 9. USER PROGRESS TABLE (Workout Log)
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    duration_minutes INTEGER NOT NULL,
    calories_burned INTEGER DEFAULT 0,
    completion_percentage DECIMAL(3,2) DEFAULT 1.0,
    heart_rate_avg INTEGER,
    heart_rate_max INTEGER,
    notes TEXT,
    rating INTEGER DEFAULT 5 CHECK (rating BETWEEN 1 AND 5),
    mood TEXT CHECK (mood IN ('energized', 'tired', 'motivated', 'neutral', 'stressed')),
    counted_for_streak BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_progress_user ON public.user_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_user_progress_completed ON public.user_progress(completed_at);
CREATE INDEX IF NOT EXISTS idx_user_progress_user_date ON public.user_progress(user_id, completed_at);

-- ============================================
-- 10. MONTH PROGRESS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.month_progress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    year INTEGER NOT NULL,
    month INTEGER NOT NULL CHECK (month BETWEEN 1 AND 12),
    total_workouts INTEGER DEFAULT 0,
    total_minutes INTEGER DEFAULT 0,
    total_calories INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    days_active INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.0,
    average_completion DECIMAL(3,2) DEFAULT 0.0,
    workouts_by_category JSONB DEFAULT '{}',
    workouts_by_day JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, year, month)
);

CREATE INDEX IF NOT EXISTS idx_month_progress_user ON public.month_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_month_progress_date ON public.month_progress(year, month);

-- ============================================
-- 11. USER PLANS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    weekly_workout_target INTEGER NOT NULL,
    session_duration_minutes INTEGER NOT NULL,
    weekly_calorie_target INTEGER DEFAULT 0,
    preferred_workout_types TEXT[] DEFAULT '{}',
    target_goals TEXT[] DEFAULT '{}',
    fitness_level TEXT NOT NULL CHECK (fitness_level IN ('beginner', 'intermediate', 'advanced')),
    preferred_time TEXT NOT NULL CHECK (preferred_time IN ('morning', 'afternoon', 'evening')),
    weekly_schedule JSONB DEFAULT '{}',
    duration_weeks INTEGER DEFAULT 12,
    start_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    current_week INTEGER DEFAULT 1,
    completion_rate DECIMAL(3,2) DEFAULT 0.0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_user_plans_user ON public.user_plans(user_id);
CREATE INDEX IF NOT EXISTS idx_user_plans_active ON public.user_plans(user_id, is_active);

-- ============================================
-- 12. PLAN WEEKS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.plan_weeks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_id UUID NOT NULL REFERENCES public.user_plans(id) ON DELETE CASCADE,
    week_number INTEGER NOT NULL,
    theme TEXT,
    description TEXT,
    target_workouts INTEGER NOT NULL,
    completed_workouts INTEGER DEFAULT 0,
    target_minutes INTEGER NOT NULL,
    completed_minutes INTEGER DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    week_start_date DATE NOT NULL,
    week_end_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_plan_weeks_plan ON public.plan_weeks(plan_id);

-- ============================================
-- 13. SCHEDULED WORKOUTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.scheduled_workouts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    plan_id UUID NOT NULL REFERENCES public.user_plans(id) ON DELETE CASCADE,
    plan_week_id UUID REFERENCES public.plan_weeks(id) ON DELETE SET NULL,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    workout_id UUID NOT NULL REFERENCES public.workouts(id) ON DELETE CASCADE,
    scheduled_date DATE NOT NULL,
    scheduled_time TIME,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    progress_id UUID REFERENCES public.user_progress(id) ON DELETE SET NULL,
    reminder_sent BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_scheduled_workouts_user ON public.scheduled_workouts(user_id);
CREATE INDEX IF NOT EXISTS idx_scheduled_workouts_date ON public.scheduled_workouts(scheduled_date);

-- ============================================
-- 14. POSTS TABLE (Community)
-- ============================================
CREATE TABLE IF NOT EXISTS public.posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    image_urls TEXT[] DEFAULT '{}',
    video_url TEXT,
    post_type TEXT NOT NULL CHECK (post_type IN ('text', 'image', 'video', 'workout_share', 'achievement', 'recipe_share')),
    linked_workout_id UUID REFERENCES public.workouts(id) ON DELETE SET NULL,
    linked_recipe_id UUID,
    linked_achievement_id UUID REFERENCES public.user_achievements(id) ON DELETE SET NULL,
    is_public BOOLEAN DEFAULT TRUE,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    shares_count INTEGER DEFAULT 0,
    tags TEXT[] DEFAULT '{}',
    is_pinned BOOLEAN DEFAULT FALSE,
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_posts_user ON public.posts(user_id);
CREATE INDEX IF NOT EXISTS idx_posts_created ON public.posts(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_type ON public.posts(post_type);

-- ============================================
-- 15. COMMENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    likes_count INTEGER DEFAULT 0,
    replies_count INTEGER DEFAULT 0,
    is_edited BOOLEAN DEFAULT FALSE,
    edited_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_comments_post ON public.comments(post_id);
CREATE INDEX IF NOT EXISTS idx_comments_user ON public.comments(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_parent ON public.comments(parent_comment_id);

-- ============================================
-- 16. LIKES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    post_id UUID REFERENCES public.posts(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
    like_type TEXT NOT NULL CHECK (like_type IN ('post', 'comment')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT like_target_check CHECK (
        (post_id IS NOT NULL AND comment_id IS NULL AND like_type = 'post') OR
        (comment_id IS NOT NULL AND post_id IS NULL AND like_type = 'comment')
    ),
    UNIQUE(user_id, post_id, like_type),
    UNIQUE(user_id, comment_id, like_type)
);

CREATE INDEX IF NOT EXISTS idx_likes_user ON public.likes(user_id);
CREATE INDEX IF NOT EXISTS idx_likes_post ON public.likes(post_id);
CREATE INDEX IF NOT EXISTS idx_likes_comment ON public.likes(comment_id);

-- ============================================
-- 17. SHARES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.shares (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    share_type TEXT NOT NULL CHECK (share_type IN ('internal', 'external')),
    share_message TEXT,
    platform TEXT CHECK (platform IN ('twitter', 'facebook', 'instagram', 'copy_link', 'other')),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_shares_post ON public.shares(post_id);

-- ============================================
-- 18. SAVED POSTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.saved_posts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    saved_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, post_id)
);

CREATE INDEX IF NOT EXISTS idx_saved_posts_user ON public.saved_posts(user_id);

-- ============================================
-- 19. FOLLOWS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.follows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(follower_id, following_id),
    CONSTRAINT no_self_follow CHECK (follower_id != following_id)
);

CREATE INDEX IF NOT EXISTS idx_follows_follower ON public.follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following ON public.follows(following_id);

-- ============================================
-- 20. CHALLENGES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    image_url TEXT,
    challenge_type TEXT NOT NULL CHECK (challenge_type IN ('workout_count', 'streak', 'minutes', 'calories', 'specific_category')),
    target_category TEXT,
    target_value INTEGER NOT NULL,
    target_unit TEXT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status TEXT DEFAULT 'active' CHECK (status IN ('upcoming', 'active', 'completed')),
    visibility TEXT DEFAULT 'public' CHECK (visibility IN ('public', 'members_only')),
    created_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
    participant_count INTEGER DEFAULT 0,
    max_participants INTEGER,
    rules TEXT[] DEFAULT '{}',
    prizes JSONB DEFAULT '[]',
    is_featured BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_challenges_status ON public.challenges(status);
CREATE INDEX IF NOT EXISTS idx_challenges_dates ON public.challenges(start_date, end_date);

-- ============================================
-- 21. USER CHALLENGES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    challenge_id UUID NOT NULL REFERENCES public.challenges(id) ON DELETE CASCADE,
    current_progress INTEGER DEFAULT 0,
    rank INTEGER DEFAULT 0,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMPTZ,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, challenge_id)
);

CREATE INDEX IF NOT EXISTS idx_user_challenges_user ON public.user_challenges(user_id);
CREATE INDEX IF NOT EXISTS idx_user_challenges_challenge ON public.user_challenges(challenge_id);
CREATE INDEX IF NOT EXISTS idx_user_challenges_rank ON public.user_challenges(challenge_id, current_progress DESC);

-- ============================================
-- 22. RECIPES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.recipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    image_url TEXT,
    image_urls TEXT[] DEFAULT '{}',
    prep_time_minutes INTEGER NOT NULL,
    cook_time_minutes INTEGER NOT NULL,
    servings INTEGER NOT NULL,
    difficulty TEXT NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
    meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack', 'dessert')),
    dietary_tags TEXT[] DEFAULT '{}',
    ingredients JSONB DEFAULT '[]',
    instructions JSONB DEFAULT '[]',
    nutrition_info JSONB,
    calories INTEGER DEFAULT 0,
    protein DECIMAL(6,2) DEFAULT 0,
    carbs DECIMAL(6,2) DEFAULT 0,
    fat DECIMAL(6,2) DEFAULT 0,
    fiber DECIMAL(6,2) DEFAULT 0,
    is_public BOOLEAN DEFAULT TRUE,
    is_featured BOOLEAN DEFAULT FALSE,
    likes_count INTEGER DEFAULT 0,
    saves_count INTEGER DEFAULT 0,
    average_rating DECIMAL(3,2) DEFAULT 0.0,
    ratings_count INTEGER DEFAULT 0,
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_recipes_user ON public.recipes(user_id);
CREATE INDEX IF NOT EXISTS idx_recipes_meal_type ON public.recipes(meal_type);
CREATE INDEX IF NOT EXISTS idx_recipes_difficulty ON public.recipes(difficulty);

-- Update posts table to reference recipes
ALTER TABLE public.posts
    ADD CONSTRAINT fk_posts_recipe
    FOREIGN KEY (linked_recipe_id)
    REFERENCES public.recipes(id)
    ON DELETE SET NULL;

-- ============================================
-- 23. SAVED RECIPES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.saved_recipes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    saved_at TIMESTAMPTZ DEFAULT NOW(),
    collection_name TEXT,
    note TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, recipe_id)
);

CREATE INDEX IF NOT EXISTS idx_saved_recipes_user ON public.saved_recipes(user_id);

-- ============================================
-- 24. RECIPE RATINGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.recipe_ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    recipe_id UUID NOT NULL REFERENCES public.recipes(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, recipe_id)
);

CREATE INDEX IF NOT EXISTS idx_recipe_ratings_recipe ON public.recipe_ratings(recipe_id);

-- ============================================
-- 25. JOURNAL ENTRIES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    mood TEXT CHECK (mood IN ('energized', 'happy', 'neutral', 'tired', 'stressed')),
    energy_level INTEGER DEFAULT 3 CHECK (energy_level BETWEEN 1 AND 5),
    tags TEXT[] DEFAULT '{}',
    linked_workout_id UUID REFERENCES public.workouts(id) ON DELETE SET NULL,
    linked_challenge_id UUID REFERENCES public.challenges(id) ON DELETE SET NULL,
    image_urls TEXT[] DEFAULT '{}',
    is_private BOOLEAN DEFAULT TRUE,
    entry_date DATE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_journal_entries_user ON public.journal_entries(user_id);
CREATE INDEX IF NOT EXISTS idx_journal_entries_date ON public.journal_entries(entry_date DESC);

-- ============================================
-- 26. ONBOARDING RESPONSES TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.onboarding_responses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    fitness_goals TEXT[] DEFAULT '{}',
    fitness_level TEXT NOT NULL,
    workout_days_per_week INTEGER DEFAULT 3,
    preferred_time TEXT NOT NULL,
    session_duration INTEGER DEFAULT 30,
    preferred_workout_types TEXT[] DEFAULT '{}',
    physical_limitations TEXT[] DEFAULT '{}',
    available_equipment TEXT[] DEFAULT '{}',
    biggest_challenge TEXT NOT NULL,
    current_feeling TEXT NOT NULL,
    timeline TEXT NOT NULL,
    motivation TEXT NOT NULL,
    additional_data JSONB,
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- ============================================
-- 27. NOTIFICATIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    body TEXT NOT NULL,
    image_url TEXT,
    notification_type TEXT NOT NULL,
    action_type TEXT DEFAULT 'none' CHECK (action_type IN ('navigate', 'open_url', 'deep_link', 'none')),
    screen_reference JSONB,
    external_url TEXT,
    priority TEXT DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMPTZ,
    scheduled_for TIMESTAMPTZ NOT NULL,
    is_sent BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMPTZ,
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_unread ON public.notifications(user_id, is_read) WHERE is_read = FALSE;
CREATE INDEX IF NOT EXISTS idx_notifications_scheduled ON public.notifications(scheduled_for) WHERE is_sent = FALSE;

-- ============================================
-- 28. USER NOTIFICATION SETTINGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_notification_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    push_enabled BOOLEAN DEFAULT TRUE,
    workout_reminders BOOLEAN DEFAULT TRUE,
    challenge_updates BOOLEAN DEFAULT TRUE,
    achievement_alerts BOOLEAN DEFAULT TRUE,
    social_notifications BOOLEAN DEFAULT TRUE,
    subscription_alerts BOOLEAN DEFAULT TRUE,
    marketing_notifications BOOLEAN DEFAULT FALSE,
    email_enabled BOOLEAN DEFAULT TRUE,
    email_weekly_summary BOOLEAN DEFAULT TRUE,
    email_challenge_updates BOOLEAN DEFAULT TRUE,
    email_promotions BOOLEAN DEFAULT FALSE,
    quiet_hours_enabled BOOLEAN DEFAULT FALSE,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id)
);

-- ============================================
-- 29. SUBSCRIPTIONS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS public.subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    plan TEXT NOT NULL CHECK (plan IN ('free', 'monthly', 'annual')),
    status TEXT NOT NULL CHECK (status IN ('active', 'cancelled', 'expired', 'pending')),
    stripe_customer_id TEXT,
    stripe_subscription_id TEXT,
    current_period_start TIMESTAMPTZ,
    current_period_end TIMESTAMPTZ,
    cancel_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    cancel_at_period_end BOOLEAN DEFAULT FALSE,
    amount DECIMAL(10,2),
    currency TEXT DEFAULT 'USD',
    payment_method TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_subscriptions_user ON public.subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_stripe ON public.subscriptions(stripe_customer_id);

-- ============================================
-- ENABLE ROW LEVEL SECURITY
-- ============================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trainers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievement_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.month_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.plan_weeks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.scheduled_workouts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.recipe_ratings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.onboarding_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_notification_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

COMMIT;
