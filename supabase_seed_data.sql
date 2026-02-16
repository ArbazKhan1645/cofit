-- ============================================================
-- COFIT COLLECTIVE - SEED DATA
-- ============================================================
-- Run this in the Supabase SQL Editor to populate all tables
-- with realistic sample data for demo/testing purposes.
--
-- WARNING: This will DELETE existing data in these tables first.
-- Remove the DELETE lines below if you want to keep existing data.
-- ============================================================

-- Clean existing seed data (remove these lines to keep existing data)
DELETE FROM weekly_schedule_items;
DELETE FROM weekly_schedules;
DELETE FROM workout_exercises;
DELETE FROM workout_variants;
DELETE FROM saved_workouts;
DELETE FROM user_challenges;
DELETE FROM challenges;
DELETE FROM user_achievements;
DELETE FROM achievements;
DELETE FROM workouts;
DELETE FROM trainers;

DO $$
DECLARE
  -- ==============================
  -- TRAINER IDs
  -- ==============================
  t_jessica  UUID := gen_random_uuid();
  t_marcus   UUID := gen_random_uuid();
  t_aisha    UUID := gen_random_uuid();
  t_ryan     UUID := gen_random_uuid();
  t_sophia   UUID := gen_random_uuid();
  t_david    UUID := gen_random_uuid();

  -- ==============================
  -- WORKOUT IDs (4 per trainer = 24 total)
  -- ==============================
  -- Jessica (HIIT/Cardio)
  w_hiit_blast      UUID := gen_random_uuid();
  w_morning_energy   UUID := gen_random_uuid();
  w_fat_burn         UUID := gen_random_uuid();
  w_cardio_circuit   UUID := gen_random_uuid();

  -- Marcus (Strength/Full Body)
  w_total_strength   UUID := gen_random_uuid();
  w_upper_power      UUID := gen_random_uuid();
  w_dumbbell_full    UUID := gen_random_uuid();
  w_chest_back       UUID := gen_random_uuid();

  -- Aisha (Yoga/Pilates)
  w_sunrise_yoga     UUID := gen_random_uuid();
  w_deep_stretch     UUID := gen_random_uuid();
  w_pilates_sculpt   UUID := gen_random_uuid();
  w_flex_balance     UUID := gen_random_uuid();

  -- Ryan (CrossFit/HIIT)
  w_crossfit_wod     UUID := gen_random_uuid();
  w_hiit_warrior     UUID := gen_random_uuid();
  w_full_burn        UUID := gen_random_uuid();
  w_athletic_cond    UUID := gen_random_uuid();

  -- Sophia (Pilates/Core)
  w_core_stability   UUID := gen_random_uuid();
  w_pilates_fusion   UUID := gen_random_uuid();
  w_ab_sculptor      UUID := gen_random_uuid();
  w_lower_core       UUID := gen_random_uuid();

  -- David (Functional/Lower Body)
  w_leg_day          UUID := gen_random_uuid();
  w_glute_builder    UUID := gen_random_uuid();
  w_functional_fit   UUID := gen_random_uuid();
  w_lower_blast      UUID := gen_random_uuid();

  -- ==============================
  -- SCHEDULE ID
  -- ==============================
  sched_id UUID := gen_random_uuid();

BEGIN

-- ============================================================
-- 1. TRAINERS (6 trainers)
-- ============================================================
INSERT INTO trainers (id, full_name, email, avatar_url, bio, specialties, certifications, years_experience, instagram_handle, website_url, is_active, total_workouts, average_rating) VALUES

(t_jessica, 'Jessica Martinez',
 'jessica@cofitcollective.com',
 'https://randomuser.me/api/portraits/women/44.jpg',
 'Former competitive dancer turned fitness coach. Jessica brings energy and rhythm to every workout. Her HIIT and cardio classes are designed to push your limits while keeping you motivated with upbeat routines. She believes fitness should be fun, challenging, and accessible to everyone.',
 ARRAY['HIIT', 'Cardio', 'Dance Fitness'],
 ARRAY['ACE Certified Personal Trainer', 'NASM Group Fitness Instructor', 'Zumba Licensed Instructor'],
 8, '@jessicamfitness', 'https://jessicamartinezfit.com',
 true, 4, 4.8),

(t_marcus, 'Marcus Thompson',
 'marcus@cofitcollective.com',
 'https://randomuser.me/api/portraits/men/32.jpg',
 'Marcus is a strength and conditioning specialist with a background in collegiate athletics. He focuses on building functional strength through compound movements and progressive overload. His no-nonsense approach to training has helped hundreds of clients achieve their strength goals.',
 ARRAY['Strength Training', 'Full Body', 'Sports Conditioning'],
 ARRAY['NSCA Certified Strength & Conditioning Specialist', 'NASM Certified Personal Trainer', 'USA Weightlifting Level 1'],
 12, '@marcusliftsheavy', NULL,
 true, 4, 4.9),

(t_aisha, 'Aisha Patel',
 'aisha@cofitcollective.com',
 'https://randomuser.me/api/portraits/women/63.jpg',
 'Aisha discovered yoga during her travels through India and has been teaching for over a decade. She combines traditional yoga philosophy with modern movement science to create classes that nurture both body and mind. Her sessions focus on breath work, flexibility, and inner strength.',
 ARRAY['Yoga', 'Pilates', 'Meditation'],
 ARRAY['RYT-500 Registered Yoga Teacher', 'Pilates Method Alliance Certified', 'Mindfulness-Based Stress Reduction (MBSR)'],
 11, '@aisha_yoga_flow', 'https://aishapatelyoga.com',
 true, 4, 4.7),

