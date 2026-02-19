import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../data/models/community_model.dart';
import '../../notifications/firebase_sender.dart';
import '../../shared/controllers/base_controller.dart';

class AdminCommunityController extends BaseController {
  final SupabaseService _supabase = SupabaseService.to;
  final FcmNotificationSender _fcmSender = FcmNotificationSender();

  // ============================================
  // STATE
  // ============================================

  final RxList<PostModel> allPosts = <PostModel>[].obs;
  final RxString filterStatus = 'all'.obs; // all, pending, approved, rejected
  final RxString searchQuery = ''.obs;

  // Stats
  final RxInt totalPosts = 0.obs;
  final RxInt pendingPosts = 0.obs;
  final RxInt approvedPosts = 0.obs;
  final RxInt rejectedPosts = 0.obs;
  final RxInt mediaPosts = 0.obs;

  // Top posters
  final RxList<Map<String, dynamic>> topPosters = <Map<String, dynamic>>[].obs;

  // Post type stats
  final RxMap<String, int> postTypeStats = <String, int>{}.obs;

  // Detail view
  final Rx<PostModel?> selectedPost = Rx<PostModel?>(null);
  final rejectionReasonController = TextEditingController();

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  @override
  void onClose() {
    rejectionReasonController.dispose();
    super.onClose();
  }

  // ============================================
  // COMPUTED
  // ============================================

  List<PostModel> get filteredPosts {
    var list = allPosts.toList();

    // Filter by status
    switch (filterStatus.value) {
      case 'pending':
        list = list.where((p) => p.isPending).toList();
        break;
      case 'approved':
        list = list.where((p) => p.isApproved).toList();
        break;
      case 'rejected':
        list = list.where((p) => p.isRejected).toList();
        break;
    }

    // Search
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where((p) =>
              p.content.toLowerCase().contains(q) ||
              p.authorName.toLowerCase().contains(q) ||
              p.postType.toLowerCase().contains(q))
          .toList();
    }

