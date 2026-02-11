/// Media Service Configuration - All constants for media operations
class MediaConfig {
  MediaConfig._();

  // ============================================
  // SUPABASE STORAGE BUCKETS
  // ============================================
  static const String postImagesBucket = 'post-images';
  static const String profileImagesBucket = 'profile-images';
  static const String trainerImagesBucket = 'trainer-images';
  static const String workoutMediaBucket = 'workout-media';
  static const String challengeImagesBucket = 'challenge-images';

  // ============================================
  // IMAGE COMPRESSION
  // ============================================
  static const int defaultQuality = 80;
  static const int thumbnailQuality = 60;
  static const int maxImageWidth = 1080;
  static const int maxImageHeight = 1080;
  static const int profileImageSize = 512;
  static const int thumbnailSize = 200;

  /// Minimum file size (in bytes) to trigger compression
  /// Images smaller than 100KB skip compression
  static const int compressionThreshold = 100 * 1024;

  // ============================================
  // CACHE
  // ============================================
  static const String profileCacheDir = 'profile_cache';
  static const String profileCacheMetaKey = 'profile_cache_meta';

  // ============================================
  // FILE NAMING
  // ============================================
  static const String defaultImageExtension = 'jpg';
  static const String defaultContentType = 'image/jpeg';
}