(t_ryan, 'Ryan O''Brien',
 'ryan@cofitcollective.com',
 'https://randomuser.me/api/portraits/men/75.jpg',
 'Ryan is a former military fitness instructor who brings discipline and intensity to every session. His CrossFit-inspired workouts combine Olympic lifting, gymnastics, and metabolic conditioning. Known for his tough-but-fair coaching style, he pushes clients beyond what they think is possible.',
 ARRAY['CrossFit', 'HIIT', 'Olympic Lifting'],
 ARRAY['CrossFit Level 2 Trainer', 'NASM Performance Enhancement Specialist', 'First Aid/CPR/AED Certified'],
 9, '@ryan_obrien_fit', NULL,
 true, 4, 4.6),

(t_sophia, 'Sophia Chen',
 'sophia@cofitcollective.com',
 'https://randomuser.me/api/portraits/women/17.jpg',
 'Sophia is a Pilates master instructor and core specialist. With a background in physical therapy, she designs workouts that strengthen from the inside out. Her classes are perfect for anyone looking to improve posture, core stability, and body awareness.',
 ARRAY['Pilates', 'Core Training', 'Rehabilitation'],
 ARRAY['Comprehensive Pilates Certification (Balanced Body)', 'Doctor of Physical Therapy', 'Corrective Exercise Specialist'],
 7, '@sophia_pilates', 'https://sophiachenpilates.com',
 true, 4, 4.8),

(t_david, 'David Kim',
 'david@cofitcollective.com',
 'https://randomuser.me/api/portraits/men/52.jpg',
 'David specializes in functional fitness and lower body training. A former track athlete, he understands the importance of strong legs and glutes for overall performance. His workouts combine traditional strength training with plyometrics and mobility work.',
 ARRAY['Functional Training', 'Lower Body', 'Plyometrics'],
 ARRAY['ACSM Certified Personal Trainer', 'FMS Level 2 Certified', 'TRX Suspension Training Certified'],
 6, '@davidkim_fitness', NULL,
 true, 4, 4.5);


-- ============================================================
-- 2. WORKOUTS (24 workouts, 4 per trainer)
-- ============================================================
INSERT INTO workouts (id, trainer_id, title, description, thumbnail_url, video_url, duration_minutes, difficulty, category, calories_burned, equipment, target_muscles, tags, week_number, sort_order, is_premium, is_active, total_completions, average_rating, published_at) VALUES

-- ========== JESSICA (HIIT/Cardio) ==========
(w_hiit_blast, t_jessica,
 'HIIT Cardio Blast',
 'An intense 30-minute high-intensity interval training session designed to torch calories and boost your cardiovascular endurance. Alternating between all-out effort and active recovery, this workout will keep your heart rate elevated and your metabolism fired up for hours.',
 'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/4761611/4761611-hd_1920_1080_30fps.mp4',
 30, 'intermediate', 'hiit', 350, ARRAY['none'], ARRAY['full body', 'cardiovascular'],
 ARRAY['fat burn', 'no equipment', 'high intensity'], 1, 1, false, true, 234, 4.7,
 NOW() - INTERVAL '30 days'),

(w_morning_energy, t_jessica,
 'Morning Energizer',
 'Start your day with this upbeat 20-minute cardio routine that will wake up every muscle in your body. Combining light plyometrics with dance-inspired movements, this workout is perfect for getting your blood flowing and energy levels soaring.',
 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/4065204/4065204-hd_1920_1080_30fps.mp4',
 20, 'beginner', 'cardio', 200, ARRAY['none'], ARRAY['full body', 'cardiovascular'],
 ARRAY['morning', 'energy', 'beginner friendly'], 1, 2, false, true, 456, 4.8,
 NOW() - INTERVAL '25 days'),

(w_fat_burn, t_jessica,
 'Fat Burn Express',
 'No time? No problem. This explosive 25-minute HIIT workout maximizes calorie burn with compound movements that target multiple muscle groups simultaneously. Perfect for busy schedules when you need maximum results in minimum time.',
 'https://images.unsplash.com/photo-1576678927484-cc907957088c?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/4536567/4536567-hd_1920_1080_25fps.mp4',
 25, 'advanced', 'hiit', 380, ARRAY['none'], ARRAY['full body', 'core'],
 ARRAY['fat burn', 'express', 'intense'], 2, 3, false, true, 189, 4.6,
 NOW() - INTERVAL '20 days'),

(w_cardio_circuit, t_jessica,
 'Cardio Dance Circuit',
 'Get your groove on with this fun 35-minute dance-inspired cardio circuit. Combining Latin rhythms with fitness moves, you will burn calories without even realizing you are working out. Suitable for all fitness levels with easy-to-follow choreography.',
 'https://images.unsplash.com/photo-1518310383802-640c2de311b2?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/3327400/3327400-hd_1920_1080_24fps.mp4',
 35, 'beginner', 'cardio', 280, ARRAY['none'], ARRAY['full body', 'legs'],
 ARRAY['dance', 'fun', 'all levels'], 2, 4, false, true, 312, 4.9,
 NOW() - INTERVAL '15 days'),

-- ========== MARCUS (Strength/Full Body) ==========
(w_total_strength, t_marcus,
 'Total Body Strength',
 'A comprehensive 45-minute strength session hitting every major muscle group. Using compound movements like squats, deadlifts, and presses, this workout builds real-world functional strength. Progressive overload principles ensure continuous gains.',
 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/4753879/4753879-hd_1920_1080_25fps.mp4',
 45, 'intermediate', 'full_body', 400, ARRAY['dumbbells', 'mat'], ARRAY['chest', 'back', 'legs', 'shoulders'],
 ARRAY['strength', 'muscle building', 'compound'], 1, 5, false, true, 567, 4.9,
 NOW() - INTERVAL '28 days'),

