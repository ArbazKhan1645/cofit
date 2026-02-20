import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/services/supabase_service.dart';
import '../../../shared/widgets/cofit_image.dart';
import '../../../shared/widgets/cofit_avatar.dart';
import '../../../shared/widgets/full_screen_image_viewer.dart';
import '../../../data/models/community_model.dart';
import '../controllers/community_controller.dart';
import '../widgets/approval_badge.dart';
import '../widgets/winning_card.dart';
import '../widgets/workout_recipe_card.dart';
import '../widgets/user_profile_sheet.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final CommunityController controller = Get.find<CommunityController>();
  bool _commentsLoaded = false;

  @override
  void initState() {
    super.initState();
    // Load comments only once when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_commentsLoaded && controller.currentPost.value != null) {
        _commentsLoaded = true;
        controller.loadComments(controller.currentPost.value!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Post'),
        actions: [
          Obx(() {
            final post = controller.currentPost.value;
            if (post != null && post.userId == SupabaseService.to.userId) {
              return PopupMenuButton<String>(
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
                        Icon(Iconsax.trash, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Delete Post', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        final post = controller.currentPost.value;
        if (post == null) {
          return const Center(child: Text('Post not found'));
        }

        return Column(
          children: [
            // Post content
            Expanded(
              child: SingleChildScrollView(
                padding: AppPadding.screenAll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Post card
                    _buildPostCard(context, post),
                    const SizedBox(height: 24),

                    // Comments section
                    _buildCommentsSection(context, post),
                  ],
                ),
              ),
            ),

            // Comment input
            _buildCommentInput(context, post.id),
          ],
        );
      }),
    );
  }

  Widget _buildPostCard(BuildContext context, PostModel post) {
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
                GestureDetector(
                  onTap: () {
                    if (post.authorAvatar != null &&
                        post.authorAvatar!.isNotEmpty) {
                      FullScreenImageViewer.open(context, post.authorAvatar!);
                    }
                  },
                  child: CofitAvatar(
                    imageUrl: post.authorAvatar,
                    userId: post.author?.id,
                    userName: post.authorName,
                    radius: 24,
                  ),
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
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Approval badge
          if (post.userId == SupabaseService.to.userId && !post.isApproved)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ApprovalBadge(
                status: post.approvalStatus,
                rejectionReason: post.rejectionReason,
              ),
            ),

          // Content - dispatch by post type
          _buildPostContent(context, post),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Actions
          Row(
            children: [
              _buildActionButton(
                context,
                icon: post.isLikedByMe ? Iconsax.heart5 : Iconsax.heart,
                label: '${post.likesCount} Likes',
                color: post.isLikedByMe ? AppColors.primary : null,
                onTap: () => controller.toggleLikePost(post.id),
              ),
              const SizedBox(width: 24),
              _buildActionButton(
                context,
                icon: Iconsax.message,
                label: '${post.commentsCount}',
                onTap: () {},
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
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
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
              const SizedBox(height: 12),
              Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
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
              const SizedBox(height: 12),
              Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ],
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (post.content.isNotEmpty)
          Text(post.content, style: Theme.of(context).textTheme.bodyLarge),
        if (post.imageUrls.isNotEmpty) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => FullScreenImageViewer.open(
              context,
              post.imageUrls.first,
            ),
            child: CofitImage(imageUrl: post.imageUrls.first, width: double.infinity, borderRadius: AppRadius.medium),
          ),
        ],
      ],
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
          Icon(icon, size: 22, color: color ?? AppColors.textMuted),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: color ?? AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCommentsSection(BuildContext context, PostModel post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Iconsax.message_text_1,
              size: 20,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Comments',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 8),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.small,
                  ),
                  child: Text(
                    '${controller.postComments.length}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                )),
          ],
        ),
        const SizedBox(height: 16),

        // Comments list
        Obx(() {
          if (controller.isLoadingComments.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.postComments.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Iconsax.message_question,
                      size: 48,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No comments yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Be the first to comment!',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: controller.postComments.asMap().entries.map((entry) {
              final index = entry.key;
              final comment = entry.value;
              return _buildCommentItem(context, comment, post.id)
                  .animate()
                  .fadeIn(delay: (index * 50).ms, duration: 300.ms)
                  .slideX(begin: 0.1, end: 0);
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildCommentItem(BuildContext context, CommentModel comment, String postId) {
    final isMyComment = comment.userId == SupabaseService.to.userId;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.medium,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CofitAvatar(
                imageUrl: comment.author?.avatarUrl,
                userId: comment.author?.id,
                userName: comment.author?.displayName,
                radius: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.author?.displayName ?? 'User',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      comment.timeAgo,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
              ),
              if (isMyComment)
                GestureDetector(
                  onTap: () => _showDeleteCommentConfirmation(
                    context,
                    comment.id,
                    postId,
                  ),
                  child: Icon(
                    Iconsax.trash,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment.content,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context, String postId) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.bgBlush,
                borderRadius: AppRadius.large,
              ),
              child: TextField(
                controller: controller.commentController,
                decoration: InputDecoration(
                  hintText: 'Write a comment...',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  border: InputBorder.none,
                ),
                maxLines: null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Obx(() => GestureDetector(
                onTap: controller.isPostingComment.value
                    ? null
                    : () => controller.addComment(postId),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: controller.isPostingComment.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Iconsax.send_1,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              )),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deletePost(postId);
              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCommentConfirmation(
    BuildContext context,
    String commentId,
    String postId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteComment(commentId, postId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
