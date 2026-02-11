import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/cofit_image.dart';
import '../../../shared/widgets/cofit_avatar.dart';
import '../../../data/models/community_model.dart';
import '../controllers/community_controller.dart';
import '../widgets/approval_badge.dart';
import '../widgets/winning_card.dart';
import '../widgets/workout_recipe_card.dart';
import '../widgets/user_profile_sheet.dart';
import 'create_post_screen.dart';
import 'community_search_screen.dart';
import 'post_detail_screen.dart';
import 'my_posts_screen.dart';
import 'filtered_posts_screen.dart';

class CommunityScreen extends GetView<CommunityController> {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('CoFit Community'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: () => Get.to(() => const CommunitySearchScreen()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const CreatePostScreen()),
        backgroundColor: AppColors.primary,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Quick access tabs
          _buildQuickAccessTabs(context),

          // Feed
          Expanded(
            child: Obx(() {
              // Show loading shimmer on initial load
              if (controller.isLoading.value && controller.posts.isEmpty) {
                return _buildLoadingShimmer(context);
              }

              // Show empty state
              if (!controller.isLoading.value && controller.posts.isEmpty) {
                return _buildEmptyFeed(context);
              }

              // Show feed
              return RefreshIndicator(
                onRefresh: controller.refreshFeed,
                color: AppColors.primary,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    // Load more when near bottom
                    if (notification is ScrollEndNotification &&
                        notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent - 200) {
                      controller.loadMorePosts();
                    }
                    return false;
                  },
                  child: ListView.separated(
                    padding: AppPadding.screen,
                    itemCount:
                        controller.posts.length +
                        (controller.hasMorePosts.value ? 1 : 0),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      // Show loading indicator at bottom
                      if (index >= controller.posts.length) {
                        return _buildLoadMoreIndicator();
                      }

                      final post = controller.posts[index];
                      return _buildPostCard(context, post, index);
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickTab(
              context,
              icon: Iconsax.cup,
              label: 'Challenges',
              onTap: () {
                controller.loadChallengePosts();
                Get.to(
                  () => const FilteredPostsScreen(
                    postType: FilteredPostType.challenges,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickTab(
              context,
              icon: Iconsax.book,
              label: 'Recipes',
              onTap: () {
                controller.loadRecipePosts();
                Get.to(
                  () => const FilteredPostsScreen(
                    postType: FilteredPostType.recipes,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickTab(
              context,
              icon: Iconsax.document,
              label: 'My Posts',
              onTap: () {
                controller.loadMyPosts();
                Get.to(() => const MyPostsScreen());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickTab(
    BuildContext context, {
    required IconData icon,
    required String label,
    int? badgeCount,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.medium,
          boxShadow: AppShadows.subtle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(height: 4),
                Text(label, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
            if (badgeCount != null)
              Positioned(
                top: 0,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badgeCount',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, PostModel post, int index) {
    final isMyPost = post.userId == SupabaseService.to.userId;

    return Container(
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          GestureDetector(
            onTap: () {
              if (post.author != null) {
                controller.loadUserProfile(post.author!);
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const UserProfileSheet(),
                );
              }
            },
            child: Row(
              children: [
                CofitAvatar(
                  imageUrl: post.authorAvatar,
                  userId: post.author?.id,
                  userName: post.authorName,
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        post.timeAgo,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isMyPost)
                  PopupMenuButton<String>(
                    icon: Icon(
                      Iconsax.more,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(context, post.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Iconsax.trash, color: Colors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  )
                else
                  const SizedBox(width: 40),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Approval badge for own non-approved posts
          if (isMyPost && !post.isApproved)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ApprovalBadge(
                status: post.approvalStatus,
                rejectionReason: post.rejectionReason,
              ),
            ),

          // Content - dispatch by post type
          GestureDetector(
            onTap: () {
              controller.setCurrentPost(post);
              Get.to(() => const PostDetailScreen());
            },
            child: _buildPostContent(context, post),
          ),

          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              _buildActionButton(
                context,
                icon: post.isLikedByMe ? Iconsax.heart5 : Iconsax.heart,
                label: '${post.likesCount}',
                color: post.isLikedByMe ? AppColors.primary : null,
                onTap: () => controller.toggleLikePost(post.id),
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                context,
                icon: Iconsax.message,
                label: '${post.commentsCount}',
                onTap: () {
                  controller.setCurrentPost(post);
                  Get.to(() => const PostDetailScreen());
                },
              ),
              const Spacer(),
              _buildActionButton(
                context,
                icon: post.isSavedByMe ? Iconsax.bookmark5 : Iconsax.bookmark,
                label: '',
                color: post.isSavedByMe ? AppColors.primary : null,
                onTap: () => controller.toggleSavePost(post.id),
              ),
              const SizedBox(width: 16),
              _buildActionButton(
                context,
                icon: Iconsax.send_2,
                label: '',
                onTap: () => controller.sharePost(post),
              ),
            ],
          ),

          // View comments link (if has comments)
          if (post.commentsCount > 0) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                controller.setCurrentPost(post);
                Get.to(() => const PostDetailScreen());
              },
              child: Text(
                'View all ${post.commentsCount} comments',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? AppColors.textMuted),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color ?? AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostContent(BuildContext context, PostModel post) {
    // Challenge winning card
    if (post.isChallengePost) {
      final meta = post.challengeMetadata;
      if (meta != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WinningCard(metadata: meta),
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                post.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );
      }
    }

    // Workout recipe card
    if (post.isWorkoutRecipePost) {
      final meta = post.workoutRecipeMetadata;
      if (meta != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WorkoutRecipeCard(metadata: meta),
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                post.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );
      }
    }

    // Default: text + image
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.content.isNotEmpty)
          Text(
            post.content,
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        if (post.imageUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          CofitImage(
            imageUrl: post.imageUrls.first,
            width: double.infinity,
            height: 200,
            borderRadius: AppRadius.medium,
          ),
        ],
      ],
    );
  }

  Widget _buildLoadMoreIndicator() {
    return Obx(() {
      if (controller.isLoadingMore.value) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2,
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return ListView.builder(
      padding: AppPadding.screen,
      itemCount: 3,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.large,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(radius: 20),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 100, height: 12, color: Colors.white),
                        const SizedBox(height: 4),
                        Container(width: 60, height: 10, color: Colors.white),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 14,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Container(width: 200, height: 14, color: Colors.white),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 150,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyFeed(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document_text, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share something!',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Get.to(() => const CreatePostScreen()),
            icon: const Icon(Iconsax.add),
            label: const Text('Create Post'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deletePost(postId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
