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
import 'create_post_screen.dart';

enum FilteredPostType { challenges, recipes }

class FilteredPostsScreen extends GetView<CommunityController> {
  final FilteredPostType postType;

  const FilteredPostsScreen({super.key, required this.postType});

  String get title => postType == FilteredPostType.challenges ? 'Challenges' : 'Recipes';
  IconData get icon => postType == FilteredPostType.challenges ? Iconsax.cup : Iconsax.book;
  String get emptyTitle => postType == FilteredPostType.challenges
      ? 'No challenges yet'
      : 'No recipes yet';
  String get emptySubtitle => postType == FilteredPostType.challenges
      ? 'Share your fitness achievements!'
      : 'Share your healthy recipes!';

  RxList<PostModel> get posts => postType == FilteredPostType.challenges
      ? controller.challengePosts
      : controller.recipePosts;

  RxBool get isLoading => postType == FilteredPostType.challenges
      ? controller.isLoadingChallenges
      : controller.isLoadingRecipes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: Text(title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Pre-select the appropriate post type
          controller.setPostType(
            postType == FilteredPostType.challenges ? 'achievement' : 'recipe_share',
          );
          Get.to(() => const CreatePostScreen());
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Iconsax.add, color: Colors.white),
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (posts.isEmpty) {
          return _buildEmptyState(context);
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (postType == FilteredPostType.challenges) {
              await controller.loadChallengePosts();
            } else {
              await controller.loadRecipePosts();
            }
          },
          color: AppColors.primary,
          child: ListView.separated(
            padding: AppPadding.screenAll,
            itemCount: posts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final post = posts[index];
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
            icon,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            emptyTitle,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            emptySubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              controller.setPostType(
                postType == FilteredPostType.challenges ? 'achievement' : 'recipe_share',
              );
              Get.to(() => const CreatePostScreen());
            },
            icon: const Icon(Iconsax.add),
            label: Text(postType == FilteredPostType.challenges
                ? 'Share Challenge'
                : 'Share Recipe'),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(BuildContext context, PostModel post, int index) {
    return GestureDetector(
      onTap: () {
        controller.setCurrentPost(post);
        Get.to(() => const PostDetailScreen());
      },
      child: Container(
        padding: AppPadding.card,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with author and badge
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
                // Post type badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.small,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        postType == FilteredPostType.challenges ? 'Challenge' : 'Recipe',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Content - dispatch by post type
            _buildPostContent(context, post),

            const SizedBox(height: 12),

            // Actions row
            Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: () => controller.toggleLikePost(post.id),
                  child: Row(
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
                              color: post.isLikedByMe ? AppColors.primary : AppColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Comments
                Row(
                  children: [
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
                  ],
                ),
                const Spacer(),
                // Save button
                GestureDetector(
                  onTap: () => controller.toggleSavePost(post.id),
                  child: Icon(
                    post.isSavedByMe ? Iconsax.bookmark5 : Iconsax.bookmark,
                    size: 18,
                    color: post.isSavedByMe ? AppColors.primary : AppColors.textMuted,
                  ),
                ),
                const SizedBox(width: 16),
                // Share button
                GestureDetector(
                  onTap: () => controller.sharePost(post),
                  child: Icon(
                    Iconsax.send_2,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),

            // View comments link
            if (post.commentsCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                'View ${post.commentsCount} comments',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ],
        ),
      ).animate().fadeIn(delay: (index * 50).ms, duration: 300.ms).slideY(
            begin: 0.05,
            end: 0,
            delay: (index * 50).ms,
            duration: 300.ms,
          ),
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
          Text(post.content, style: Theme.of(context).textTheme.bodyMedium, maxLines: 6, overflow: TextOverflow.ellipsis),
        if (post.imageUrls.isNotEmpty) ...[
          const SizedBox(height: 12),
          CofitImage(imageUrl: post.imageUrls.first, width: double.infinity, height: 180, borderRadius: AppRadius.medium),
        ],
      ],
    );
  }
}
