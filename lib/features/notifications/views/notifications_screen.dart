import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Mark all read',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: AppPadding.screen,
        children: [
          const SizedBox(height: 8),

          // Today
          _buildSectionHeader(context, 'Today'),
          const SizedBox(height: 12),
          _buildNotificationCard(
            context,
            icon: Iconsax.medal_star,
            iconColor: AppColors.sunnyYellow,
            iconBgColor: AppColors.sunnyYellow.withValues(alpha: 0.15),
            title: 'New Badge Unlocked!',
            message: 'Congratulations! You\'ve earned the "7 Day Streak" badge. Keep going!',
            time: '2 hours ago',
            isUnread: true,
          ),
          _buildNotificationCard(
            context,
            icon: Iconsax.video_play,
            iconColor: AppColors.primary,
            iconBgColor: AppColors.bgBlush,
            title: 'New Workout Available',
            message: 'Jess just dropped a new HIIT workout - "Summer Body Blast"!',
            time: '4 hours ago',
            isUnread: true,
          ),

          const SizedBox(height: 24),

          // Yesterday
          _buildSectionHeader(context, 'Yesterday'),
          const SizedBox(height: 12),
          _buildNotificationCard(
            context,
            icon: Iconsax.cup,
            iconColor: AppColors.lavender,
            iconBgColor: AppColors.lavender.withValues(alpha: 0.15),
            title: 'Challenge Update',
            message: '3 days left in the "30 Day Core Challenge". You\'re doing amazing!',
            time: 'Yesterday',
            isUnread: false,
          ),
          _buildNotificationCard(
            context,
            icon: Iconsax.heart,
            iconColor: AppColors.primary,
            iconBgColor: AppColors.bgBlush,
            title: 'Community Love',
            message: 'Sarah M. liked your progress post. Spread the positivity!',
            time: 'Yesterday',
            isUnread: false,
          ),
          _buildNotificationCard(
            context,
            icon: Iconsax.message,
            iconColor: AppColors.mintFresh,
            iconBgColor: AppColors.mintFresh.withValues(alpha: 0.15),
            title: 'New Comment',
            message: 'Emma K. commented on your post: "You\'re inspiring me!"',
            time: 'Yesterday',
            isUnread: false,
          ),

          const SizedBox(height: 24),

          // Earlier
          _buildSectionHeader(context, 'Earlier This Week'),
          const SizedBox(height: 12),
          _buildNotificationCard(
            context,
            icon: Iconsax.flash_1,
            iconColor: AppColors.sunnyYellow,
            iconBgColor: AppColors.sunnyYellow.withValues(alpha: 0.15),
            title: 'Streak Reminder',
            message: 'Don\'t break your streak! Complete a workout today to keep it going.',
            time: '3 days ago',
            isUnread: false,
          ),
          _buildNotificationCard(
            context,
            icon: Iconsax.book_1,
            iconColor: AppColors.peach,
            iconBgColor: AppColors.peach.withValues(alpha: 0.15),
            title: 'New Recipe',
            message: 'Check out the new "Post-Workout Smoothie Bowl" recipe!',
            time: '5 days ago',
            isUnread: false,
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return Container(
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
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: AppRadius.medium,
            ),
            child: Icon(icon, color: iconColor, size: 24),
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
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500,
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
                  message,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  time,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
