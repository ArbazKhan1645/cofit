-- ============================================
-- DIET PLAN / RECIPE MODULE - SEED DATA
-- Run this AFTER the schema SQL
-- ============================================

-- ============================================
-- 1) DIET PLANS
-- ============================================

INSERT INTO diet_plans (id, title, description, plan_type, duration_days, category, difficulty_level, calories_per_day, tags, is_published, is_featured, cover_image_url, created_at, updated_at)
VALUES
  -- Plan 1: 7-Day Weight Loss
  ('a1000000-0000-0000-0000-000000000001',
   '7-Day Clean Eating Plan',
   'A beginner-friendly weekly plan focused on whole foods and balanced macros. Perfect for kickstarting your weight loss journey with simple, delicious meals.',
   'weekly', 7, 'weight_loss', 'beginner', 1500,
   ARRAY['clean eating', 'beginner', 'low calorie'],
   true, true,
   'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80',
   now(), now()),

  -- Plan 2: 30-Day Muscle Gain
  ('a1000000-0000-0000-0000-000000000002',
   '30-Day Muscle Builder',
   'High-protein monthly meal plan designed for lean muscle growth. Packed with protein-rich foods, complex carbs, and healthy fats to fuel your workouts.',
   'monthly', 30, 'muscle_gain', 'intermediate', 2800,
   ARRAY['high protein', 'muscle', 'bulk'],
   true, true,
   'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=800&q=80',
   now(), now()),

  -- Plan 3: 14-Day Keto
  ('a1000000-0000-0000-0000-000000000003',
   '14-Day Keto Kickstart',
   'Enter ketosis with this carefully structured 2-week plan. Low carb, high fat meals that keep you energized while burning fat efficiently.',
   'custom', 14, 'keto', 'intermediate', 1800,
   ARRAY['keto', 'low carb', 'fat burning'],
   true, true,
   'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=800&q=80',
   now(), now()),

  -- Plan 4: 7-Day Vegan
  ('a1000000-0000-0000-0000-000000000004',
   '7-Day Plant Power',
   'A vibrant plant-based weekly plan rich in nutrients and flavor. Proves that vegan eating can be satisfying, protein-packed, and incredibly tasty.',
   'weekly', 7, 'vegan', 'beginner', 1700,
   ARRAY['vegan', 'plant based', 'green'],
   true, false,
   'https://images.unsplash.com/photo-1540914124281-342587941389?w=800&q=80',
   now(), now()),

  -- Plan 5: 21-Day High Protein (draft)
  ('a1000000-0000-0000-0000-000000000005',
   '21-Day Protein Challenge',
   'Three weeks of high-protein meals to support intense training. Each day is optimized for pre and post workout nutrition.',
   'custom', 21, 'high_protein', 'advanced', 2400,
   ARRAY['high protein', 'challenge', 'athletic'],
   false, false,
   'https://images.unsplash.com/photo-1547592180-85f173990554?w=800&q=80',
   now(), now());


-- ============================================
-- 2) DIET PLAN DAYS
-- ============================================

-- === Plan 1: 7-Day Clean Eating (all 7 days) ===
INSERT INTO diet_plan_days (id, plan_id, day_number, title, total_calories, total_protein_g, total_carbs_g, total_fat_g, created_at, updated_at)
VALUES
  ('d1000000-0000-0000-0001-000000000001', 'a1000000-0000-0000-0000-000000000001', 1, 'Day 1 - Fresh Start',    1480, 95, 165, 52, now(), now()),
  ('d1000000-0000-0000-0001-000000000002', 'a1000000-0000-0000-0000-000000000001', 2, 'Day 2 - Green Focus',    1510, 90, 170, 55, now(), now()),
  ('d1000000-0000-0000-0001-000000000003', 'a1000000-0000-0000-0000-000000000001', 3, 'Day 3 - Protein Boost',  1520, 110, 150, 55, now(), now()),
  ('d1000000-0000-0000-0001-000000000004', 'a1000000-0000-0000-0000-000000000001', 4, 'Day 4 - Light & Fresh',  1450, 85, 175, 48, now(), now()),
  ('d1000000-0000-0000-0001-000000000005', 'a1000000-0000-0000-0000-000000000001', 5, 'Day 5 - Energy Day',     1500, 92, 168, 53, now(), now()),
  ('d1000000-0000-0000-0001-000000000006', 'a1000000-0000-0000-0000-000000000001', 6, 'Day 6 - Power Meals',    1530, 105, 155, 58, now(), now()),
  ('d1000000-0000-0000-0001-000000000007', 'a1000000-0000-0000-0000-000000000001', 7, 'Day 7 - Finish Strong',  1490, 98, 162, 50, now(), now());

