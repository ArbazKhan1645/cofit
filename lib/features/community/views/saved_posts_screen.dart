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
import '../widgets/winning_card.dart';
import '../widgets/workout_recipe_card.dart';
import 'post_detail_screen.dart';

class SavedPostsScreen extends GetView<CommunityController> {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Saved Posts'),
      ),
      body: Obx(() {
        if (controller.isLoadingSavedPosts.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.savedPosts.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadSavedPosts(),
          color: AppColors.primary,
          child: ListView.separated(
            padding: AppPadding.screenAll,
            itemCount: controller.savedPosts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final post = controller.savedPosts[index];
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
            Iconsax.bookmark,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'No saved posts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bookmark posts to find them here later',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
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
          // Header
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
              IconButton(
                icon: const Icon(Iconsax.bookmark5, size: 20, color: AppColors.primary),
                onPressed: () {
                  controller.toggleSavePost(post.id);
                  controller.savedPosts.removeWhere((p) => p.id == post.id);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content
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
}
