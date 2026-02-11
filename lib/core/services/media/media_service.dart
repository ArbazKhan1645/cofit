import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../supabase_service.dart';
import 'media_cache_service.dart';
import 'media_config.dart';
import 'media_upload_service.dart';

/// Main Media Service - Single entry point for all media operations.
///
/// Usage:
///   final url = await MediaService.to.uploadPostImage(bytes);
///   final picked = await MediaService.to.pickImageFromGallery();
///   await MediaService.to.cacheProfileImage(userId, url);
class MediaService extends GetxService {
  static MediaService get to => Get.find();

  late final MediaUploadService _uploadService;
  late final MediaCacheService _cacheService;
  final _picker = ImagePicker();

  /// Initialize the media service and its sub-services
  Future<MediaService> init() async {
    final supabase = Get.find<SupabaseService>();
    _uploadService = MediaUploadService(supabase);
    _cacheService = MediaCacheService();
    await _cacheService.init();
    return this;
  }

  // ============================================
  // IMAGE PICKING
  // ============================================

  /// Pick an image from gallery. Returns compressed bytes or null if cancelled.
  Future<Uint8List?> pickImageFromGallery({
    int maxWidth = MediaConfig.maxImageWidth,
    int maxHeight = MediaConfig.maxImageHeight,
    int quality = MediaConfig.defaultQuality,
  }) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
      imageQuality: quality,
    );
    if (picked == null) return null;
    return await picked.readAsBytes();
  }

  /// Pick an image from camera. Returns compressed bytes or null if cancelled.
  Future<Uint8List?> pickImageFromCamera({
    int maxWidth = MediaConfig.maxImageWidth,
    int maxHeight = MediaConfig.maxImageHeight,
    int quality = MediaConfig.defaultQuality,
  }) async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
      imageQuality: quality,
    );
    if (picked == null) return null;
    return await picked.readAsBytes();
  }

  /// Pick multiple images from gallery.
  Future<List<Uint8List>> pickMultipleImages({
    int maxWidth = MediaConfig.maxImageWidth,
    int maxHeight = MediaConfig.maxImageHeight,
    int quality = MediaConfig.defaultQuality,
  }) async {
    final picked = await _picker.pickMultiImage(
      maxWidth: maxWidth.toDouble(),
      maxHeight: maxHeight.toDouble(),
      imageQuality: quality,
    );
    if (picked.isEmpty) return [];
    final futures = picked.map((xFile) => xFile.readAsBytes());
    return await Future.wait(futures);
  }

  /// Pick a video from gallery. Returns bytes or null if cancelled.
  Future<Uint8List?> pickVideoFromGallery({Duration? maxDuration}) async {
    final picked = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: maxDuration ?? const Duration(minutes: 30),
    );
    if (picked == null) return null;
    return await picked.readAsBytes();
  }

  // ============================================
  // UPLOAD API (give file, get URL)
  // ============================================

  /// Upload a post image. Compresses and uploads to post-images bucket.
  /// Returns the public URL.
  Future<String> uploadPostImage(Uint8List bytes) async {
    return await _uploadService.upload(
      bytes,
      bucket: MediaConfig.postImagesBucket,
      compress: false,
    );
  }

  /// Upload a profile image. Compresses to 512x512 and uploads.
  /// Also caches the image permanently for offline access.
  /// Returns the public URL.
  Future<String> uploadProfileImage(Uint8List bytes) async {
    // Compress to profile size
    final compressed = await _uploadService.compressProfileImage(bytes);

    // Upload
    final url = await _uploadService.upload(
      compressed,
      bucket: MediaConfig.profileImagesBucket,
      compress: false, // Already compressed above
    );

    // Cache permanently for offline access
    final userId = Get.find<SupabaseService>().userId;
    if (userId != null) {
      await _cacheService.cacheProfileImageBytes(userId, compressed, url);
    }

    return url;
  }

  /// Upload a trainer avatar image. Returns the public URL.
  Future<String> uploadTrainerImage(Uint8List bytes) async {
    return await _uploadService.upload(
      bytes,
      bucket: MediaConfig.trainerImagesBucket,
      compress: true,
    );
  }

  /// Upload a challenge cover image. Returns the public URL.
  Future<String> uploadChallengeImage(Uint8List bytes) async {
    return await _uploadService.upload(
      bytes,
      bucket: MediaConfig.challengeImagesBucket,
      compress: true,
    );
  }

  /// Upload a workout thumbnail image. Returns the public URL.
  Future<String> uploadWorkoutThumbnail(Uint8List bytes) async {
    return await _uploadService.upload(
      bytes,
      bucket: MediaConfig.workoutMediaBucket,
      compress: true,
    );
  }

  /// Upload a workout video. Returns the public URL.
  Future<String> uploadWorkoutVideo(Uint8List bytes) async {
    return await _uploadService.uploadRaw(
      bytes,
      bucket: MediaConfig.workoutMediaBucket,
    );
  }

  /// Delete a trainer image from storage.
  Future<void> deleteTrainerImage(String publicUrl) async {
    await _uploadService.delete(
      publicUrl,
      bucket: MediaConfig.trainerImagesBucket,
    );
  }

  /// Delete a challenge image from storage.
  Future<void> deleteChallengeImage(String publicUrl) async {
    await _uploadService.delete(
      publicUrl,
      bucket: MediaConfig.challengeImagesBucket,
    );
  }

  /// Delete a workout thumbnail from storage.
  Future<void> deleteWorkoutThumbnail(String publicUrl) async {
    await _uploadService.delete(
      publicUrl,
      bucket: MediaConfig.workoutMediaBucket,
    );
  }

  /// Upload multiple post images in parallel. Returns list of public URLs.
  Future<List<String>> uploadMultipleImages(List<Uint8List> imageBytes) async {
    return await _uploadService.uploadMultiple(
      imageBytes,
      bucket: MediaConfig.postImagesBucket,
    );
  }

  /// Delete an image from storage by its public URL.
  Future<void> deleteImage(String publicUrl, {String? bucket}) async {
    await _uploadService.delete(
      publicUrl,
      bucket: bucket ?? MediaConfig.postImagesBucket,
    );
  }

  // ============================================
  // COMPRESSION (direct access if needed)
  // ============================================

  /// Compress image bytes (runs on native thread).
  Future<Uint8List> compressImage(
    Uint8List bytes, {
    int quality = MediaConfig.defaultQuality,
    int maxWidth = MediaConfig.maxImageWidth,
    int maxHeight = MediaConfig.maxImageHeight,
  }) async {
    return await _uploadService.compressImage(
      bytes,
      quality: quality,
      maxWidth: maxWidth,
      maxHeight: maxHeight,
    );
  }

  // ============================================
  // CACHE API
  // ============================================

  /// Cache a profile image permanently for offline access.
  /// Call this when you load a user's profile to ensure their avatar
  /// is always available even without internet.
  Future<void> cacheProfileImage(String userId, String url) async {
    await _cacheService.cacheProfileImage(userId, url);
  }

  /// Get the cached profile image as a File (for FileImage provider).
  /// Returns null if not cached.
  Future<File?> getCachedProfileImage(String userId) async {
    return await _cacheService.getProfileImage(userId);
  }

  /// Get cached profile image file path (synchronous).
  /// Returns null if not cached.
  String? getCachedProfileImagePath(String userId) {
    return _cacheService.getProfileImagePath(userId);
  }

  /// Check if a profile image is cached.
  bool hasProfileImageCached(String userId) {
    return _cacheService.hasProfileImage(userId);
  }

  /// Preload images so they're ready when displayed.
  /// Useful for prefetching feed images.
  Future<void> preloadImages(List<String> urls) async {
    await _cacheService.preloadImages(urls);
  }

  /// Preload a single image.
  Future<void> preloadImage(String url) async {
    await _cacheService.preloadImage(url);
  }

  /// Clear all image cache (profile + general).
  Future<void> clearImageCache() async {
    await _cacheService.clearAll();
  }

  /// Clear only the general image cache (keep profile images).
  Future<void> clearGeneralCache() async {
    await _cacheService.clearGeneralCache();
  }

  /// Get approximate cache size in bytes.
  Future<int> getCacheSizeInBytes() async {
    return await _cacheService.getCacheSizeBytes();
  }

  // ============================================
  // URL HELPERS
  // ============================================

  /// Get a Supabase storage public URL.
  String getPublicUrl(String bucket, String path) {
    return Get.find<SupabaseService>().getPublicUrl(bucket: bucket, path: path);
  }

  /// Get a thumbnail URL using Supabase image transforms.
  /// This generates a transformed URL that Supabase renders on the fly.
  String getThumbnailUrl(
    String originalUrl, {
    int width = MediaConfig.thumbnailSize,
    int height = MediaConfig.thumbnailSize,
  }) {
    // Supabase image transform format:
    // /storage/v1/render/image/public/bucket/path?width=200&height=200&resize=cover
    return originalUrl
        .replaceFirst(
          '/storage/v1/object/public/',
          '/storage/v1/render/image/public/',
        )
        .replaceFirst(RegExp(r'\?.*$'), '');
  }
}
