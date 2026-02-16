-- ============================================================
-- COFIT COLLECTIVE - COMMUNITY SEED DATA
-- ============================================================
-- Users, Posts (text/image/challenge/recipe), Comments, Likes, Recipes
--
-- This script creates auth.users entries first, then public.users
-- so that the FK constraint (users.id → auth.users.id) is satisfied.
-- ============================================================

-- Clean existing community data (reverse order of dependencies)
DELETE FROM likes;
DELETE FROM comments;
DELETE FROM saved_posts;
DELETE FROM posts;
DELETE FROM saved_recipes;
DELETE FROM recipe_ratings;
DELETE FROM recipes;
-- Clean demo users from both tables
DELETE FROM users WHERE email LIKE '%@demo.cofit.com';
DELETE FROM auth.users WHERE email LIKE '%@demo.cofit.com';

DO $$
DECLARE
  -- ==============================
  -- USER IDs (8 demo users)
  -- ==============================
  u_sarah    UUID := gen_random_uuid();
  u_mike     UUID := gen_random_uuid();
  u_emma     UUID := gen_random_uuid();
  u_james    UUID := gen_random_uuid();
  u_olivia   UUID := gen_random_uuid();
  u_carlos   UUID := gen_random_uuid();
  u_nina     UUID := gen_random_uuid();
  u_alex     UUID := gen_random_uuid();

  -- ==============================
  -- POST IDs (15 posts)
  -- ==============================
  -- Image posts
  p_sarah_progress  UUID := gen_random_uuid();
  p_mike_gym        UUID := gen_random_uuid();
  p_emma_yoga       UUID := gen_random_uuid();
  p_carlos_outdoor  UUID := gen_random_uuid();
  p_nina_transform  UUID := gen_random_uuid();

  -- Text posts
  p_james_tip       UUID := gen_random_uuid();
  p_olivia_question UUID := gen_random_uuid();

  -- Challenge posts
  p_sarah_challenge UUID := gen_random_uuid();
  p_mike_challenge  UUID := gen_random_uuid();
  p_alex_challenge  UUID := gen_random_uuid();

  -- Recipe share posts
  p_emma_recipe     UUID := gen_random_uuid();
  p_olivia_recipe   UUID := gen_random_uuid();
  p_nina_recipe     UUID := gen_random_uuid();

  -- Workout share posts
  p_james_workout   UUID := gen_random_uuid();
  p_alex_workout    UUID := gen_random_uuid();

  -- ==============================
  -- RECIPE IDs
  -- ==============================
  r_smoothie   UUID := gen_random_uuid();
  r_bowl       UUID := gen_random_uuid();
  r_salad      UUID := gen_random_uuid();
  r_overnight  UUID := gen_random_uuid();
  r_wrap       UUID := gen_random_uuid();
  r_energy     UUID := gen_random_uuid();

  -- ==============================
  -- COMMENT IDs (for nesting replies)
  -- ==============================
  c1 UUID := gen_random_uuid();
  c2 UUID := gen_random_uuid();
  c3 UUID := gen_random_uuid();

BEGIN

