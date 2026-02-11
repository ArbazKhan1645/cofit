-- ============================================
-- CoFit Collective - Row Level Security Policies
-- Run this after 001_initial_schema.sql
-- ============================================

-- ============================================
-- USERS POLICIES
-- ============================================
-- Users can read all profiles (for community)
CREATE POLICY "Users can view all profiles"
    ON public.users FOR SELECT
    USING (true);

-- Users can only update their own profile
CREATE POLICY "Users can update own profile"
    ON public.users FOR UPDATE
    USING (auth.uid() = id);

-- Users can insert their own profile on signup
CREATE POLICY "Users can insert own profile"
    ON public.users FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ============================================
-- TRAINERS POLICIES
-- ============================================
CREATE POLICY "Anyone can view trainers"
    ON public.trainers FOR SELECT
    USING (is_active = true);

-- ============================================
-- WORKOUTS POLICIES
-- ============================================
CREATE POLICY "Anyone can view active workouts"
    ON public.workouts FOR SELECT
    USING (is_active = true);

-- ============================================
-- WORKOUT EXERCISES POLICIES
-- ============================================
CREATE POLICY "Anyone can view workout exercises"
    ON public.workout_exercises FOR SELECT
    USING (true);

-- ============================================
-- SAVED WORKOUTS POLICIES
-- ============================================
CREATE POLICY "Users can view own saved workouts"
    ON public.saved_workouts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can save workouts"
    ON public.saved_workouts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unsave workouts"
    ON public.saved_workouts FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- BADGES POLICIES
-- ============================================
CREATE POLICY "Anyone can view badges"
    ON public.badges FOR SELECT
    USING (is_active = true);

-- ============================================
-- USER ACHIEVEMENTS POLICIES
-- ============================================
CREATE POLICY "Users can view own achievements"
    ON public.user_achievements FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view others achievements for community"
    ON public.user_achievements FOR SELECT
    USING (true);

CREATE POLICY "System can insert achievements"
    ON public.user_achievements FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own achievements"
    ON public.user_achievements FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================
-- ACHIEVEMENT PROGRESS POLICIES
-- ============================================
CREATE POLICY "Users can view own progress"
    ON public.achievement_progress FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own progress"
    ON public.achievement_progress FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own progress"
    ON public.achievement_progress FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================
-- USER PROGRESS POLICIES
-- ============================================
CREATE POLICY "Users can view own workout progress"
    ON public.user_progress FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own workout progress"
    ON public.user_progress FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own workout progress"
    ON public.user_progress FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================
-- MONTH PROGRESS POLICIES
-- ============================================
CREATE POLICY "Users can view own month progress"
    ON public.month_progress FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own month progress"
    ON public.month_progress FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own month progress"
    ON public.month_progress FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================
-- USER PLANS POLICIES
-- ============================================
CREATE POLICY "Users can view own plans"
    ON public.user_plans FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own plans"
    ON public.user_plans FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own plans"
    ON public.user_plans FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own plans"
    ON public.user_plans FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- PLAN WEEKS POLICIES
-- ============================================
CREATE POLICY "Users can view own plan weeks"
    ON public.plan_weeks FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.user_plans
            WHERE user_plans.id = plan_weeks.plan_id
            AND user_plans.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own plan weeks"
    ON public.plan_weeks FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.user_plans
            WHERE user_plans.id = plan_id
            AND user_plans.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own plan weeks"
    ON public.plan_weeks FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.user_plans
            WHERE user_plans.id = plan_weeks.plan_id
            AND user_plans.user_id = auth.uid()
        )
    );

-- ============================================
-- SCHEDULED WORKOUTS POLICIES
-- ============================================
CREATE POLICY "Users can view own scheduled workouts"
    ON public.scheduled_workouts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own scheduled workouts"
    ON public.scheduled_workouts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own scheduled workouts"
    ON public.scheduled_workouts FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own scheduled workouts"
    ON public.scheduled_workouts FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- POSTS POLICIES
-- ============================================
CREATE POLICY "Anyone can view public posts"
    ON public.posts FOR SELECT
    USING (is_public = true);

CREATE POLICY "Users can view own posts"
    ON public.posts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create posts"
    ON public.posts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own posts"
    ON public.posts FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own posts"
    ON public.posts FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- COMMENTS POLICIES