-- === Plan 2: 30-Day Muscle (first 7 days seeded) ===
INSERT INTO diet_plan_days (id, plan_id, day_number, title, total_calories, total_protein_g, total_carbs_g, total_fat_g, created_at, updated_at)
VALUES
  ('d1000000-0000-0000-0002-000000000001', 'a1000000-0000-0000-0000-000000000002', 1, 'Day 1 - Foundation',  2780, 180, 310, 85, now(), now()),
  ('d1000000-0000-0000-0002-000000000002', 'a1000000-0000-0000-0000-000000000002', 2, 'Day 2 - Push Day',    2820, 185, 305, 90, now(), now()),
  ('d1000000-0000-0000-0002-000000000003', 'a1000000-0000-0000-0000-000000000002', 3, 'Day 3 - Pull Day',    2750, 178, 300, 88, now(), now()),
  ('d1000000-0000-0000-0002-000000000004', 'a1000000-0000-0000-0000-000000000002', 4, 'Day 4 - Leg Day',     2900, 190, 330, 82, now(), now()),
  ('d1000000-0000-0000-0002-000000000005', 'a1000000-0000-0000-0000-000000000002', 5, 'Day 5 - Active Rest', 2600, 165, 290, 80, now(), now()),
  ('d1000000-0000-0000-0002-000000000006', 'a1000000-0000-0000-0000-000000000002', 6, 'Day 6 - Upper Body',  2800, 182, 315, 86, now(), now()),
  ('d1000000-0000-0000-0002-000000000007', 'a1000000-0000-0000-0000-000000000002', 7, 'Day 7 - Lower Body',  2850, 188, 320, 84, now(), now());

-- === Plan 3: 14-Day Keto (first 7 days seeded) ===
INSERT INTO diet_plan_days (id, plan_id, day_number, title, total_calories, total_protein_g, total_carbs_g, total_fat_g, created_at, updated_at)
VALUES
  ('d1000000-0000-0000-0003-000000000001', 'a1000000-0000-0000-0000-000000000003', 1, 'Day 1 - Keto Start',       1780, 110, 25, 140, now(), now()),
  ('d1000000-0000-0000-0003-000000000002', 'a1000000-0000-0000-0000-000000000003', 2, 'Day 2 - Fat Adapted',      1800, 115, 22, 142, now(), now()),
  ('d1000000-0000-0000-0003-000000000003', 'a1000000-0000-0000-0000-000000000003', 3, 'Day 3 - Keto Cruise',      1820, 112, 28, 138, now(), now()),
  ('d1000000-0000-0000-0003-000000000004', 'a1000000-0000-0000-0000-000000000003', 4, 'Day 4 - Deep Ketosis',     1750, 108, 20, 140, now(), now()),
  ('d1000000-0000-0000-0003-000000000005', 'a1000000-0000-0000-0000-000000000003', 5, 'Day 5 - Keto Balance',     1790, 114, 24, 137, now(), now()),
  ('d1000000-0000-0000-0003-000000000006', 'a1000000-0000-0000-0000-000000000003', 6, 'Day 6 - Keto Power',       1810, 118, 26, 139, now(), now()),
  ('d1000000-0000-0000-0003-000000000007', 'a1000000-0000-0000-0000-000000000003', 7, 'Day 7 - Week 1 Complete',  1780, 112, 23, 141, now(), now());

-- === Plan 4: 7-Day Vegan (all 7 days) ===
INSERT INTO diet_plan_days (id, plan_id, day_number, title, total_calories, total_protein_g, total_carbs_g, total_fat_g, created_at, updated_at)
VALUES
  ('d1000000-0000-0000-0004-000000000001', 'a1000000-0000-0000-0000-000000000004', 1, 'Day 1 - Green Machine',  1680, 65, 230, 55, now(), now()),
  ('d1000000-0000-0000-0004-000000000002', 'a1000000-0000-0000-0000-000000000004', 2, 'Day 2 - Rainbow Bowl',   1720, 70, 225, 58, now(), now()),
  ('d1000000-0000-0000-0004-000000000003', 'a1000000-0000-0000-0000-000000000004', 3, 'Day 3 - Bean Power',     1700, 72, 220, 56, now(), now()),
  ('d1000000-0000-0000-0004-000000000004', 'a1000000-0000-0000-0000-000000000004', 4, 'Day 4 - Tofu Tuesday',   1690, 68, 228, 54, now(), now()),
  ('d1000000-0000-0000-0004-000000000005', 'a1000000-0000-0000-0000-000000000004', 5, 'Day 5 - Grain Glory',    1710, 66, 235, 52, now(), now()),
  ('d1000000-0000-0000-0004-000000000006', 'a1000000-0000-0000-0000-000000000004', 6, 'Day 6 - Nut Butter Day', 1740, 74, 218, 62, now(), now()),
  ('d1000000-0000-0000-0004-000000000007', 'a1000000-0000-0000-0000-000000000004', 7, 'Day 7 - Veggie Feast',   1700, 70, 225, 57, now(), now());


