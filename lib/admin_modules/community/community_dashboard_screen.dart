import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/community_model.dart';
import '../../shared/widgets/cofit_image.dart';
import 'community_controller.dart';

class CommunityDashboardScreen extends GetView<AdminCommunityController> {
  const CommunityDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Community'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.document_text),
            onPressed: () => Get.toNamed(AppRoutes.adminPostsList),
            tooltip: 'All Posts',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.allPosts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppPadding.screen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                // Stats cards
                _buildStatsGrid(context),
                const SizedBox(height: 20),
                // Post types breakdown
                _buildPostTypesCard(context),
                const SizedBox(height: 20),
                // Pending posts queue
                _buildPendingSection(context),
                const SizedBox(height: 20),
                // Top posters
                _buildTopPostersSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ============================================
  // STATS GRID
  // ============================================
  Widget _buildStatsGrid(BuildContext context) {
    return Obx(() => Column(
          children: [
            Row(
              children: [
                _buildStatCard(context, '${controller.totalPosts.value}',
                    'Total Posts', Iconsax.document, AppColors.primary),
                const SizedBox(width: 12),
                _buildStatCard(context, '${controller.pendingPosts.value}',
                    'Pending', Iconsax.clock, AppColors.warning),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard(context, '${controller.approvedPosts.value}',
                    'Approved', Iconsax.tick_circle, AppColors.success),
                const SizedBox(width: 12),
                _buildStatCard(context, '${controller.mediaPosts.value}',
                    'With Media', Iconsax.image, AppColors.lavender),
              ],
            ),
          ],
        ));
  }

  Widget _buildStatCard(BuildContext context, String value, String label,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.medium,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // POST TYPES BREAKDOWN
  // ============================================
  Widget _buildPostTypesCard(BuildContext context) {
    return Obx(() {
      final stats = controller.postTypeStats;
      if (stats.isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: AppPadding.card,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Post Types',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: stats.entries.map((entry) {
                final color = _postTypeColor(entry.key);
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: AppRadius.pill,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_postTypeIcon(entry.key), size: 16, color: color),
                      const SizedBox(width: 6),
                      Text(
                        '${controller.postTypeLabel(entry.key)}: ${entry.value}',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: color, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  Color _postTypeColor(String type) {
    switch (type) {
      case 'text':
        return AppColors.textSecondary;
      case 'image':
        return AppColors.lavender;
      case 'video':
        return AppColors.skyBlue;
      case 'workout_share':
        return AppColors.primary;
      case 'achievement':
        return AppColors.sunnyYellow;
      case 'recipe_share':
        return AppColors.mintFresh;
      default:
        return AppColors.textMuted;
    }
  }

  IconData _postTypeIcon(String type) {
    switch (type) {
      case 'text':
        return Iconsax.text;
      case 'image':
        return Iconsax.image;
      case 'video':
        return Iconsax.video;
      case 'workout_share':
        return Iconsax.weight;
      case 'achievement':
        return Iconsax.medal_star;
      case 'recipe_share':
        return Iconsax.book_1;
      default:
        return Iconsax.document;
    }
  }

  // ============================================
  // PENDING POSTS SECTION
  // ============================================
  Widget _buildPendingSection(BuildContext context) {
    return Obx(() {
      final pending = controller.allPosts.where((p) => p.isPending).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Pending Approval',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              if (pending.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text('${pending.length}',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                ),
              const Spacer(),
              if (pending.isNotEmpty)
                TextButton(
                  onPressed: () {
                    controller.filterStatus.value = 'pending';
                    Get.toNamed(AppRoutes.adminPostsList);
                  },
                  child: const Text('View All'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (pending.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.large,
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                children: [
                  const Icon(Iconsax.tick_circle,
                      size: 40, color: AppColors.success),
                  const SizedBox(height: 8),
                  Text('All caught up!',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textMuted)),
                ],
              ),
            )
          else
            ...pending
                .take(5)
                .map((post) => _buildPendingPostCard(context, post)),
        ],
      );
    });
  }

  Widget _buildPendingPostCard(BuildContext context, PostModel post) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
        border: Border.all(
            color: AppColors.warning.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              _buildSmallAvatar(post.author),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.authorName,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(post.timeAgo,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: AppRadius.small,
                ),
                child: Text(controller.postTypeLabel(post.postType),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                        fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Content preview
          Text(post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall),
          // Media indicator
          if (post.hasMedia) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                    post.imageUrls.isNotEmpty ? Iconsax.image : Iconsax.video,
                    size: 14,
                    color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  post.imageUrls.isNotEmpty
                      ? '${post.imageUrls.length} image${post.imageUrls.length > 1 ? 's' : ''}'
                      : 'Video',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.approvePost(post),
                  icon: const Icon(Iconsax.tick_circle, size: 16),
                  label: const Text('Approve'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.success,
                    side: const BorderSide(color: AppColors.success),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.medium),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.showRejectDialog(post),
                  icon: const Icon(Iconsax.close_circle, size: 16),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.medium),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================
  // TOP POSTERS
  // ============================================
  Widget _buildTopPostersSection(BuildContext context) {
    return Obx(() {
      if (controller.topPosters.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Top Posters',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.large,
              boxShadow: AppShadows.subtle,
            ),
            child: Column(
              children: controller.topPosters.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                final user = data['user'] as UserSummary?;
                final count = data['postCount'] as int;
                final likes = data['totalLikes'] as int;

                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      leading: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${index + 1}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: index < 3
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildSmallAvatar(user),
                        ],
                      ),
                      title: Text(user?.displayName ?? 'Unknown',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('$count posts',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.w600)),
                              Text('$likes likes',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(color: AppColors.textMuted)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (index < controller.topPosters.length - 1)
                      const Divider(height: 1, indent: 64),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      );
    });
  }

  // ============================================
  // HELPERS
  // ============================================
  Widget _buildSmallAvatar(dynamic user) {
    final avatarUrl =
        user is UserSummary ? user.avatarUrl : (user as UserSummary?)?.avatarUrl;
    final name =
        user is UserSummary ? user.displayName : (user as UserSummary?)?.displayName ?? 'U';

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: CofitImage(imageUrl: avatarUrl, width: 36, height: 36),
      );
    }
    return CircleAvatar(
      radius: 18,
      backgroundColor: AppColors.bgBlush,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'U',
        style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 14),
      ),
    );
  }
}