(w_upper_power, t_marcus,
 'Upper Body Power',
 'Sculpt and strengthen your upper body with this focused 40-minute workout. Targeting chest, back, shoulders, and arms through a mix of pressing, pulling, and isolation exercises. Designed for building lean muscle and improving posture.',
 'https://images.unsplash.com/photo-1541534741688-6078c6bfb5c5?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/5319454/5319454-hd_1920_1080_30fps.mp4',
 40, 'intermediate', 'upper_body', 320, ARRAY['dumbbells', 'resistance_band'], ARRAY['chest', 'back', 'shoulders', 'arms'],
 ARRAY['upper body', 'strength', 'muscle tone'], 1, 6, false, true, 345, 4.8,
 NOW() - INTERVAL '22 days'),

(w_dumbbell_full, t_marcus,
 'Dumbbell Full Body Blast',
 'All you need is a pair of dumbbells for this killer 35-minute full-body workout. Marcus takes you through supersets and giant sets that keep the intensity high while building strength and endurance. A gym-quality workout you can do anywhere.',
 'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/856935/856935-hd_1920_1080_25fps.mp4',
 35, 'beginner', 'full_body', 300, ARRAY['dumbbells'], ARRAY['full body'],
 ARRAY['dumbbells only', 'home workout', 'supersets'], 2, 7, false, true, 423, 4.7,
 NOW() - INTERVAL '18 days'),

(w_chest_back, t_marcus,
 'Chest & Back Builder',
 'An advanced push-pull workout that targets your chest and back for a balanced upper body. This 50-minute session uses heavy compound lifts paired with isolation finishers to maximize muscle growth and strength gains.',
 'https://images.unsplash.com/photo-1550345332-09e3ac987658?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/4761611/4761611-hd_1920_1080_30fps.mp4',
 50, 'advanced', 'upper_body', 420, ARRAY['dumbbells', 'resistance_band'], ARRAY['chest', 'back', 'core'],
 ARRAY['push pull', 'advanced', 'hypertrophy'], 3, 8, true, true, 178, 4.8,
 NOW() - INTERVAL '12 days'),

-- ========== AISHA (Yoga/Pilates) ==========
(w_sunrise_yoga, t_aisha,
 'Sunrise Yoga Flow',
 'Welcome the day with this gentle 30-minute vinyasa flow. Moving through sun salutations and standing poses, this practice builds heat gradually while improving flexibility and balance. Finish with a calming savasana to set positive intentions for the day.',
 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/3327400/3327400-hd_1920_1080_24fps.mp4',
 30, 'beginner', 'yoga', 150, ARRAY['mat'], ARRAY['full body', 'core'],
 ARRAY['morning', 'vinyasa', 'flexibility'], 1, 9, false, true, 678, 4.9,
 NOW() - INTERVAL '26 days'),

(w_deep_stretch, t_aisha,
 'Deep Stretch Recovery',
 'This restorative 25-minute yoga session is perfect for rest days or after intense workouts. Using long-held yin poses and gentle stretches, you will release tension in tight muscles, improve range of motion, and promote faster recovery.',
 'https://images.unsplash.com/photo-1574680096145-d05b474e2155?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/5319454/5319454-hd_1920_1080_30fps.mp4',
 25, 'beginner', 'yoga', 100, ARRAY['mat'], ARRAY['hamstrings', 'hips', 'back'],
 ARRAY['recovery', 'stretching', 'yin yoga'], 1, 10, false, true, 534, 4.7,
 NOW() - INTERVAL '24 days'),

(w_pilates_sculpt, t_aisha,
 'Pilates Core Sculpt',
 'A challenging 35-minute mat Pilates workout focusing on deep core activation and full-body sculpting. Aisha guides you through the classical Pilates repertoire with modern variations that challenge stability and build long, lean muscles.',
 'https://images.unsplash.com/photo-1575052814086-f385e2e2ad1b?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/4753879/4753879-hd_1920_1080_25fps.mp4',
 35, 'intermediate', 'pilates', 200, ARRAY['mat'], ARRAY['core', 'glutes', 'back'],
 ARRAY['pilates', 'core', 'sculpt'], 2, 11, false, true, 389, 4.8,
 NOW() - INTERVAL '19 days'),

(w_flex_balance, t_aisha,
 'Flexibility & Balance',
 'Improve your flexibility and balance with this mindful 40-minute practice. Combining yoga poses with balance challenges, this session is ideal for athletes wanting to prevent injuries and anyone seeking greater body awareness.',
 'https://images.unsplash.com/photo-1518459031867-a89b944bffe4?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/4065204/4065204-hd_1920_1080_30fps.mp4',
 40, 'intermediate', 'yoga', 160, ARRAY['mat'], ARRAY['full body', 'hips', 'ankles'],
 ARRAY['balance', 'flexibility', 'injury prevention'], 3, 12, false, true, 267, 4.6,
 NOW() - INTERVAL '14 days'),

-- ========== RYAN (CrossFit/HIIT) ==========
(w_crossfit_wod, t_ryan,
 'CrossFit WOD Challenge',
 'Test your limits with this 40-minute CrossFit-inspired workout of the day. Combining heavy lifts with gymnastics movements and metabolic conditioning, this WOD will push every aspect of your fitness. Scale the movements to your level.',
 'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/4536567/4536567-hd_1920_1080_25fps.mp4',
 40, 'advanced', 'hiit', 480, ARRAY['dumbbells', 'mat'], ARRAY['full body'],
 ARRAY['crossfit', 'wod', 'competitive'], 1, 13, false, true, 156, 4.6,
 NOW() - INTERVAL '27 days'),

