import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/cofit_image.dart';
import '../../../shared/widgets/cofit_avatar.dart';
import '../../../data/models/community_model.dart';
import '../controllers/community_controller.dart';
import '../widgets/approval_badge.dart';
import '../widgets/winning_card.dart';
import '../widgets/workout_recipe_card.dart';
import 'post_detail_screen.dart';
import 'create_post_screen.dart';

class MyPostsScreen extends GetView<CommunityController> {
  const MyPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('My Posts'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const CreatePostScreen()),
        backgroundColor: AppColors.primary,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoadingMyPosts.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.myPosts.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadMyPosts(),
          color: AppColors.primary,
          child: ListView.separated(
            padding: AppPadding.screenAll,
            itemCount: controller.myPosts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final post = controller.myPosts[index];
              return _buildPostCard(context, post, index);
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.document_text,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Share your fitness journey!',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
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

  Widget _buildPostCard(BuildContext context, PostModel post, int index) {
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
          // Header with time and delete
          Row(
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
              PopupMenuButton<String>(
                icon: Icon(Iconsax.more, size: 20, color: AppColors.textMuted),
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
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Approval badge
          if (!post.isApproved)
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

          // Stats row
          Row(
            children: [
              Icon(
                post.isLikedByMe ? Iconsax.heart5 : Iconsax.heart,
                size: 18,
                color: post.isLikedByMe ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.likesCount}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(width: 20),
              Icon(
                Iconsax.message,
                size: 18,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${post.commentsCount}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const Spacer(),
              if (post.commentsCount > 0)
                GestureDetector(
                  onTap: () {
                    controller.setCurrentPost(post);
                    Get.to(() => const PostDetailScreen());
                  },
                  child: Text(
                    'View comments',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms).slideY(
          begin: 0.05,
          end: 0,
          delay: (index * 50).ms,
          duration: 300.ms,
        );
  }

  Widget _buildPostContent(BuildContext context, PostModel post) {
    if (post.isChallengePost) {
      final meta = post.challengeMetadata;
      if (meta != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WinningCard(metadata: meta),
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(post.content, style: Theme.of(context).textTheme.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
          ],
        );
      }
    }

    if (post.isWorkoutRecipePost) {
      final meta = post.workoutRecipeMetadata;
      if (meta != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WorkoutRecipeCard(metadata: meta),
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(post.content, style: Theme.of(context).textTheme.bodyMedium, maxLines: 3, overflow: TextOverflow.ellipsis),
            ],
          ],
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.content.isNotEmpty)
          Text(post.content, style: Theme.of(context).textTheme.bodyMedium, maxLines: 4, overflow: TextOverflow.ellipsis),
        if (post.imageUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          CofitImage(imageUrl: post.imageUrls.first, width: double.infinity, height: 180, borderRadius: AppRadius.medium),
        ],
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
            'Are you sure you want to delete this post? This action cannot be undone.'),
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
