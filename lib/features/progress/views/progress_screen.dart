import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/progress_controller.dart';

class ProgressScreen extends GetView<ProgressController> {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Your Progress'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.calendar),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildMotivationBanner(context),
            const SizedBox(height: 24),
            _buildStatsGrid(context),
            const SizedBox(height: 24),
            _buildBadgesSection(context),
            const SizedBox(height: 24),
            _buildStreakCalendar(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationBanner(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        gradient: AppColors.mintGradient,
        borderRadius: AppRadius.extraLarge,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.medal_star, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.getMotivationalMessage(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Keep up the amazing work!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Iconsax.activity,
                value: '${controller.totalWorkouts.value}',
                label: 'Total Workouts',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Iconsax.flash_1,
                value: '${controller.currentStreak.value}',
                label: 'Current Streak',
                color: AppColors.sunnyYellow,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Iconsax.timer_1,
                value: '${controller.totalMinutes.value}',
                label: 'Minutes Active',
                color: AppColors.lavender,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Iconsax.strongbox,
                value: '${controller.longestStreak.value}',
                label: 'Longest Streak',
                color: AppColors.mintFresh,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppRadius.small,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildBadgesSection(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() => GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: controller.badges.take(8).length,
              itemBuilder: (context, index) {
                final badge = controller.badges[index];
                return _buildBadgeItem(context, badge);
              },
            )),
      ],
    );
  }

  Widget _buildBadgeItem(BuildContext context, dynamic badge) {
    final isUnlocked = badge.isUnlocked;

    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isUnlocked ? AppColors.bgBlush : AppColors.bgCream,
            shape: BoxShape.circle,
            border: Border.all(
              color: isUnlocked ? AppColors.primary : AppColors.borderLight,
              width: 2,
            ),
          ),
          child: Icon(
            _getBadgeIcon(badge.iconName),
            color: isUnlocked ? AppColors.primary : AppColors.textDisabled,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          badge.name,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isUnlocked ? AppColors.textPrimary : AppColors.textMuted,
              ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  IconData _getBadgeIcon(String iconName) {
    switch (iconName) {
      case 'footsteps':
        return Iconsax.lovely;
      case 'calendar':
        return Iconsax.calendar_tick;
      case 'sunrise':
        return Iconsax.sun_1;
      case 'star':
        return Iconsax.star_1;
      case 'trophy':
        return Iconsax.cup;
      case 'fire':
        return Iconsax.flash_1;
      case 'medal':
        return Iconsax.medal;
      case 'crown':
        return Iconsax.crown_1;
      default:
        return Iconsax.award;
    }
  }

  Widget _buildStreakCalendar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Month',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Container(
          padding: AppPadding.card,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.large,
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            children: [
              // Simplified calendar view
              _buildWeekRow(context, 'Week 1', 5, 7),
              const SizedBox(height: 12),
              _buildWeekRow(context, 'Week 2', 4, 7),
              const SizedBox(height: 12),
              _buildWeekRow(context, 'Week 3', 3, 7),
              const SizedBox(height: 12),
              _buildWeekRow(context, 'Week 4', 0, 3),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekRow(BuildContext context, String label, int completed, int total) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        Expanded(
          child: LinearPercentIndicator(
            lineHeight: 12,
            percent: total > 0 ? (completed / total).clamp(0.0, 1.0) : 0,
            backgroundColor: AppColors.bgBlush,
            progressColor: AppColors.primary,
            barRadius: const Radius.circular(6),
            padding: EdgeInsets.zero,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$completed/$total',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