-- ============================================
-- 3) MEALS - Plan 1: 7-Day Clean Eating
-- ============================================

-- ---- Day 1 ----
INSERT INTO diet_plan_meals (day_id, meal_type, title, description, calories, protein_g, carbs_g, fat_g, fiber_g, prep_time_minutes, ingredients, recipe_instructions, image_url, sort_order)
VALUES
  ('d1000000-0000-0000-0001-000000000001', 'breakfast',
   'Greek Yogurt Parfait',
   'Creamy Greek yogurt layered with fresh berries, honey, and crunchy granola.',
   380, 22, 48, 12, 4, 5,
   '[{"name":"Greek yogurt","quantity":"200","unit":"g"},{"name":"Mixed berries","quantity":"100","unit":"g"},{"name":"Granola","quantity":"30","unit":"g"},{"name":"Honey","quantity":"1","unit":"tbsp"}]'::jsonb,
   '1. Add yogurt to a bowl or jar.\n2. Layer with mixed berries.\n3. Sprinkle granola on top.\n4. Drizzle with honey.\n5. Serve immediately.',
   'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=600&q=80',
   0),

  ('d1000000-0000-0000-0001-000000000001', 'morning_snack',
   'Apple Slices with Almond Butter',
   'Crisp apple slices paired with creamy almond butter for a satisfying mid-morning snack.',
   180, 5, 22, 10, 3, 3,
   '[{"name":"Apple","quantity":"1","unit":"medium"},{"name":"Almond butter","quantity":"1","unit":"tbsp"}]'::jsonb,
   '1. Wash and slice the apple.\n2. Serve with almond butter for dipping.',
   'https://images.unsplash.com/photo-1568702846914-96b305d2uj68?w=600&q=80',
   1),

  ('d1000000-0000-0000-0001-000000000001', 'lunch',
   'Grilled Chicken Quinoa Bowl',
   'Tender grilled chicken breast over fluffy quinoa with roasted vegetables and a lemon tahini dressing.',
   520, 42, 50, 16, 6, 25,
   '[{"name":"Chicken breast","quantity":"150","unit":"g"},{"name":"Quinoa","quantity":"80","unit":"g"},{"name":"Mixed vegetables","quantity":"150","unit":"g"},{"name":"Tahini","quantity":"1","unit":"tbsp"},{"name":"Lemon juice","quantity":"1","unit":"tbsp"},{"name":"Olive oil","quantity":"1","unit":"tsp"}]'::jsonb,
   '1. Cook quinoa according to package directions.\n2. Season chicken with salt, pepper, and paprika.\n3. Grill chicken for 6-7 min per side until cooked through.\n4. Roast mixed vegetables at 200°C for 15 min.\n5. Slice chicken and arrange over quinoa with vegetables.\n6. Mix tahini with lemon juice and drizzle on top.',
   'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=600&q=80',
   2),

  ('d1000000-0000-0000-0001-000000000001', 'afternoon_snack',
   'Hummus & Veggie Sticks',
   'Crunchy carrot and cucumber sticks with smooth, savory hummus.',
   150, 6, 18, 6, 4, 5,
   '[{"name":"Hummus","quantity":"3","unit":"tbsp"},{"name":"Carrot sticks","quantity":"1","unit":"cup"},{"name":"Cucumber sticks","quantity":"1","unit":"cup"}]'::jsonb,
   '1. Cut carrots and cucumber into sticks.\n2. Serve with hummus for dipping.',
   'https://images.unsplash.com/photo-1623428187969-5da2dcea5ebf?w=600&q=80',
   3),

  ('d1000000-0000-0000-0001-000000000001', 'dinner',
   'Baked Salmon with Sweet Potato',
   'Omega-3 rich salmon fillet baked with herbs, served alongside roasted sweet potato and steamed broccoli.',
   480, 38, 42, 18, 5, 30,
   '[{"name":"Salmon fillet","quantity":"150","unit":"g"},{"name":"Sweet potato","quantity":"200","unit":"g"},{"name":"Broccoli","quantity":"150","unit":"g"},{"name":"Olive oil","quantity":"1","unit":"tbsp"},{"name":"Garlic","quantity":"2","unit":"cloves"},{"name":"Lemon","quantity":"1","unit":"slice"},{"name":"Dill","quantity":"1","unit":"tsp"}]'::jsonb,
   '1. Preheat oven to 200°C.\n2. Cube sweet potato, toss with olive oil, and roast for 20 min.\n3. Season salmon with garlic, dill, salt, and pepper.\n4. Place salmon on baking sheet with lemon slice. Bake 12-15 min.\n5. Steam broccoli for 5 min.\n6. Plate everything together and serve.',
   'https://images.unsplash.com/photo-1467003909585-2f8a72700288?w=600&q=80',
   4);

