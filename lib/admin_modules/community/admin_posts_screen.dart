import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/community_model.dart';
import '../../shared/widgets/cofit_image.dart';
import 'community_controller.dart';

class AdminPostsScreen extends GetView<AdminCommunityController> {
  const AdminPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: const Text('All Posts')),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search posts or authors...',
                prefixIcon: const Icon(Iconsax.search_normal),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.medium,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Filter tabs
          Padding(
            padding: AppPadding.horizontal,
            child: Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(context, 'All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          context, 'Pending (${controller.pendingPosts.value})', 'pending'),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, 'Approved', 'approved'),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, 'Rejected', 'rejected'),
                    ],
                  ),
                )),
          ),
          const SizedBox(height: 12),
          // Posts list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allPosts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final posts = controller.filteredPosts;
              if (posts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.document,
                          size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text('No posts found',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refreshData,
                child: ListView.separated(
                  padding: AppPadding.screen,
                  itemCount: posts.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _buildPostCard(context, posts[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ============================================
  // FILTER CHIP
  // ============================================
  Widget _buildFilterChip(BuildContext context, String label, String value) {
    final selected = controller.filterStatus.value == value;
    return GestureDetector(
      onTap: () => controller.filterStatus.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: AppRadius.pill,
          boxShadow: selected ? [] : AppShadows.subtle,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  // ============================================
  // POST CARD
  // ============================================
  Widget _buildPostCard(BuildContext context, PostModel post) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: author + status + menu
          Row(
            children: [
              _buildAvatar(post.author),
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
                    Text(
                      '${DateFormat('d MMM yyyy, HH:mm').format(post.createdAt)} \u2022 ${controller.postTypeLabel(post.postType)}',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(context, post),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                onSelected: (val) => _handleMenuAction(val, post),
                itemBuilder: (_) => [
                  if (post.isPending || post.isRejected)
                    const PopupMenuItem(
                      value: 'approve',
                      child: Row(children: [
                        Icon(Iconsax.tick_circle,
                            size: 18, color: AppColors.success),
                        SizedBox(width: 8),
                        Text('Approve',
                            style: TextStyle(color: AppColors.success)),
                      ]),
                    ),
                  if (post.isPending || post.isApproved)
                    const PopupMenuItem(
                      value: 'reject',
                      child: Row(children: [
                        Icon(Iconsax.close_circle,
                            size: 18, color: AppColors.warning),
                        SizedBox(width: 8),
                        Text('Reject',
                            style: TextStyle(color: AppColors.warning)),
                      ]),
                    ),
                  PopupMenuItem(
                    value: 'pin',
                    child: Row(children: [
                      Icon(post.isPinned ? Iconsax.flag : Iconsax.flag,
                          size: 18,
                          color: post.isPinned
                              ? AppColors.textMuted
                              : AppColors.primary),
                      const SizedBox(width: 8),
                      Text(post.isPinned ? 'Unpin' : 'Pin'),
                    ]),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Iconsax.trash, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(color: AppColors.error)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Content
          Text(post.content,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall),
          // Image preview
          if (post.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: post.imageUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) => ClipRRect(
                  borderRadius: AppRadius.medium,
                  child: CofitImage(
                    imageUrl: post.imageUrls[index],
                    width: 80,
                    height: 80,
                  ),
                ),
              ),
            ),
          ],
          // Rejection reason
          if (post.isRejected && post.rejectionReason != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: AppRadius.small,
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.info_circle,
                      size: 14, color: AppColors.error),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(post.rejectionReason!,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.error,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          // Stats row
          Row(
            children: [
              _buildStat(context, Iconsax.heart, '${post.likesCount}'),
              const SizedBox(width: 16),
              _buildStat(context, Iconsax.message, '${post.commentsCount}'),
              const SizedBox(width: 16),
              _buildStat(context, Iconsax.send_2, '${post.sharesCount}'),
              const Spacer(),
              if (post.isPinned)
                const Icon(Iconsax.flag5, size: 16, color: AppColors.primary),
              if (post.hasMedia) ...[
                const SizedBox(width: 8),
                Icon(
                    post.imageUrls.isNotEmpty ? Iconsax.image : Iconsax.video,
                    size: 16,
                    color: AppColors.lavender),
              ],
            ],
          ),
          // Quick approve/reject for pending
          if (post.isPending) ...[
            const SizedBox(height: 10),
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
                      padding: const EdgeInsets.symmetric(vertical: 6),
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
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.medium),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar(UserSummary? user) {
    if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CofitImage(imageUrl: user.avatarUrl!, width: 40, height: 40),
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.bgBlush,
      child: Text(
        user?.displayName.isNotEmpty == true
            ? user!.displayName[0].toUpperCase()
            : 'U',
        style: const TextStyle(
            color: AppColors.primary, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, PostModel post) {
    Color color;
    Color bgColor;
    String label;

    if (post.isPending) {
      color = AppColors.warning;
      bgColor = AppColors.warningLight;
      label = 'Pending';
    } else if (post.isRejected) {
      color = AppColors.error;
      bgColor = AppColors.errorLight;
      label = 'Rejected';
    } else {
      color = AppColors.success;
      bgColor = AppColors.successLight;
      label = 'Approved';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.small,
      ),
      child: Text(label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color, fontWeight: FontWeight.w600, fontSize: 10)),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(count,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: AppColors.textMuted)),
      ],
    );
  }

  void _handleMenuAction(String action, PostModel post) {
    switch (action) {
      case 'approve':
        controller.approvePost(post);
        break;
      case 'reject':
        controller.showRejectDialog(post);
        break;
      case 'pin':
        controller.togglePin(post);
        break;
      case 'delete':
        controller.deletePost(post);
        break;
    }
  }
}