-- ============================================
CREATE POLICY "Anyone can view comments on public posts"
    ON public.comments FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.posts
            WHERE posts.id = comments.post_id
            AND posts.is_public = true
        )
    );

CREATE POLICY "Users can create comments"
    ON public.comments FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own comments"
    ON public.comments FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments"
    ON public.comments FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- LIKES POLICIES
-- ============================================
CREATE POLICY "Anyone can view likes"
    ON public.likes FOR SELECT
    USING (true);

CREATE POLICY "Users can create likes"
    ON public.likes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own likes"
    ON public.likes FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- SHARES POLICIES
-- ============================================
CREATE POLICY "Anyone can view shares"
    ON public.shares FOR SELECT
    USING (true);

CREATE POLICY "Users can create shares"
    ON public.shares FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================
-- SAVED POSTS POLICIES
-- ============================================
CREATE POLICY "Users can view own saved posts"
    ON public.saved_posts FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can save posts"
    ON public.saved_posts FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unsave posts"
    ON public.saved_posts FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- FOLLOWS POLICIES
-- ============================================
CREATE POLICY "Anyone can view follows"
    ON public.follows FOR SELECT
    USING (true);

CREATE POLICY "Users can create follows"
    ON public.follows FOR INSERT
    WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "Users can delete own follows"
    ON public.follows FOR DELETE
    USING (auth.uid() = follower_id);

-- ============================================
-- CHALLENGES POLICIES
-- ============================================
CREATE POLICY "Anyone can view public challenges"
    ON public.challenges FOR SELECT
    USING (visibility = 'public' OR visibility = 'members_only');

-- ============================================
-- USER CHALLENGES POLICIES
-- ============================================
CREATE POLICY "Users can view own challenge participation"
    ON public.user_challenges FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can view challenge leaderboard"
    ON public.user_challenges FOR SELECT
    USING (true);

CREATE POLICY "Users can join challenges"
    ON public.user_challenges FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own challenge progress"
    ON public.user_challenges FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================
-- RECIPES POLICIES
-- ============================================
CREATE POLICY "Anyone can view public recipes"
    ON public.recipes FOR SELECT
    USING (is_public = true);

CREATE POLICY "Users can view own recipes"
    ON public.recipes FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create recipes"
    ON public.recipes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own recipes"
    ON public.recipes FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own recipes"
    ON public.recipes FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- SAVED RECIPES POLICIES
-- ============================================
CREATE POLICY "Users can view own saved recipes"
    ON public.saved_recipes FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can save recipes"
    ON public.saved_recipes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unsave recipes"
    ON public.saved_recipes FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- RECIPE RATINGS POLICIES
-- ============================================
CREATE POLICY "Anyone can view recipe ratings"
    ON public.recipe_ratings FOR SELECT
    USING (true);

CREATE POLICY "Users can create ratings"
    ON public.recipe_ratings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own ratings"
    ON public.recipe_ratings FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own ratings"
    ON public.recipe_ratings FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- JOURNAL ENTRIES POLICIES
-- ============================================
CREATE POLICY "Users can view own journal entries"
    ON public.journal_entries FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create journal entries"
    ON public.journal_entries FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own journal entries"
    ON public.journal_entries FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own journal entries"
    ON public.journal_entries FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- ONBOARDING RESPONSES POLICIES
-- ============================================
CREATE POLICY "Users can view own onboarding responses"
    ON public.onboarding_responses FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create onboarding responses"
    ON public.onboarding_responses FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own onboarding responses"
    ON public.onboarding_responses FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================
-- NOTIFICATIONS POLICIES
-- ============================================
CREATE POLICY "Users can view own notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
    ON public.notifications FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "System can insert notifications"
    ON public.notifications FOR INSERT
    WITH CHECK (true);

-- ============================================
-- USER NOTIFICATION SETTINGS POLICIES
-- ============================================
CREATE POLICY "Users can view own notification settings"
    ON public.user_notification_settings FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can create notification settings"
    ON public.user_notification_settings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notification settings"
    ON public.user_notification_settings FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================
-- SUBSCRIPTIONS POLICIES
-- ============================================
CREATE POLICY "Users can view own subscriptions"
    ON public.subscriptions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "System can manage subscriptions"
    ON public.subscriptions FOR ALL
    USING (true);

COMMIT;
