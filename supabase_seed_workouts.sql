-- ============================================================
-- COFIT COLLECTIVE - WORKOUT SEED DATA WITH FULL VARIANTS
-- ============================================================
-- Creates 6 new workouts (1 per trainer) with:
--   • All 18 condition-based variants per workout (108 total)
--   • Default exercises for each workout
--   • Condition-appropriate exercises for every variant
--
-- Variant groups:
--   G1 Lower Body Protected: knee_issue, ankle_issue, hip_issue, foot_issue
--   G2 Upper Body Protected: shoulder_issue, elbow_issue, wrist_issue, neck_issue
--   G3 Back Protected:       lower_back_issue, upper_back_issue
--   G4 Low Impact:           cardio_limit, balance_issue, overweight_safe
--   G5 Extra Gentle:         pregnancy_safe, senior_safe, rehab_mode
--   G6 Mobility Only:        mobility_only
--   G7 Beginner:             beginner
-- ============================================================

DO $$
DECLARE
  -- Trainer IDs (fetched from existing data)
  t_jessica UUID;
  t_marcus  UUID;
  t_aisha   UUID;
  t_ryan    UUID;
  t_sophia  UUID;
  t_david   UUID;

  -- New Workout IDs
  w1 UUID := gen_random_uuid();  -- Cardio Kickstart
  w2 UUID := gen_random_uuid();  -- Strength Foundations
  w3 UUID := gen_random_uuid();  -- Gentle Morning Flow
  w4 UUID := gen_random_uuid();  -- Power HIIT Challenge
  w5 UUID := gen_random_uuid();  -- Core Pilates Essentials
  w6 UUID := gen_random_uuid();  -- Leg Day Power

