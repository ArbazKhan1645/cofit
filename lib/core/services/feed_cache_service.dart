import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/models/community_model.dart';

/// Feed Cache Service - Handles local caching for optimized feed loading
/// Provides instant feed display on app open while fetching fresh data
class FeedCacheService extends GetxService {
  static FeedCacheService get to => Get.find();

  final _storage = GetStorage();

  // Cache keys
  static const String _feedCacheKey = 'cached_feed_posts';
  static const String _feedCacheTimestampKey = 'feed_cache_timestamp';
  static const String _userPostsCacheKey = 'cached_user_posts_';

  // Cache duration (5 minutes for feed freshness)
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Initialize the service
  Future<FeedCacheService> init() async {
    return this;
  }

  /// Cache feed posts
  Future<void> cacheFeedPosts(List<PostModel> posts) async {
    try {
      final jsonList = posts.map((p) => p.toJson()).toList();
      await _storage.write(_feedCacheKey, jsonEncode(jsonList));
      await _storage.write(
        _feedCacheTimestampKey,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      // Silently fail - caching is optional
    }
  }

  /// Get cached feed posts
  List<PostModel>? getCachedFeedPosts() {
    try {
      final cached = _storage.read<String>(_feedCacheKey);
      if (cached == null) return null;

      final jsonList = jsonDecode(cached) as List;
      return jsonList
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Check if cache is still fresh
  bool isCacheFresh() {
    try {
      final timestamp = _storage.read<String>(_feedCacheTimestampKey);
      if (timestamp == null) return false;

      final cacheTime = DateTime.parse(timestamp);
      return DateTime.now().difference(cacheTime) < _cacheDuration;
    } catch (e) {
      return false;
    }
  }

  /// Cache user's posts
  Future<void> cacheUserPosts(String userId, List<PostModel> posts) async {
    try {
      final jsonList = posts.map((p) => p.toJson()).toList();
      await _storage.write('$_userPostsCacheKey$userId', jsonEncode(jsonList));
    } catch (e) {
      // Silently fail
    }
  }

  /// Get cached user posts
  List<PostModel>? getCachedUserPosts(String userId) {
    try {
      final cached = _storage.read<String>('$_userPostsCacheKey$userId');
      if (cached == null) return null;

      final jsonList = jsonDecode(cached) as List;
      return jsonList
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return null;
    }
  }

  /// Update single post in cache (for like/comment updates)
  Future<void> updatePostInCache(PostModel updatedPost) async {
    try {
      final posts = getCachedFeedPosts();
      if (posts == null) return;

      final index = posts.indexWhere((p) => p.id == updatedPost.id);
      if (index != -1) {
        posts[index] = updatedPost;
        await cacheFeedPosts(posts);
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Remove post from cache
  Future<void> removePostFromCache(String postId) async {
    try {
      final posts = getCachedFeedPosts();
      if (posts == null) return;

      posts.removeWhere((p) => p.id == postId);
      await cacheFeedPosts(posts);
    } catch (e) {
      // Silently fail
    }
  }

  /// Add new post to cache (at the beginning)
  Future<void> addPostToCache(PostModel post) async {
    try {
      final posts = getCachedFeedPosts() ?? [];
      posts.insert(0, post);
      await cacheFeedPosts(posts);
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear all feed cache
  Future<void> clearCache() async {
    await _storage.remove(_feedCacheKey);
    await _storage.remove(_feedCacheTimestampKey);
  }
}