(w_hiit_warrior, t_ryan,
 'HIIT Warrior',
 'A brutal 30-minute HIIT session designed for those who want to be pushed to their absolute limit. 40 seconds on, 20 seconds off for 6 rounds of compound bodyweight movements that build mental toughness alongside physical fitness.',
 'https://images.unsplash.com/photo-1599058917212-d750089bc07e?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/856935/856935-hd_1920_1080_25fps.mp4',
 30, 'advanced', 'hiit', 420, ARRAY['none'], ARRAY['full body', 'cardiovascular'],
 ARRAY['warrior', 'extreme', 'no equipment'], 2, 14, false, true, 201, 4.5,
 NOW() - INTERVAL '21 days'),

(w_full_burn, t_ryan,
 'Full Body Burn',
 'This 35-minute metabolic conditioning workout combines strength and cardio into one efficient session. Using a mix of dumbbells and bodyweight exercises in circuit format, you will build strength while keeping your heart rate in the fat-burning zone.',
 'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/4761611/4761611-hd_1920_1080_30fps.mp4',
 35, 'intermediate', 'full_body', 380, ARRAY['dumbbells'], ARRAY['full body'],
 ARRAY['metabolic', 'circuit', 'burn'], 2, 15, false, true, 298, 4.7,
 NOW() - INTERVAL '16 days'),

(w_athletic_cond, t_ryan,
 'Athletic Conditioning',
 'Train like an athlete with this 45-minute conditioning workout. Featuring ladder drills, agility work, plyometrics, and sprint intervals, this session improves speed, power, and coordination. Perfect for sports enthusiasts wanting a competitive edge.',
 'https://images.unsplash.com/photo-1549576490-b0b4831ef60a?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/4065204/4065204-hd_1920_1080_30fps.mp4',
 45, 'advanced', 'cardio', 450, ARRAY['none'], ARRAY['legs', 'cardiovascular', 'core'],
 ARRAY['athletic', 'speed', 'agility'], 3, 16, true, true, 134, 4.6,
 NOW() - INTERVAL '10 days'),

-- ========== SOPHIA (Pilates/Core) ==========
(w_core_stability, t_sophia,
 'Core Stability Flow',
 'Build unshakeable core strength with this 30-minute stability-focused workout. Using Pilates principles and physical therapy techniques, Sophia guides you through exercises that strengthen your deep stabilizer muscles for better posture and injury prevention.',
 'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/3327400/3327400-hd_1920_1080_24fps.mp4',
 30, 'beginner', 'core', 180, ARRAY['mat'], ARRAY['core', 'back', 'glutes'],
 ARRAY['stability', 'posture', 'rehab friendly'], 1, 17, false, true, 445, 4.8,
 NOW() - INTERVAL '23 days'),

(w_pilates_fusion, t_sophia,
 'Pilates Fusion',
 'A creative 40-minute blend of classical Pilates with contemporary movement. This intermediate session challenges your core, improves flexibility, and builds long lean muscles. Features unique exercise combinations you will not find anywhere else.',
 'https://images.unsplash.com/photo-1562771379-eafdca7a02f8?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/5319454/5319454-hd_1920_1080_30fps.mp4',
 40, 'intermediate', 'pilates', 220, ARRAY['mat', 'resistance_band'], ARRAY['core', 'full body'],
 ARRAY['pilates', 'fusion', 'creative'], 2, 18, false, true, 312, 4.7,
 NOW() - INTERVAL '17 days'),

(w_ab_sculptor, t_sophia,
 'Ab Sculptor',
 'A laser-focused 20-minute core workout that targets every angle of your abdominals. From deep transverse activation to oblique burners and rectus crushers, this workout delivers a complete core training experience in minimal time.',
 'https://images.unsplash.com/photo-1594737625785-a6cbdabd333c?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/4753879/4753879-hd_1920_1080_25fps.mp4',
 20, 'intermediate', 'core', 160, ARRAY['mat'], ARRAY['abs', 'obliques', 'lower back'],
 ARRAY['abs', 'quick', 'targeted'], 3, 19, false, true, 567, 4.9,
 NOW() - INTERVAL '13 days'),

(w_lower_core, t_sophia,
 'Lower Core & Glutes',
 'Strengthen the connection between your core and glutes with this specialized 30-minute Pilates workout. Using slow, controlled movements with resistance bands, this session targets the muscles that matter most for lower body stability and power.',
 'https://images.unsplash.com/photo-1540497077202-7c8a3999166f?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/4536567/4536567-hd_1920_1080_25fps.mp4',
 30, 'beginner', 'core', 190, ARRAY['mat', 'resistance_band'], ARRAY['glutes', 'core', 'hips'],
 ARRAY['glutes', 'lower core', 'bands'], 1, 20, false, true, 389, 4.7,
 NOW() - INTERVAL '11 days'),

-- ========== DAVID (Functional/Lower Body) ==========
(w_leg_day, t_david,
 'Leg Day Domination',
 'The ultimate lower body workout - 45 minutes of squats, lunges, deadlifts, and more. David takes you through a progressive workout that builds serious leg strength and muscle. Not for the faint-hearted, but modifications are provided for all levels.',
 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/856935/856935-hd_1920_1080_25fps.mp4',
 45, 'advanced', 'lower_body', 400, ARRAY['dumbbells'], ARRAY['quads', 'hamstrings', 'glutes', 'calves'],
 ARRAY['leg day', 'strength', 'power'], 1, 21, false, true, 234, 4.7,
 NOW() - INTERVAL '29 days'),