-- ---- Day 2 ----
INSERT INTO diet_plan_meals (day_id, meal_type, title, description, calories, protein_g, carbs_g, fat_g, fiber_g, prep_time_minutes, ingredients, recipe_instructions, image_url, sort_order)
VALUES
  ('d1000000-0000-0000-0001-000000000002', 'breakfast',
   'Overnight Oats with Banana',
   'Creamy overnight oats topped with sliced banana, chia seeds, and a drizzle of maple syrup.',
   400, 14, 62, 12, 6, 5,
   '[{"name":"Rolled oats","quantity":"60","unit":"g"},{"name":"Milk","quantity":"150","unit":"ml"},{"name":"Chia seeds","quantity":"1","unit":"tbsp"},{"name":"Banana","quantity":"1","unit":"medium"},{"name":"Maple syrup","quantity":"1","unit":"tsp"}]'::jsonb,
   '1. Mix oats, milk, and chia seeds in a jar.\n2. Refrigerate overnight.\n3. Top with sliced banana and maple syrup in the morning.',
   'https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=600&q=80',
   0),

  ('d1000000-0000-0000-0001-000000000002', 'morning_snack',
   'Mixed Nuts',
   'A handful of raw mixed nuts for a quick energy boost.',
   170, 5, 8, 15, 2, 1,
   '[{"name":"Mixed nuts","quantity":"30","unit":"g"}]'::jsonb,
   '1. Portion out nuts and enjoy.',
   'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=600&q=80',
   1),

  ('d1000000-0000-0000-0001-000000000002', 'lunch',
   'Mediterranean Salad with Tuna',
   'Fresh garden salad with canned tuna, olives, cherry tomatoes, feta cheese, and olive oil dressing.',
   480, 38, 28, 24, 5, 10,
   '[{"name":"Canned tuna","quantity":"150","unit":"g"},{"name":"Mixed greens","quantity":"100","unit":"g"},{"name":"Cherry tomatoes","quantity":"80","unit":"g"},{"name":"Cucumber","quantity":"80","unit":"g"},{"name":"Black olives","quantity":"30","unit":"g"},{"name":"Feta cheese","quantity":"30","unit":"g"},{"name":"Olive oil","quantity":"1","unit":"tbsp"},{"name":"Lemon juice","quantity":"1","unit":"tsp"}]'::jsonb,
   '1. Arrange mixed greens on a plate.\n2. Top with drained tuna, halved tomatoes, sliced cucumber, and olives.\n3. Crumble feta cheese over the top.\n4. Drizzle with olive oil and lemon juice.',
   'https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=600&q=80',
   2),

  ('d1000000-0000-0000-0001-000000000002', 'afternoon_snack',
   'Rice Cakes with Avocado',
   'Whole grain rice cakes topped with mashed avocado, salt, and chili flakes.',
   160, 3, 20, 8, 3, 3,
   '[{"name":"Rice cakes","quantity":"2","unit":"pieces"},{"name":"Avocado","quantity":"0.5","unit":"medium"},{"name":"Chili flakes","quantity":"1","unit":"pinch"}]'::jsonb,
   '1. Mash avocado with a fork.\n2. Spread on rice cakes.\n3. Season with salt and chili flakes.',
   'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600&q=80',
   3),

  ('d1000000-0000-0000-0001-000000000002', 'dinner',
   'Turkey Stir-Fry with Brown Rice',
   'Lean ground turkey stir-fried with colorful bell peppers, snap peas, and ginger soy sauce over brown rice.',
   500, 40, 52, 14, 5, 20,
   '[{"name":"Ground turkey","quantity":"150","unit":"g"},{"name":"Brown rice","quantity":"80","unit":"g"},{"name":"Bell peppers","quantity":"100","unit":"g"},{"name":"Snap peas","quantity":"80","unit":"g"},{"name":"Soy sauce","quantity":"1","unit":"tbsp"},{"name":"Ginger","quantity":"1","unit":"tsp"},{"name":"Garlic","quantity":"2","unit":"cloves"},{"name":"Sesame oil","quantity":"1","unit":"tsp"}]'::jsonb,
   '1. Cook brown rice according to package.\n2. Heat sesame oil in a wok.\n3. Brown the turkey with garlic and ginger.\n4. Add sliced bell peppers and snap peas, stir-fry 3-4 min.\n5. Add soy sauce and toss to combine.\n6. Serve over brown rice.',
   'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=600&q=80',
   4);

