import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'app/app.dart';
import 'core/services/supabase_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/feed_cache_service.dart';
import 'core/services/media/media_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize services
  await _initServices();

  runApp(const CoFitApp());
}

/// Initialize all app services
Future<void> _initServices() async {
  // Initialize Supabase first
  await Get.putAsync<SupabaseService>(
    () => SupabaseService().init(),
    permanent: true,
  );

  // Initialize Auth Service (depends on Supabase)
  await Get.putAsync<AuthService>(() => AuthService().init(), permanent: true);

  // Initialize Feed Cache Service
  await Get.putAsync<FeedCacheService>(
    () => FeedCacheService().init(),
    permanent: true,
  );

  // Initialize Media Service (depends on Supabase)
  await Get.putAsync<MediaService>(
    () => MediaService().init(),
    permanent: true,
  );
}