(w_glute_builder, t_david,
 'Glute Builder Pro',
 'A targeted 35-minute workout designed to activate, strengthen, and sculpt your glutes from every angle. Using hip thrusts, Romanian deadlifts, and lateral band work, this session is perfect for building a stronger, more defined posterior chain.',
 'https://images.unsplash.com/photo-1607962837359-5e7e89f86776?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/4761611/4761611-hd_1920_1080_30fps.mp4',
 35, 'intermediate', 'lower_body', 280, ARRAY['dumbbells', 'resistance_band'], ARRAY['glutes', 'hamstrings', 'hips'],
 ARRAY['glutes', 'booty', 'sculpt'], 2, 22, false, true, 456, 4.8,
 NOW() - INTERVAL '20 days'),

(w_functional_fit, t_david,
 'Functional Fitness',
 'Move better in everyday life with this 30-minute functional training session. Combining movement patterns like pushing, pulling, squatting, hinging, and carrying, this workout builds real-world strength that transfers to everything you do.',
 'https://images.unsplash.com/photo-1598971639058-fab3c3109a00?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/5319454/5319454-hd_1920_1080_30fps.mp4',
 30, 'beginner', 'full_body', 250, ARRAY['dumbbells'], ARRAY['full body'],
 ARRAY['functional', 'everyday strength', 'beginner'], 2, 23, false, true, 345, 4.6,
 NOW() - INTERVAL '15 days'),

(w_lower_blast, t_david,
 'Lower Body Blast',
 'A high-intensity 25-minute lower body session combining strength moves with plyometric bursts. This workout alternates between heavy lifts and explosive jumps to build both strength and power in your legs. Finish with a targeted stretch cool-down.',
 'https://images.unsplash.com/photo-1532384748853-8f54a8f476e2?w=800&h=600&fit=crop',
 'https://videos.pexels.com/video-files/4065204/4065204-hd_1920_1080_30fps.mp4',
 25, 'intermediate', 'lower_body', 300, ARRAY['dumbbells'], ARRAY['quads', 'glutes', 'calves'],
 ARRAY['plyo', 'power', 'explosive'], 3, 24, false, true, 267, 4.5,
 NOW() - INTERVAL '8 days');


-- ============================================================
-- 3. WORKOUT EXERCISES (6-8 per workout, covering 6 workouts)
-- ============================================================

-- Exercises for: HIIT Cardio Blast (Jessica)
INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type) VALUES
(w_hiit_blast, 'Warm-Up Jog in Place', 'Light jogging in place to gradually raise heart rate. Swing your arms naturally and stay on the balls of your feet.', 0, 60, NULL, NULL, NULL, 'timed'),
(w_hiit_blast, 'Jump Squats', 'Squat down until thighs are parallel, then explode upward. Land softly and immediately go into the next rep.', 1, 40, 12, 3, 20, 'reps'),
(w_hiit_blast, 'Mountain Climbers', 'Start in plank position. Drive knees to chest alternately at maximum speed. Keep hips level and core tight.', 2, 40, NULL, NULL, 20, 'timed'),
(w_hiit_blast, 'Burpees', 'From standing, drop to push-up position, perform a push-up, jump feet to hands, and explode upward with arms overhead.', 3, 40, 10, 3, 20, 'reps'),
(w_hiit_blast, 'Rest', 'Active recovery. Walk around and keep moving. Take deep breaths.', 4, 60, NULL, NULL, NULL, 'rest'),
(w_hiit_blast, 'High Knees', 'Run in place driving knees as high as possible. Pump your arms and maintain an upright torso.', 5, 40, NULL, NULL, 20, 'timed'),
(w_hiit_blast, 'Plank Jacks', 'In plank position, jump feet wide and back together like a horizontal jumping jack. Keep core engaged throughout.', 6, 40, NULL, NULL, 20, 'timed'),
(w_hiit_blast, 'Cool-Down Stretch', 'Standing quad stretch, hamstring stretch, and deep breathing. Hold each stretch for 20 seconds.', 7, 120, NULL, NULL, NULL, 'timed');

-- Exercises for: Total Body Strength (Marcus)
INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type) VALUES
(w_total_strength, 'Dynamic Warm-Up', 'Arm circles, leg swings, hip circles, and bodyweight squats to prepare joints and muscles for heavy lifting.', 0, 120, NULL, NULL, NULL, 'timed'),
(w_total_strength, 'Goblet Squats', 'Hold dumbbell at chest level. Squat deep with chest up and elbows tracking inside knees. Drive through heels to stand.', 1, 45, 12, 4, 60, 'reps'),
(w_total_strength, 'Dumbbell Romanian Deadlifts', 'Hinge at hips with slight knee bend. Lower dumbbells along shins until you feel a hamstring stretch. Squeeze glutes at top.', 2, 45, 10, 4, 60, 'reps'),
(w_total_strength, 'Dumbbell Bench Press', 'Lie on floor or bench. Press dumbbells from chest level to full extension. Lower with control and pause at the bottom.', 3, 45, 10, 4, 60, 'reps'),
(w_total_strength, 'Bent-Over Rows', 'Hinge forward 45 degrees. Pull dumbbells to ribcage, squeezing shoulder blades together. Lower with a 2-second negative.', 4, 45, 12, 4, 60, 'reps'),
(w_total_strength, 'Rest', 'Hydrate and prepare for the next exercise block. Shake out your muscles.', 5, 90, NULL, NULL, NULL, 'rest'),
(w_total_strength, 'Overhead Press', 'Press dumbbells from shoulder height to full lockout overhead. Keep core braced and avoid arching your lower back.', 6, 45, 10, 3, 60, 'reps'),
(w_total_strength, 'Farmer''s Carry', 'Hold heavy dumbbells at sides and walk with perfect posture. Shoulders back, core tight, take controlled steps.', 7, 60, NULL, 3, 45, 'timed');