-- ---- Day 3 ----
INSERT INTO diet_plan_meals (day_id, meal_type, title, description, calories, protein_g, carbs_g, fat_g, fiber_g, prep_time_minutes, ingredients, recipe_instructions, image_url, sort_order)
VALUES
  ('d1000000-0000-0000-0001-000000000003', 'breakfast',
   'Egg White Omelette with Spinach',
   'Fluffy egg white omelette loaded with spinach, mushrooms, and a sprinkle of feta cheese.',
   280, 30, 8, 14, 2, 10,
   '[{"name":"Egg whites","quantity":"5","unit":"large"},{"name":"Spinach","quantity":"50","unit":"g"},{"name":"Mushrooms","quantity":"50","unit":"g"},{"name":"Feta cheese","quantity":"20","unit":"g"},{"name":"Olive oil spray","quantity":"1","unit":"spray"}]'::jsonb,
   '1. Heat a non-stick pan with olive oil spray.\n2. Sauté mushrooms and spinach until wilted.\n3. Pour egg whites over vegetables.\n4. Cook until set, fold in half.\n5. Top with crumbled feta.',
   'https://images.unsplash.com/photo-1510693206972-df098062cb71?w=600&q=80',
   0),

  ('d1000000-0000-0000-0001-000000000003', 'morning_snack',
   'Protein Smoothie',
   'Refreshing smoothie with protein powder, banana, and peanut butter.',
   250, 25, 28, 6, 3, 5,
   '[{"name":"Protein powder","quantity":"1","unit":"scoop"},{"name":"Banana","quantity":"0.5","unit":"medium"},{"name":"Peanut butter","quantity":"1","unit":"tsp"},{"name":"Milk","quantity":"200","unit":"ml"},{"name":"Ice","quantity":"4","unit":"cubes"}]'::jsonb,
   '1. Add all ingredients to a blender.\n2. Blend until smooth.\n3. Pour and enjoy.',
   'https://images.unsplash.com/photo-1553530666-ba11a7da3888?w=600&q=80',
   1),

  ('d1000000-0000-0000-0001-000000000003', 'lunch',
   'Chicken Caesar Wrap',
   'Grilled chicken wrapped in a whole wheat tortilla with romaine lettuce, parmesan, and light Caesar dressing.',
   480, 38, 40, 18, 4, 15,
   '[{"name":"Chicken breast","quantity":"120","unit":"g"},{"name":"Whole wheat tortilla","quantity":"1","unit":"large"},{"name":"Romaine lettuce","quantity":"50","unit":"g"},{"name":"Parmesan","quantity":"15","unit":"g"},{"name":"Caesar dressing (light)","quantity":"1","unit":"tbsp"}]'::jsonb,
   '1. Grill and slice chicken breast.\n2. Warm the tortilla.\n3. Layer lettuce, chicken, and parmesan.\n4. Drizzle with dressing.\n5. Roll tightly and slice in half.',
   'https://images.unsplash.com/photo-1626700051175-6818013e1d4f?w=600&q=80',
   2),

  ('d1000000-0000-0000-0001-000000000003', 'afternoon_snack',
   'Cottage Cheese with Pineapple',
   'Low-fat cottage cheese topped with fresh pineapple chunks.',
   140, 14, 16, 2, 1, 2,
   '[{"name":"Cottage cheese","quantity":"120","unit":"g"},{"name":"Pineapple chunks","quantity":"80","unit":"g"}]'::jsonb,
   '1. Scoop cottage cheese into a bowl.\n2. Top with fresh pineapple chunks.',
   'https://images.unsplash.com/photo-1559181567-c3190ca9959b?w=600&q=80',
   3),

  ('d1000000-0000-0000-0001-000000000003', 'dinner',
   'Lean Beef Steak with Roasted Veggies',
   'Perfectly seared lean beef steak with a side of roasted zucchini, bell peppers, and asparagus.',
   520, 45, 28, 25, 5, 25,
   '[{"name":"Lean beef steak","quantity":"150","unit":"g"},{"name":"Zucchini","quantity":"100","unit":"g"},{"name":"Bell pepper","quantity":"80","unit":"g"},{"name":"Asparagus","quantity":"80","unit":"g"},{"name":"Olive oil","quantity":"1","unit":"tbsp"},{"name":"Rosemary","quantity":"1","unit":"sprig"},{"name":"Garlic","quantity":"2","unit":"cloves"}]'::jsonb,
   '1. Season steak with salt, pepper, and rosemary.\n2. Sear in a hot pan 4 min per side for medium.\n3. Rest for 5 minutes.\n4. Toss vegetables with olive oil and garlic.\n5. Roast at 200°C for 15 min.\n6. Slice steak and plate with vegetables.',
   'https://images.unsplash.com/photo-1558030006-450675393462?w=600&q=80',
   4);


-- ============================================
-- 4) MEALS - Plan 3: 14-Day Keto (Day 1 only)
-- ============================================

