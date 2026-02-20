import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../app/routes/app_routes.dart';
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
          IconButton(icon: const Icon(Iconsax.calendar), onPressed: () {}),
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
            child: const Icon(
              Iconsax.medal_star,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.getMotivationalMessage(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
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
        Text('Your Stats', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Obx(
          () => Column(
            children: [
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
          ),
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
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
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
            Text('Achievements', style: Theme.of(context).textTheme.titleLarge),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.achievements),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.isLoadingAchievements.value) {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final displayItems = controller.sortedDisplayItems;
          if (displayItems.isEmpty) {
            return Container(
              width: double.infinity,
              padding: AppPadding.cardLarge,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.large,
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                children: [
                  Icon(
                    Iconsax.medal_star,
                    size: 40,
                    color: AppColors.textDisabled,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No achievements yet',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: displayItems.take(8).length,
            itemBuilder: (context, index) {
              final item = displayItems[index];
              return _buildAchievementItem(context, item);
            },
          );
        }),
      ],
    );
  }

  Widget _buildAchievementItem(BuildContext context, dynamic item) {
    final achievement = item.achievement;
    final bool isCompleted = item.isCompleted;
    final bool isInProgress = item.isInProgress;

    Color borderColor;
    Color bgColor;
    Color iconColor;
    if (isCompleted) {
      borderColor = AppColors.success;
      bgColor = AppColors.success.withValues(alpha: 0.1);
      iconColor = AppColors.success;
    } else if (isInProgress) {
      borderColor = AppColors.primary;
      bgColor = AppColors.bgBlush;
      iconColor = AppColors.primary;
    } else {
      borderColor = AppColors.borderLight;
      bgColor = AppColors.bgCream;
      iconColor = AppColors.textDisabled;
    }

    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
              ),
              child: Icon(
                achievement.getIconData(),
                color: iconColor,
                size: 24,
              ),
            ),
            if (isCompleted)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          achievement.name,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isCompleted || isInProgress
                ? AppColors.textPrimary
                : AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildStreakCalendar(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(builder: (context) {
          const monthNames = [
            'January', 'February', 'March', 'April', 'May', 'June',
            'July', 'August', 'September', 'October', 'November', 'December',
          ];
          final now = DateTime.now();
          return Text(
            '${monthNames[now.month - 1]} ${now.year}',
            style: Theme.of(context).textTheme.titleLarge,
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          final now = DateTime.now();
          final monthStart = DateTime(now.year, now.month, 1);
          final monthEnd = DateTime(now.year, now.month + 1, 0);

          // Find the Monday on or before month start
          final firstMonday = monthStart.subtract(
            Duration(days: (monthStart.weekday - 1) % 7),
          );

          // Build Monday-to-Sunday weeks for the entire month
          final weekWidgets = <Widget>[];
          var weekStart = firstMonday;
          int weekNum = 1;

          while (!weekStart.isAfter(monthEnd)) {
            int completed = 0;
            int total = 0;

            for (int d = 0; d < 7; d++) {
              final day = weekStart.add(Duration(days: d));
              // Count all days of this week that fall within the month
              if (day.month == now.month && day.year == now.year) {
                total++;
                if (controller.workoutDates.any(
                  (wd) =>
                      wd.year == day.year &&
                      wd.month == day.month &&
                      wd.day == day.day,
                )) {
                  completed++;
                }
              }
            }

            if (total > 0) {
              if (weekWidgets.isNotEmpty) {
                weekWidgets.add(const SizedBox(height: 12));
              }
              weekWidgets.add(
                _buildWeekRow(context, 'Week $weekNum', completed, total),
              );
            }
            weekNum++;
            weekStart = weekStart.add(const Duration(days: 7));
          }

          if (weekWidgets.isEmpty) {
            return Container(
              width: double.infinity,
              padding: AppPadding.card,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.large,
                boxShadow: AppShadows.subtle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    'No workout data this month',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }

          return Container(
            padding: AppPadding.card,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.large,
              boxShadow: AppShadows.subtle,
            ),
            child: Column(children: weekWidgets),
          );
        }),
      ],
    );
  }

  Widget _buildWeekRow(
    BuildContext context,
    String label,
    int completed,
    int total,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: Theme.of(context).textTheme.labelSmall),
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
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