BEGIN

  -- ============================================================
  -- FETCH EXISTING TRAINER IDs
  -- ============================================================
  SELECT id INTO t_jessica FROM trainers WHERE full_name = 'Jessica Martinez' LIMIT 1;
  SELECT id INTO t_marcus  FROM trainers WHERE full_name = 'Marcus Thompson' LIMIT 1;
  SELECT id INTO t_aisha   FROM trainers WHERE full_name = 'Aisha Patel' LIMIT 1;
  SELECT id INTO t_ryan    FROM trainers WHERE full_name LIKE 'Ryan O%' LIMIT 1;
  SELECT id INTO t_sophia  FROM trainers WHERE full_name = 'Sophia Chen' LIMIT 1;
  SELECT id INTO t_david   FROM trainers WHERE full_name = 'David Kim' LIMIT 1;


  -- ============================================================
  -- 1. WORKOUTS (6 new workouts)
  -- ============================================================
  INSERT INTO workouts (id, trainer_id, title, description, thumbnail_url, video_url, duration_minutes, difficulty, category, calories_burned, equipment, target_muscles, tags, week_number, sort_order, is_premium, is_active, total_completions, average_rating, published_at) VALUES

  (w1, t_jessica,
   'Cardio Kickstart',
   'A fun 30-minute cardio session to get your heart pumping and energy flowing. Mixing bodyweight intervals with active recovery, this workout is perfect for burning calories and improving cardiovascular fitness.',
   'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=800&h=600&fit=crop',
   'https://videos.pexels.com/video-files/4761611/4761611-hd_1920_1080_30fps.mp4',
   30, 'intermediate', 'hiit', 320, ARRAY['none'], ARRAY['full body', 'cardiovascular'],
   ARRAY['cardio', 'no equipment', 'fat burn'], 1, 25, false, true, 0, 0.0, NOW()),

  (w2, t_marcus,
   'Strength Foundations',
   'Build real strength with this 35-minute full-body dumbbell workout. Focusing on compound movements with controlled tempo, this session develops muscle, stability, and confidence for lifters of all levels.',
   'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800&h=600&fit=crop',
   'https://videos.pexels.com/video-files/4753879/4753879-hd_1920_1080_25fps.mp4',
   35, 'intermediate', 'full_body', 350, ARRAY['dumbbells', 'mat'], ARRAY['chest', 'back', 'legs', 'shoulders'],
   ARRAY['strength', 'dumbbells', 'compound'], 1, 26, false, true, 0, 0.0, NOW()),

  (w3, t_aisha,
   'Gentle Morning Flow',
   'A calming 25-minute yoga session to start your day with intention. Flowing through gentle sun salutations, standing poses, and seated stretches, this practice nurtures both body and mind.',
   'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=800&h=600&fit=crop',
   'https://videos.pexels.com/video-files/3327400/3327400-hd_1920_1080_24fps.mp4',
   25, 'beginner', 'yoga', 130, ARRAY['mat'], ARRAY['full body', 'core', 'hips'],
   ARRAY['yoga', 'morning', 'flexibility'], 1, 27, false, true, 0, 0.0, NOW()),

  (w4, t_ryan,
   'Power HIIT Challenge',
   'Push your limits with this 35-minute advanced HIIT workout. Combining dumbbell power moves with explosive bodyweight intervals, this session builds strength and endurance simultaneously.',
   'https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=800&h=600&fit=crop',
   'https://videos.pexels.com/video-files/4536567/4536567-hd_1920_1080_25fps.mp4',
   35, 'advanced', 'hiit', 450, ARRAY['dumbbells', 'mat'], ARRAY['full body', 'cardiovascular'],
   ARRAY['hiit', 'power', 'advanced'], 2, 28, false, true, 0, 0.0, NOW()),

  (w5, t_sophia,
   'Core Pilates Essentials',
   'Strengthen your core from the inside out with this 25-minute Pilates mat workout. Using controlled movements and breath work, build deep core stability, improve posture, and develop body awareness.',
   'https://images.unsplash.com/photo-1575052814086-f385e2e2ad1b?w=800&h=600&fit=crop',
   'https://videos.pexels.com/video-files/5319454/5319454-hd_1920_1080_30fps.mp4',
   25, 'beginner', 'pilates', 160, ARRAY['mat'], ARRAY['core', 'back', 'glutes'],
   ARRAY['pilates', 'core', 'posture'], 2, 29, false, true, 0, 0.0, NOW()),

  (w6, t_david,
   'Leg Day Power',
   'A focused 35-minute lower body workout targeting quads, hamstrings, glutes, and calves. Using dumbbells and bodyweight, this session builds serious leg strength with progressive intensity.',
   'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=800&h=600&fit=crop',
   'https://videos.pexels.com/video-files/856935/856935-hd_1920_1080_25fps.mp4',
   35, 'intermediate', 'lower_body', 340, ARRAY['dumbbells'], ARRAY['quads', 'hamstrings', 'glutes', 'calves'],
   ARRAY['legs', 'strength', 'glutes'], 2, 30, false, true, 0, 0.0, NOW());


  -- ============================================================
  -- 2. VARIANTS (18 per workout = 108 total via CROSS JOIN)
  -- ============================================================
  INSERT INTO workout_variants (workout_id, variant_tag, label, description)
  SELECT w.wid, ct.tag, ct.lbl, 'Modified for ' || ct.lbl || ' users'
  FROM (VALUES (w1), (w2), (w3), (w4), (w5), (w6)) AS w(wid)
  CROSS JOIN (VALUES
    ('knee_issue',       'Knee Issue'),
    ('ankle_issue',      'Ankle Issue'),
    ('hip_issue',        'Hip Issue'),
    ('foot_issue',       'Foot Issue'),
    ('lower_back_issue', 'Lower Back Issue'),
    ('upper_back_issue', 'Upper Back Issue'),
    ('neck_issue',       'Neck Issue'),
    ('shoulder_issue',   'Shoulder Issue'),
    ('elbow_issue',      'Elbow Issue'),
    ('wrist_issue',      'Wrist Issue'),
    ('cardio_limit',     'Cardio Limitation'),
    ('balance_issue',    'Balance Issue'),
    ('overweight_safe',  'Overweight Safe'),
    ('pregnancy_safe',   'Pregnancy Safe'),
    ('senior_safe',      'Senior Safe'),
    ('rehab_mode',       'Rehab Mode'),
    ('mobility_only',    'Mobility Only'),
    ('beginner',         'Beginner')
  ) AS ct(tag, lbl);


  -- ============================================================
  -- 3. DEFAULT EXERCISES
  -- ============================================================

  -- ===== W1: Cardio Kickstart (Jessica) =====
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type) VALUES
  (w1, 'Jog in Place Warm-Up', 'Light jogging to raise your heart rate. Stay on the balls of your feet and swing your arms naturally.', 0, 60, NULL, NULL, NULL, 'timed'),
  (w1, 'Squat Jumps', 'Squat down, then explode upward. Land softly and immediately drop into the next rep.', 1, 40, 12, 3, 20, 'reps'),
  (w1, 'Burpee Push-Ups', 'Drop to the floor, push-up, jump feet to hands, and leap up with arms overhead.', 2, 45, 10, 3, 25, 'reps'),
  (w1, 'Mountain Climbers', 'In plank position, drive knees to chest alternately at max speed. Keep core tight.', 3, 40, NULL, NULL, 15, 'timed'),
  (w1, 'High Knees', 'Run in place driving knees as high as possible. Pump your arms and stay tall.', 4, 40, NULL, NULL, 15, 'timed'),
  (w1, 'Cool-Down Stretch', 'Full-body static stretches. Hold each position 20 seconds. Breathe deeply.', 5, 90, NULL, NULL, NULL, 'timed');

  -- ===== W2: Strength Foundations (Marcus) =====
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type) VALUES
  (w2, 'Dynamic Warm-Up', 'Arm circles, leg swings, and bodyweight squats. Prepare your joints for lifting.', 0, 120, NULL, NULL, NULL, 'timed'),
  (w2, 'Goblet Squats', 'Hold dumbbell at chest. Squat deep with chest up and elbows inside knees.', 1, 45, 12, 4, 60, 'reps'),
  (w2, 'Dumbbell Bent-Over Rows', 'Hinge forward 45 degrees. Pull dumbbells to ribcage, squeeze shoulder blades.', 2, 45, 10, 4, 60, 'reps'),
  (w2, 'Dumbbell Shoulder Press', 'Press dumbbells overhead from shoulder height. Keep core braced.', 3, 45, 10, 3, 60, 'reps'),
  (w2, 'Romanian Deadlifts', 'Hinge at hips, lower dumbbells along shins. Squeeze glutes at the top.', 4, 45, 12, 4, 60, 'reps'),
  (w2, 'Plank Hold', 'Forearm plank with a straight line from head to heels. Breathe steadily.', 5, 45, NULL, 3, 30, 'timed');

  -- ===== W3: Gentle Morning Flow (Aisha) =====
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type) VALUES
  (w3, 'Seated Breathing', 'Sit comfortably, close your eyes, and focus on deep belly breathing.', 0, 90, NULL, NULL, NULL, 'timed'),
  (w3, 'Cat-Cow Flow', 'On hands and knees, alternate arching and rounding the spine with each breath.', 1, 60, NULL, NULL, NULL, 'timed'),
  (w3, 'Sun Salutation A', 'Forward fold, halfway lift, plank, chaturanga, upward dog, downward dog. 3 rounds.', 2, 180, NULL, 3, NULL, 'timed'),
  (w3, 'Warrior I & II', 'Hold Warrior I for 5 breaths, open to Warrior II for 5 breaths. Both sides.', 3, 120, NULL, NULL, NULL, 'timed'),
  (w3, 'Tree Pose', 'Balance on one foot, other foot on inner thigh or calf. Arms overhead. Both sides.', 4, 60, NULL, NULL, NULL, 'timed'),
  (w3, 'Savasana', 'Lie flat on your back. Close eyes, relax every muscle. Final resting pose.', 5, 120, NULL, NULL, NULL, 'timed');

  -- ===== W4: Power HIIT Challenge (Ryan) =====
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type) VALUES
  (w4, 'Dynamic Warm-Up', 'High knees, butt kicks, arm swings, and bodyweight lunges. Get ready to work.', 0, 90, NULL, NULL, NULL, 'timed'),
  (w4, 'Dumbbell Thrusters', 'Front squat into overhead press in one fluid motion. Full power each rep.', 1, 50, 12, 4, 45, 'reps'),
  (w4, 'Burpee Box Jumps', 'Burpee on the ground then explode into a jump landing on a step. Scale as needed.', 2, 50, 10, 3, 40, 'reps'),
  (w4, 'Renegade Rows', 'In push-up position with dumbbells, row one arm at a time. Keep hips level.', 3, 50, 10, 3, 40, 'reps'),
  (w4, 'Sprint Intervals', 'All-out sprint for 20 seconds, walk for 10 seconds. Repeat for full duration.', 4, 60, NULL, NULL, 30, 'timed'),
  (w4, 'Cool-Down & Stretch', 'Full-body stretching. Focus on shoulders, hips, and legs. 30 seconds each.', 5, 120, NULL, NULL, NULL, 'timed');

  -- ===== W5: Core Pilates Essentials (Sophia) =====
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type) VALUES
  (w5, 'Diaphragmatic Breathing', 'Lie on back, knees bent. Breathe deep into belly. Activate deep core muscles.', 0, 90, NULL, NULL, NULL, 'timed'),
  (w5, 'The Hundred', 'Curl head and shoulders up, legs in tabletop. Pump arms: breathe in 5, out 5.', 1, 60, NULL, 2, 30, 'timed'),
  (w5, 'Roll-Up', 'Lie flat, slowly roll up vertebra by vertebra reaching for toes. Roll back down.', 2, 45, 8, 3, 30, 'reps'),
  (w5, 'Single Leg Stretch', 'Curl up, extend one leg while pulling the other knee to chest. Alternate.', 3, 45, 10, 3, 25, 'reps'),
  (w5, 'Side Plank Hold', 'Stack feet, lift hips. Hold creating a straight line. Both sides.', 4, 30, NULL, 3, 20, 'timed'),
  (w5, 'Spine Stretch Forward', 'Sit tall, legs wide. Round forward reaching past toes. Breathe and lengthen.', 5, 60, NULL, NULL, NULL, 'timed');

  -- ===== W6: Leg Day Power (David) =====
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type) VALUES
  (w6, 'Leg Swing Warm-Up', 'Hold wall for balance. Swing each leg forward, back, and side to side.', 0, 90, NULL, NULL, NULL, 'timed'),
  (w6, 'Dumbbell Front Squats', 'Dumbbells at shoulder height. Deep squat with upright torso. Drive through heels.', 1, 50, 12, 4, 60, 'reps'),
  (w6, 'Walking Lunges', 'Step forward into a deep lunge, alternate legs. Hold dumbbells at your sides.', 2, 50, 10, 4, 60, 'reps'),
  (w6, 'Stiff-Leg Deadlifts', 'Legs nearly straight, hinge at hips lowering dumbbells. Squeeze glutes at top.', 3, 50, 12, 3, 60, 'reps'),
  (w6, 'Step-Ups', 'Step onto a bench or box alternating legs. Hold dumbbells for added resistance.', 4, 45, 10, 3, 45, 'reps'),
  (w6, 'Calf Raises', 'Rise onto toes with 2-second hold at top. Lower slowly below starting position.', 5, 40, 15, 3, 30, 'reps');


  -- ============================================================
  -- 4. VARIANT EXERCISES
  -- ============================================================
  -- Pattern: CROSS JOIN generates exercises for all tags in a group.
  -- Each group shares condition-appropriate exercise modifications.

  -- ╔══════════════════════════════════════════════════════════════╗
  -- ║  W1: CARDIO KICKSTART (Jessica) - Variant Exercises         ║
  -- ╚══════════════════════════════════════════════════════════════╝

  -- G1: Lower Body Protected (knee, ankle, hip, foot)
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w1, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Arm Circle Warm-Up',     'Seated or standing arm circles to raise heart rate without leg impact.',     0, 60,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Seated Punches',         'Sit on chair, punch forward alternating arms at max speed.',                 1, 40,  NULL,      NULL,      15,        'timed'),
    ('Seated Torso Twists',    'Sit tall, twist side to side with arms at chest level. Control the motion.', 2, 40,  15,        3,         20,        'reps'),
    ('Seated Knee Lifts',      'Sit on edge of chair, lift knees alternately toward chest.',                 3, 40,  12,        3,         20,        'reps'),
    ('Arm Raise Pulses',       'Raise arms overhead, pulse up for duration. Keep core engaged.',             4, 40,  NULL,      NULL,      15,        'timed'),
    ('Seated Stretch',         'Gentle upper body stretches from seated position. Breathe deeply.',          5, 90,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w1 AND wv.variant_tag IN ('knee_issue','ankle_issue','hip_issue','foot_issue');

  -- G2: Upper Body Protected (shoulder, elbow, wrist, neck)
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w1, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Jog in Place Warm-Up',   'Light jogging to raise heart rate. Keep arms relaxed at your sides.',        0, 60,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Bodyweight Squats',      'Feet shoulder-width, squat deep with arms crossed at chest. No arm load.',   1, 40,  15,        3,         20,        'reps'),
    ('Glute Bridges',          'Lie on back, drive hips up squeezing glutes. No arm involvement needed.',    2, 40,  12,        3,         20,        'reps'),
    ('Lateral Shuffles',       'Shuffle side to side in athletic stance. Keep arms relaxed.',                 3, 40,  NULL,      NULL,      15,        'timed'),
    ('Standing Knee Drives',   'Drive knees up alternately. Keep hands on hips to avoid arm strain.',        4, 40,  NULL,      NULL,      15,        'timed'),
    ('Lower Body Stretch',     'Standing quad stretch, hamstring stretch, hip flexor stretch.',               5, 90,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w1 AND wv.variant_tag IN ('shoulder_issue','elbow_issue','wrist_issue','neck_issue');

  -- G3: Back Protected (lower back, upper back)
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w1, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Gentle March Warm-Up',   'March in place with gentle arm swings. Keep spine neutral throughout.',      0, 60,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Wall Sit Hold',          'Back flat against wall, thighs parallel to floor. Hold and breathe.',        1, 40,  NULL,      3,         20,        'timed'),
    ('Standing Side Steps',    'Step side to side in a wide stance. Keep torso upright and stable.',         2, 40,  NULL,      NULL,      15,        'timed'),
    ('Standing Knee Raises',   'Stand tall, lift knees alternately to hip height. No spinal bending.',       3, 40,  12,        3,         20,        'reps'),
    ('Calf Raise March',       'Alternate calf raises while marching in place. Stay upright.',               4, 40,  NULL,      NULL,      15,        'timed'),
    ('Standing Stretch',       'Gentle standing stretches avoiding forward folds. Side bends and quad pulls.', 5, 90, NULL,     NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w1 AND wv.variant_tag IN ('lower_back_issue','upper_back_issue');

  -- G4: Low Impact (cardio limit, balance issue, overweight safe)
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w1, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Slow March Warm-Up',     'March in place at a comfortable pace. Focus on breathing rhythm.',           0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Half Squats',            'Squat halfway down, pause, return to standing. No jumping required.',        1, 40,  10,        3,         30,        'reps'),
    ('Step-Out Jacks',         'Step one foot out at a time instead of jumping. Arms overhead each step.',   2, 40,  NULL,      NULL,      20,        'timed'),
    ('Slow Marching',          'March in place lifting knees to comfortable height. Steady pace.',           3, 40,  NULL,      NULL,      20,        'timed'),
    ('Wall Push-Ups',          'Push-ups against the wall. Feet back, lean in, push away. Controlled.',      4, 40,  10,        3,         25,        'reps'),
    ('Cool-Down Stretch',      'Gentle full-body stretches. Hold each 20 seconds. Take your time.',         5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w1 AND wv.variant_tag IN ('cardio_limit','balance_issue','overweight_safe');

  -- G5: Extra Gentle (pregnancy safe, senior safe, rehab mode)
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w1, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Seated Breathing',       'Sit comfortably and take deep breaths. Raise your body temperature gently.', 0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Chair Sit-to-Stand',     'Sit on a sturdy chair, stand up using legs, sit back down slowly.',          1, 40,  8,         3,         30,        'reps'),
    ('Seated Arm Raises',      'Raise arms overhead slowly, lower with control. Light and rhythmic.',        2, 40,  10,        3,         25,        'reps'),
    ('Seated Marching',        'March in place while seated. Lift knees gently and swing arms.',             3, 40,  NULL,      NULL,      25,        'timed'),
    ('Chair Heel Raises',      'Hold chair back for support. Rise onto toes and lower slowly.',              4, 40,  10,        3,         20,        'reps'),
    ('Seated Gentle Stretch',  'Seated neck, shoulder, and side stretches. Slow and controlled.',            5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w1 AND wv.variant_tag IN ('pregnancy_safe','senior_safe','rehab_mode');

  -- G6: Mobility Only
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w1, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Neck Rotations',         'Slowly rotate your neck in circles. 5 each direction. Release tension.',     0, 60,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Shoulder Rolls',         'Roll shoulders forward and backward. Open the chest between rolls.',         1, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Standing Side Bends',    'Reach one arm overhead and lean to the opposite side. Alternate.',           2, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Hip Circles',            'Hands on hips, draw large circles with your hips. Both directions.',         3, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Hamstring Stretch',      'Step one foot forward, hinge at hips to stretch back of leg. Both sides.',   4, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Full Body Stretch',      'Combine arm reaches, side bends, and gentle twists. Breathe deeply.',        5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w1 AND wv.variant_tag = 'mobility_only';

  -- G7: Beginner
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w1, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('March in Place Warm-Up', 'March in place swinging arms. Build up your pace gradually.',                0, 60,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Half Squats',            'Squat halfway down and stand back up. Keep your weight on your heels.',      1, 40,  10,        3,         25,        'reps'),
    ('Modified Burpees',       'Step feet back to plank (no jump), step forward, stand up. No push-up.',     2, 40,  6,         2,         30,        'reps'),
    ('Slow Mountain Climbers', 'In plank, step one foot forward at a time slowly. Keep core tight.',         3, 30,  NULL,      NULL,      20,        'timed'),
    ('Marching High Knees',    'March in place, lifting knees to hip height. Gentle pace.',                  4, 30,  NULL,      NULL,      20,        'timed'),
    ('Cool-Down Stretch',      'Full-body stretches with extra time for each hold. Breathe slowly.',         5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w1 AND wv.variant_tag = 'beginner';


  -- ╔══════════════════════════════════════════════════════════════╗
  -- ║  W2: STRENGTH FOUNDATIONS (Marcus) - Variant Exercises       ║
  -- ╚══════════════════════════════════════════════════════════════╝

  -- G1: Lower Body Protected
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w2, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Upper Body Warm-Up',      'Arm swings, shoulder circles, and chest openers. Skip lower body moves.',    0, 120, NULL::int, NULL::int, NULL::int, 'timed'),
    ('Seated Dumbbell Press',   'Sit on chair, press dumbbells overhead. No leg involvement needed.',         1, 45,  10,        4,         60,        'reps'),
    ('Seated Dumbbell Rows',    'Sit on edge of chair, hinge forward slightly, row dumbbells to ribs.',      2, 45,  10,        4,         60,        'reps'),
    ('Floor Chest Press',       'Lie on back, press dumbbells up from chest. Feet flat on floor.',            3, 45,  10,        3,         60,        'reps'),
    ('Seated Bicep Curls',      'Sit tall, curl dumbbells with controlled tempo. Full range of motion.',      4, 40,  12,        3,         45,        'reps'),
    ('Seated Stretch',          'Upper body stretches from seated position. Shoulders, arms, and chest.',     5, 60,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w2 AND wv.variant_tag IN ('knee_issue','ankle_issue','hip_issue','foot_issue');

  -- G2: Upper Body Protected
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w2, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Lower Body Warm-Up',      'Leg swings, hip circles, and bodyweight squats. Skip arm movements.',       0, 120, NULL::int, NULL::int, NULL::int, 'timed'),
    ('Goblet Squats',           'Hold light dumbbell at chest. Squat deep with chest tall.',                 1, 45,  12,        4,         60,        'reps'),
    ('Sumo Deadlifts',          'Wide stance, toes out. Lower dumbbell between legs, drive hips forward.',   2, 45,  10,        4,         60,        'reps'),
    ('Walking Lunges',          'Step forward into lunge, alternate legs. Arms at sides, no overhead.',      3, 45,  10,        3,         60,        'reps'),
    ('Glute Bridges',           'Lie on back, feet flat, drive hips up. Add dumbbell on hips if able.',      4, 45,  12,        3,         45,        'reps'),
    ('Lower Body Stretch',      'Quad stretch, hamstring stretch, hip flexor stretch. 20 seconds each.',     5, 60,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w2 AND wv.variant_tag IN ('shoulder_issue','elbow_issue','wrist_issue','neck_issue');

  -- G3: Back Protected
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w2, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Dynamic Warm-Up',         'Arm circles, knee raises, and gentle twists. Avoid forward bends.',         0, 120, NULL::int, NULL::int, NULL::int, 'timed'),
    ('Wall Squats',             'Back flat against wall, slide down to seated position. Hold and press up.',  1, 45,  10,        4,         60,        'reps'),
    ('Seated Shoulder Press',   'Sit tall on chair. Press dumbbells overhead keeping back against chair.',    2, 45,  10,        3,         60,        'reps'),
    ('Chest Fly on Floor',      'Lie on back, arms out wide with dumbbells. Bring arms together overhead.',  3, 45,  10,        3,         60,        'reps'),
    ('Standing Calf Raises',    'Stand tall, rise onto toes, hold 2 seconds, lower slowly.',                 4, 40,  15,        3,         30,        'reps'),
    ('Standing Stretch',        'Gentle standing stretches. Avoid bending forward. Side bends and arm pulls.', 5, 60, NULL,     NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w2 AND wv.variant_tag IN ('lower_back_issue','upper_back_issue');

  -- G4: Low Impact
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w2, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Gentle Warm-Up',          'Slow marching with arm swings. Take your time to warm up fully.',           0, 120, NULL::int, NULL::int, NULL::int, 'timed'),
    ('Light Goblet Squats',     'Use light weight. Squat to comfortable depth only. Focus on form.',         1, 45,  10,        3,         60,        'reps'),
    ('Supported Rows',          'Use chair for support. One-arm rows with light weight.',                    2, 45,  10,        3,         60,        'reps'),
    ('Light Shoulder Press',    'Very light dumbbells. Press overhead slowly with full control.',             3, 45,  8,         3,         60,        'reps'),
    ('Glute Bridges',           'Lie on back, feet flat. Drive hips up, hold 3 seconds, lower slowly.',      4, 45,  10,        3,         45,        'reps'),
    ('Extended Stretch',        'Full-body stretches with longer holds. Focus on breathing.',                 5, 90,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w2 AND wv.variant_tag IN ('cardio_limit','balance_issue','overweight_safe');

  -- G5: Extra Gentle
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w2, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Seated Warm-Up',          'Seated arm swings and gentle torso rotations to warm up muscles.',          0, 120, NULL::int, NULL::int, NULL::int, 'timed'),
    ('Chair Sit-to-Stand',      'Using sturdy chair, stand up and sit down slowly. Use arms if needed.',     1, 45,  8,         3,         45,        'reps'),
    ('Seated Dumbbell Curls',   'Very light dumbbells. Curl slowly with 3-second tempo each way.',           2, 40,  8,         3,         40,        'reps'),
    ('Seated Arm Raises',       'Light dumbbells. Raise arms to shoulder height and lower. Controlled.',     3, 40,  8,         3,         40,        'reps'),
    ('Seated Leg Extensions',   'Sit tall, extend one leg straight, hold 3 seconds, lower. Alternate.',     4, 40,  8,         3,         30,        'reps'),
    ('Seated Relaxation',       'Gentle seated stretches. Neck rolls, shoulder shrugs, wrist circles.',      5, 90,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w2 AND wv.variant_tag IN ('pregnancy_safe','senior_safe','rehab_mode');

  -- G6: Mobility Only
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w2, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Wrist & Forearm Circles', 'Rotate wrists in circles. Open and close fists. Loosen up joints.',        0, 60,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Shoulder Pass-Through',   'Use a towel or band overhead, pass from front to back. Open shoulders.',    1, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Standing Hip Circles',    'Hands on hips, draw large circles. 10 each direction.',                     2, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Thoracic Spine Twist',    'Stand with arms out, rotate upper body left and right gently.',             3, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Ankle Circles',           'Lift one foot and draw circles with your toes. Both directions, both feet.', 4, 60,  NULL,     NULL,      NULL,      'timed'),
    ('Full Body Joint Mobility','Combine all joint movements in a flowing sequence. Head to toe.',           5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w2 AND wv.variant_tag = 'mobility_only';

  -- G7: Beginner
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w2, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Easy Warm-Up',            'March in place, arm swings, and gentle bodyweight squats.',                  0, 120, NULL::int, NULL::int, NULL::int, 'timed'),
    ('Bodyweight Squats',       'No weight needed. Squat to a comfortable depth. Focus on proper form.',     1, 45,  10,        3,         45,        'reps'),
    ('Light Dumbbell Rows',     'Use very light weight. One arm at a time supported by chair.',              2, 45,  8,         3,         45,        'reps'),
    ('Wall Push-Ups',           'Push-ups against the wall. Easy on joints, great for building strength.',   3, 40,  8,         3,         40,        'reps'),
    ('Bodyweight Glute Bridge', 'Lie on back, drive hips up. No weight needed. Squeeze at the top.',         4, 40,  10,        3,         40,        'reps'),
    ('Relaxed Stretch',         'Full-body stretching. Take extra time and focus on tight areas.',            5, 90,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w2 AND wv.variant_tag = 'beginner';


  -- ╔══════════════════════════════════════════════════════════════╗
  -- ║  W3: GENTLE MORNING FLOW (Aisha) - Variant Exercises        ║
  -- ╚══════════════════════════════════════════════════════════════╝

  -- G1: Lower Body Protected
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w3, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Seated Breathing',        'Sit comfortably. Deep belly breathing to center yourself.',                  0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Seated Cat-Cow',          'Sit on chair. Alternate between arching and rounding spine with breath.',    1, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Seated Sun Salutation',   'Modified seated sequence: arms up, fold forward, arms up. Slow and fluid.', 2, 150, NULL,      3,         NULL,      'timed'),
    ('Seated Warrior Arms',     'Sit tall, extend arms like Warrior II. Hold 5 breaths each side.',          3, 120, NULL,      NULL,      NULL,      'timed'),
    ('Seated Side Stretch',     'Reach one arm overhead, lean to opposite side. Hold 5 breaths each.',       4, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Seated Savasana',         'Close eyes, relax arms on thighs. Focus on breath. Full relaxation.',       5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w3 AND wv.variant_tag IN ('knee_issue','ankle_issue','hip_issue','foot_issue');

  -- G2: Upper Body Protected
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w3, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Seated Breathing',        'Sit comfortably. Deep belly breathing to center yourself.',                  0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Cat-Cow Flow',            'On hands and knees gently. If wrists hurt, use fists or forearms.',         1, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Standing Forward Fold',   'Fold forward from hips, let arms hang. No weight on arms. Gentle.',        2, 150, NULL,      NULL,      NULL,      'timed'),
    ('Warrior Legs Only',       'Warrior I and II focus on leg position. Hands on hips instead of overhead.', 3, 120, NULL,      NULL,      NULL,      'timed'),
    ('Standing Balance',        'Stand on one foot, hands on hips. Focus on leg stability.',                 4, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Savasana',                'Lie flat, arms at sides. Full relaxation. No weight on shoulders or arms.',  5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w3 AND wv.variant_tag IN ('shoulder_issue','elbow_issue','wrist_issue','neck_issue');

  -- G3: Back Protected
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w3, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Seated Breathing',        'Sit tall with supported back. Deep breathing to start.',                    0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Gentle Cat-Cow',          'Very small range of motion. Focus on breath more than movement.',           1, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Standing Arm Reaches',    'Reach arms overhead alternately. Gentle side bends. No deep back bend.',    2, 120, NULL,      NULL,      NULL,      'timed'),
    ('Supported Warrior',       'Use wall for support. Warrior II with back against wall for alignment.',    3, 120, NULL,      NULL,      NULL,      'timed'),
    ('Standing Hip Opener',     'Figure-four stretch standing with wall support. Open hips gently.',         4, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Savasana',                'Lie on back with knees bent to support lower back. Full relaxation.',        5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w3 AND wv.variant_tag IN ('lower_back_issue','upper_back_issue');

  -- G4: Low Impact
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w3, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Seated Breathing',        'Sit comfortably. Breathe in for 4, hold 4, out for 4. Repeat.',            0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Gentle Cat-Cow',          'Slow cat-cow on hands and knees. Move with your breath.',                   1, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Modified Sun Salutation', 'Simplified sequence with no jumps. Step back to plank, step forward.',      2, 150, NULL,      2,         NULL,      'timed'),
    ('Supported Warrior',       'Use wall or chair for balance. Hold each pose for 5 breaths.',              3, 120, NULL,      NULL,      NULL,      'timed'),
    ('Wall-Supported Balance',  'Stand near wall, lift one foot. Touch wall for support as needed.',         4, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Savasana',                'Lie flat, relax completely. Extended rest for 2 minutes.',                   5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w3 AND wv.variant_tag IN ('cardio_limit','balance_issue','overweight_safe');

  -- G5: Extra Gentle
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w3, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Chair Seated Breathing',  'Sit in a sturdy chair. Deep breathing with eyes closed.',                   0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Chair Seated Cat-Cow',    'Hands on knees, gently round and arch spine while seated.',                 1, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Chair Arm Reaches',       'Seated, raise arms gently overhead on inhale, lower on exhale.',            2, 120, NULL,      NULL,      NULL,      'timed'),
    ('Chair Seated Twists',     'Sit tall, gently twist to each side. Hold 5 breaths.',                     3, 90,  NULL,      NULL,      NULL,      'timed'),
    ('Chair Seated Side Bend',  'Reach one arm overhead, lean gently. Hold 5 breaths each side.',           4, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Chair Relaxation',        'Close eyes, relax hands on thighs, focus on calm breathing.',               5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w3 AND wv.variant_tag IN ('pregnancy_safe','senior_safe','rehab_mode');

  -- G6: Mobility Only
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w3, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Breath Awareness',        'Sit still, observe your natural breath pattern. No effort needed.',         0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Neck & Shoulder Release', 'Gentle neck tilts, rolls, and shoulder shrugs to release tension.',         1, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Seated Spinal Twist',     'Sit cross-legged, twist gently to each side. Hold 8 breaths.',             2, 120, NULL,      NULL,      NULL,      'timed'),
    ('Hip Opener Stretch',      'Butterfly pose: soles of feet together, gently press knees down.',         3, 90,  NULL,      NULL,      NULL,      'timed'),
    ('Hamstring Stretch',       'Extend one leg, fold gently forward. Hold 30 seconds each side.',          4, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Savasana',                'Lie flat, arms at sides, palms up. Full rest and relaxation.',               5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w3 AND wv.variant_tag = 'mobility_only';

  -- G7: Beginner
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w3, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Easy Breathing',          'Sit comfortably. Breathe in through nose, out through mouth. Simple.',      0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Gentle Cat-Cow',          'On hands and knees, slowly round and arch your back. Follow your breath.',  1, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Simple Sun Salutation',   'Simplified: reach up, fold down, step back to plank, step up. 2 rounds.',  2, 120, NULL,      2,         NULL,      'timed'),
    ('Easy Warrior Hold',       'Wide stance, arms out to sides. Hold steadily for 5 breaths each side.',   3, 90,  NULL,      NULL,      NULL,      'timed'),
    ('Wall-Assisted Tree Pose', 'Stand near wall for support. Lift one foot to calf. 5 breaths each.',      4, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Savasana',                'Lie flat and relax. Let go of all effort. Rest for 2 minutes.',              5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w3 AND wv.variant_tag = 'beginner';


  -- ╔══════════════════════════════════════════════════════════════╗
  -- ║  W4: POWER HIIT CHALLENGE (Ryan) - Variant Exercises        ║
  -- ╚══════════════════════════════════════════════════════════════╝

  -- G1: Lower Body Protected
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w4, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Upper Body Warm-Up',      'Arm swings, chest openers, and shoulder circles. No leg work.',             0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Seated DB Press',         'Sit on bench or chair. Press dumbbells overhead explosively.',               1, 50,  12,        4,         45,        'reps'),
    ('Seated DB Chest Fly',     'Sit on edge of chair. Open arms wide with dumbbells, bring together.',      2, 50,  10,        3,         40,        'reps'),
    ('Seated Band Rows',        'Sit tall, pull resistance band toward chest. Squeeze shoulder blades.',     3, 50,  10,        3,         40,        'reps'),
    ('Seated Arm Intervals',    'Alternate fast arm raises and slow bicep curls. 20s fast, 10s slow.',       4, 60,  NULL,      NULL,      30,        'timed'),
    ('Upper Body Stretch',      'Stretch shoulders, arms, chest, and upper back thoroughly.',                 5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w4 AND wv.variant_tag IN ('knee_issue','ankle_issue','hip_issue','foot_issue');

  -- G2: Upper Body Protected
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w4, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Dynamic Leg Warm-Up',     'High knees, butt kicks, and lateral shuffles. Arms relaxed.',               0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Jump Squats',             'Squat deep then explode upward. Land softly. Arms crossed at chest.',       1, 50,  12,        4,         45,        'reps'),
    ('Jump Lunges',             'Alternate lunge jumps explosively. Hands on hips for balance.',             2, 50,  10,        3,         40,        'reps'),
    ('Box Jumps',               'Jump onto a step or box. Step down carefully. Full leg power each rep.',    3, 50,  10,        3,         40,        'reps'),
    ('Sprint Intervals',        'All-out running in place. 20 seconds on, 10 seconds off.',                 4, 60,  NULL,      NULL,      30,        'timed'),
    ('Leg Stretch',             'Deep quad stretch, hamstring stretch, calf stretch. Hold each 30 seconds.', 5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w4 AND wv.variant_tag IN ('shoulder_issue','elbow_issue','wrist_issue','neck_issue');

  -- G3: Back Protected
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w4, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Light Warm-Up',           'Marching in place with gentle arm swings. Keep spine neutral.',             0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('DB Goblet Squats',        'Hold dumbbell at chest, squat deep. Keep back straight throughout.',        1, 50,  12,        4,         45,        'reps'),
    ('Standing DB Curls',       'Stand tall, curl dumbbells. Keep elbows pinned to sides. No back sway.',    2, 45,  10,        3,         40,        'reps'),
    ('Wall Sit Hold',           'Back flat against wall, hold squat position. Spine fully supported.',       3, 45,  NULL,      3,         40,        'timed'),
    ('Lateral Step-Outs',       'Step side to side with quick tempo. Keep core stable, spine neutral.',      4, 60,  NULL,      NULL,      30,        'timed'),
    ('Gentle Stretch',          'Standing stretches avoiding loaded forward bends. Side bends and twists.',  5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w4 AND wv.variant_tag IN ('lower_back_issue','upper_back_issue');

  -- G4: Low Impact
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w4, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Easy Warm-Up',            'Slow marching with arm reaches. Build up gradually over 90 seconds.',       0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Bodyweight Squats',       'Squat at your own pace. Full range if comfortable, half if not.',           1, 50,  10,        3,         45,        'reps'),
    ('Step-Back Lunges',        'Step one foot back into a gentle lunge. Alternate. No jumping.',            2, 50,  8,         3,         40,        'reps'),
    ('Standing Rows',           'Hinge slightly, row light dumbbells to ribs. Controlled speed.',            3, 45,  10,        3,         40,        'reps'),
    ('March in Place',          'Moderate-paced marching. Lift knees to comfortable height.',                4, 60,  NULL,      NULL,      30,        'timed'),
    ('Full Stretch',            'Extended cool-down. Hold each stretch 30 seconds. Focus on breath.',        5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w4 AND wv.variant_tag IN ('cardio_limit','balance_issue','overweight_safe');

  -- G5: Extra Gentle
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w4, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Chair Warm-Up',           'Seated marching and arm circles from a sturdy chair.',                      0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Chair Squats',            'Stand up from chair and sit back down. Use armrests if needed.',            1, 45,  8,         3,         40,        'reps'),
    ('Seated Light Press',      'Very light dumbbells overhead from seated position. Slow and steady.',      2, 40,  8,         3,         40,        'reps'),
    ('Seated Knee Extensions',  'Sit tall, extend one leg out straight, hold 3 seconds, alternate.',        3, 40,  8,         3,         30,        'reps'),
    ('Seated Arm Swings',       'Gently swing arms forward and back while seated. Build rhythm.',           4, 40,  NULL,      NULL,      30,        'timed'),
    ('Chair Stretch',           'Gentle full-body stretches from seated position. No strain.',                5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w4 AND wv.variant_tag IN ('pregnancy_safe','senior_safe','rehab_mode');

  -- G6: Mobility Only
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w4, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Joint Warm-Up',           'Circle every joint: wrists, elbows, shoulders, hips, knees, ankles.',       0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('World''s Greatest Stretch','Lunge position, twist toward front knee, reach to sky. Both sides.',       1, 90,  NULL,      NULL,      NULL,      'timed'),
    ('Leg Swings',              'Hold wall, swing each leg forward/back and side to side. Loosen hips.',     2, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Thoracic Rotation',       'On hands and knees, thread one arm under body then reach to sky.',          3, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Calf & Ankle Mobility',   'Stand on a step, drop heels below step. Hold and pulse gently.',           4, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Full Body Flow',          'Combine all stretches in a flowing sequence. Move continuously.',            5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w4 AND wv.variant_tag = 'mobility_only';

  -- G7: Beginner
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w4, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Easy Warm-Up',            'March in place, arm swings, and gentle bodyweight squats.',                  0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('DB Goblet Squats',        'Light dumbbell held at chest. Squat to comfortable depth.',                 1, 50,  8,         3,         45,        'reps'),
    ('Modified Burpees',        'Step feet back to plank, step forward, stand up. No jumping.',              2, 50,  6,         2,         40,        'reps'),
    ('Supported Rows',          'One arm on chair for support, row light dumbbell with the other.',          3, 45,  8,         3,         40,        'reps'),
    ('Marching in Place',       'Moderate march with high knees. Focus on steady breathing.',                4, 45,  NULL,      NULL,      30,        'timed'),
    ('Full Cool-Down',          'Extended stretching. Hold each stretch 25 seconds. Breathe deeply.',        5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w4 AND wv.variant_tag = 'beginner';


  -- ╔══════════════════════════════════════════════════════════════╗
  -- ║  W5: CORE PILATES ESSENTIALS (Sophia) - Variant Exercises   ║
  -- ╚══════════════════════════════════════════════════════════════╝

  -- G1: Lower Body Protected
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w5, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Breathing Prep',          'Lie on back, knees bent, feet flat. Deep core breathing activation.',        0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Supine Arm Reaches',      'Arms to ceiling, slowly lower overhead and back. Core stays engaged.',      1, 45,  10,        3,         25,        'reps'),
    ('Dead Bug Arms Only',      'Lie on back, arms to ceiling. Alternate lowering arms. Legs stay still.',   2, 45,  10,        3,         25,        'reps'),
    ('Supine Oblique Twist',    'Knees bent, feet flat. Drop both knees gently side to side.',               3, 45,  10,        3,         20,        'reps'),
    ('Forearm Plank',           'Plank on forearms, knees on floor if needed. Hold with flat back.',         4, 30,  NULL,      3,         20,        'timed'),
    ('Seated Spine Stretch',    'Sit tall, round forward gently. Breathe and lengthen.',                     5, 60,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w5 AND wv.variant_tag IN ('knee_issue','ankle_issue','hip_issue','foot_issue');

  -- G2: Upper Body Protected
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w5, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Breathing Prep',          'Lie on back. Deep core breathing with hands on belly.',                     0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Pelvic Tilts',            'Lie on back, knees bent. Tilt pelvis to flatten lower back to floor.',      1, 45,  10,        3,         25,        'reps'),
    ('Leg Slides',              'Lie on back. Slowly slide one heel along floor extending leg. Alternate.',  2, 45,  10,        3,         25,        'reps'),
    ('Single Leg Circles',      'Lie on back, one leg to ceiling. Draw small circles. Both directions.',     3, 45,  8,         3,         20,        'reps'),
    ('Glute Bridge Hold',       'Feet flat, drive hips up. Hold 5 seconds at top. No arm push.',            4, 40,  8,         3,         20,        'reps'),
    ('Supine Rest',             'Lie flat, gently hug knees to chest. Rock side to side.',                   5, 60,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w5 AND wv.variant_tag IN ('shoulder_issue','elbow_issue','wrist_issue','neck_issue');

  -- G3: Back Protected
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w5, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Supported Breathing',     'Lie on back with rolled towel under knees. Gentle core activation.',        0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Pelvic Floor Lifts',      'Lie on back. Gently draw pelvic floor up, hold 5 seconds, release.',       1, 45,  8,         3,         25,        'reps'),
    ('Heel Taps',               'Lie on back, knees in tabletop. Alternate tapping toes to floor gently.',   2, 45,  10,        3,         25,        'reps'),
    ('Standing Side Bend',      'Stand tall, gentle side bend with arm overhead. Alternate sides.',          3, 45,  8,         3,         20,        'reps'),
    ('Wall Plank',              'Lean against wall in plank angle. Hold core tight. No back load.',          4, 30,  NULL,      3,         20,        'timed'),
    ('Standing Spine Twist',    'Stand tall, gently rotate upper body side to side. Arms relaxed.',          5, 60,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w5 AND wv.variant_tag IN ('lower_back_issue','upper_back_issue');

  -- G4: Low Impact
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w5, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Breathing Prep',          'Lie on back. Focus on deep, slow belly breathing for 90 seconds.',          0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Gentle Hundred',          'Modified hundred with knees bent, feet on floor. Small arm pumps.',         1, 45,  NULL,      2,         30,        'timed'),
    ('Supine Knee Drops',       'Lie on back. Slowly drop both knees to one side, return center.',           2, 45,  8,         3,         25,        'reps'),
    ('Leg Slides',              'Lie on back. Slowly extend one leg along floor and return.',                3, 45,  8,         3,         25,        'reps'),
    ('Supported Side Plank',    'Side plank on knees instead of feet. Hold with good alignment.',            4, 25,  NULL,      3,         20,        'timed'),
    ('Spine Stretch',           'Sit tall, legs wide. Round forward gently. Breathe into the stretch.',      5, 60,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w5 AND wv.variant_tag IN ('cardio_limit','balance_issue','overweight_safe');

  -- G5: Extra Gentle
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w5, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Gentle Breathing',        'Lie on back with support under knees. Slow, calm belly breathing.',         0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Pelvic Tilts',            'Very gentle rocking of pelvis. Flatten lower back then release.',           1, 40,  6,         3,         30,        'reps'),
    ('Arm Floats',              'Lie on back, slowly float arms up and over head. Lower gently.',            2, 40,  6,         3,         30,        'reps'),
    ('Knee Sways',              'Knees bent, feet flat. Sway knees gently left and right.',                  3, 40,  6,         3,         25,        'reps'),
    ('Seated Core Activation',  'Sit tall, draw belly button in, hold 5 seconds, release. Gentle.',         4, 40,  6,         3,         25,        'reps'),
    ('Rest & Breathe',          'Lie comfortably. Progressive relaxation from toes to head.',                5, 90,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w5 AND wv.variant_tag IN ('pregnancy_safe','senior_safe','rehab_mode');

  -- G6: Mobility Only
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w5, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Breath Work',             'Lie on back. Alternate between chest and belly breathing.',                  0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Spinal Articulation',     'Roll up from lying one vertebra at a time. Roll back down slowly.',         1, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Hip Mobility Circles',    'Lie on back, one knee to chest. Circle the hip joint. Both sides.',         2, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Thread the Needle',       'On hands and knees, thread one arm under body, then reach to sky.',         3, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Figure Four Stretch',     'Lie on back, cross one ankle over opposite knee. Pull gently toward you.',  4, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Full Body Lengthening',   'Lie flat, reach arms overhead, point toes. Stretch everything long.',       5, 90,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w5 AND wv.variant_tag = 'mobility_only';

  -- G7: Beginner
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w5, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Breathing Prep',          'Lie on back, knees bent. Practice deep belly breathing.',                    0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Easy Hundred',            'Knees bent, feet on floor. Gentle arm pumps. Head down if needed.',         1, 40,  NULL,      2,         30,        'timed'),
    ('Pelvic Tilts',            'Lie on back. Gently rock pelvis to flatten and release lower back.',        2, 40,  8,         3,         25,        'reps'),
    ('Single Leg Stretch',      'One knee to chest, other foot on floor. Alternate slowly.',                 3, 40,  8,         3,         25,        'reps'),
    ('Modified Side Plank',     'Side plank on knees and forearm. Short hold with good form.',               4, 20,  NULL,      3,         20,        'timed'),
    ('Gentle Spine Stretch',    'Sit tall, legs out. Round forward slowly. Only go as far as comfortable.',  5, 60,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w5 AND wv.variant_tag = 'beginner';


  -- ╔══════════════════════════════════════════════════════════════╗
  -- ║  W6: LEG DAY POWER (David) - Variant Exercises              ║
  -- ╚══════════════════════════════════════════════════════════════╝

  -- G1: Lower Body Protected
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w6, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Seated Warm-Up',          'Seated arm circles and torso twists. Skip lower body warm-up.',             0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Seated Leg Extensions',   'Sit tall, extend one leg straight, hold 3 seconds. Alternate.',            1, 45,  10,        4,         45,        'reps'),
    ('Lying Glute Bridge',      'Lie on back, feet flat. Lift hips using glutes. Gentle on knees.',         2, 45,  12,        4,         45,        'reps'),
    ('Side-Lying Leg Lifts',    'Lie on side, lift top leg 45 degrees. Lower slowly. Both sides.',          3, 45,  10,        3,         40,        'reps'),
    ('Lying Hamstring Curl',    'Lie face down, slowly curl heels toward glutes. Lower with control.',      4, 40,  10,        3,         40,        'reps'),
    ('Gentle Leg Stretch',      'Lying hamstring stretch with strap or towel. Hold 30 seconds each.',       5, 90,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w6 AND wv.variant_tag IN ('knee_issue','ankle_issue','hip_issue','foot_issue');

  -- G2: Upper Body Protected (leg day is mostly unaffected by upper body issues)
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w6, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Leg Swing Warm-Up',       'Hold wall, swing each leg forward/back and side to side.',                  0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Bodyweight Squats',       'No dumbbells. Squat deep with arms crossed at chest.',                      1, 50,  12,        4,         60,        'reps'),
    ('Reverse Lunges',          'Step back into lunge, return. Arms at sides, no weight needed.',            2, 50,  10,        4,         60,        'reps'),
    ('Glute Bridges',           'Lie on back, drive hips up. No dumbbell on hips.',                          3, 50,  12,        3,         45,        'reps'),
    ('Bodyweight Step-Ups',     'Step onto a box using leg power only. No dumbbell load.',                   4, 45,  10,        3,         45,        'reps'),
    ('Leg Stretch',             'Standing quad stretch, hamstring stretch. Hold wall for balance.',           5, 90,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w6 AND wv.variant_tag IN ('shoulder_issue','elbow_issue','wrist_issue','neck_issue');

  -- G3: Back Protected
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w6, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Gentle Warm-Up',          'Light marching and leg swings. Keep spine neutral at all times.',            0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Wall Squats',             'Back against wall for support. Slide to seated and press back up.',         1, 50,  10,        4,         60,        'reps'),
    ('Stationary Lunges',       'Static split stance. Lower and rise without walking. Spine stays tall.',    2, 50,  10,        4,         60,        'reps'),
    ('Glute Bridge March',      'In bridge position, alternate lifting feet slightly off ground.',           3, 45,  10,        3,         45,        'reps'),
    ('Standing Calf Raises',    'Rise onto toes, hold 2 seconds, lower slowly. Wall for balance.',          4, 40,  15,        3,         30,        'reps'),
    ('Standing Stretch',        'Quad and calf stretches only. Avoid forward folds for hamstrings.',         5, 90,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w6 AND wv.variant_tag IN ('lower_back_issue','upper_back_issue');

  -- G4: Low Impact
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w6, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Easy Warm-Up',            'Slow marching and gentle leg swings. Take 90 seconds to warm up.',         0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Supported Squats',        'Hold onto chair back. Squat to comfortable depth slowly.',                  1, 50,  10,        3,         60,        'reps'),
    ('Gentle Step-Backs',       'Small step back into shallow lunge. No deep bending required.',             2, 50,  8,         3,         60,        'reps'),
    ('Lying Glute Bridges',     'Lie on back, feet flat. Lift hips gently. No weight needed.',               3, 45,  10,        3,         45,        'reps'),
    ('Seated Calf Raises',      'Sit on edge of chair, raise heels off ground. Lower slowly.',              4, 40,  12,        3,         30,        'reps'),
    ('Relaxed Stretch',         'Long holds for each stretch. Breathe deeply and relax into it.',            5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w6 AND wv.variant_tag IN ('cardio_limit','balance_issue','overweight_safe');

  -- G5: Extra Gentle
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w6, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Chair Seated Warm-Up',    'Seated leg circles and ankle rotations from a sturdy chair.',               0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Chair Sit-to-Stand',      'Slowly stand from chair using legs. Sit back down with control.',           1, 45,  6,         3,         45,        'reps'),
    ('Seated Knee Lifts',       'Sit tall, lift one knee at a time. Hold 3 seconds at top.',                2, 45,  8,         3,         40,        'reps'),
    ('Chair-Supported Squats',  'Hold chair back, squat very shallow. Rise up slowly.',                     3, 40,  8,         3,         40,        'reps'),
    ('Seated Heel Raises',      'Sit on chair, raise heels up. Lower slowly. Strengthen calves gently.',    4, 40,  10,        3,         30,        'reps'),
    ('Seated Leg Stretch',      'Extend one leg, reach gently toward toes. Hold 20 seconds each.',          5, 90,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w6 AND wv.variant_tag IN ('pregnancy_safe','senior_safe','rehab_mode');

  -- G6: Mobility Only
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w6, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Ankle Circles',           'Lift one foot, draw circles with toes. Both directions, both feet.',        0, 60,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Knee Circles',            'Feet together, hands on knees, draw gentle circles. Both directions.',      1, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Hip Opener Stretch',      'Deep lunge with back knee down. Open hip flexor. Both sides.',             2, 90,  NULL,      NULL,      NULL,      'timed'),
    ('Hamstring Stretch',       'Prop foot on low surface. Hinge forward gently at hips. Both legs.',       3, 90,  NULL,      NULL,      NULL,      'timed'),
    ('Quad Stretch',            'Hold wall, pull foot behind you. Open the front of the thigh.',            4, 60,  NULL,      NULL,      NULL,      'timed'),
    ('Calf & Achilles Stretch', 'Step one foot back, press heel down. Lean into wall. Both sides.',         5, 60,  NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w6 AND wv.variant_tag = 'mobility_only';

  -- G7: Beginner
  INSERT INTO workout_exercises (workout_id, name, description, order_index, duration_seconds, reps, sets, rest_seconds, exercise_type, variant_id)
  SELECT w6, e.nm, e.ds, e.oi, e.dur, e.rp, e.st, e.rs, e.et, wv.id
  FROM workout_variants wv CROSS JOIN (VALUES
    ('Easy Warm-Up',            'Gentle marching and leg swings. Take your time.',                            0, 90,  NULL::int, NULL::int, NULL::int, 'timed'),
    ('Bodyweight Squats',       'No weight. Squat to comfortable depth. Focus on form over depth.',          1, 50,  10,        3,         45,        'reps'),
    ('Reverse Lunges',          'Step back gently into shallow lunge. Alternate legs each rep.',             2, 50,  8,         3,         45,        'reps'),
    ('Glute Bridges',           'Lie on back, feet flat. Lift hips. Hold 3 seconds. Lower slowly.',         3, 45,  10,        3,         40,        'reps'),
    ('Wall Calf Raises',        'Face a wall with hands on it. Rise onto toes, lower slowly.',              4, 40,  12,        3,         30,        'reps'),
    ('Full Leg Stretch',        'Standing quad, hamstring, and calf stretches. 20 seconds each.',            5, 120, NULL,      NULL,      NULL,      'timed')
  ) AS e(nm, ds, oi, dur, rp, st, rs, et)
  WHERE wv.workout_id = w6 AND wv.variant_tag = 'beginner';


END $$;


-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================
-- Run these to confirm data was inserted correctly:
--
-- SELECT w.title, COUNT(DISTINCT wv.id) AS variants, COUNT(DISTINCT we.id) AS exercises
-- FROM workouts w
-- LEFT JOIN workout_variants wv ON wv.workout_id = w.id
-- LEFT JOIN workout_exercises we ON we.workout_id = w.id
-- WHERE w.title IN ('Cardio Kickstart','Strength Foundations','Gentle Morning Flow',
--                   'Power HIIT Challenge','Core Pilates Essentials','Leg Day Power')
-- GROUP BY w.title ORDER BY w.title;
--
-- Expected: Each workout has 18 variants and ~114 exercises (6 default + 108 variant)