INSERT INTO diet_plan_meals (day_id, meal_type, title, description, calories, protein_g, carbs_g, fat_g, fiber_g, prep_time_minutes, ingredients, recipe_instructions, image_url, sort_order)
VALUES
  ('d1000000-0000-0000-0003-000000000001', 'breakfast',
   'Bacon & Cheese Scrambled Eggs',
   'Fluffy scrambled eggs with crispy bacon bits and melted cheddar cheese. A keto breakfast classic.',
   450, 30, 3, 36, 0, 10,
   '[{"name":"Eggs","quantity":"3","unit":"large"},{"name":"Bacon","quantity":"3","unit":"strips"},{"name":"Cheddar cheese","quantity":"30","unit":"g"},{"name":"Butter","quantity":"1","unit":"tbsp"},{"name":"Salt & pepper","quantity":"1","unit":"pinch"}]'::jsonb,
   '1. Cook bacon until crispy, crumble.\n2. Melt butter in the pan.\n3. Whisk eggs and pour into pan.\n4. Scramble gently, add cheese and bacon.\n5. Serve immediately.',
   'https://images.unsplash.com/photo-1525351484163-7529414344d8?w=600&q=80',
   0),

  ('d1000000-0000-0000-0003-000000000001', 'morning_snack',
   'Celery with Cream Cheese',
   'Crunchy celery sticks filled with herbed cream cheese.',
   130, 3, 4, 12, 1, 3,
   '[{"name":"Celery stalks","quantity":"3","unit":"large"},{"name":"Cream cheese","quantity":"2","unit":"tbsp"},{"name":"Chives","quantity":"1","unit":"tsp"}]'::jsonb,
   '1. Wash and trim celery stalks.\n2. Mix cream cheese with chopped chives.\n3. Fill celery grooves with cream cheese mixture.',
   'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?w=600&q=80',
   1),

  ('d1000000-0000-0000-0003-000000000001', 'lunch',
   'Avocado Chicken Lettuce Wraps',
   'Seasoned chicken and creamy avocado wrapped in fresh butter lettuce leaves.',
   520, 40, 8, 38, 6, 15,
   '[{"name":"Chicken thigh","quantity":"150","unit":"g"},{"name":"Avocado","quantity":"1","unit":"medium"},{"name":"Butter lettuce","quantity":"4","unit":"leaves"},{"name":"Lime juice","quantity":"1","unit":"tbsp"},{"name":"Cumin","quantity":"0.5","unit":"tsp"},{"name":"Olive oil","quantity":"1","unit":"tsp"}]'::jsonb,
   '1. Season chicken with cumin, salt, pepper.\n2. Cook chicken in olive oil, slice.\n3. Slice avocado and squeeze lime over it.\n4. Fill lettuce cups with chicken and avocado.\n5. Serve with extra lime.',
   'https://images.unsplash.com/photo-1515543237350-b3eea1ec8082?w=600&q=80',
   2),

  ('d1000000-0000-0000-0003-000000000001', 'afternoon_snack',
   'Macadamia Nuts',
   'A handful of buttery macadamia nuts - the perfect keto snack.',
   200, 2, 4, 21, 2, 1,
   '[{"name":"Macadamia nuts","quantity":"30","unit":"g"}]'::jsonb,
   '1. Portion and enjoy.',
   'https://images.unsplash.com/photo-1606890737304-57a1ca8a5b62?w=600&q=80',
   3),

  ('d1000000-0000-0000-0003-000000000001', 'dinner',
   'Garlic Butter Steak with Asparagus',
   'Pan-seared ribeye with garlic herb butter, served with roasted asparagus drizzled in olive oil.',
   580, 42, 6, 44, 3, 20,
   '[{"name":"Ribeye steak","quantity":"180","unit":"g"},{"name":"Butter","quantity":"2","unit":"tbsp"},{"name":"Garlic","quantity":"3","unit":"cloves"},{"name":"Asparagus","quantity":"150","unit":"g"},{"name":"Olive oil","quantity":"1","unit":"tbsp"},{"name":"Thyme","quantity":"2","unit":"sprigs"},{"name":"Salt & pepper","quantity":"1","unit":"pinch"}]'::jsonb,
   '1. Season steak generously.\n2. Sear in hot pan 4 min each side.\n3. Add butter, garlic, and thyme to pan. Baste steak.\n4. Rest steak 5 min.\n5. Toss asparagus in olive oil, roast at 200°C for 12 min.\n6. Plate steak with asparagus, spoon garlic butter over top.',
   'https://images.unsplash.com/photo-1432139555190-58524dae6a55?w=600&q=80',
   4);


-- ============================================
-- 5) MEALS - Plan 4: 7-Day Vegan (Day 1 only)
-- ============================================