-- ============================================================
-- 0. AUTH USERS (create in auth.users first to satisfy FK)
-- ============================================================
-- Password: 'demo123456' (bcrypt hash)
INSERT INTO auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, raw_app_meta_data, raw_user_meta_data, created_at, updated_at, confirmation_token, recovery_token)
VALUES
(u_sarah,  '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'sarah@demo.cofit.com',  '$2a$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', NOW(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, NOW(), NOW(), '', ''),
(u_mike,   '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'mike@demo.cofit.com',   '$2a$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', NOW(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, NOW(), NOW(), '', ''),
(u_emma,   '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'emma@demo.cofit.com',   '$2a$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', NOW(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, NOW(), NOW(), '', ''),
(u_james,  '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'james@demo.cofit.com',  '$2a$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', NOW(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, NOW(), NOW(), '', ''),
(u_olivia, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'olivia@demo.cofit.com', '$2a$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', NOW(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, NOW(), NOW(), '', ''),
(u_carlos, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'carlos@demo.cofit.com', '$2a$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', NOW(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, NOW(), NOW(), '', ''),
(u_nina,   '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'nina@demo.cofit.com',   '$2a$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', NOW(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, NOW(), NOW(), '', ''),
(u_alex,   '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'alex@demo.cofit.com',   '$2a$10$abcdefghijklmnopqrstuuABCDEFGHIJKLMNOPQRSTUVWXYZ012345', NOW(), '{"provider":"email","providers":["email"]}'::jsonb, '{}'::jsonb, NOW(), NOW(), '', '');


-- ============================================================
-- 1. USERS (8 demo users in public.users)
-- ============================================================
-- Using ON CONFLICT because Supabase's auth trigger auto-creates
-- a minimal row in public.users when auth.users is inserted.
-- We upsert to fill in all profile fields.
INSERT INTO users (id, email, full_name, username, avatar_url, bio, date_of_birth, gender, height_cm, weight_kg, fitness_level, fitness_goals, workout_days_per_week, preferred_workout_time, preferred_session_duration, preferred_workout_types, available_equipment, total_workouts_completed, total_minutes_worked_out, total_calories_burned, current_streak, longest_streak, last_workout_date, onboarding_completed, subscription_status, subscription_plan, user_type) VALUES

(u_sarah, 'sarah@demo.cofit.com', 'Sarah Johnson', 'sarahfit',
 'https://randomuser.me/api/portraits/women/28.jpg',
 'Fitness enthusiast on a journey to become my best self. Love HIIT and strength training. 6 months in and never looking back!',
 '1994-03-15', 'female', 165, 62, 'intermediate',
 ARRAY['lose weight', 'build muscle', 'improve endurance'],
 5, 'morning', 45, ARRAY['hiit', 'full_body', 'cardio'],
 ARRAY['dumbbells', 'mat', 'resistance_band'],
 87, 3480, 28500, 12, 21, NOW() - INTERVAL '1 day',
 true, 'active', 'annual', 'user'),

(u_mike, 'mike@demo.cofit.com', 'Mike Chen', 'mikepumps',
 'https://randomuser.me/api/portraits/men/45.jpg',
 'Gym bro turning into a mindful athlete. Discovering that recovery is just as important as the grind. Yoga convert.',
 '1991-07-22', 'male', 180, 85, 'advanced',
 ARRAY['build muscle', 'improve flexibility', 'stress relief'],
 6, 'afternoon', 60, ARRAY['full_body', 'upper_body', 'yoga'],
 ARRAY['dumbbells', 'mat'],
 156, 7800, 62000, 8, 34, NOW() - INTERVAL '0 days',
 true, 'active', 'monthly', 'user'),

(u_emma, 'emma@demo.cofit.com', 'Emma Wilson', 'emmawellness',
 'https://randomuser.me/api/portraits/women/35.jpg',
 'Yoga teacher by day, foodie by night. Sharing healthy recipes and mindful movement. Believe in balance, not perfection.',
 '1996-11-08', 'female', 170, 58, 'intermediate',
 ARRAY['improve flexibility', 'stress relief', 'healthy eating'],
 4, 'morning', 40, ARRAY['yoga', 'pilates', 'core'],
 ARRAY['mat'],
 112, 4480, 22000, 15, 28, NOW() - INTERVAL '0 days',
 true, 'active', 'annual', 'user'),

(u_james, 'james@demo.cofit.com', 'James Rodriguez', 'jamesfit',
 'https://randomuser.me/api/portraits/men/67.jpg',
 'Former couch potato, now addicted to the runner''s high. If I can do it, anyone can. Currently training for my first half marathon.',
 '1988-05-30', 'male', 175, 78, 'intermediate',
 ARRAY['improve endurance', 'lose weight', 'run a marathon'],
 4, 'evening', 50, ARRAY['cardio', 'hiit', 'lower_body'],
 ARRAY['none'],
 65, 3250, 26000, 5, 14, NOW() - INTERVAL '2 days',
 true, 'active', 'monthly', 'user'),

(u_olivia, 'olivia@demo.cofit.com', 'Olivia Brown', 'livfit',
 'https://randomuser.me/api/portraits/women/52.jpg',
 'New mom getting back into fitness. Taking it one day at a time. Love Pilates and anything core-focused. Clean eating advocate.',
 '1993-09-12', 'female', 163, 67, 'beginner',
 ARRAY['lose weight', 'improve core strength', 'increase energy'],
 3, 'morning', 30, ARRAY['pilates', 'core', 'yoga'],
 ARRAY['mat', 'resistance_band'],
 28, 840, 7000, 3, 7, NOW() - INTERVAL '1 day',
 true, 'active', 'monthly', 'user'),

(u_carlos, 'carlos@demo.cofit.com', 'Carlos Mendez', 'carlosstrong',
 'https://randomuser.me/api/portraits/men/22.jpg',
 'CrossFit athlete and outdoor enthusiast. Love pushing my limits and helping others find their strength. Weekend warrior.',
 '1990-12-01', 'male', 178, 82, 'advanced',
 ARRAY['build muscle', 'improve performance', 'compete'],
 5, 'afternoon', 60, ARRAY['hiit', 'full_body', 'lower_body'],
 ARRAY['dumbbells', 'mat'],
 198, 9900, 79000, 18, 45, NOW() - INTERVAL '0 days',
 true, 'active', 'annual', 'user'),

(u_nina, 'nina@demo.cofit.com', 'Nina Patel', 'ninaflows',
 'https://randomuser.me/api/portraits/women/71.jpg',
 'Pilates instructor in training. Passionate about body awareness and mindful movement. Also a nutrition nerd who loves meal prep!',
 '1995-04-18', 'female', 160, 55, 'intermediate',
 ARRAY['improve flexibility', 'build core strength', 'healthy eating'],
 5, 'morning', 45, ARRAY['pilates', 'yoga', 'core'],
 ARRAY['mat', 'resistance_band'],
 134, 6030, 33000, 22, 30, NOW() - INTERVAL '0 days',
 true, 'active', 'annual', 'user'),

(u_alex, 'alex@demo.cofit.com', 'Alex Taylor', 'alextfitness',
 'https://randomuser.me/api/portraits/men/86.jpg',
 'Tech worker fighting the sedentary lifestyle. Started 3 months ago and already feeling like a different person. Consistency over intensity!',
 '1997-08-25', 'male', 183, 90, 'beginner',
 ARRAY['lose weight', 'improve endurance', 'build healthy habits'],
 3, 'evening', 30, ARRAY['cardio', 'full_body'],
 ARRAY['none'],
 34, 1020, 8500, 4, 10, NOW() - INTERVAL '1 day',
 true, 'active', 'monthly', 'user')
ON CONFLICT (id) DO UPDATE SET
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  username = EXCLUDED.username,
  avatar_url = EXCLUDED.avatar_url,
  bio = EXCLUDED.bio,
  date_of_birth = EXCLUDED.date_of_birth,
  gender = EXCLUDED.gender,
  height_cm = EXCLUDED.height_cm,
  weight_kg = EXCLUDED.weight_kg,
  fitness_level = EXCLUDED.fitness_level,
  fitness_goals = EXCLUDED.fitness_goals,
  workout_days_per_week = EXCLUDED.workout_days_per_week,
  preferred_workout_time = EXCLUDED.preferred_workout_time,
  preferred_session_duration = EXCLUDED.preferred_session_duration,
  preferred_workout_types = EXCLUDED.preferred_workout_types,
  available_equipment = EXCLUDED.available_equipment,
  total_workouts_completed = EXCLUDED.total_workouts_completed,
  total_minutes_worked_out = EXCLUDED.total_minutes_worked_out,
  total_calories_burned = EXCLUDED.total_calories_burned,
  current_streak = EXCLUDED.current_streak,
  longest_streak = EXCLUDED.longest_streak,
  last_workout_date = EXCLUDED.last_workout_date,
  onboarding_completed = EXCLUDED.onboarding_completed,
  subscription_status = EXCLUDED.subscription_status,
  subscription_plan = EXCLUDED.subscription_plan,
  user_type = EXCLUDED.user_type;


-- ============================================================
-- 2. RECIPES (6 healthy recipes)
-- ============================================================
INSERT INTO recipes (id, user_id, title, description, image_url, image_urls, prep_time_minutes, cook_time_minutes, servings, difficulty, meal_type, dietary_tags, ingredients, instructions, calories, protein, carbs, fat, fiber, is_public, is_featured, likes_count, saves_count, average_rating, ratings_count, tags) VALUES

(r_smoothie, u_emma, 'Green Power Smoothie',
 'Start your morning with this nutrient-packed green smoothie. Loaded with spinach, banana, and protein powder, it keeps you full and energized through your morning workout.',
 'https://images.unsplash.com/photo-1638176066666-ffb2f013c7dd?w=800&h=600&fit=crop',
 ARRAY['https://images.unsplash.com/photo-1638176066666-ffb2f013c7dd?w=800&h=600&fit=crop'],
 5, 0, 1, 'easy', 'breakfast',
 ARRAY['vegan', 'gluten-free', 'high-protein'],
 '[{"name":"spinach","quantity":2,"unit":"cups","notes":"fresh"},{"name":"banana","quantity":1,"unit":"whole","notes":"frozen"},{"name":"protein powder","quantity":1,"unit":"scoop","notes":"vanilla"},{"name":"almond milk","quantity":1,"unit":"cup"},{"name":"chia seeds","quantity":1,"unit":"tbsp"},{"name":"peanut butter","quantity":1,"unit":"tbsp","is_optional":true}]'::jsonb,
 '[{"step_number":1,"instruction":"Add almond milk and spinach to blender. Blend until smooth."},{"step_number":2,"instruction":"Add frozen banana, protein powder, and chia seeds."},{"step_number":3,"instruction":"Blend on high for 60 seconds until creamy.","tip":"Add ice cubes for a thicker consistency."},{"step_number":4,"instruction":"Pour into glass and top with chia seeds. Enjoy immediately!"}]'::jsonb,
 320, 28, 35, 8, 6, true, true, 45, 32, 4.7, 18,
 ARRAY['smoothie', 'pre-workout', 'quick']),

(r_bowl, u_nina, 'Protein-Packed Buddha Bowl',
 'A colorful and satisfying lunch bowl with quinoa, roasted chickpeas, avocado, and tahini dressing. Perfect post-workout fuel that tastes as good as it looks.',
 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&h=600&fit=crop',
 ARRAY['https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&h=600&fit=crop'],
 15, 25, 2, 'medium', 'lunch',
 ARRAY['vegetarian', 'high-protein', 'meal-prep'],
 '[{"name":"quinoa","quantity":1,"unit":"cup","notes":"dry"},{"name":"chickpeas","quantity":1,"unit":"can","notes":"drained"},{"name":"sweet potato","quantity":1,"unit":"medium","notes":"cubed"},{"name":"avocado","quantity":1,"unit":"whole"},{"name":"kale","quantity":2,"unit":"cups","notes":"chopped"},{"name":"tahini","quantity":2,"unit":"tbsp"},{"name":"lemon juice","quantity":1,"unit":"tbsp"},{"name":"olive oil","quantity":1,"unit":"tbsp"}]'::jsonb,
 '[{"step_number":1,"instruction":"Cook quinoa according to package directions. Set aside."},{"step_number":2,"instruction":"Toss chickpeas and sweet potato with olive oil, salt, and cumin. Roast at 400F for 25 minutes.","timer_minutes":25},{"step_number":3,"instruction":"Massage kale with a drizzle of olive oil and lemon juice."},{"step_number":4,"instruction":"Make dressing: whisk tahini, lemon juice, garlic, and water until smooth."},{"step_number":5,"instruction":"Assemble bowls: quinoa base, roasted veggies, kale, sliced avocado. Drizzle with tahini dressing."}]'::jsonb,
 480, 22, 52, 18, 12, true, true, 67, 48, 4.8, 25,
 ARRAY['bowl', 'meal prep', 'post-workout']),

(r_salad, u_olivia, 'Mediterranean Chicken Salad',
 'A fresh and filling salad loaded with grilled chicken, cucumber, cherry tomatoes, feta cheese, and a zesty lemon-herb dressing. High protein, low carb perfection.',
 'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800&h=600&fit=crop',
 ARRAY['https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=800&h=600&fit=crop'],
 15, 10, 2, 'easy', 'lunch',
 ARRAY['high-protein', 'low-carb', 'gluten-free'],
 '[{"name":"chicken breast","quantity":2,"unit":"pieces","notes":"grilled"},{"name":"mixed greens","quantity":4,"unit":"cups"},{"name":"cucumber","quantity":1,"unit":"medium","notes":"diced"},{"name":"cherry tomatoes","quantity":1,"unit":"cup","notes":"halved"},{"name":"feta cheese","quantity":0.5,"unit":"cup","notes":"crumbled"},{"name":"kalamata olives","quantity":0.25,"unit":"cup"},{"name":"red onion","quantity":0.25,"unit":"medium","notes":"thinly sliced"},{"name":"olive oil","quantity":2,"unit":"tbsp"},{"name":"lemon juice","quantity":2,"unit":"tbsp"}]'::jsonb,
 '[{"step_number":1,"instruction":"Season chicken with salt, pepper, and oregano. Grill for 6-7 minutes per side until cooked through.","timer_minutes":14},{"step_number":2,"instruction":"Let chicken rest 5 minutes, then slice into strips."},{"step_number":3,"instruction":"In a large bowl, combine greens, cucumber, tomatoes, olives, and red onion."},{"step_number":4,"instruction":"Whisk olive oil, lemon juice, garlic, and herbs for dressing."},{"step_number":5,"instruction":"Top salad with chicken and feta. Drizzle with dressing and serve."}]'::jsonb,
 380, 42, 12, 18, 4, true, false, 38, 29, 4.6, 14,
 ARRAY['salad', 'high protein', 'mediterranean']),

(r_overnight, u_emma, 'Overnight Protein Oats',
 'Prep the night before and wake up to a delicious breakfast. Creamy oats with protein powder, berries, and a drizzle of honey. Zero morning effort required.',
 'https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=800&h=600&fit=crop',
 ARRAY['https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=800&h=600&fit=crop'],
 5, 0, 1, 'easy', 'breakfast',
 ARRAY['vegetarian', 'high-protein', 'meal-prep'],
 '[{"name":"rolled oats","quantity":0.5,"unit":"cup"},{"name":"protein powder","quantity":1,"unit":"scoop","notes":"vanilla or chocolate"},{"name":"Greek yogurt","quantity":0.25,"unit":"cup"},{"name":"milk","quantity":0.5,"unit":"cup"},{"name":"chia seeds","quantity":1,"unit":"tbsp"},{"name":"mixed berries","quantity":0.5,"unit":"cup"},{"name":"honey","quantity":1,"unit":"tsp","is_optional":true}]'::jsonb,
 '[{"step_number":1,"instruction":"In a jar or container, combine oats, protein powder, yogurt, milk, and chia seeds."},{"step_number":2,"instruction":"Stir well until protein powder is fully dissolved. No lumps!","tip":"Use a fork for better mixing."},{"step_number":3,"instruction":"Top with berries and drizzle with honey if desired."},{"step_number":4,"instruction":"Cover and refrigerate overnight (at least 6 hours).","timer_minutes":360},{"step_number":5,"instruction":"In the morning, stir and enjoy cold or microwave for 2 minutes if you prefer warm oats."}]'::jsonb,
 350, 32, 40, 8, 7, true, true, 89, 67, 4.9, 35,
 ARRAY['oats', 'meal prep', 'quick breakfast']),

(r_wrap, u_nina, 'Spicy Chicken Lettuce Wraps',
 'Crunchy, spicy, and incredibly satisfying. These Asian-inspired lettuce wraps are packed with lean ground chicken, water chestnuts, and a killer sauce. Under 300 calories!',
 'https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=800&h=600&fit=crop',
 ARRAY['https://images.unsplash.com/photo-1529006557810-274b9b2fc783?w=800&h=600&fit=crop'],
 10, 15, 4, 'easy', 'dinner',
 ARRAY['high-protein', 'low-carb', 'gluten-free'],
 '[{"name":"ground chicken","quantity":1,"unit":"lb"},{"name":"butter lettuce","quantity":1,"unit":"head"},{"name":"water chestnuts","quantity":1,"unit":"can","notes":"diced"},{"name":"green onions","quantity":3,"unit":"stalks","notes":"chopped"},{"name":"garlic","quantity":3,"unit":"cloves","notes":"minced"},{"name":"soy sauce","quantity":2,"unit":"tbsp"},{"name":"sriracha","quantity":1,"unit":"tbsp"},{"name":"sesame oil","quantity":1,"unit":"tsp"}]'::jsonb,
 '[{"step_number":1,"instruction":"Heat sesame oil in a large skillet over medium-high heat."},{"step_number":2,"instruction":"Add garlic and cook for 30 seconds until fragrant."},{"step_number":3,"instruction":"Add ground chicken, breaking it up. Cook for 6-7 minutes until browned.","timer_minutes":7},{"step_number":4,"instruction":"Add water chestnuts, soy sauce, and sriracha. Cook 2 more minutes."},{"step_number":5,"instruction":"Separate lettuce leaves and fill each with the chicken mixture."},{"step_number":6,"instruction":"Garnish with green onions and serve immediately.","tip":"Add extra sriracha if you like it hot!"}]'::jsonb,
 280, 34, 8, 12, 2, true, false, 52, 41, 4.5, 20,
 ARRAY['wraps', 'low carb', 'asian']),

(r_energy, u_sarah, 'No-Bake Energy Bites',
 'The perfect pre-workout snack or afternoon pick-me-up. Made with oats, peanut butter, chocolate chips, and honey. Batch prep for the whole week in 10 minutes!',
 'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?w=800&h=600&fit=crop',
 ARRAY['https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?w=800&h=600&fit=crop'],
 10, 0, 15, 'easy', 'snack',
 ARRAY['vegetarian', 'meal-prep', 'high-energy'],
 '[{"name":"rolled oats","quantity":1,"unit":"cup"},{"name":"peanut butter","quantity":0.5,"unit":"cup"},{"name":"honey","quantity":0.33,"unit":"cup"},{"name":"dark chocolate chips","quantity":0.25,"unit":"cup"},{"name":"flax seeds","quantity":2,"unit":"tbsp"},{"name":"vanilla extract","quantity":1,"unit":"tsp"}]'::jsonb,
 '[{"step_number":1,"instruction":"Mix all ingredients in a large bowl until fully combined."},{"step_number":2,"instruction":"Refrigerate for 30 minutes to make the mixture easier to handle.","timer_minutes":30},{"step_number":3,"instruction":"Roll into 15 small balls (about 1 tablespoon each).","tip":"Wet your hands slightly to prevent sticking."},{"step_number":4,"instruction":"Place on a parchment-lined tray and refrigerate until firm."},{"step_number":5,"instruction":"Store in an airtight container in the fridge for up to 1 week."}]'::jsonb,
 120, 5, 14, 6, 2, true, true, 73, 58, 4.8, 30,
 ARRAY['snack', 'pre-workout', 'no bake']);


-- ============================================================
-- 3. POSTS (15 posts across all types)
-- ============================================================
INSERT INTO posts (id, user_id, content, image_urls, post_type, metadata, likes_count, comments_count, tags, is_public, approval_status, is_pinned, created_at, updated_at) VALUES

-- ===== IMAGE POSTS =====
(p_sarah_progress, u_sarah,
 'Month 3 vs Month 6 - I cannot believe the difference! Consistency really is the key. No crash diets, no shortcuts - just showing up every day and putting in the work. Thank you CoFit community for keeping me accountable!',
 ARRAY['https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=600&fit=crop', 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=800&h=600&fit=crop'],
 'image', '{}'::jsonb, 47, 12,
 ARRAY['transformation', 'progress', 'consistency'],
 true, 'approved', true, NOW() - INTERVAL '2 hours', NOW() - INTERVAL '2 hours'),

(p_mike_gym, u_mike,
 'New PR on deadlifts today! 315 lbs for 3 reps. Six months ago I could barely pull 225. Marcus''s Total Body Strength program is no joke. If you have not tried it, what are you waiting for?',
 ARRAY['https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&h=600&fit=crop'],
 'image', '{}'::jsonb, 34, 8,
 ARRAY['strength', 'deadlift', 'pr'],
 true, 'approved', false, NOW() - INTERVAL '5 hours', NOW() - INTERVAL '5 hours'),

(p_emma_yoga, u_emma,
 'Sunrise yoga on the balcony this morning. There is something magical about flowing with the first light of day. Aisha''s Sunrise Yoga Flow is my go-to every Tuesday and Thursday. Who else is a morning yoga person?',
 ARRAY['https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&h=600&fit=crop', 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&h=600&fit=crop'],
 'image', '{}'::jsonb, 56, 15,
 ARRAY['yoga', 'morning routine', 'mindfulness'],
 true, 'approved', false, NOW() - INTERVAL '8 hours', NOW() - INTERVAL '8 hours'),

(p_carlos_outdoor, u_carlos,
 'Took the workout outside today. Nothing beats fresh air and natural terrain for a conditioning session. Sprints, bear crawls, and box jumps on park benches. Nature is the best gym!',
 ARRAY['https://images.unsplash.com/photo-1549576490-b0b4831ef60a?w=800&h=600&fit=crop'],
 'image', '{}'::jsonb, 29, 6,
 ARRAY['outdoor', 'conditioning', 'nature'],
 true, 'approved', false, NOW() - INTERVAL '1 day', NOW() - INTERVAL '1 day'),

(p_nina_transform, u_nina,
 'One year of Pilates has completely changed my posture and the way I carry myself. Left pic is day 1, right pic is today. Core strength is not just about abs - it is about how you move through life.',
 ARRAY['https://images.unsplash.com/photo-1575052814086-f385e2e2ad1b?w=800&h=600&fit=crop', 'https://images.unsplash.com/photo-1562771379-eafdca7a02f8?w=800&h=600&fit=crop'],
 'image', '{}'::jsonb, 72, 18,
 ARRAY['pilates', 'transformation', 'posture'],
 true, 'approved', false, NOW() - INTERVAL '1 day 3 hours', NOW() - INTERVAL '1 day 3 hours'),

-- ===== TEXT POSTS =====
(p_james_tip, u_james,
 'Pro tip for fellow beginners: Do not compare your Day 1 to someone else''s Day 365. I used to get intimidated watching people do advanced workouts. Now I realize everyone started somewhere. Focus on YOUR progress, not anyone else''s. You got this!',
 ARRAY[]::TEXT[], 'text', '{}'::jsonb, 63, 11,
 ARRAY['motivation', 'beginner', 'mindset'],
 true, 'approved', false, NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days'),

(p_olivia_question, u_olivia,
 'Question for the community: How do you stay motivated on days when you really do not feel like working out? I have been struggling with consistency lately, especially on evenings after long days with my toddler. Any tips would be appreciated!',
 ARRAY[]::TEXT[], 'text', '{}'::jsonb, 41, 22,
 ARRAY['motivation', 'question', 'community'],
 true, 'approved', false, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),

-- ===== CHALLENGE COMPLETION POSTS =====
(p_sarah_challenge, u_sarah,
 'I just completed the February Fitness Frenzy challenge! 20 workouts in one month - I actually did 23. So proud of myself for staying consistent even during that week I was feeling under the weather. Bring on March!',
 ARRAY['https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800&h=600&fit=crop'],
 'achievement',
 '{"challenge_id":"00000000-0000-0000-0000-000000000001","challenge_title":"February Fitness Frenzy","challenge_type":"workout_count","user_rank":3,"total_progress":23,"target_value":20,"target_unit":"workouts","completed_at":"2026-02-14T10:00:00Z","personal_message":"Never giving up!"}'::jsonb,
 38, 9,
 ARRAY['challenge', 'completed', 'february'],
 true, 'approved', false, NOW() - INTERVAL '12 hours', NOW() - INTERVAL '12 hours'),

(p_mike_challenge, u_mike,
 'Day 7 of the 7-Day Yoga Journey complete! As someone who always skipped stretching, this challenge opened my eyes to how important flexibility and mindfulness are. My body feels completely different. Thank you Aisha for the amazing yoga content!',
 ARRAY['https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800&h=600&fit=crop'],
 'achievement',
 '{"challenge_id":"00000000-0000-0000-0000-000000000002","challenge_title":"7-Day Yoga Journey","challenge_type":"streak","user_rank":1,"total_progress":7,"target_value":7,"target_unit":"days","completed_at":"2026-02-15T08:00:00Z","personal_message":"Yoga changed my perspective"}'::jsonb,
 52, 14,
 ARRAY['yoga', 'challenge', 'streak'],
 true, 'approved', false, NOW() - INTERVAL '6 hours', NOW() - INTERVAL '6 hours'),

(p_alex_challenge, u_alex,
 'Just hit my 10th workout for the February Frenzy! Halfway there. Not going to lie, some days were really hard, but seeing everyone else''s progress on here keeps me going. We are all in this together!',
 ARRAY[]::TEXT[],
 'achievement',
 '{"challenge_id":"00000000-0000-0000-0000-000000000001","challenge_title":"February Fitness Frenzy","challenge_type":"workout_count","user_rank":12,"total_progress":10,"target_value":20,"target_unit":"workouts","personal_message":"Halfway there!"}'::jsonb,
 25, 7,
 ARRAY['challenge', 'progress', 'motivation'],
 true, 'approved', false, NOW() - INTERVAL '1 day 6 hours', NOW() - INTERVAL '1 day 6 hours'),

-- ===== RECIPE SHARE POSTS =====
(p_emma_recipe, u_emma,
 'My go-to post-workout breakfast! This green smoothie takes 5 minutes and keeps me full until lunch. Packed with 28g of protein and tastes like a tropical treat. Recipe linked below!',
 ARRAY['https://images.unsplash.com/photo-1638176066666-ffb2f013c7dd?w=800&h=600&fit=crop'],
 'recipe_share',
 '{"recipe_title":"Green Power Smoothie","goal":"fat_loss","exercises":[],"total_duration_minutes":5,"difficulty":"beginner","notes":"Best consumed within 30 minutes of your workout"}'::jsonb,
 44, 10,
 ARRAY['recipe', 'smoothie', 'healthy'],
 true, 'approved', false, NOW() - INTERVAL '4 hours', NOW() - INTERVAL '4 hours'),

(p_olivia_recipe, u_olivia,
 'Meal prep Sunday! Made a big batch of overnight protein oats for the week. Five jars ready to grab and go. Total prep time: 10 minutes for the whole week. This is a game changer for busy mornings!',
 ARRAY['https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=800&h=600&fit=crop'],
 'recipe_share',
 '{"recipe_title":"Overnight Protein Oats","goal":"fat_loss","exercises":[],"total_duration_minutes":10,"difficulty":"beginner","notes":"Prep 5 jars on Sunday for the whole week"}'::jsonb,
 55, 13,
 ARRAY['meal prep', 'recipe', 'oats'],
 true, 'approved', false, NOW() - INTERVAL '2 days 4 hours', NOW() - INTERVAL '2 days 4 hours'),

(p_nina_recipe, u_nina,
 'This Buddha Bowl is my new obsession! Roasted chickpeas, quinoa, avocado, and the most amazing tahini dressing. 480 calories of pure deliciousness with 22g of protein. Perfect post-Pilates fuel.',
 ARRAY['https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&h=600&fit=crop'],
 'recipe_share',
 '{"recipe_title":"Protein-Packed Buddha Bowl","goal":"muscle_gain","exercises":[],"total_duration_minutes":40,"difficulty":"intermediate","notes":"Great for meal prep - keeps well for 3 days"}'::jsonb,
 61, 16,
 ARRAY['bowl', 'recipe', 'vegetarian'],
 true, 'approved', false, NOW() - INTERVAL '3 days 2 hours', NOW() - INTERVAL '3 days 2 hours'),

-- ===== WORKOUT SHARE POSTS =====
(p_james_workout, u_james,
 'Just crushed Jessica''s Fat Burn Express! 25 minutes and I am absolutely drenched. The burpee section nearly killed me but I pushed through. 380 calories burned! Who needs a gym when you have CoFit?',
 ARRAY['https://images.unsplash.com/photo-1576678927484-cc907957088c?w=800&h=600&fit=crop'],
 'workout_share', '{}'::jsonb, 31, 8,
 ARRAY['workout', 'hiit', 'fat burn'],
 true, 'approved', false, NOW() - INTERVAL '18 hours', NOW() - INTERVAL '18 hours'),

(p_alex_workout, u_alex,
 'First time trying David''s Functional Fitness workout. It was labeled beginner but my legs are shaking! The farmer''s carry at the end was brutal. Already looking forward to doing it again next week though.',
 ARRAY[]::TEXT[],
 'workout_share', '{}'::jsonb, 22, 5,
 ARRAY['workout', 'functional', 'beginner'],
 true, 'approved', false, NOW() - INTERVAL '2 days 8 hours', NOW() - INTERVAL '2 days 8 hours');


-- ============================================================
-- 4. COMMENTS (varied across posts)
-- ============================================================
INSERT INTO comments (id, post_id, user_id, parent_comment_id, content, likes_count, created_at, updated_at) VALUES

-- Comments on Sarah's progress post
(c1, p_sarah_progress, u_emma, NULL, 'This is absolutely incredible Sarah! You look so strong and confident. What a journey!', 8, NOW() - INTERVAL '1 hour 45 min', NOW() - INTERVAL '1 hour 45 min'),
(gen_random_uuid(), p_sarah_progress, u_mike, NULL, 'Gains are real! Keep crushing it. Consistency always wins.', 5, NOW() - INTERVAL '1 hour 30 min', NOW() - INTERVAL '1 hour 30 min'),
(gen_random_uuid(), p_sarah_progress, u_carlos, NULL, 'This is what dedication looks like. Respect!', 4, NOW() - INTERVAL '1 hour', NOW() - INTERVAL '1 hour'),
(gen_random_uuid(), p_sarah_progress, u_sarah, c1, 'Thank you so much Emma! Your yoga tips have been a huge part of my recovery days.', 3, NOW() - INTERVAL '50 min', NOW() - INTERVAL '50 min'),

-- Comments on Emma's yoga post
(c2, p_emma_yoga, u_nina, NULL, 'Morning yoga is the best! I have been doing Aisha''s flow every morning for 3 weeks now. Life-changing!', 6, NOW() - INTERVAL '7 hours', NOW() - INTERVAL '7 hours'),
(gen_random_uuid(), p_emma_yoga, u_sarah, NULL, 'This looks so peaceful! I need to try morning yoga instead of always going straight to HIIT.', 4, NOW() - INTERVAL '6 hours 30 min', NOW() - INTERVAL '6 hours 30 min'),
(gen_random_uuid(), p_emma_yoga, u_olivia, NULL, 'Those sunrise views! Where is this? I need to find a spot like this near me.', 3, NOW() - INTERVAL '6 hours', NOW() - INTERVAL '6 hours'),
(gen_random_uuid(), p_emma_yoga, u_emma, c2, 'It really is Nina! I feel so different on days I start with yoga vs days I skip it.', 2, NOW() - INTERVAL '5 hours', NOW() - INTERVAL '5 hours'),

-- Comments on Olivia's question post
(c3, p_olivia_question, u_james, NULL, 'I tell myself I only have to do 10 minutes. Once I start, I almost always finish the whole workout. The hardest part is pressing play!', 12, NOW() - INTERVAL '2 days 22 hours', NOW() - INTERVAL '2 days 22 hours'),
(gen_random_uuid(), p_olivia_question, u_sarah, NULL, 'I lay out my workout clothes the night before. Somehow seeing them ready makes it harder to skip. Also, shorter workouts are totally valid!', 9, NOW() - INTERVAL '2 days 20 hours', NOW() - INTERVAL '2 days 20 hours'),
(gen_random_uuid(), p_olivia_question, u_carlos, NULL, 'Find a workout buddy or accountability partner. Knowing someone is counting on you makes a huge difference.', 7, NOW() - INTERVAL '2 days 18 hours', NOW() - INTERVAL '2 days 18 hours'),
(gen_random_uuid(), p_olivia_question, u_nina, NULL, 'As a fellow busy person - I switched to morning workouts before my day gets crazy. Even 20 minutes of Pilates sets such a positive tone.', 8, NOW() - INTERVAL '2 days 16 hours', NOW() - INTERVAL '2 days 16 hours'),
(gen_random_uuid(), p_olivia_question, u_mike, NULL, 'Progress photos! Looking back at where I started always remotivates me. You are doing amazing even on the hard days.', 6, NOW() - INTERVAL '2 days 14 hours', NOW() - INTERVAL '2 days 14 hours'),
(gen_random_uuid(), p_olivia_question, u_emma, NULL, 'Yoga and stretching count as workouts too! On tired days, I do Aisha''s Deep Stretch Recovery - it is only 25 min and feels amazing.', 5, NOW() - INTERVAL '2 days 12 hours', NOW() - INTERVAL '2 days 12 hours'),
(gen_random_uuid(), p_olivia_question, u_olivia, c3, 'The 10-minute trick is genius James! I am going to try this tomorrow. Thank you!', 4, NOW() - INTERVAL '2 days 10 hours', NOW() - INTERVAL '2 days 10 hours'),

-- Comments on Mike's challenge post
(gen_random_uuid(), p_mike_challenge, u_emma, NULL, 'Welcome to the yoga family Mike! So happy to see more strength athletes embracing flexibility work.', 5, NOW() - INTERVAL '5 hours', NOW() - INTERVAL '5 hours'),
(gen_random_uuid(), p_mike_challenge, u_nina, NULL, 'This is awesome! Yoga and lifting is the perfect combination. Your recovery must be so much better now.', 4, NOW() - INTERVAL '4 hours 30 min', NOW() - INTERVAL '4 hours 30 min'),
(gen_random_uuid(), p_mike_challenge, u_sarah, NULL, 'I am starting this challenge next week! Any tips for someone who can barely touch their toes?', 3, NOW() - INTERVAL '4 hours', NOW() - INTERVAL '4 hours'),

-- Comments on Nina's transformation post
(gen_random_uuid(), p_nina_transform, u_emma, NULL, 'Your posture transformation is remarkable! Pilates really does work wonders for alignment.', 7, NOW() - INTERVAL '1 day 2 hours', NOW() - INTERVAL '1 day 2 hours'),
(gen_random_uuid(), p_nina_transform, u_carlos, NULL, 'Incredible progress Nina! Core strength is the foundation of everything.', 5, NOW() - INTERVAL '1 day 1 hour', NOW() - INTERVAL '1 day 1 hour'),

-- Comments on recipe posts
(gen_random_uuid(), p_emma_recipe, u_sarah, NULL, 'Made this today and it is SO good! Added some frozen mango too. Game changer!', 4, NOW() - INTERVAL '3 hours', NOW() - INTERVAL '3 hours'),
(gen_random_uuid(), p_emma_recipe, u_olivia, NULL, 'Can I use regular milk instead of almond milk? My toddler drinks the rest anyway haha.', 2, NOW() - INTERVAL '2 hours 30 min', NOW() - INTERVAL '2 hours 30 min'),
(gen_random_uuid(), p_emma_recipe, u_emma, NULL, 'Absolutely Olivia! Any milk works great. I have tried it with oat milk too and it is delicious.', 3, NOW() - INTERVAL '2 hours', NOW() - INTERVAL '2 hours'),

(gen_random_uuid(), p_nina_recipe, u_carlos, NULL, 'This looks incredible! How long does it keep in the fridge?', 3, NOW() - INTERVAL '3 days 1 hour', NOW() - INTERVAL '3 days 1 hour'),
(gen_random_uuid(), p_nina_recipe, u_nina, NULL, 'Thanks Carlos! It keeps well for about 3 days. Just store the dressing separately.', 2, NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
(gen_random_uuid(), p_nina_recipe, u_james, NULL, 'Finally a healthy lunch that actually tastes good AND fills me up. Made it twice already this week.', 5, NOW() - INTERVAL '2 days 22 hours', NOW() - INTERVAL '2 days 22 hours'),

-- Comments on James's tip post
(gen_random_uuid(), p_james_tip, u_alex, NULL, 'Needed to hear this today. Just started 3 months ago and sometimes I feel so behind everyone.', 8, NOW() - INTERVAL '1 day 20 hours', NOW() - INTERVAL '1 day 20 hours'),
(gen_random_uuid(), p_james_tip, u_olivia, NULL, 'So true! Comparison really is the thief of joy. Thanks for the reminder James.', 6, NOW() - INTERVAL '1 day 18 hours', NOW() - INTERVAL '1 day 18 hours'),

-- Comments on workout share posts
(gen_random_uuid(), p_james_workout, u_mike, NULL, 'Jessica''s HIIT workouts are brutal in the best way! That burpee section is legendary.', 3, NOW() - INTERVAL '17 hours', NOW() - INTERVAL '17 hours'),
(gen_random_uuid(), p_james_workout, u_sarah, NULL, 'Fat Burn Express is my favorite! Try pairing it with her Morning Energizer the next day for a killer combo.', 4, NOW() - INTERVAL '16 hours', NOW() - INTERVAL '16 hours');


-- ============================================================
-- 5. LIKES (spread across posts from various users)
-- ============================================================
INSERT INTO likes (user_id, post_id, like_type) VALUES
-- Likes on Sarah's progress
(u_mike, p_sarah_progress, 'post'),
(u_emma, p_sarah_progress, 'post'),
(u_james, p_sarah_progress, 'post'),
(u_olivia, p_sarah_progress, 'post'),
(u_carlos, p_sarah_progress, 'post'),
(u_nina, p_sarah_progress, 'post'),
(u_alex, p_sarah_progress, 'post'),

-- Likes on Mike's gym post
(u_sarah, p_mike_gym, 'post'),
(u_carlos, p_mike_gym, 'post'),
(u_james, p_mike_gym, 'post'),
(u_alex, p_mike_gym, 'post'),

-- Likes on Emma's yoga
(u_sarah, p_emma_yoga, 'post'),
(u_mike, p_emma_yoga, 'post'),
(u_nina, p_emma_yoga, 'post'),
(u_olivia, p_emma_yoga, 'post'),
(u_carlos, p_emma_yoga, 'post'),
(u_james, p_emma_yoga, 'post'),
(u_alex, p_emma_yoga, 'post'),

-- Likes on Nina's transformation
(u_sarah, p_nina_transform, 'post'),
(u_emma, p_nina_transform, 'post'),
(u_mike, p_nina_transform, 'post'),
(u_olivia, p_nina_transform, 'post'),
(u_carlos, p_nina_transform, 'post'),
(u_james, p_nina_transform, 'post'),
(u_alex, p_nina_transform, 'post'),

-- Likes on James's tip
(u_sarah, p_james_tip, 'post'),
(u_emma, p_james_tip, 'post'),
(u_mike, p_james_tip, 'post'),
(u_olivia, p_james_tip, 'post'),
(u_alex, p_james_tip, 'post'),
(u_nina, p_james_tip, 'post'),

-- Likes on Olivia's question
(u_sarah, p_olivia_question, 'post'),
(u_james, p_olivia_question, 'post'),
(u_emma, p_olivia_question, 'post'),
(u_nina, p_olivia_question, 'post'),
(u_carlos, p_olivia_question, 'post'),

-- Likes on challenge posts
(u_emma, p_sarah_challenge, 'post'),
(u_mike, p_sarah_challenge, 'post'),
(u_carlos, p_sarah_challenge, 'post'),
(u_nina, p_sarah_challenge, 'post'),

(u_sarah, p_mike_challenge, 'post'),
(u_emma, p_mike_challenge, 'post'),
(u_nina, p_mike_challenge, 'post'),
(u_carlos, p_mike_challenge, 'post'),
(u_james, p_mike_challenge, 'post'),

(u_sarah, p_alex_challenge, 'post'),
(u_mike, p_alex_challenge, 'post'),
(u_james, p_alex_challenge, 'post'),

-- Likes on recipe posts
(u_sarah, p_emma_recipe, 'post'),
(u_olivia, p_emma_recipe, 'post'),
(u_nina, p_emma_recipe, 'post'),
(u_mike, p_emma_recipe, 'post'),

(u_sarah, p_olivia_recipe, 'post'),
(u_emma, p_olivia_recipe, 'post'),
(u_nina, p_olivia_recipe, 'post'),
(u_james, p_olivia_recipe, 'post'),
(u_carlos, p_olivia_recipe, 'post'),

(u_emma, p_nina_recipe, 'post'),
(u_sarah, p_nina_recipe, 'post'),
(u_carlos, p_nina_recipe, 'post'),
(u_olivia, p_nina_recipe, 'post'),
(u_james, p_nina_recipe, 'post'),

-- Likes on workout shares
(u_sarah, p_james_workout, 'post'),
(u_mike, p_james_workout, 'post'),
(u_carlos, p_james_workout, 'post'),

(u_james, p_alex_workout, 'post'),
(u_sarah, p_alex_workout, 'post');


END $$;

-- ============================================================
-- VERIFICATION
-- ============================================================
-- SELECT 'Users' AS entity, COUNT(*) FROM users WHERE email LIKE '%@demo.cofit.com'
-- UNION ALL SELECT 'Recipes', COUNT(*) FROM recipes
-- UNION ALL SELECT 'Posts', COUNT(*) FROM posts
-- UNION ALL SELECT 'Comments', COUNT(*) FROM comments
-- UNION ALL SELECT 'Likes', COUNT(*) FROM likes;
