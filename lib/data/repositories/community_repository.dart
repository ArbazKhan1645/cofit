import '../models/models.dart';
import 'base_repository.dart';

/// Community Repository - Handles posts, likes, comments, follows
class CommunityRepository extends BaseRepository {
  // ============================================
  // POSTS
  // ============================================

  /// Get feed posts with pagination
  Future<Result<List<PostModel>>> getFeedPosts({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await executeFunction<List<dynamic>>(
        'get_feed_posts',
        params: {
          'p_user_id': userId,
          'p_limit': limit,
          'p_offset': offset,
        },
      );

      final posts = response
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Result.success(posts);
    } catch (e) {
      // Fallback to direct query if function fails
      return _getFeedPostsDirect(limit: limit, offset: offset);
    }
  }

  Future<Result<List<PostModel>>> _getFeedPostsDirect({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('posts')
          .select('*, users(id, full_name, username, avatar_url)')
          .or('and(is_public.eq.true,approval_status.eq.approved),user_id.eq.$userId')
          .order('is_pinned', ascending: false)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Get user's likes and saves for these posts
      final postIds = (response as List).map((p) => p['id'] as String).toList();

      Map<String, bool> likedPostIds = {};
      Map<String, bool> savedPostIds = {};

      if (userId != null && postIds.isNotEmpty) {
        // Fetch user's likes for these posts
        final likesResponse = await client
            .from('likes')
            .select('post_id')
            .eq('user_id', userId!)
            .eq('like_type', 'post')
            .inFilter('post_id', postIds);

        for (var like in (likesResponse as List)) {
          likedPostIds[like['post_id'] as String] = true;
        }

        // Fetch user's saved posts
        final savesResponse = await client
            .from('saved_posts')
            .select('post_id')
            .eq('user_id', userId!)
            .inFilter('post_id', postIds);

        for (var save in (savesResponse as List)) {
          savedPostIds[save['post_id'] as String] = true;
        }
      }

      final posts = response.map((json) {
        final postId = json['id'] as String;
        // Add isLikedByMe and isSavedByMe to json
        final enrichedJson = Map<String, dynamic>.from(json);
        enrichedJson['is_liked_by_me'] = likedPostIds[postId] ?? false;
        enrichedJson['is_saved_by_me'] = savedPostIds[postId] ?? false;
        return PostModel.fromJson(enrichedJson);
      }).toList();

      return Result.success(posts);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get post by ID
  Future<Result<PostModel>> getPost(String postId) async {
    try {
      final response = await client
          .from('posts')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('id', postId)
          .single();

      return Result.success(PostModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Create a new post
  Future<Result<PostModel>> createPost({
    required String content,
    required String postType,
    List<String>? imageUrls,
    String? videoUrl,
    String? linkedWorkoutId,
    String? linkedRecipeId,
    String? linkedAchievementId,
    List<String>? tags,
    bool isPublic = true,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final insertData = {
        'user_id': userId!,
        'content': content,
        'post_type': postType,
        'image_urls': imageUrls ?? [],
        'video_url': videoUrl,
        'linked_workout_id': linkedWorkoutId,
        'linked_recipe_id': linkedRecipeId,
        'linked_achievement_id': linkedAchievementId,
        'tags': tags ?? [],
        'is_public': isPublic,
      };

      if (metadata != null && metadata.isNotEmpty) {
        insertData['metadata'] = metadata;
      }

      final response = await client
          .from('posts')
          .insert(insertData)
          .select('*, users(id, full_name, username, avatar_url)')
          .single();

      return Result.success(PostModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Update a post
  Future<Result<PostModel>> updatePost({
    required String postId,
    String? content,
    List<String>? tags,
    bool? isPublic,
  }) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final updates = <String, dynamic>{
        'is_edited': true,
        'edited_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (content != null) updates['content'] = content;
      if (tags != null) updates['tags'] = tags;
      if (isPublic != null) updates['is_public'] = isPublic;

      final response = await client
          .from('posts')
          .update(updates)
          .eq('id', postId)
          .eq('user_id', userId!)
          .select('*, users(id, full_name, username, avatar_url)')
          .single();

      return Result.success(PostModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Delete a post
  Future<Result<void>> deletePost(String postId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('posts')
          .delete()
          .eq('id', postId)
          .eq('user_id', userId!);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get user's posts
  Future<Result<List<PostModel>>> getUserPosts(String targetUserId,
      {int limit = 20, int offset = 0}) async {
    try {
      final response = await client
          .from('posts')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('user_id', targetUserId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      // Get user's likes and saves for these posts
      final postIds = (response as List).map((p) => p['id'] as String).toList();

      Map<String, bool> likedPostIds = {};
      Map<String, bool> savedPostIds = {};

      if (userId != null && postIds.isNotEmpty) {
        final likesResponse = await client
            .from('likes')
            .select('post_id')
            .eq('user_id', userId!)
            .eq('like_type', 'post')
            .inFilter('post_id', postIds);

        for (var like in (likesResponse as List)) {
          likedPostIds[like['post_id'] as String] = true;
        }

        final savesResponse = await client
            .from('saved_posts')
            .select('post_id')
            .eq('user_id', userId!)
            .inFilter('post_id', postIds);

        for (var save in (savesResponse as List)) {
          savedPostIds[save['post_id'] as String] = true;
        }
      }

      final posts = response.map((json) {
        final postId = json['id'] as String;
        final enrichedJson = Map<String, dynamic>.from(json);
        enrichedJson['is_liked_by_me'] = likedPostIds[postId] ?? false;
        enrichedJson['is_saved_by_me'] = savedPostIds[postId] ?? false;
        return PostModel.fromJson(enrichedJson);
      }).toList();

      return Result.success(posts);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // LIKES
  // ============================================

  /// Like a post
  Future<Result<void>> likePost(String postId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client.from('likes').insert({
        'user_id': userId!,
        'post_id': postId,
        'like_type': 'post',
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Unlike a post
  Future<Result<void>> unlikePost(String postId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('likes')
          .delete()
          .eq('user_id', userId!)
          .eq('post_id', postId)
          .eq('like_type', 'post');

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Toggle post like
  Future<Result<bool>> togglePostLike(String postId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      // Check if already liked
      final existing = await client
          .from('likes')
          .select('id')
          .eq('user_id', userId!)
          .eq('post_id', postId)
          .eq('like_type', 'post')
          .maybeSingle();

      if (existing != null) {
        await unlikePost(postId);
        return Result.success(false);
      } else {
        await likePost(postId);
        return Result.success(true);
      }
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Like a comment
  Future<Result<void>> likeComment(String commentId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client.from('likes').insert({
        'user_id': userId!,
        'comment_id': commentId,
        'like_type': 'comment',
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Unlike a comment
  Future<Result<void>> unlikeComment(String commentId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('likes')
          .delete()
          .eq('user_id', userId!)
          .eq('comment_id', commentId)
          .eq('like_type', 'comment');

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // COMMENTS
  // ============================================

  /// Get comments for a post
  Future<Result<List<CommentModel>>> getPostComments(
    String postId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('comments')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('post_id', postId)
          .isFilter('parent_comment_id', null)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final comments = (response as List)
          .map((json) => CommentModel.fromJson(json))
          .toList();

      return Result.success(comments);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get replies to a comment
  Future<Result<List<CommentModel>>> getCommentReplies(
    String commentId, {
    int limit = 20,
  }) async {
    try {
      final response = await client
          .from('comments')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('parent_comment_id', commentId)
          .order('created_at')
          .limit(limit);

      final replies = (response as List)
          .map((json) => CommentModel.fromJson(json))
          .toList();

      return Result.success(replies);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Create a comment
  Future<Result<CommentModel>> createComment({
    required String postId,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final response = await client
          .from('comments')
          .insert({
            'post_id': postId,
            'user_id': userId!,
            'content': content,
            'parent_comment_id': parentCommentId,
          })
          .select('*, users(id, full_name, username, avatar_url)')
          .single();

      return Result.success(CommentModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Delete a comment
  Future<Result<void>> deleteComment(String commentId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('comments')
          .delete()
          .eq('id', commentId)
          .eq('user_id', userId!);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // FOLLOWS
  // ============================================

  /// Follow a user
  Future<Result<void>> followUser(String targetUserId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      if (userId == targetUserId) {
        return Result.failure(
            RepositoryException(message: 'Cannot follow yourself'));
      }

      await client.from('follows').insert({
        'follower_id': userId!,
        'following_id': targetUserId,
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Unfollow a user
  Future<Result<void>> unfollowUser(String targetUserId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('follows')
          .delete()
          .eq('follower_id', userId!)
          .eq('following_id', targetUserId);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Toggle follow
  Future<Result<bool>> toggleFollow(String targetUserId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final isFollowingResult = await isFollowing(targetUserId);
      if (!isFollowingResult.isSuccess) {
        return Result.failure(isFollowingResult.error!);
      }

      if (isFollowingResult.data!) {
        await unfollowUser(targetUserId);
        return Result.success(false);
      } else {
        await followUser(targetUserId);
        return Result.success(true);
      }
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Check if following a user
  Future<Result<bool>> isFollowing(String targetUserId) async {
    try {
      if (userId == null) return Result.success(false);

      final response = await client
          .from('follows')
          .select('id')
          .eq('follower_id', userId!)
          .eq('following_id', targetUserId)
          .maybeSingle();

      return Result.success(response != null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get followers
  Future<Result<List<FollowModel>>> getFollowers(
    String targetUserId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('follows')
          .select('*, follower:users!follower_id(id, full_name, username, avatar_url)')
          .eq('following_id', targetUserId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final followers = (response as List)
          .map((json) => FollowModel.fromJson(json))
          .toList();

      return Result.success(followers);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get following
  Future<Result<List<FollowModel>>> getFollowing(
    String targetUserId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await client
          .from('follows')
          .select('*, following:users!following_id(id, full_name, username, avatar_url)')
          .eq('follower_id', targetUserId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final following = (response as List)
          .map((json) => FollowModel.fromJson(json))
          .toList();

      return Result.success(following);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // SAVED POSTS
  // ============================================

  /// Save a post
  Future<Result<void>> savePost(String postId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client.from('saved_posts').insert({
        'user_id': userId!,
        'post_id': postId,
        'saved_at': DateTime.now().toIso8601String(),
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Unsave a post
  Future<Result<void>> unsavePost(String postId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('saved_posts')
          .delete()
          .eq('user_id', userId!)
          .eq('post_id', postId);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Toggle save post
  Future<Result<bool>> toggleSavePost(String postId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      // Check if already saved
      final existing = await client
          .from('saved_posts')
          .select('id')
          .eq('user_id', userId!)
          .eq('post_id', postId)
          .maybeSingle();

      if (existing != null) {
        await unsavePost(postId);
        return Result.success(false);
      } else {
        await savePost(postId);
        return Result.success(true);
      }
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get saved posts
  Future<Result<List<SavedPostModel>>> getSavedPosts({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final response = await client
          .from('saved_posts')
          .select('*, posts(*, users(id, full_name, username, avatar_url))')
          .eq('user_id', userId!)
          .order('saved_at', ascending: false)
          .range(offset, offset + limit - 1);

      final saved = (response as List)
          .map((json) => SavedPostModel.fromJson(json))
          .toList();

      return Result.success(saved);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // SHARES
  // ============================================

  /// Share a post
  Future<Result<void>> sharePost({
    required String postId,
    required String shareType,
    String? platform,
    String? shareMessage,
  }) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client.from('shares').insert({
        'user_id': userId!,
        'post_id': postId,
        'share_type': shareType,
        'platform': platform,
        'share_message': shareMessage,
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // CHALLENGES (for posting)
  // ============================================

  /// Get current user's completed/won challenges for posting
  Future<Result<List<UserChallengeModel>>> getMyWonChallenges() async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final response = await client
          .from('user_challenges')
          .select('*, challenges(*)')
          .eq('user_id', userId!)
          .eq('is_completed', true)
          .gt('rank', 0)
          .lte('rank', 10)
          .order('completed_at', ascending: false);

      final challenges = (response as List)
          .map((json) => UserChallengeModel.fromJson(json))
          .toList();

      return Result.success(challenges);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }
}
