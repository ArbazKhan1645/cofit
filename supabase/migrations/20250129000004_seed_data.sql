-- ============================================
-- CoFit Collective - Seed Data
-- Initial badges, trainers, and sample workouts
-- ============================================

-- ============================================
-- BADGES SEED DATA
-- ============================================
INSERT INTO public.badges (id, name, description, icon_url, category, requirement_type, required_count, xp_reward, rarity, sort_order) VALUES
-- Streak Badges
('550e8400-e29b-41d4-a716-446655440001', 'First Steps', 'Complete your first workout', 'badges/first_steps.png', 'workout', 'workouts_completed', 1, 10, 'common', 1),
('550e8400-e29b-41d4-a716-446655440002', 'Week Warrior', 'Complete 7 workouts', 'badges/week_warrior.png', 'workout', 'workouts_completed', 7, 50, 'common', 2),
('550e8400-e29b-41d4-a716-446655440003', 'Dedicated', 'Complete 30 workouts', 'badges/dedicated.png', 'workout', 'workouts_completed', 30, 150, 'rare', 3),
('550e8400-e29b-41d4-a716-446655440004', 'Century Club', 'Complete 100 workouts', 'badges/century.png', 'workout', 'workouts_completed', 100, 500, 'epic', 4),
('550e8400-e29b-41d4-a716-446655440005', 'Fitness Legend', 'Complete 500 workouts', 'badges/legend.png', 'workout', 'workouts_completed', 500, 2000, 'legendary', 5),

-- Streak Badges
('550e8400-e29b-41d4-a716-446655440011', '3 Day Streak', 'Maintain a 3-day workout streak', 'badges/streak_3.png', 'streak', 'streak_days', 3, 30, 'common', 10),
('550e8400-e29b-41d4-a716-446655440012', 'Week Streak', 'Maintain a 7-day workout streak', 'badges/streak_7.png', 'streak', 'streak_days', 7, 75, 'rare', 11),
('550e8400-e29b-41d4-a716-446655440013', 'Two Week Streak', 'Maintain a 14-day workout streak', 'badges/streak_14.png', 'streak', 'streak_days', 14, 150, 'rare', 12),
('550e8400-e29b-41d4-a716-446655440014', 'Month Master', 'Maintain a 30-day workout streak', 'badges/streak_30.png', 'streak', 'streak_days', 30, 500, 'epic', 13),
('550e8400-e29b-41d4-a716-446655440015', 'Unstoppable', 'Maintain a 60-day workout streak', 'badges/streak_60.png', 'streak', 'streak_days', 60, 1000, 'legendary', 14),

-- Community Badges
('550e8400-e29b-41d4-a716-446655440021', 'Social Butterfly', 'Make your first post', 'badges/social.png', 'community', 'posts_created', 1, 20, 'common', 20),
('550e8400-e29b-41d4-a716-446655440022', 'Supporter', 'Like 50 community posts', 'badges/supporter.png', 'community', 'likes_given', 50, 50, 'common', 21),
('550e8400-e29b-41d4-a716-446655440023', 'Challenge Champ', 'Complete a challenge', 'badges/challenge.png', 'community', 'challenges_completed', 1, 100, 'rare', 22),
('550e8400-e29b-41d4-a716-446655440024', 'Recipe Master', 'Share 5 recipes', 'badges/recipe.png', 'community', 'recipes_shared', 5, 75, 'rare', 23),

-- Special Badges
('550e8400-e29b-41d4-a716-446655440031', 'Early Bird', 'Complete a workout before 7 AM', 'badges/early_bird.png', 'special', 'morning_workout', 1, 25, 'common', 30),
('550e8400-e29b-41d4-a716-446655440032', 'Night Owl', 'Complete a workout after 9 PM', 'badges/night_owl.png', 'special', 'evening_workout', 1, 25, 'common', 31),
('550e8400-e29b-41d4-a716-446655440033', 'Weekend Warrior', 'Complete workouts on 4 consecutive weekends', 'badges/weekend.png', 'special', 'weekend_workouts', 4, 100, 'rare', 32);