-- Exercises for: Sunrise Yoga Flow (Aisha)
INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type) VALUES
(w_sunrise_yoga, 'Seated Meditation', 'Find a comfortable seated position. Close your eyes and focus on your breath. Set an intention for your practice.', 0, 120, NULL, NULL, NULL, 'timed'),
(w_sunrise_yoga, 'Cat-Cow Flow', 'On hands and knees, alternate between arching and rounding the spine with each breath. Move slowly and mindfully.', 1, 90, NULL, NULL, NULL, 'timed'),
(w_sunrise_yoga, 'Sun Salutation A', 'Flow through the classic sequence: forward fold, halfway lift, plank, chaturanga, upward dog, downward dog. Repeat 3 rounds.', 2, 180, NULL, 3, NULL, 'timed'),
(w_sunrise_yoga, 'Warrior I to Warrior II Flow', 'From Warrior I, open hips and arms to Warrior II. Hold each for 5 breaths. Feel the strength in your legs and the openness in your chest.', 3, 120, NULL, NULL, NULL, 'timed'),
(w_sunrise_yoga, 'Triangle Pose', 'Extend your reach and open your side body in this classic standing pose. Hold for 8 breaths each side.', 4, 90, NULL, NULL, NULL, 'timed'),
(w_sunrise_yoga, 'Tree Pose', 'Find your balance on one foot. Place the other foot on your inner thigh or calf. Arms overhead or at heart center.', 5, 60, NULL, NULL, NULL, 'timed'),
(w_sunrise_yoga, 'Seated Forward Fold', 'Sit with legs extended. Hinge from hips and reach toward toes. Breathe deeply and surrender into the stretch.', 6, 90, NULL, NULL, NULL, 'timed'),
(w_sunrise_yoga, 'Savasana', 'Lie flat on your back. Close your eyes and relax every muscle. Let go of all tension and simply be.', 7, 180, NULL, NULL, NULL, 'timed');

-- Exercises for: Core Stability Flow (Sophia)
INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type) VALUES
(w_core_stability, 'Diaphragmatic Breathing', 'Lie on back with knees bent. Place hands on belly. Breathe deeply into your diaphragm, feeling your belly rise and fall.', 0, 90, NULL, NULL, NULL, 'timed'),
(w_core_stability, 'Dead Bug', 'Lie on back, arms reaching to ceiling, knees at 90 degrees. Slowly extend opposite arm and leg while keeping lower back pressed to floor.', 1, 45, 10, 3, 30, 'reps'),
(w_core_stability, 'Bird Dog', 'On hands and knees, extend opposite arm and leg simultaneously. Hold for 3 seconds, return slowly. Focus on not rotating your hips.', 2, 45, 10, 3, 30, 'reps'),
(w_core_stability, 'Forearm Plank', 'Hold a plank on your forearms. Keep a straight line from head to heels. Breathe steadily and do not let your hips sag.', 3, 45, NULL, 3, 30, 'timed'),
(w_core_stability, 'Side Plank', 'Stack feet and lift hips creating a straight line. Hold on each side. Modify by dropping the bottom knee if needed.', 4, 30, NULL, 3, 20, 'timed'),
(w_core_stability, 'Rest & Hydrate', 'Take a moment to rest. Sip water and prepare for the next set.', 5, 60, NULL, NULL, NULL, 'rest'),
(w_core_stability, 'Pilates Hundred', 'Lie on back, legs in tabletop. Curl head and shoulders up. Pump arms vigorously while breathing in for 5 counts, out for 5 counts.', 6, 60, NULL, 2, 30, 'timed'),
(w_core_stability, 'Glute Bridge', 'Lie on back, feet flat. Drive hips up squeezing glutes at top. Hold 3 seconds and lower with control.', 7, 45, 12, 3, 30, 'reps');

-- Exercises for: Leg Day Domination (David)
INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type) VALUES
(w_leg_day, 'Leg Swing Warm-Up', 'Hold a wall for balance. Swing each leg forward and back, then side to side. 20 swings per direction per leg.', 0, 120, NULL, NULL, NULL, 'timed'),
(w_leg_day, 'Dumbbell Front Squats', 'Hold dumbbells at shoulder height. Squat deep with an upright torso. Push through your heels to stand. Full range of motion.', 1, 50, 10, 4, 90, 'reps'),
(w_leg_day, 'Bulgarian Split Squats', 'Rear foot elevated on a bench or step. Lower into a deep lunge. Keep front knee tracking over toes. Alternate legs each set.', 2, 50, 10, 4, 60, 'reps'),
(w_leg_day, 'Dumbbell Stiff-Leg Deadlifts', 'Legs nearly straight, hinge at hips lowering dumbbells to mid-shin. Feel a deep stretch in hamstrings. Squeeze glutes at top.', 3, 50, 12, 4, 60, 'reps'),
(w_leg_day, 'Rest', 'Walk around and shake out your legs. Prepare for the plyometric portion.', 4, 120, NULL, NULL, NULL, 'rest'),
(w_leg_day, 'Jump Lunges', 'From a lunge position, explode upward and switch legs in the air. Land softly and go directly into the next rep.', 5, 40, 10, 3, 45, 'reps'),
(w_leg_day, 'Calf Raises', 'Stand on a step or flat ground. Rise onto your toes with a 2-second hold at the top. Lower slowly below starting position.', 6, 40, 15, 3, 30, 'reps'),
(w_leg_day, 'Wall Sit', 'Back against wall, thighs parallel to ground. Hold as long as possible. Keep breathing and push through the burn.', 7, 60, NULL, 2, 30, 'timed');

