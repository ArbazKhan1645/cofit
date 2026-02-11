import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'media_config.dart';

/// Facebook-style image cache service.
/// - Profile images: permanently cached on disk, available offline forever
/// - Post images: cached via CachedNetworkImage (auto TTL, disk-backed)
/// - Preload support: prefetch images before they're shown
class MediaCacheService {
  final _storage = GetStorage();

  late final Directory _profileCacheDir;

  // ============================================
  // INITIALIZATION
  // ============================================

  Future<void> init() async {
    // Create persistent profile cache directory
    final appDir = await getApplicationDocumentsDirectory();
    _profileCacheDir = Directory('${appDir.path}/${MediaConfig.profileCacheDir}');
    if (!await _profileCacheDir.exists()) {
      await _profileCacheDir.create(recursive: true);
    }
  }

  // ============================================
  // PROFILE IMAGE CACHE (PERMANENT)
  // ============================================

  /// Cache a profile image permanently on disk.
  /// Downloads the image and saves it to the profile cache directory.
  Future<void> cacheProfileImage(String userId, String url) async {
    if (url.isEmpty) return;

    try {
      // Check if we already have this exact URL cached
      final meta = _getProfileMeta(userId);
      if (meta != null && meta['url'] == url) {
        // Already cached this exact URL
        final file = File(_profileImagePath(userId));
        if (await file.exists()) return;
      }

      // Download the image
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) return;

      // Save to disk
      final file = File(_profileImagePath(userId));
      await file.writeAsBytes(response.bodyBytes);

      // Save metadata
      _setProfileMeta(userId, {'url': url, 'cachedAt': DateTime.now().toIso8601String()});
    } catch (_) {
      // Silently fail - caching is best-effort
    }
  }

  /// Cache a profile image from bytes (e.g., after uploading)
  Future<void> cacheProfileImageBytes(String userId, Uint8List bytes, String url) async {
    try {
      final file = File(_profileImagePath(userId));
      await file.writeAsBytes(bytes);
      _setProfileMeta(userId, {'url': url, 'cachedAt': DateTime.now().toIso8601String()});
    } catch (_) {}
  }

  /// Get cached profile image as File (for FileImage provider)
  Future<File?> getProfileImage(String userId) async {
    final file = File(_profileImagePath(userId));
    if (await file.exists()) return file;
    return null;
  }

  /// Get cached profile image path (synchronous check)
  String? getProfileImagePath(String userId) {
    final file = File(_profileImagePath(userId));
    if (file.existsSync()) return file.path;
    return null;
  }

  /// Check if profile image is cached
  bool hasProfileImage(String userId) {
    return File(_profileImagePath(userId)).existsSync();
  }

  /// Remove cached profile image
  Future<void> removeProfileImage(String userId) async {
    try {
      final file = File(_profileImagePath(userId));
      if (await file.exists()) await file.delete();
      _removeProfileMeta(userId);
    } catch (_) {}
  }

  // ============================================
  // GENERAL IMAGE PRELOADING
  // ============================================

  /// Preload a single image into CachedNetworkImage's cache
  Future<void> preloadImage(String url) async {
    if (url.isEmpty) return;
    try {
      await DefaultCacheManager().downloadFile(url);
    } catch (_) {}
  }

  /// Preload multiple images in parallel
  Future<void> preloadImages(List<String> urls) async {
    final validUrls = urls.where((u) => u.isNotEmpty).toList();
    if (validUrls.isEmpty) return;
    await Future.wait(validUrls.map((url) => preloadImage(url)));
  }

  // ============================================
  // CACHE MANAGEMENT
  // ============================================

  /// Clear all cached images (both profile and general)
  Future<void> clearAll() async {
    try {
      // Clear profile cache
      if (await _profileCacheDir.exists()) {
        await _profileCacheDir.delete(recursive: true);
        await _profileCacheDir.create(recursive: true);
      }
      _storage.remove(MediaConfig.profileCacheMetaKey);

      // Clear CachedNetworkImage cache
      await DefaultCacheManager().emptyCache();
      await CachedNetworkImage.evictFromCache('');
    } catch (_) {}
  }

  /// Clear only the general image cache (keep profile images)
  Future<void> clearGeneralCache() async {
    try {
      await DefaultCacheManager().emptyCache();
    } catch (_) {}
  }

  /// Get approximate total cache size in bytes
  Future<int> getCacheSizeBytes() async {
    int totalSize = 0;
    try {
      // Profile cache size
      if (await _profileCacheDir.exists()) {
        await for (var entity in _profileCacheDir.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
    } catch (_) {}
    return totalSize;
  }

  // ============================================
  // PRIVATE HELPERS
  // ============================================

  String _profileImagePath(String userId) {
    return '${_profileCacheDir.path}/$userId.jpg';
  }

  Map<String, dynamic>? _getProfileMeta(String userId) {
    try {
      final allMeta = _storage.read<String>(MediaConfig.profileCacheMetaKey);
      if (allMeta == null) return null;
      final map = jsonDecode(allMeta) as Map<String, dynamic>;
      return map[userId] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  void _setProfileMeta(String userId, Map<String, dynamic> meta) {
    try {
      final allMeta = _storage.read<String>(MediaConfig.profileCacheMetaKey);
      final map = allMeta != null
          ? (jsonDecode(allMeta) as Map<String, dynamic>)
          : <String, dynamic>{};
      map[userId] = meta;
      _storage.write(MediaConfig.profileCacheMetaKey, jsonEncode(map));
    } catch (_) {}
  }

  void _removeProfileMeta(String userId) {
    try {
      final allMeta = _storage.read<String>(MediaConfig.profileCacheMetaKey);
      if (allMeta == null) return;
      final map = jsonDecode(allMeta) as Map<String, dynamic>;
      map.remove(userId);
      _storage.write(MediaConfig.profileCacheMetaKey, jsonEncode(map));
    } catch (_) {}
  }
}