-- ============================================
-- TRAINERS SEED DATA
-- ============================================
INSERT INTO public.trainers (id, full_name, email, avatar_url, bio, specialties, certifications, years_experience, instagram_handle, is_active) VALUES
('660e8400-e29b-41d4-a716-446655440001', 'Jess', 'jess@cofitcollective.com', 'trainers/jess.jpg',
 'Hey beautiful! I''m Jess, your go-to trainer for all things strength and HIIT. I believe fitness should be fun, challenging, and totally empowering. Let''s crush those goals together!',
 ARRAY['Strength Training', 'HIIT', 'Full Body', 'Core'],
 ARRAY['NASM Certified', 'CrossFit L2', 'TRX Certified'],
 8, '@jess_fit', true),

('660e8400-e29b-41d4-a716-446655440002', 'Nadine', 'nadine@cofitcollective.com', 'trainers/nadine.jpg',
 'Namaste! I''m Nadine, and I''m here to guide you through mindful movement and inner peace. My classes focus on flexibility, strength, and connecting with your body.',
 ARRAY['Yoga', 'Pilates', 'Stretching', 'Meditation'],
 ARRAY['RYT-500', 'Pilates Certified', 'Meditation Teacher'],
 10, '@nadine_wellness', true);

-- ============================================
-- WORKOUTS SEED DATA (Week 1 Rotation)
-- ============================================
INSERT INTO public.workouts (id, trainer_id, title, description, thumbnail_url, video_url, duration_minutes, difficulty, category, calories_burned, equipment, target_muscles, tags, week_number, sort_order) VALUES
-- Jess Workouts (Week 1)
('770e8400-e29b-41d4-a716-446655440001', '660e8400-e29b-41d4-a716-446655440001',
 'Full Body Burn', 'A complete full body workout to get your heart pumping and muscles working. Perfect for starting your fitness journey!',
 'workouts/full_body_burn.jpg', 'workouts/full_body_burn.mp4',
 30, 'intermediate', 'full_body', 250,
 ARRAY['mat', 'dumbbells'], ARRAY['full_body', 'core', 'legs', 'arms'],
 ARRAY['strength', 'cardio', 'endurance'], 1, 1),

('770e8400-e29b-41d4-a716-446655440002', '660e8400-e29b-41d4-a716-446655440001',
 'Core Crusher', 'Target your core with this intense ab-focused workout. Build a strong foundation for all your movements!',
 'workouts/core_crusher.jpg', 'workouts/core_crusher.mp4',
 20, 'beginner', 'core', 150,
 ARRAY['mat'], ARRAY['abs', 'obliques', 'lower_back'],
 ARRAY['core', 'strength', 'beginner_friendly'], 1, 2),

('770e8400-e29b-41d4-a716-446655440003', '660e8400-e29b-41d4-a716-446655440001',
 'Lower Body Sculpt', 'Sculpt and tone your legs and glutes with this targeted workout. Feel the burn in all the right places!',
 'workouts/lower_body_sculpt.jpg', 'workouts/lower_body_sculpt.mp4',
 35, 'intermediate', 'lower_body', 280,
 ARRAY['mat', 'resistance_band'], ARRAY['glutes', 'quads', 'hamstrings', 'calves'],
 ARRAY['legs', 'booty', 'strength', 'toning'], 1, 3),

('770e8400-e29b-41d4-a716-446655440004', '660e8400-e29b-41d4-a716-446655440001',
 'Cardio Dance Party', 'Get moving with this fun dance cardio session! No choreography experience needed - just have fun!',
 'workouts/cardio_dance.jpg', 'workouts/cardio_dance.mp4',
 25, 'beginner', 'cardio', 200,
 ARRAY['none'], ARRAY['full_body'],
 ARRAY['cardio', 'dance', 'fun', 'beginner_friendly'], 1, 4),