INSERT INTO diet_plan_meals (day_id, meal_type, title, description, calories, protein_g, carbs_g, fat_g, fiber_g, prep_time_minutes, ingredients, recipe_instructions, image_url, sort_order)
VALUES
  ('d1000000-0000-0000-0004-000000000001', 'breakfast',
   'Tropical Acai Bowl',
   'Thick blended acai base topped with sliced mango, coconut flakes, and granola.',
   420, 10, 68, 14, 8, 10,
   '[{"name":"Acai puree","quantity":"100","unit":"g"},{"name":"Banana","quantity":"1","unit":"frozen"},{"name":"Mango","quantity":"80","unit":"g"},{"name":"Coconut flakes","quantity":"10","unit":"g"},{"name":"Granola","quantity":"30","unit":"g"},{"name":"Almond milk","quantity":"80","unit":"ml"}]'::jsonb,
   '1. Blend acai puree with frozen banana and almond milk.\n2. Pour into a bowl.\n3. Top with sliced mango, coconut flakes, and granola.',
   'https://images.unsplash.com/photo-1590301157890-4810ed352733?w=600&q=80',
   0),

  ('d1000000-0000-0000-0004-000000000001', 'morning_snack',
   'Edamame with Sea Salt',
   'Steamed edamame pods sprinkled with flaky sea salt.',
   150, 12, 10, 6, 4, 5,
   '[{"name":"Edamame (in pods)","quantity":"150","unit":"g"},{"name":"Sea salt","quantity":"1","unit":"pinch"}]'::jsonb,
   '1. Steam edamame for 5 minutes.\n2. Sprinkle with sea salt and serve.',
   'https://images.unsplash.com/photo-1564894809611-1742fc40ed80?w=600&q=80',
   1),

  ('d1000000-0000-0000-0004-000000000001', 'lunch',
   'Buddha Bowl with Tahini Dressing',
   'A nourishing bowl with roasted chickpeas, sweet potato, avocado, kale, and creamy tahini dressing.',
   580, 22, 78, 22, 12, 30,
   '[{"name":"Chickpeas","quantity":"100","unit":"g"},{"name":"Sweet potato","quantity":"150","unit":"g"},{"name":"Kale","quantity":"60","unit":"g"},{"name":"Avocado","quantity":"0.5","unit":"medium"},{"name":"Tahini","quantity":"1","unit":"tbsp"},{"name":"Lemon juice","quantity":"1","unit":"tbsp"},{"name":"Olive oil","quantity":"1","unit":"tsp"},{"name":"Cumin","quantity":"0.5","unit":"tsp"}]'::jsonb,
   '1. Cube sweet potato, toss with olive oil and cumin. Roast 20 min at 200°C.\n2. Drain chickpeas, season, and roast alongside for 15 min.\n3. Massage kale with a little olive oil.\n4. Make dressing: mix tahini, lemon juice, and water.\n5. Assemble bowl with kale, sweet potato, chickpeas, and avocado slices.\n6. Drizzle with tahini dressing.',
   'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80',
   2),

  ('d1000000-0000-0000-0004-000000000001', 'afternoon_snack',
   'Trail Mix Energy Bites',
   'No-bake energy balls made with oats, dates, peanut butter, and dark chocolate chips.',
   180, 5, 26, 8, 3, 15,
   '[{"name":"Rolled oats","quantity":"40","unit":"g"},{"name":"Medjool dates","quantity":"3","unit":"pieces"},{"name":"Peanut butter","quantity":"1","unit":"tbsp"},{"name":"Dark chocolate chips","quantity":"10","unit":"g"},{"name":"Chia seeds","quantity":"1","unit":"tsp"}]'::jsonb,
   '1. Blend dates in a food processor.\n2. Mix with oats, peanut butter, chia seeds, and chocolate chips.\n3. Roll into 4 balls.\n4. Refrigerate for 30 min.',
   'https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?w=600&q=80',
   3),

  ('d1000000-0000-0000-0004-000000000001', 'dinner',
   'Coconut Lentil Curry',
   'Creamy red lentil curry simmered in coconut milk with warming spices, served over basmati rice.',
   550, 22, 72, 18, 10, 25,
   '[{"name":"Red lentils","quantity":"100","unit":"g"},{"name":"Coconut milk","quantity":"200","unit":"ml"},{"name":"Basmati rice","quantity":"80","unit":"g"},{"name":"Onion","quantity":"1","unit":"medium"},{"name":"Garlic","quantity":"3","unit":"cloves"},{"name":"Ginger","quantity":"1","unit":"tsp"},{"name":"Curry powder","quantity":"1","unit":"tbsp"},{"name":"Tomato paste","quantity":"1","unit":"tbsp"},{"name":"Spinach","quantity":"50","unit":"g"}]'::jsonb,
   '1. Cook rice according to package.\n2. Sauté onion, garlic, and ginger until fragrant.\n3. Add curry powder and tomato paste, cook 1 min.\n4. Add lentils and coconut milk. Simmer 18-20 min.\n5. Stir in spinach until wilted.\n6. Serve curry over basmati rice.',
   'https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?w=600&q=80',
   4);