-- Exercises for: CrossFit WOD Challenge (Ryan)
INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type) VALUES
(w_crossfit_wod, 'Rowing Warm-Up', 'Easy pace rowing or jogging to elevate heart rate. Include dynamic stretches between sets.', 0, 120, NULL, NULL, NULL, 'timed'),
(w_crossfit_wod, 'Thrusters', 'Front squat into overhead press in one fluid motion. Keep core tight and drive through heels. This is the ultimate compound movement.', 1, 60, 15, 3, 60, 'reps'),
(w_crossfit_wod, 'Pull-Up / Banded Pull-Up', 'Full range pull-ups from dead hang. Scale with resistance band if needed. Focus on getting chin above the bar.', 2, 60, 10, 3, 60, 'reps'),
(w_crossfit_wod, 'Box Jumps / Step-Ups', 'Jump onto a box or step, landing softly with both feet. Step down and repeat. Scale to step-ups if needed.', 3, 45, 12, 3, 45, 'reps'),
(w_crossfit_wod, 'Rest', 'Active recovery. Walk around and keep blood flowing. 2 minutes before the AMRAP.', 4, 120, NULL, NULL, NULL, 'rest'),
(w_crossfit_wod, 'AMRAP - Burpees', 'As Many Reps As Possible in 3 minutes. Chest to floor burpees with a jump at the top. Push your limits.', 5, 180, NULL, NULL, NULL, 'timed'),
(w_crossfit_wod, 'Dumbbell Snatches', 'Single-arm dumbbell snatch from ground to overhead in one explosive movement. Alternate arms each rep.', 6, 45, 10, 3, 45, 'reps'),
(w_crossfit_wod, 'Cool-Down & Stretch', 'Full body stretching focusing on shoulders, hips, and legs. Hold each stretch for 30 seconds minimum.', 7, 180, NULL, NULL, NULL, 'timed');


-- ============================================================
-- 4. ACHIEVEMENTS (15 achievements)
-- ============================================================
-- Icon codes reference: https://api.flutter.dev/flutter/material/Icons-class.html
-- 0xe5d2 = fitness_center, 0xe567 = timer, 0xe866 = local_fire_department
-- 0xe518 = star, 0xf06bc = sports_score, 0xe332 = emoji_events
-- 0xe0e9 = flash_on, 0xe043 = directions_run, 0xe559 = today
-- 0xef83 = self_improvement, 0xe14f = favorite, 0xe30b = military_tech
-- 0xe612 = trending_up, 0xf854 = rocket_launch, 0xe6e1 = whatshot

INSERT INTO achievements (name, description, icon_code, type, target_value, target_unit, category, target_category, is_active, sort_order) VALUES

-- Milestone Achievements
('First Step', 'Complete your very first workout. Every journey begins with a single step!', 58322, 'first_workout', 1, 'workouts', 'milestone', NULL, true, 1),
('Challenge Accepted', 'Complete your first community challenge. You are ready for anything!', 58162, 'first_challenge', 1, 'challenges', 'milestone', NULL, true, 2),

-- Workout Count Achievements
('Getting Started', 'Complete 5 workouts. You are building a great habit!', 58834, 'workout_count', 5, 'workouts', 'workout', NULL, true, 3),
('Workout Warrior', 'Complete 25 workouts. You are on fire!', 58834, 'workout_count', 25, 'workouts', 'workout', NULL, true, 4),
('Century Club', 'Complete 100 workouts. You are a true fitness champion!', 58099, 'workout_count', 100, 'workouts', 'workout', NULL, true, 5),

-- Streak Achievements
('3-Day Streak', 'Work out for 3 consecutive days. Consistency is key!', 59043, 'streak_days', 3, 'days', 'streak', NULL, true, 6),
('Week Warrior', 'Maintain a 7-day workout streak. An entire week of dedication!', 59043, 'streak_days', 7, 'days', 'streak', NULL, true, 7),
('Monthly Machine', 'Maintain a 30-day workout streak. You are unstoppable!', 61524, 'streak_days', 30, 'days', 'streak', NULL, true, 8),

-- Minutes Achievements
('Hour Power', 'Accumulate 60 minutes of total workout time.', 58727, 'workout_minutes', 60, 'minutes', 'workout', NULL, true, 9),
('Marathon Mover', 'Accumulate 500 minutes of total workout time. That is over 8 hours of training!', 58727, 'workout_minutes', 500, 'minutes', 'workout', NULL, true, 10),

-- Calories Achievements
('Calorie Crusher', 'Burn 1,000 total calories through workouts.', 58854, 'calories_burned', 1000, 'calories', 'workout', NULL, true, 11),
('Inferno Mode', 'Burn 5,000 total calories. You are a calorie-burning machine!', 59105, 'calories_burned', 5000, 'calories', 'workout', NULL, true, 12),

-- Category-Specific Achievements
('Yoga Devotee', 'Complete 10 yoga workouts. Find your inner peace and strength.', 61315, 'category_workouts', 10, 'workouts', 'special', 'yoga', true, 13),
('HIIT Hero', 'Complete 10 HIIT workouts. You thrive on intensity!', 57577, 'category_workouts', 10, 'workouts', 'special', 'hiit', true, 14),

-- Challenge Achievements
('Challenge Champion', 'Complete 5 community challenges. You are a team player!', 58675, 'challenge_completions', 5, 'challenges', 'community', NULL, true, 15);


-- ============================================================
-- 5. CHALLENGES (5 challenges)
-- ============================================================
INSERT INTO challenges (title, description, image_url, challenge_type, target_category, target_value, target_unit, start_date, end_date, status, visibility, participant_count, max_participants, rules, prizes, is_featured) VALUES

