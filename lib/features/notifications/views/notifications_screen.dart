import 'package:cofit_collective/data/models/notification_model.dart';
import 'package:cofit_collective/features/notifications/controller/notification_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller must already be Put via binding or main nav
    final controller = Get.find<NotificationController>();

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Obx(() {
            if (!controller.hasUnread) return const SizedBox.shrink();
            return TextButton(
              onPressed: controller.markAllAsRead,
              child: Text(
                'Mark all read',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.primary),
              ),
            );
          }),
        ],
      ),
      body: Obx(() => _buildBody(context, controller)),
    );
  }

  Widget _buildBody(BuildContext context, NotificationController controller) {
    // ── Loading state (initial fetch only) ──
    if (controller.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppColors.primary),
        ),
      );
    }

    // ── Error state ──
    if (controller.hasError && controller.notifications.isEmpty) {
      return _ErrorView(
        message: controller.errorMessage.value ?? 'Something went wrong',
        onRetry: controller.refresh,
      );
    }

    // ── Empty state ──
    if (controller.notifications.isEmpty) {
      return const _EmptyView();
    }

    // ── Notification list ──
    final groups = controller.groupedNotifications;
    final sectionKeys = groups.keys.toList();

    return RefreshIndicator(
      onRefresh: controller.refresh,
      color: AppColors.primary,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          // Trigger load-more when 200px from bottom
          if (!controller.isLoadingMore &&
              controller.hasMore.value &&
              scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200) {
            controller.loadMore();
          }
          return false;
        },
        child: ListView.builder(
          padding: AppPadding.screen,
          itemCount:
              _totalItemCount(groups, sectionKeys) +
              (controller.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            return _buildItem(context, index, groups, sectionKeys, controller);
          },
        ),
      ),
    );
  }

  /// Calculates total list items: section headers + notification cards
  int _totalItemCount(
    Map<String, List<NotificationModel>> groups,
    List<String> keys,
  ) {
    int count = 0;
    for (final key in keys) {
      count += 1 + (groups[key]?.length ?? 0); // header + items
    }
    return count;
  }

  Widget _buildItem(
    BuildContext context,
    int index,
    Map<String, List<NotificationModel>> groups,
    List<String> sectionKeys,
    NotificationController controller,
  ) {
    // Loading-more spinner at the very bottom
    final total = _totalItemCount(groups, sectionKeys);
    if (index == total) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      );
    }

    // Walk through sections to find what this index maps to
    int cursor = 0;
    for (final sectionKey in sectionKeys) {
      final items = groups[sectionKey]!;

      // Section header
      if (index == cursor) {
        return Padding(
          padding: EdgeInsets.only(top: cursor == 0 ? 8 : 24, bottom: 12),
          child: _SectionHeader(title: sectionKey),
        );
      }
      cursor++;

      // Notification cards
      if (index < cursor + items.length) {
        final notification = items[index - cursor];
        return _SwipeableNotificationCard(
          notification: notification,
          onTap: () => controller.onNotificationTap(notification),
          onDismissed: () => controller.deleteNotification(notification.id),
        );
      }
      cursor += items.length;
    }

    return const SizedBox.shrink();
  }
}

// ─── SECTION HEADER ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        color: AppColors.textMuted,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// ─── SWIPEABLE CARD ───────────────────────────────────────────────────────────

class _SwipeableNotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _SwipeableNotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      background: _DismissBackground(),
      onDismissed: (_) => onDismissed(),
      child: _NotificationCard(notification: notification, onTap: onTap),
    );
  }
}

class _DismissBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade400,
        borderRadius: AppRadius.large,
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Icon(Iconsax.trash, color: Colors.white, size: 22),
    );
  }
}

// ─── NOTIFICATION CARD ────────────────────────────────────────────────────────

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final iconData = _iconForType(notification.type);
    final iconColor = _colorForType(notification.type);
    final iconBgColor = iconColor.withValues(alpha: 0.15);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread ? Colors.white : Colors.white.withValues(alpha: 0.7),
          borderRadius: AppRadius.large,
          boxShadow: isUnread ? AppShadows.subtle : null,
          border: isUnread
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.2))
              : Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: AppRadius.medium,
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.timeAgo,
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
    );
  }

  // ── Icon mapping ──────────────────────────────────────────────────────────

  IconData _iconForType(NotificationType type) {
    switch (type) {
      case NotificationType.workoutReminder:
      case NotificationType.workoutCompleted:
      case NotificationType.newWorkoutAvailable:
      case NotificationType.weeklyWorkoutsUpdated:
        return Iconsax.video_play;

      case NotificationType.challengeStarted:
      case NotificationType.challengeEnding:
      case NotificationType.challengeCompleted:
      case NotificationType.challengeRankUpdate:
      case NotificationType.newChallengeAvailable:
        return Iconsax.cup;

      case NotificationType.badgeUnlocked:
        return Iconsax.medal_star;

      case NotificationType.streakMilestone:
        return Iconsax.flash_1;

      case NotificationType.progressMilestone:
        return Iconsax.chart;

      case NotificationType.newFollower:
      case NotificationType.postLiked:
        return Iconsax.heart;

      case NotificationType.postCommented:
      case NotificationType.mentionedInPost:
        return Iconsax.message;

      case NotificationType.postShared:
        return Iconsax.share;

      case NotificationType.recipeShared:
        return Iconsax.book_1;

      case NotificationType.subscriptionRenewal:
      case NotificationType.subscriptionExpiring:
      case NotificationType.subscriptionExpired:
      case NotificationType.paymentFailed:
        return Iconsax.card;

      case NotificationType.welcomeMessage:
        return Iconsax.gift;

      case NotificationType.promotionalOffer:
        return Iconsax.tag;

      default:
        return Iconsax.notification;
    }
  }

  Color _colorForType(NotificationType type) {
    switch (type) {
      case NotificationType.badgeUnlocked:
      case NotificationType.streakMilestone:
        return AppColors.sunnyYellow;

      case NotificationType.challengeStarted:
      case NotificationType.challengeEnding:
      case NotificationType.challengeCompleted:
      case NotificationType.challengeRankUpdate:
      case NotificationType.newChallengeAvailable:
        return AppColors.lavender;

      case NotificationType.postCommented:
      case NotificationType.mentionedInPost:
      case NotificationType.recipeShared:
        return AppColors.mintFresh;

      case NotificationType.subscriptionExpiring:
      case NotificationType.subscriptionExpired:
      case NotificationType.paymentFailed:
        return Colors.red.shade400;

      case NotificationType.promotionalOffer:
        return AppColors.peach;

      default:
        return AppColors.primary;
    }
  }
}

// ─── EMPTY STATE ──────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.bgBlush,
              borderRadius: AppRadius.large,
            ),
            child: const Icon(
              Iconsax.notification,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "You're all caught up!",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            "No new notifications right now.",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// ─── ERROR STATE ──────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppPadding.screen,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.warning_2, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
