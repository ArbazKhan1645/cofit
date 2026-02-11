import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:share_plus/share_plus.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../shared/widgets/widgets.dart';
import '../../../data/models/community_model.dart';
import '../../../data/models/challenge_model.dart';
import '../../../data/repositories/community_repository.dart';
import '../../../core/services/feed_cache_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/media/media_service.dart';

class CommunityController extends BaseController {
  final CommunityRepository _repository = CommunityRepository();
  final FeedCacheService _cacheService = FeedCacheService.to;
  final SupabaseService _supabase = SupabaseService.to;

  // Feed state
  final RxList<PostModel> posts = <PostModel>[].obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMorePosts = true.obs;
  final RxBool isRefreshing = false.obs;
  int _currentOffset = 0;
  static const int _pageSize = 20;

  // My posts
  final RxList<PostModel> myPosts = <PostModel>[].obs;
  final RxBool isLoadingMyPosts = false.obs;

  // Challenges posts
  final RxList<PostModel> challengePosts = <PostModel>[].obs;
  final RxBool isLoadingChallenges = false.obs;

  // Recipe posts
  final RxList<PostModel> recipePosts = <PostModel>[].obs;
  final RxBool isLoadingRecipes = false.obs;

  // User profile posts (for bottom sheet)
  final RxList<PostModel> userProfilePosts = <PostModel>[].obs;
  final Rx<UserSummary?> selectedUser = Rx<UserSummary?>(null);
  final RxBool isLoadingUserPosts = false.obs;

  // User stats for profile sheet
  final RxInt userTotalLikes = 0.obs;
  final RxInt userStreak = 0.obs;

  // Search
  final RxList<PostModel> searchPosts = <PostModel>[].obs;
  final RxList<UserSummary> searchUsers = <UserSummary>[].obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final searchController = TextEditingController();

  // Post creation
  final RxBool isCreatingPost = false.obs;
  final Rx<Uint8List?> selectedImage = Rx<Uint8List?>(null);
  final RxString selectedImagePath = ''.obs;
  final postContentController = TextEditingController();
  final RxString selectedPostType = 'text'.obs;

  // Recipe fields
  final recipeNameController = TextEditingController();
  final recipeIngredientsController = TextEditingController();
  final recipeInstructionsController = TextEditingController();

  // Challenge fields (legacy)
  final challengeNameController = TextEditingController();
  final challengeDescriptionController = TextEditingController();

  // Challenge winning post fields
  final RxList<UserChallengeModel> wonChallenges = <UserChallengeModel>[].obs;
  final RxBool isLoadingWonChallenges = false.obs;
  final Rx<UserChallengeModel?> selectedWonChallenge = Rx<UserChallengeModel?>(null);
  final challengeMessageController = TextEditingController();

  // Workout recipe structured fields
  final recipeTitleController = TextEditingController();
  final recipeNotesController = TextEditingController();
  final recipeDurationController = TextEditingController();
  final RxString recipeGoal = 'fat_loss'.obs;
  final RxString recipeDifficulty = 'beginner'.obs;
  final RxList<WorkoutRecipeExercise> recipeExercises = <WorkoutRecipeExercise>[].obs;

  // Comments
  final RxList<CommentModel> postComments = <CommentModel>[].obs;
  final RxBool isLoadingComments = false.obs;
  final commentController = TextEditingController();
  final RxBool isPostingComment = false.obs;