-- ============================================
-- 6) MEALS - Plan 2: 30-Day Muscle (Day 1 only)
-- ============================================

INSERT INTO diet_plan_meals (day_id, meal_type, title, description, calories, protein_g, carbs_g, fat_g, fiber_g, prep_time_minutes, ingredients, recipe_instructions, image_url, sort_order)
VALUES
  ('d1000000-0000-0000-0002-000000000001', 'breakfast',
   'Protein Pancakes with Berries',
   'Fluffy protein-packed pancakes made with oats and whey, topped with fresh berries and a light syrup drizzle.',
   550, 40, 62, 14, 5, 15,
   '[{"name":"Oats","quantity":"60","unit":"g"},{"name":"Protein powder","quantity":"1","unit":"scoop"},{"name":"Eggs","quantity":"2","unit":"large"},{"name":"Banana","quantity":"1","unit":"medium"},{"name":"Mixed berries","quantity":"80","unit":"g"},{"name":"Maple syrup","quantity":"1","unit":"tsp"}]'::jsonb,
   '1. Blend oats, protein powder, eggs, and banana.\n2. Cook pancakes on a non-stick pan, 2-3 min per side.\n3. Stack and top with berries and syrup.',
   'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=600&q=80',
   0),

  ('d1000000-0000-0000-0002-000000000001', 'morning_snack',
   'Boiled Eggs & Rice Cakes',
   'Two hard-boiled eggs with whole grain rice cakes for a quick pre-workout snack.',
   280, 18, 28, 10, 2, 15,
   '[{"name":"Eggs","quantity":"2","unit":"large"},{"name":"Rice cakes","quantity":"2","unit":"pieces"},{"name":"Salt & pepper","quantity":"1","unit":"pinch"}]'::jsonb,
   '1. Boil eggs for 10 min, cool and peel.\n2. Serve with rice cakes.',
   'https://images.unsplash.com/photo-1482049016688-2d3e1b311543?w=600&q=80',
   1),

  ('d1000000-0000-0000-0002-000000000001', 'lunch',
   'Double Chicken Rice Bowl',
   'Large portion of grilled chicken breast with jasmine rice, black beans, corn, and avocado salsa.',
   750, 55, 80, 20, 8, 25,
   '[{"name":"Chicken breast","quantity":"200","unit":"g"},{"name":"Jasmine rice","quantity":"120","unit":"g"},{"name":"Black beans","quantity":"80","unit":"g"},{"name":"Corn","quantity":"50","unit":"g"},{"name":"Avocado","quantity":"0.5","unit":"medium"},{"name":"Lime juice","quantity":"1","unit":"tbsp"},{"name":"Cilantro","quantity":"2","unit":"tbsp"}]'::jsonb,
   '1. Cook rice. Season and grill chicken.\n2. Heat black beans and corn.\n3. Dice avocado, mix with lime and cilantro.\n4. Build bowl: rice, beans, corn, sliced chicken, avocado salsa.',
   'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=600&q=80',
   2),

  ('d1000000-0000-0000-0002-000000000001', 'afternoon_snack',
   'Protein Shake with Banana',
   'Post-workout protein shake blended with banana and oat milk.',
   320, 32, 38, 6, 3, 3,
   '[{"name":"Whey protein","quantity":"1.5","unit":"scoops"},{"name":"Banana","quantity":"1","unit":"medium"},{"name":"Oat milk","quantity":"250","unit":"ml"}]'::jsonb,
   '1. Add all ingredients to a blender.\n2. Blend until smooth.\n3. Drink within 30 min of workout.',
   'https://images.unsplash.com/photo-1622597467836-f3285f2131b8?w=600&q=80',
   3),

  ('d1000000-0000-0000-0002-000000000001', 'dinner',
   'Salmon with Pasta & Greens',
   'Grilled Atlantic salmon fillet served with whole wheat penne, sautéed spinach, and garlic olive oil.',
   680, 48, 65, 24, 6, 25,
   '[{"name":"Salmon fillet","quantity":"180","unit":"g"},{"name":"Whole wheat penne","quantity":"100","unit":"g"},{"name":"Spinach","quantity":"80","unit":"g"},{"name":"Garlic","quantity":"3","unit":"cloves"},{"name":"Olive oil","quantity":"1.5","unit":"tbsp"},{"name":"Cherry tomatoes","quantity":"80","unit":"g"},{"name":"Lemon","quantity":"1","unit":"wedge"}]'::jsonb,
   '1. Cook pasta al dente.\n2. Season and grill salmon 5-6 min per side.\n3. Sauté garlic in olive oil, add spinach and tomatoes.\n4. Toss pasta with the garlic spinach mixture.\n5. Plate pasta, top with salmon and a lemon squeeze.',
   'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=600&q=80',
   4);