('February Fitness Frenzy',
 'Kick off February strong with 20 workouts this month! Any workout counts - from yoga to HIIT to strength training. Push yourself and join the community in crushing this goal together.',
 'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?w=800&h=600&fit=crop',
 'workout_count', NULL, 20, 'workouts',
 '2026-02-01', '2026-02-28', 'active', 'public', 47, NULL,
 ARRAY['Any workout type counts toward your total', 'Workouts must be at least 15 minutes long', 'Track your progress in the app after each workout'],
 '[{"rank": 0, "title": "Completion Badge", "description": "Earn the February Frenzy badge", "xp_reward": 500}]'::jsonb,
 true),

('7-Day Yoga Journey',
 'Discover the transformative power of daily yoga. Complete one yoga session every day for 7 consecutive days. Build flexibility, reduce stress, and develop a lasting practice.',
 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&h=600&fit=crop',
 'streak', 'yoga', 7, 'days',
 '2026-02-10', '2026-03-10', 'active', 'public', 32, 50,
 ARRAY['Must complete a yoga workout each day', 'Any yoga workout from the library counts', 'Missing a day resets your streak'],
 '[{"rank": 0, "title": "Yoga Explorer Badge", "description": "Awarded for completing the 7-day journey", "xp_reward": 300}]'::jsonb,
 true),

('Calorie Torch Challenge',
 'Can you burn 3,000 calories in 2 weeks? Track your calorie burn across all workouts and see how you stack up against the community. Every rep counts!',
 'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=800&h=600&fit=crop',
 'calories', NULL, 3000, 'calories',
 '2026-02-15', '2026-03-01', 'active', 'public', 28, NULL,
 ARRAY['All workout types contribute to calorie total', 'Calorie burns are estimated based on workout type and duration', 'Leaderboard updates in real-time'],
 '[{"rank": 1, "title": "Torch Master", "description": "Highest calorie burn wins", "xp_reward": 1000}, {"rank": 0, "title": "Heat Seeker", "description": "Complete the 3,000 calorie goal", "xp_reward": 400}]'::jsonb,
 false),

('March Strength Month',
 'Get stronger this March! Complete 15 strength-focused workouts including full body, upper body, and lower body sessions. Build muscle, build confidence.',
 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&h=600&fit=crop',
 'specific_category', 'full_body', 15, 'workouts',
 '2026-03-01', '2026-03-31', 'upcoming', 'public', 0, 100,
 ARRAY['Only strength workouts count (Full Body, Upper Body, Lower Body)', 'Minimum workout duration of 20 minutes', 'Complete workouts with proper form'],
 '[{"rank": 1, "title": "Iron Champion", "description": "Most strength workouts completed", "xp_reward": 800}, {"rank": 0, "title": "Strength Builder", "description": "Complete all 15 workouts", "xp_reward": 500}]'::jsonb,
 true),

('10K Minutes Club',
 'A long-term challenge for the dedicated. Accumulate 10,000 minutes of total workout time. This is a marathon, not a sprint - take your time and stay consistent.',
 'https://images.unsplash.com/photo-1517963879433-6ad2b056d712?w=800&h=600&fit=crop',
 'minutes', NULL, 10000, 'minutes',
 '2026-01-01', '2026-12-31', 'active', 'members_only', 15, NULL,
 ARRAY['All workout types and durations count', 'Progress accumulates over the entire year', 'Check in weekly to track your standing'],
 '[{"rank": 0, "title": "10K Legend", "description": "Join the exclusive 10K minutes club", "xp_reward": 2000}]'::jsonb,
 false);


-- ============================================================
-- 6. WEEKLY SCHEDULE (1 active schedule with workouts assigned)
-- ============================================================
INSERT INTO weekly_schedules (id, title, disabled_days, is_active)
VALUES (sched_id, 'CoFit Weekly Plan', ARRAY[6], true);
-- Sunday (6) is rest day

INSERT INTO weekly_schedule_items (schedule_id, day_of_week, workout_id, sort_order) VALUES
-- Monday: Morning + Strength
(sched_id, 0, w_morning_energy, 0),
(sched_id, 0, w_total_strength, 1),

-- Tuesday: Yoga + Core
(sched_id, 1, w_sunrise_yoga, 0),
(sched_id, 1, w_core_stability, 1),

-- Wednesday: HIIT
(sched_id, 2, w_hiit_blast, 0),
(sched_id, 2, w_full_burn, 1),

-- Thursday: Pilates + Lower Body
(sched_id, 3, w_pilates_fusion, 0),
(sched_id, 3, w_glute_builder, 1),

-- Friday: Full Body Power
(sched_id, 4, w_crossfit_wod, 0),
(sched_id, 4, w_dumbbell_full, 1),

-- Saturday: Recovery + Flexibility
(sched_id, 5, w_deep_stretch, 0),
(sched_id, 5, w_flex_balance, 1);

-- Sunday (6) = REST DAY (no items, disabled_days=[6])


END $$;

-- ============================================================
-- VERIFICATION QUERIES (run these to confirm data was inserted)
-- ============================================================
-- SELECT 'Trainers:' AS entity, COUNT(*) AS count FROM trainers
-- UNION ALL SELECT 'Workouts', COUNT(*) FROM workouts
-- UNION ALL SELECT 'Exercises', COUNT(*) FROM workout_exercises
-- UNION ALL SELECT 'Achievements', COUNT(*) FROM achievements
-- UNION ALL SELECT 'Challenges', COUNT(*) FROM challenges
-- UNION ALL SELECT 'Schedule Items', COUNT(*) FROM weekly_schedule_items;