    return list;
  }

  // ============================================
  // LOAD DATA
  // ============================================

  Future<void> loadDashboardData() async {
    setLoading(true);
    try {
      await Future.wait([
        _loadAllPosts(),
        _loadTopPosters(),
      ]);
      _calculateStats();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  }

  Future<void> _loadAllPosts() async {
    final response = await _supabase
        .from('posts')
        .select('*, users(id, full_name, username, avatar_url)')
        .order('created_at', ascending: false);
    allPosts.value = (response as List)
        .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> _loadTopPosters() async {
    // Get post counts grouped by user, with user info
    final response = await _supabase
        .from('posts')
        .select('user_id, users(id, full_name, username, avatar_url)')
        .order('created_at', ascending: false);

    final userPostCounts = <String, Map<String, dynamic>>{};
    for (final row in (response as List)) {
      final userId = row['user_id'] as String;
      if (!userPostCounts.containsKey(userId)) {
        userPostCounts[userId] = {
          'user': row['users'],
          'count': 0,
          'likes': 0,
        };
      }
      userPostCounts[userId]!['count'] =
          (userPostCounts[userId]!['count'] as int) + 1;
    }

    // Also calculate total likes per user from allPosts
    for (final post in allPosts) {
      if (userPostCounts.containsKey(post.userId)) {
        userPostCounts[post.userId]!['likes'] =
            (userPostCounts[post.userId]!['likes'] as int) + post.likesCount;
      }
    }

    // Sort by post count descending, take top 10
    final sorted = userPostCounts.entries.toList()
      ..sort((a, b) =>
          (b.value['count'] as int).compareTo(a.value['count'] as int));

    topPosters.value = sorted
        .take(10)
        .map((e) => {
              'user': e.value['user'] != null
                  ? UserSummary.fromJson(
                      e.value['user'] as Map<String, dynamic>)
                  : null,
              'postCount': e.value['count'],
              'totalLikes': e.value['likes'],
            })
        .toList();
  }

  void _calculateStats() {
    totalPosts.value = allPosts.length;
    pendingPosts.value = allPosts.where((p) => p.isPending).length;
    approvedPosts.value = allPosts.where((p) => p.isApproved).length;
    rejectedPosts.value = allPosts.where((p) => p.isRejected).length;
    mediaPosts.value = allPosts.where((p) => p.hasMedia).length;

    // Post type breakdown
    final typeMap = <String, int>{};
    for (final post in allPosts) {
      typeMap[post.postType] = (typeMap[post.postType] ?? 0) + 1;
    }
    postTypeStats.value = typeMap;
  }

  Future<void> refreshData() async => loadDashboardData();

  // ============================================
  // APPROVE / REJECT
  // ============================================

  Future<void> approvePost(PostModel post) async {
    try {
      await _supabase
          .from('posts')
          .update({
            'approval_status': 'approved',
            'rejection_reason': null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', post.id);

      _updatePostLocally(
          post.id, post.copyWith(approvalStatus: 'approved', rejectionReason: null));

      // FCM: post creator ko "approved" + community topic par "new post available"
      final preview = post.content.length > 50
          ? '${post.content.substring(0, 47)}...'
          : post.content.isNotEmpty
              ? post.content
              : null;
      _fcmSender.sendPostApprovedNotification(
        postOwnerId: post.userId,
        postId: post.id,
        postAuthorName: post.authorName,
        postPreview: preview,
      );

      Get.snackbar('Approved', '${post.authorName}\'s post has been approved',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to approve post',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> rejectPost(PostModel post, {String? reason}) async {
    try {
      await _supabase
          .from('posts')
          .update({
            'approval_status': 'rejected',
            'rejection_reason': reason,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', post.id);

      _updatePostLocally(post.id,
          post.copyWith(approvalStatus: 'rejected', rejectionReason: reason));

      // FCM: sirf post creator ko "rejected" notification
      _fcmSender.sendPostRejectedNotification(
        postOwnerId: post.userId,
        postId: post.id,
        rejectionReason: reason,
      );

      Get.snackbar('Rejected', '${post.authorName}\'s post has been rejected',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to reject post',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void showRejectDialog(PostModel post) {
    rejectionReasonController.clear();
    Get.dialog(
      AlertDialog(
        title: const Text('Reject Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject ${post.authorName}\'s post?'),
            const SizedBox(height: 12),
            TextField(
              controller: rejectionReasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                hintText: 'e.g. Inappropriate content',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              rejectPost(post,
                  reason: rejectionReasonController.text.trim().isNotEmpty
                      ? rejectionReasonController.text.trim()
                      : null);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // DELETE POST
  // ============================================

  Future<void> deletePost(PostModel post) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Post'),
        content: Text(
            'Permanently delete ${post.authorName}\'s post? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _supabase.from('posts').delete().eq('id', post.id);
      allPosts.removeWhere((p) => p.id == post.id);
      _calculateStats();
      Get.snackbar('Deleted', 'Post has been deleted',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete post',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ============================================
  // PIN / UNPIN
  // ============================================

  Future<void> togglePin(PostModel post) async {
    final newPinned = !post.isPinned;
    try {
      await _supabase
          .from('posts')
          .update({
            'is_pinned': newPinned,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', post.id);

      _updatePostLocally(post.id, post.copyWith(isPinned: newPinned));
    } catch (e) {
      Get.snackbar('Error', 'Failed to update pin status',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ============================================
  // HELPERS
  // ============================================

  void _updatePostLocally(String postId, PostModel updatedPost) {
    final index = allPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      allPosts[index] = updatedPost;
      allPosts.refresh();
    }
    if (selectedPost.value?.id == postId) {
      selectedPost.value = updatedPost;
    }
    _calculateStats();
  }

  String postTypeLabel(String type) {
    switch (type) {
      case 'text':
        return 'Text';
      case 'image':
        return 'Image';
      case 'video':
        return 'Video';
      case 'workout_share':
        return 'Workout';
      case 'achievement':
        return 'Achievement';
      case 'recipe_share':
        return 'Recipe';
      default:
        return type;
    }
  }
}
