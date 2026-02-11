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
import '../views/post_detail_screen.dart';

class UserProfileSheet extends GetView<CommunityController> {
  const UserProfileSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.bgCream,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // User profile header
              Obx(() {
                final user = controller.selectedUser.value;
                if (user == null) {
                  return const SizedBox(height: 100);
                }
                return _buildProfileHeader(context, user);
              }),

              const SizedBox(height: 16),

              // User's posts
              Expanded(
                child: Obx(() {
                  if (controller.isLoadingUserPosts.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.userProfilePosts.isEmpty) {
                    return _buildEmptyPosts(context);
                  }

                  return ListView.separated(
                    controller: scrollController,
                    padding: AppPadding.screen,
                    itemCount: controller.userProfilePosts.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final post = controller.userProfilePosts[index];
                      return _buildPostItem(context, post)
                          .animate()
                          .fadeIn(delay: (index * 50).ms, duration: 300.ms)
                          .slideY(begin: 0.1, end: 0);
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserSummary user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Avatar
          CofitAvatar(
            imageUrl: user.avatarUrl,
            userId: user.id,
            userName: user.displayName,
            radius: 45,
          ).animate().scale(duration: 300.ms, curve: Curves.easeOut),
          const SizedBox(height: 12),

          // Name
          Text(
            user.displayName,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ).animate().fadeIn(delay: 100.ms),

          // Username
          if (user.username != null)
            Text(
              '@${user.username}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            ).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 16),

          // Stats row - 3 items for better UI
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  context,
                  '${controller.userProfilePosts.length}',
                  'Posts',
                  Iconsax.document_text,
                ),
                SizedBox(width: 10),
                _buildStatItem(
                  context,
                  '${controller.userTotalLikes.value}',
                  'Likes',
                  Iconsax.heart,
                ),
                SizedBox(width: 10),
                _buildStatItem(
                  context,
                  '${controller.userStreak.value}',
                  'Day Streak',
                  Iconsax.flash_1,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          // Section title
          Row(
            children: [
              Icon(Iconsax.document_text, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Posts',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ).animate().fadeIn(delay: 250.ms),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.medium,
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPosts(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.document, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text(
            'No posts yet',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, PostModel post) {
    return GestureDetector(
      onTap: () {
        controller.setCurrentPost(post);
        Get.back(); // Close sheet first
        Get.to(() => const PostDetailScreen());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.medium,
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Content
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),

            // Image preview
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              CofitImage(
                imageUrl: post.imageUrls.first,
                width: double.infinity,
                height: 150,
                borderRadius: AppRadius.small,
              ),
            ],

            const SizedBox(height: 12),

            // Footer
            Row(
              children: [
                Text(
                  post.timeAgo,
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                ),
                const Spacer(),
                // Like button
                GestureDetector(
                  onTap: () => controller.toggleLikePost(post.id),
                  child: Row(
                    children: [
                      Icon(
                        post.isLikedByMe ? Iconsax.heart5 : Iconsax.heart,
                        size: 16,
                        color: post.isLikedByMe
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likesCount}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: post.isLikedByMe
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Comments
                Icon(Iconsax.message, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${post.commentsCount}',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(width: 16),
                // Save button
                GestureDetector(
                  onTap: () => controller.toggleSavePost(post.id),
                  child: Icon(
                    post.isSavedByMe ? Iconsax.bookmark5 : Iconsax.bookmark,
                    size: 16,
                    color: post.isSavedByMe
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
