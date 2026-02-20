-- ============================================
-- CRASHLYTICS SEED DATA
-- Sample crash/exception logs for testing admin module
-- ============================================

-- Fatal crashes
INSERT INTO crash_logs (error_type, error_message, stack_trace, fatal, source, screen_route, platform, os_version, app_version, device_model, created_at) VALUES
('RangeError', 'RangeError (index): Invalid value: Not in inclusive range 0..4: 5', '#0      List.[] (dart:core-patch/growable_array.dart:264:36)\n#1      WorkoutPlayerController.nextExercise (package:cofit_collective/features/workouts/controllers/workout_player_controller.dart:142:28)\n#2      WorkoutPlayerScreen._onNextTap (package:cofit_collective/features/workouts/views/workout_player_screen.dart:89:22)', true, 'flutter', '/workout-player', 'android', 'Android 14', '1.0.0+1', 'Samsung Galaxy S24', now() - interval '2 hours'),

('NoSuchMethodError', 'NoSuchMethodError: The method ''toDouble'' was called on null.', '#0      Object.noSuchMethod (dart:core-patch/object_patch.dart:38:5)\n#1      ProgressController.calculateBMI (package:cofit_collective/features/progress/controllers/progress_controller.dart:98:34)\n#2      ProgressScreen.build (package:cofit_collective/features/progress/views/progress_screen.dart:67:18)', true, 'flutter', '/progress', 'ios', 'iOS 17.4', '1.0.0+1', 'iPhone 15 Pro', now() - interval '5 hours'),

('StateError', 'Bad state: No element', '#0      List.first (dart:core/list.dart:54:5)\n#1      HomeController.getTodayWorkout (package:cofit_collective/features/home/controllers/home_controller.dart:203:42)\n#2      HomeScreen._buildTodayCard (package:cofit_collective/features/home/views/home_screen.dart:156:30)', true, 'flutter', '/home', 'android', 'Android 13', '1.0.0+1', 'Pixel 8', now() - interval '1 day'),

('TypeError', 'type ''Null'' is not a subtype of type ''String'' in type cast', '#0      ChallengeController.loadChallengeDetail (package:cofit_collective/features/challenges/controllers/challenge_controller.dart:87:44)\n#1      ChallengeDetailScreen.build (package:cofit_collective/features/challenges/views/challenge_detail_screen.dart:34:22)', true, 'platform', '/challenge-detail', 'ios', 'iOS 16.7', '1.0.0+1', 'iPhone 13', now() - interval '2 days'),

('FormatException', 'FormatException: Invalid date format: "not-a-date"', '#0      DateTime.parse (dart:core/date_time.dart:315:7)\n#1      CommunityController.parsePostDate (package:cofit_collective/features/community/controllers/community_controller.dart:245:28)', true, 'dart', '/community', 'android', 'Android 12', '1.0.0+1', 'OnePlus 11', now() - interval '3 days');

-- Non-fatal exceptions
INSERT INTO crash_logs (error_type, error_message, stack_trace, fatal, source, screen_route, platform, os_version, app_version, device_model, created_at) VALUES
('SocketException', 'SocketException: Connection refused (OS Error: Connection refused, errno = 111)', '#0      IOClient.send (package:http/src/io_client.dart:76:7)\n#1      BaseRepository.executeQuery (package:cofit_collective/data/repositories/base_repository.dart:14:14)', false, 'dart', '/home', 'android', 'Android 14', '1.0.0+1', 'Samsung Galaxy A54', now() - interval '30 minutes'),

('TimeoutException', 'TimeoutException after 0:00:30.000000: Future not completed', '#0      SupabaseService.from (package:cofit_collective/core/services/supabase_service.dart:101:5)\n#1      CommunityRepository.getPosts (package:cofit_collective/data/repositories/community_repository.dart:23:18)', false, 'dart', '/community', 'ios', 'iOS 17.2', '1.0.0+1', 'iPhone 14', now() - interval '1 hour'),

('PostgrestException', 'PostgrestException: Could not find a relationship between ''posts'' and ''likes'' in the schema cache', '#0      BaseRepository.executeQuery (package:cofit_collective/data/repositories/base_repository.dart:16:7)\n#1      CommunityRepository.getPostsWithLikes (package:cofit_collective/data/repositories/community_repository.dart:45:12)', false, 'dart', '/community', 'android', 'Android 14', '1.0.0+1', 'Pixel 7a', now() - interval '4 hours'),

('HandshakeException', 'HandshakeException: Handshake error in client (OS Error: CERTIFICATE_VERIFY_FAILED)', '#0      IOClient.send (package:http/src/io_client.dart:56:11)\n#1      MediaService.uploadImage (package:cofit_collective/core/services/media/media_service.dart:67:14)', false, 'dart', '/edit-profile', 'ios', 'iOS 16.5', '1.0.0+1', 'iPhone 12', now() - interval '6 hours'),

