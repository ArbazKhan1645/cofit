import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/cofit_image.dart';
import '../../../shared/widgets/cofit_avatar.dart';
import '../../../data/models/community_model.dart';
import '../controllers/community_controller.dart';
import '../widgets/user_profile_sheet.dart';
import 'post_detail_screen.dart';

class CommunitySearchScreen extends GetView<CommunityController> {
  const CommunitySearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: _buildSearchField(context),
        titleSpacing: 0,
        actions: [
          Obx(() {
            if (controller.searchQuery.value.isNotEmpty) {
              return IconButton(
                icon: const Icon(Iconsax.close_circle),
                onPressed: controller.clearSearch,
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        // Show empty state when no search
        if (controller.searchQuery.value.isEmpty) {
          return _buildEmptyState(context);
        }

        // Show loading
        if (controller.isSearching.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Show results
        return _buildSearchResults(context);
      }),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: AppColors.bgBlush,
        borderRadius: AppRadius.medium,
      ),
      child: TextField(
        controller: controller.searchController,
        autofocus: true,
        onChanged: (value) {
          // Debounce search
          Future.delayed(const Duration(milliseconds: 300), () {
            if (controller.searchController.text == value) {
              controller.search(value);
            }
          });
        },
        decoration: InputDecoration(
          hintText: 'Search users or posts...',
          hintStyle: TextStyle(color: AppColors.textMuted),
          prefixIcon: Icon(
            Iconsax.search_normal,
            color: AppColors.textMuted,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_normal_1,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Search for users or posts',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find friends or discover content',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final hasUsers = controller.searchUsers.isNotEmpty;
    final hasPosts = controller.searchPosts.isNotEmpty;

    if (!hasUsers && !hasPosts) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.search_status,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: AppPadding.screen,
      children: [
        // Users section
        if (hasUsers) ...[
          _buildSectionHeader(context, 'People', controller.searchUsers.length),
          const SizedBox(height: 12),
          ...controller.searchUsers.map((user) => _buildUserItem(context, user)),
          const SizedBox(height: 24),
        ],

        // Posts section
        if (hasPosts) ...[
          _buildSectionHeader(context, 'Posts', controller.searchPosts.length),
          const SizedBox(height: 12),
          ...controller.searchPosts.map((post) => _buildPostItem(context, post)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: AppRadius.small,
          ),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserItem(BuildContext context, UserSummary user) {
    return GestureDetector(
      onTap: () {
        controller.loadUserProfile(user);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const UserProfileSheet(),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.medium,
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            CofitAvatar(
              imageUrl: user.avatarUrl,
              userId: user.id,
              userName: user.displayName,
              radius: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  if (user.username != null)
                    Text(
                      '@${user.username}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostItem(BuildContext context, PostModel post) {
    return GestureDetector(
      onTap: () {
        controller.setCurrentPost(post);
        Get.to(() => const PostDetailScreen());
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.medium,
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  Row(
                    children: [
                      Text(
                        post.authorName,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        post.timeAgo,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Iconsax.heart,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likesCount}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Iconsax.message,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.commentsCount}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (post.imageUrls.isNotEmpty)
              CofitImage(
                imageUrl: post.imageUrls.first,
                width: 60,
                height: 60,
                borderRadius: AppRadius.small,
              ),
          ],
        ),
      ),
    );
  }
}