  // Current post for detail view
  final Rx<PostModel?> currentPost = Rx<PostModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _initializeFeed();
  }

  /// Initialize feed with cached data first, then fetch fresh
  Future<void> _initializeFeed() async {
    // Load cached posts immediately for instant display
    final cachedPosts = _cacheService.getCachedFeedPosts();
    if (cachedPosts != null && cachedPosts.isNotEmpty) {
      posts.value = cachedPosts;
    }

    // Fetch fresh data in background
    await loadFeed(refresh: true, showLoading: cachedPosts == null);
  }

  /// Check internet connectivity
  Future<bool> _hasInternet() async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet);
  }

  // ============================================
  // FEED OPERATIONS
  // ============================================

  /// Load feed posts with pagination
  Future<void> loadFeed({bool refresh = false, bool showLoading = true}) async {
    if (refresh) {
      _currentOffset = 0;
      hasMorePosts.value = true;
      if (showLoading) {
        setLoading(true);
      } else {
        isRefreshing.value = true;
      }
    }

    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      // Use cached data if no internet
      final cached = _cacheService.getCachedFeedPosts();
      if (cached != null && cached.isNotEmpty) {
        posts.value = cached;
      }
      setLoading(false);
      isRefreshing.value = false;
      return;
    }

    final result = await _repository.getFeedPosts(
      limit: _pageSize,
      offset: _currentOffset,
    );

    if (result.isSuccess) {
      final newPosts = result.data!;

      if (refresh) {
        posts.value = newPosts;
        // Cache the fresh posts
        await _cacheService.cacheFeedPosts(newPosts);
      } else {
        // Filter out duplicates before adding
        final existingIds = posts.map((p) => p.id).toSet();
        final uniqueNewPosts = newPosts.where((p) => !existingIds.contains(p.id)).toList();
        posts.addAll(uniqueNewPosts);
      }

      hasMorePosts.value = newPosts.length >= _pageSize;
      _currentOffset += newPosts.length;
    }

    setLoading(false);
    isRefreshing.value = false;
  }

  /// Load more posts (pagination)
  Future<void> loadMorePosts() async {
    if (isLoadingMore.value || !hasMorePosts.value) return;

    isLoadingMore.value = true;
    await loadFeed(refresh: false, showLoading: false);
    isLoadingMore.value = false;
  }

  /// Refresh feed (pull to refresh)
  Future<void> refreshFeed() async {
    await loadFeed(refresh: true, showLoading: false);
  }

  // ============================================
  // LIKE OPERATIONS
  // ============================================

  /// Toggle like on a post - works across all post lists
  Future<void> toggleLikePost(String postId) async {
    // Find post in any list
    PostModel? originalPost;
    bool wasLiked = false;
    int originalLikesCount = 0;

    // Helper to update post in a list (does NOT modify wasLiked/originalLikesCount)
    void updateInList(RxList<PostModel> list, bool newLikedState, int newLikesCount) {
      final idx = list.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(
          isLikedByMe: newLikedState,
          likesCount: newLikesCount,
        );
        list.refresh(); // Force UI rebuild
      }
    }

    // Find the current liked state
    final mainIdx = posts.indexWhere((p) => p.id == postId);
    if (mainIdx != -1) {
      wasLiked = posts[mainIdx].isLikedByMe;
      originalLikesCount = posts[mainIdx].likesCount;
      originalPost = posts[mainIdx];
    } else {
      final challengeIdx = challengePosts.indexWhere((p) => p.id == postId);
      if (challengeIdx != -1) {
        wasLiked = challengePosts[challengeIdx].isLikedByMe;
        originalLikesCount = challengePosts[challengeIdx].likesCount;
        originalPost = challengePosts[challengeIdx];
      } else {
        final recipeIdx = recipePosts.indexWhere((p) => p.id == postId);
        if (recipeIdx != -1) {
          wasLiked = recipePosts[recipeIdx].isLikedByMe;
          originalLikesCount = recipePosts[recipeIdx].likesCount;
          originalPost = recipePosts[recipeIdx];
        } else {
          final myIdx = myPosts.indexWhere((p) => p.id == postId);
          if (myIdx != -1) {
            wasLiked = myPosts[myIdx].isLikedByMe;
            originalLikesCount = myPosts[myIdx].likesCount;
            originalPost = myPosts[myIdx];
          } else {
            final profileIdx = userProfilePosts.indexWhere((p) => p.id == postId);
            if (profileIdx != -1) {
              wasLiked = userProfilePosts[profileIdx].isLikedByMe;
              originalLikesCount = userProfilePosts[profileIdx].likesCount;
              originalPost = userProfilePosts[profileIdx];
            }
          }
        }
      }
    }

    if (originalPost == null) return;

    final newLikedState = !wasLiked;
    final newLikesCount = wasLiked ? originalLikesCount - 1 : originalLikesCount + 1;

    // Optimistic update - update all lists
    updateInList(posts, newLikedState, newLikesCount);
    updateInList(challengePosts, newLikedState, newLikesCount);
    updateInList(recipePosts, newLikedState, newLikesCount);
    updateInList(myPosts, newLikedState, newLikesCount);
    updateInList(userProfilePosts, newLikedState, newLikesCount);

    // Update current post if viewing detail
    if (currentPost.value?.id == postId) {
      currentPost.value = currentPost.value!.copyWith(
        isLikedByMe: newLikedState,
        likesCount: newLikesCount,
      );
    }

    // Make API call
    final result = await _repository.togglePostLike(postId);

    if (!result.isSuccess) {
      // Revert on failure - revert all lists
      updateInList(posts, wasLiked, originalLikesCount);
      updateInList(challengePosts, wasLiked, originalLikesCount);
      updateInList(recipePosts, wasLiked, originalLikesCount);
      updateInList(myPosts, wasLiked, originalLikesCount);
      updateInList(userProfilePosts, wasLiked, originalLikesCount);

      if (currentPost.value?.id == postId) {
        currentPost.value = currentPost.value!.copyWith(
          isLikedByMe: wasLiked,
          likesCount: originalLikesCount,
        );
      }
    } else {
      // Update cache if in main feed
      final cacheIdx = posts.indexWhere((p) => p.id == postId);
      if (cacheIdx != -1) {
        await _cacheService.updatePostInCache(posts[cacheIdx]);
      }
    }
  }

  // ============================================
  // SAVE/BOOKMARK OPERATIONS
  // ============================================

  /// Toggle save on a post - works across all post lists
  Future<void> toggleSavePost(String postId) async {
    // Find post in any list
    PostModel? originalPost;
    bool wasSaved = false;

    // Helper to update post in a list (does NOT modify wasSaved)
    void updateInList(RxList<PostModel> list, bool newSavedState) {
      final idx = list.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(isSavedByMe: newSavedState);
        list.refresh(); // Force UI rebuild
      }
    }

    // Find the current saved state
    final mainIdx = posts.indexWhere((p) => p.id == postId);
    if (mainIdx != -1) {
      wasSaved = posts[mainIdx].isSavedByMe;
      originalPost = posts[mainIdx];
    } else {
      final challengeIdx = challengePosts.indexWhere((p) => p.id == postId);
      if (challengeIdx != -1) {
        wasSaved = challengePosts[challengeIdx].isSavedByMe;
        originalPost = challengePosts[challengeIdx];
      } else {
        final recipeIdx = recipePosts.indexWhere((p) => p.id == postId);
        if (recipeIdx != -1) {
          wasSaved = recipePosts[recipeIdx].isSavedByMe;
          originalPost = recipePosts[recipeIdx];
        } else {
          final myIdx = myPosts.indexWhere((p) => p.id == postId);
          if (myIdx != -1) {
            wasSaved = myPosts[myIdx].isSavedByMe;
            originalPost = myPosts[myIdx];
          } else {
            final profileIdx = userProfilePosts.indexWhere((p) => p.id == postId);
            if (profileIdx != -1) {
              wasSaved = userProfilePosts[profileIdx].isSavedByMe;
              originalPost = userProfilePosts[profileIdx];
            }
          }
        }
      }
    }

    if (originalPost == null) return;

    final newSavedState = !wasSaved;

    // Optimistic update - update all lists
    updateInList(posts, newSavedState);
    updateInList(challengePosts, newSavedState);
    updateInList(recipePosts, newSavedState);
    updateInList(myPosts, newSavedState);
    updateInList(userProfilePosts, newSavedState);

    // Update current post if viewing detail
    if (currentPost.value?.id == postId) {
      currentPost.value = currentPost.value!.copyWith(isSavedByMe: newSavedState);
    }

    // Make API call
    final result = await _repository.toggleSavePost(postId);

    if (!result.isSuccess) {
      // Revert on failure - revert all lists
      updateInList(posts, wasSaved);
      updateInList(challengePosts, wasSaved);
      updateInList(recipePosts, wasSaved);
      updateInList(myPosts, wasSaved);
      updateInList(userProfilePosts, wasSaved);

      if (currentPost.value?.id == postId) {
        currentPost.value = currentPost.value!.copyWith(isSavedByMe: wasSaved);
      }
    } else {
      // Update cache if in main feed
      final cacheIdx = posts.indexWhere((p) => p.id == postId);
      if (cacheIdx != -1) {
        await _cacheService.updatePostInCache(posts[cacheIdx]);
      }

      // Show feedback
      if (Get.context != null) {
        AppSnackbar.success(
          Get.context!,
          message: newSavedState ? 'Post saved!' : 'Post unsaved',
        );
      }
    }
  }

  // ============================================
  // SHARE OPERATIONS
  // ============================================

  /// Share a post
  Future<void> sharePost(PostModel post) async {
    try {
      String shareText = '${post.authorName} shared:\n\n${post.content}';

      if (post.imageUrls.isNotEmpty) {
        shareText += '\n\nCheck out this post on Cofit Collective!';
      }

      await Share.share(
        shareText,
        subject: 'Check out this post on Cofit Collective!',
      );

      // Record share in database (optional tracking)
      await _repository.sharePost(
        postId: post.id,
        shareType: 'external',
        platform: 'social',
      );
    } catch (e) {
      // Silently fail - sharing is optional
    }
  }

  // ============================================
  // POST CREATION
  // ============================================

  /// Pick image for post using MediaService
  Future<void> pickImage() async {
    final bytes = await MediaService.to.pickImageFromGallery();
    if (bytes != null) {
      selectedImage.value = bytes;
      selectedImagePath.value = 'selected_image';
    }
  }

  /// Remove selected image
  void removeSelectedImage() {
    selectedImage.value = null;
    selectedImagePath.value = '';
  }

  /// Set post type
  void setPostType(String type) {
    selectedPostType.value = type;
    if (type == 'achievement') {
      loadWonChallenges();
    }
  }

  /// Load user's won challenges for challenge post selector
  Future<void> loadWonChallenges() async {
    isLoadingWonChallenges.value = true;

    final result = await _repository.getMyWonChallenges();

    if (result.isSuccess) {
      wonChallenges.value = result.data!;
    }

    isLoadingWonChallenges.value = false;
  }

  /// Select a won challenge for posting
  void selectWonChallenge(UserChallengeModel challenge) {
    selectedWonChallenge.value = challenge;
  }

  /// Add exercise to workout recipe
  void addRecipeExercise(WorkoutRecipeExercise exercise) {
    recipeExercises.add(exercise);
  }

  /// Remove exercise from workout recipe
  void removeRecipeExercise(int index) {
    if (index >= 0 && index < recipeExercises.length) {
      recipeExercises.removeAt(index);
    }
  }

  /// Clear all post creation fields
  void clearPostForm() {
    postContentController.clear();
    removeSelectedImage();
    selectedPostType.value = 'text';
    recipeNameController.clear();
    recipeIngredientsController.clear();
    recipeInstructionsController.clear();
    challengeNameController.clear();
    challengeDescriptionController.clear();
    // New structured fields
    selectedWonChallenge.value = null;
    challengeMessageController.clear();
    recipeTitleController.clear();
    recipeNotesController.clear();
    recipeDurationController.clear();
    recipeGoal.value = 'fat_loss';
    recipeDifficulty.value = 'beginner';
    recipeExercises.clear();
  }

  /// Create a new post
  Future<bool> createPost() async {
    final content = postContentController.text.trim();
    final postType = selectedPostType.value;

    // Build content and metadata based on post type
    String finalContent = content;
    Map<String, dynamic>? metadata;
    String? linkedAchievementId;

    if (postType == 'recipe_share') {
      // Structured workout recipe
      final title = recipeTitleController.text.trim();

      if (title.isEmpty) {
        if (Get.context != null) {
          AppSnackbar.warning(Get.context!, message: 'Please enter a workout title');
        }
        return false;
      }

      if (recipeExercises.isEmpty) {
        if (Get.context != null) {
          AppSnackbar.warning(Get.context!, message: 'Please add at least one exercise');
        }
        return false;
      }

      final duration = int.tryParse(recipeDurationController.text.trim()) ?? 0;

      final recipeMetadata = WorkoutRecipeMetadata(
        recipeTitle: title,
        goal: recipeGoal.value,
        exercises: recipeExercises.toList(),
        totalDurationMinutes: duration,
        difficulty: recipeDifficulty.value,
        notes: recipeNotesController.text.trim().isNotEmpty
            ? recipeNotesController.text.trim()
            : null,
      );

      metadata = recipeMetadata.toJson();
      finalContent = content.isNotEmpty ? content : title;
    } else if (postType == 'achievement') {
      // Challenge winning post
      final challenge = selectedWonChallenge.value;

      if (challenge == null) {
        if (Get.context != null) {
          AppSnackbar.warning(Get.context!, message: 'Please select a challenge');
        }
        return false;
      }

      final challengeData = challenge.challenge;
      final message = challengeMessageController.text.trim();

      final challengeMetadata = ChallengePostMetadata(
        challengeId: challenge.challengeId,
        challengeTitle: challengeData?.title ?? 'Challenge',
        challengeType: challengeData?.challengeType ?? '',
        userRank: challenge.rank,
        totalProgress: challenge.currentProgress,
        targetValue: challengeData?.targetValue ?? 0,
        targetUnit: challengeData?.targetUnit ?? '',
        completedAt: challenge.completedAt,
        personalMessage: message.isNotEmpty ? message : null,
      );

      metadata = challengeMetadata.toJson();
      linkedAchievementId = challenge.challengeId;
      finalContent = content.isNotEmpty
          ? content
          : '${challengeMetadata.rankDisplay} in ${challengeData?.title ?? "Challenge"}!';
    } else {
      if (content.isEmpty && selectedImage.value == null) {
        if (Get.context != null) {
          AppSnackbar.warning(
            Get.context!,
            message: 'Please add some content or an image',
          );
        }
        return false;
      }
    }

    // Check internet
    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      if (Get.context != null) {
        AppSnackbar.error(
          Get.context!,
          message: 'Please connect to the internet to post',
          title: 'No Internet',
        );
      }
      return false;
    }

    isCreatingPost.value = true;

    try {
      String? imageUrl;

      // Upload image if selected (compressed + uploaded via MediaService)
      if (selectedImage.value != null) {
        imageUrl = await MediaService.to.uploadPostImage(selectedImage.value!);
      }

      // Determine final post type
      String finalPostType = postType;
      if (postType == 'text' && imageUrl != null) {
        finalPostType = 'image';
      }

      // Create post
      final result = await _repository.createPost(
        content: finalContent,
        postType: finalPostType,
        imageUrls: imageUrl != null ? [imageUrl] : null,
        linkedAchievementId: linkedAchievementId,
        metadata: metadata,
      );

      if (result.isSuccess) {
        // Add to feed
        posts.insert(0, result.data!);
        await _cacheService.addPostToCache(result.data!);

        // Clear form
        clearPostForm();

        if (Get.context != null) {
          AppSnackbar.success(
            Get.context!,
            message: 'Post created successfully!',
          );
        }

        isCreatingPost.value = false;
        return true;
      } else {
        if (Get.context != null) {
          AppSnackbar.error(
            Get.context!,
            message: result.error?.message ?? 'Failed to create post',
          );
        }
        isCreatingPost.value = false;
        return false;
      }
    } catch (e) {
      if (Get.context != null) {
        AppSnackbar.error(
          Get.context!,
          message: 'Something went wrong. Please try again.',
        );
      }
      isCreatingPost.value = false;
      return false;
    }
  }

  // ============================================
  // DELETE POST
  // ============================================

  /// Delete a post
  Future<void> deletePost(String postId) async {
    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      if (Get.context != null) {
        AppSnackbar.error(
          Get.context!,
          message: 'Please connect to the internet',
        );
      }
      return;
    }

    final result = await _repository.deletePost(postId);

    if (result.isSuccess) {
      posts.removeWhere((p) => p.id == postId);
      myPosts.removeWhere((p) => p.id == postId);
      await _cacheService.removePostFromCache(postId);

      if (Get.context != null) {
        AppSnackbar.success(
          Get.context!,
          message: 'Post deleted',
        );
      }
    } else {
      if (Get.context != null) {
        AppSnackbar.error(
          Get.context!,
          message: result.error?.message ?? 'Failed to delete post',
        );
      }
    }
  }

  // ============================================
  // SEARCH
  // ============================================

  /// Search posts and users
  Future<void> search(String query) async {
    searchQuery.value = query;

    if (query.isEmpty) {
      searchPosts.clear();
      searchUsers.clear();
      isSearching.value = false;
      return;
    }

    isSearching.value = true;

    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      // Search in cached posts only
      final cached = _cacheService.getCachedFeedPosts() ?? [];
      searchPosts.value = cached
          .where((p) =>
              p.content.toLowerCase().contains(query.toLowerCase()) ||
              p.authorName.toLowerCase().contains(query.toLowerCase()))
          .toList();
      isSearching.value = false;
      return;
    }

    try {
      // Search posts
      final postsResponse = await _supabase.client
          .from('posts')
          .select('*, users(id, full_name, username, avatar_url)')
          .or('content.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(20);

      searchPosts.value = (postsResponse as List)
          .map((json) => PostModel.fromJson(json))
          .toList();

      // Search users - exclude current user
      var usersQuery = _supabase.client
          .from('users')
          .select('id, full_name, username, avatar_url')
          .or('full_name.ilike.%$query%,username.ilike.%$query%');

      // Exclude current user from results
      if (_supabase.userId != null) {
        usersQuery = usersQuery.neq('id', _supabase.userId!);
      }

      final usersResponse = await usersQuery.limit(10);

      searchUsers.value = (usersResponse as List)
          .map((json) => UserSummary.fromJson(json))
          .toList();
    } catch (e) {
      // Silently fail search
    }

    isSearching.value = false;
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchPosts.clear();
    searchUsers.clear();
  }

  // ============================================
  // MY POSTS
  // ============================================

  /// Load current user's posts
  Future<void> loadMyPosts() async {
    if (_supabase.userId == null) return;

    isLoadingMyPosts.value = true;

    final result = await _repository.getUserPosts(
      _supabase.userId!,
      limit: 50,
    );

    if (result.isSuccess) {
      myPosts.value = result.data!;
    }

    isLoadingMyPosts.value = false;
  }

  // ============================================
  // CHALLENGE POSTS
  // ============================================

  /// Load challenge/achievement posts
  Future<void> loadChallengePosts() async {
    isLoadingChallenges.value = true;

    try {
      final response = await _supabase.client
          .from('posts')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('post_type', 'achievement')
          .eq('is_public', true)
          .eq('approval_status', 'approved')
          .order('created_at', ascending: false)
          .limit(50);

      // Get user's likes and saves for these posts
      final postIds = (response as List).map((p) => p['id'] as String).toList();
      final enrichedPosts = await _enrichPostsWithUserStatus(response, postIds);

      challengePosts.value = enrichedPosts;
    } catch (e) {
      // Handle error
    }

    isLoadingChallenges.value = false;
  }

  // ============================================
  // RECIPE POSTS
  // ============================================

  /// Load recipe posts
  Future<void> loadRecipePosts() async {
    isLoadingRecipes.value = true;

    try {
      final response = await _supabase.client
          .from('posts')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('post_type', 'recipe_share')
          .eq('is_public', true)
          .eq('approval_status', 'approved')
          .order('created_at', ascending: false)
          .limit(50);

      // Get user's likes and saves for these posts
      final postIds = (response as List).map((p) => p['id'] as String).toList();
      final enrichedPosts = await _enrichPostsWithUserStatus(response, postIds);

      recipePosts.value = enrichedPosts;
    } catch (e) {
      // Handle error
    }

    isLoadingRecipes.value = false;
  }

  /// Helper to enrich posts with user's liked/saved status
  Future<List<PostModel>> _enrichPostsWithUserStatus(
    List<dynamic> response,
    List<String> postIds,
  ) async {
    Map<String, bool> likedPostIds = {};
    Map<String, bool> savedPostIds = {};

    final userId = _supabase.userId;
    if (userId != null && postIds.isNotEmpty) {
      // Fetch user's likes for these posts
      final likesResponse = await _supabase.client
          .from('likes')
          .select('post_id')
          .eq('user_id', userId)
          .eq('like_type', 'post')
          .inFilter('post_id', postIds);

      for (var like in (likesResponse as List)) {
        likedPostIds[like['post_id'] as String] = true;
      }

      // Fetch user's saved posts
      final savesResponse = await _supabase.client
          .from('saved_posts')
          .select('post_id')
          .eq('user_id', userId)
          .inFilter('post_id', postIds);

      for (var save in (savesResponse as List)) {
        savedPostIds[save['post_id'] as String] = true;
      }
    }

    return response.map((json) {
      final postId = json['id'] as String;
      final enrichedJson = Map<String, dynamic>.from(json);
      enrichedJson['is_liked_by_me'] = likedPostIds[postId] ?? false;
      enrichedJson['is_saved_by_me'] = savedPostIds[postId] ?? false;
      return PostModel.fromJson(enrichedJson);
    }).toList();
  }

  // ============================================
  // USER PROFILE (Bottom Sheet)
  // ============================================

  /// Load user profile and posts for bottom sheet
  Future<void> loadUserProfile(UserSummary user) async {
    selectedUser.value = user;
    isLoadingUserPosts.value = true;
    userProfilePosts.clear();
    userTotalLikes.value = 0;
    userStreak.value = 0;

    final result = await _repository.getUserPosts(user.id, limit: 20);

    if (result.isSuccess) {
      userProfilePosts.value = result.data!;

      // Calculate total likes from all posts
      int totalLikes = 0;
      for (var post in result.data!) {
        totalLikes += post.likesCount;
      }
      userTotalLikes.value = totalLikes;
    }

    // Calculate streak (consecutive days with posts)
    await _calculateUserStreak(user.id);

    isLoadingUserPosts.value = false;
  }

  /// Calculate user's posting streak
  Future<void> _calculateUserStreak(String userId) async {
    try {
      final response = await _supabase.client
          .from('posts')
          .select('created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(30);

      if ((response as List).isEmpty) {
        userStreak.value = 0;
        return;
      }

      // Get unique days with posts
      final Set<String> postDays = {};
      for (var post in response) {
        final date = DateTime.parse(post['created_at'] as String);
        postDays.add('${date.year}-${date.month}-${date.day}');
      }

      // Calculate consecutive days
      int streak = 0;
      DateTime checkDate = DateTime.now();

      for (int i = 0; i < 30; i++) {
        final dateStr = '${checkDate.year}-${checkDate.month}-${checkDate.day}';
        if (postDays.contains(dateStr)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (i == 0) {
          // Allow for today not having a post yet
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      userStreak.value = streak;
    } catch (e) {
      userStreak.value = 0;
    }
  }

  /// Clear user profile data
  void clearUserProfile() {
    selectedUser.value = null;
    userProfilePosts.clear();
    userTotalLikes.value = 0;
    userStreak.value = 0;
  }

  // ============================================
  // COMMENTS
  // ============================================

  /// Load comments for a post
  Future<void> loadComments(String postId) async {
    isLoadingComments.value = true;
    postComments.clear();

    final result = await _repository.getPostComments(postId);

    if (result.isSuccess) {
      postComments.value = result.data!;
    }

    isLoadingComments.value = false;
  }

  /// Add a comment
  Future<void> addComment(String postId) async {
    final content = commentController.text.trim();
    if (content.isEmpty) return;

    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      if (Get.context != null) {
        AppSnackbar.error(
          Get.context!,
          message: 'Please connect to the internet',
        );
      }
      return;
    }

    isPostingComment.value = true;

    final result = await _repository.createComment(
      postId: postId,
      content: content,
    );

    if (result.isSuccess) {
      postComments.insert(0, result.data!);
      commentController.clear();

      // Update comment count in posts list
      final index = posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        posts[index] = posts[index].copyWith(
          commentsCount: posts[index].commentsCount + 1,
        );
        await _cacheService.updatePostInCache(posts[index]);
      }

      // Update current post
      if (currentPost.value?.id == postId) {
        currentPost.value = currentPost.value!.copyWith(
          commentsCount: currentPost.value!.commentsCount + 1,
        );
      }
    } else {
      if (Get.context != null) {
        AppSnackbar.error(
          Get.context!,
          message: result.error?.message ?? 'Failed to add comment',
        );
      }
    }

    isPostingComment.value = false;
  }

  /// Delete a comment
  Future<void> deleteComment(String commentId, String postId) async {
    final result = await _repository.deleteComment(commentId);

    if (result.isSuccess) {
      postComments.removeWhere((c) => c.id == commentId);

      // Update comment count
      final index = posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        posts[index] = posts[index].copyWith(
          commentsCount: posts[index].commentsCount - 1,
        );
      }

      if (currentPost.value?.id == postId) {
        currentPost.value = currentPost.value!.copyWith(
          commentsCount: currentPost.value!.commentsCount - 1,
        );
      }
    }
  }

  /// Set current post for detail view
  void setCurrentPost(PostModel post) {
    currentPost.value = post;
  }

  // ============================================
  // CLEANUP
  // ============================================

  @override
  void onClose() {
    searchController.dispose();
    postContentController.dispose();
    commentController.dispose();
    recipeNameController.dispose();
    recipeIngredientsController.dispose();
    recipeInstructionsController.dispose();
    challengeNameController.dispose();
    challengeDescriptionController.dispose();
    challengeMessageController.dispose();
    recipeTitleController.dispose();
    recipeNotesController.dispose();
    recipeDurationController.dispose();
    super.onClose();
  }
}