('PlatformException', 'PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)', '#0      GoogleSignIn.signIn (package:google_sign_in/google_sign_in.dart:167:5)\n#1      AuthService.signInWithGoogle (package:cofit_collective/core/services/auth_service.dart:112:24)', false, 'dart', '/sign-in', 'android', 'Android 13', '1.0.0+1', 'Xiaomi Redmi Note 12', now() - interval '8 hours'),

('ImageCodecException', 'Exception: Failed to decode image: Invalid image data', '#0      _futurize (dart:ui/painting.dart:5765:7)\n#1      CofitImage.build (package:cofit_collective/shared/widgets/cofit_image.dart:45:18)', false, 'flutter', '/workout-detail', 'android', 'Android 11', '1.0.0+1', 'Samsung Galaxy M33', now() - interval '10 hours'),

('SocketException', 'SocketException: Connection timed out (OS Error: Connection timed out, errno = 110)', '#0      IOClient.send (package:http/src/io_client.dart:76:7)\n#1      NotificationService.registerToken (package:cofit_collective/notifications/service.dart:88:12)', false, 'dart', '/splash', 'ios', 'iOS 17.3', '1.0.0+1', 'iPhone 15', now() - interval '12 hours'),

('FlutterError', 'A RenderFlex overflowed by 42 pixels on the right.', '#0      RenderFlex.performLayout (package:flutter/src/rendering/flex.dart:926:5)\n#1      RenderObject.layout (package:flutter/src/rendering/object.dart:2164:7)', false, 'flutter', '/workout-detail', 'android', 'Android 14', '1.0.0+1', 'Pixel 8 Pro', now() - interval '1 day'),

('RangeError', 'RangeError (length): Invalid value: Valid value range is empty: 0', '#0      List.[] (dart:core-patch/growable_array.dart:264:36)\n#1      RecipeController.getMealsForDay (package:cofit_collective/features/recipes/controllers/recipe_controller.dart:78:22)', false, 'dart', '/recipe-detail', 'ios', 'iOS 17.1', '1.0.0+1', 'iPhone 14 Pro Max', now() - interval '1 day 6 hours'),

('TypeError', 'type ''int'' is not a subtype of type ''String''', '#0      AchievementService.checkProgress (package:cofit_collective/core/services/achievement_service.dart:134:28)\n#1      WorkoutPlayerController.onWorkoutComplete (package:cofit_collective/features/workouts/controllers/workout_player_controller.dart:198:16)', false, 'dart', '/workout-player', 'android', 'Android 12', '1.0.0+1', 'Samsung Galaxy S21', now() - interval '2 days'),

('FormatException', 'FormatException: Unexpected character (at character 1)\n<!DOCTYPE html>', '#0      _parseJson (dart:convert/json.dart:156:10)\n#1      SupabaseService.rpc (package:cofit_collective/core/services/supabase_service.dart:105:14)', false, 'dart', '/challenges', 'android', 'Android 13', '1.0.0+1', 'Nothing Phone 2', now() - interval '2 days 4 hours'),

('StateError', 'Bad state: Stream has already been listened to.', '#0      _StreamController._subscribe (dart:async/stream_controller.dart:670:7)\n#1      AuthService._listenAuthChanges (package:cofit_collective/core/services/auth_service.dart:48:32)', false, 'dart', '/main', 'ios', 'iOS 16.6', '1.0.0+1', 'iPad Air 5th Gen', now() - interval '3 days'),

('SocketException', 'SocketException: No route to host (OS Error: No route to host, errno = 113)', '#0      IOClient.send (package:http/src/io_client.dart:76:7)\n#1      FeedCacheService.syncFeed (package:cofit_collective/core/services/feed_cache_service.dart:56:18)', false, 'dart', '/community', 'android', 'Android 14', '1.0.0+1', 'Samsung Galaxy S23 Ultra', now() - interval '4 days'),

('LateInitializationError', 'LateInitializationError: Field ''_controller'' has not been initialized.', '#0      WorkoutPlayerController._controller (package:cofit_collective/features/workouts/controllers/workout_player_controller.dart:22:28)\n#1      WorkoutPlayerScreen.dispose (package:cofit_collective/features/workouts/views/workout_player_screen.dart:178:12)', false, 'dart', '/workout-player', 'ios', 'iOS 17.0', '1.0.0+1', 'iPhone 14 Plus', now() - interval '5 days'),

('TimeoutException', 'TimeoutException after 0:00:15.000000: Future not completed', '#0      SupabaseService.from (package:cofit_collective/core/services/supabase_service.dart:101:5)\n#1      SupportService.loadTickets (package:cofit_collective/core/services/support_service.dart:34:18)', false, 'dart', '/support', 'android', 'Android 13', '1.0.0+1', 'Google Pixel 6', now() - interval '6 days');