-- Nadine Workouts (Week 1)
('770e8400-e29b-41d4-a716-446655440005', '660e8400-e29b-41d4-a716-446655440002',
 'Upper Body Strength', 'Build strength in your arms, shoulders, and back. Perfect for creating a balanced, strong upper body!',
 'workouts/upper_body_strength.jpg', 'workouts/upper_body_strength.mp4',
 30, 'intermediate', 'upper_body', 220,
 ARRAY['dumbbells', 'mat'], ARRAY['shoulders', 'arms', 'back', 'chest'],
 ARRAY['strength', 'upper_body', 'toning'], 1, 5),

('770e8400-e29b-41d4-a716-446655440006', '660e8400-e29b-41d4-a716-446655440002',
 'HIIT Blast', 'High intensity interval training to maximize calorie burn. Push your limits and feel amazing!',
 'workouts/hiit_blast.jpg', 'workouts/hiit_blast.mp4',
 20, 'advanced', 'hiit', 300,
 ARRAY['none'], ARRAY['full_body'],
 ARRAY['hiit', 'cardio', 'fat_burn', 'advanced'], 1, 6),

('770e8400-e29b-41d4-a716-446655440007', '660e8400-e29b-41d4-a716-446655440002',
 'Yoga Flow', 'Relax and stretch with this calming yoga session. Perfect for recovery days or when you need to destress.',
 'workouts/yoga_flow.jpg', 'workouts/yoga_flow.mp4',
 40, 'beginner', 'yoga', 120,
 ARRAY['mat'], ARRAY['full_body', 'flexibility'],
 ARRAY['yoga', 'flexibility', 'relaxation', 'mindfulness'], 1, 7),

('770e8400-e29b-41d4-a716-446655440008', '660e8400-e29b-41d4-a716-446655440002',
 'Pilates Power', 'Strengthen your core and improve posture with Pilates. Build long, lean muscles!',
 'workouts/pilates_power.jpg', 'workouts/pilates_power.mp4',
 35, 'intermediate', 'pilates', 180,
 ARRAY['mat'], ARRAY['core', 'back', 'legs'],
 ARRAY['pilates', 'core', 'posture', 'toning'], 1, 8);

-- ============================================
-- SAMPLE CHALLENGES
-- ============================================
INSERT INTO public.challenges (id, title, description, image_url, challenge_type, target_value, target_unit, start_date, end_date, status, visibility, rules, is_featured) VALUES
('880e8400-e29b-41d4-a716-446655440001',
 '7 Day Workout Streak',
 'Complete a workout every day for 7 consecutive days. Any workout counts! Build the habit of daily movement.',
 'challenges/streak_7.jpg',
 'streak', 7, 'days',
 CURRENT_DATE, CURRENT_DATE + INTERVAL '14 days',
 'active', 'public',
 ARRAY['Complete any workout daily', 'Rest days count if you do stretching', 'Track your progress in the app'],
 true),

('880e8400-e29b-41d4-a716-446655440002',
 'February Fitness',
 'Complete 20 workouts this month. Consistency is the key to results!',
 'challenges/monthly.jpg',
 'workout_count', 20, 'workouts',
 DATE_TRUNC('month', CURRENT_DATE), DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day',
 'active', 'public',
 ARRAY['Any workout counts', 'Complete at your own pace', 'Minimum 15 minutes per workout'],
 true),

('880e8400-e29b-41d4-a716-446655440003',
 'Core Crusher Challenge',
 'Complete 10 core-focused workouts this month. Build that strong foundation!',
 'challenges/core.jpg',
 'specific_category', 10, 'core workouts',
 CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days',
 'active', 'public',
 ARRAY['Only core category workouts count', 'Mix it up with different core workouts'],
 false);

COMMIT;
