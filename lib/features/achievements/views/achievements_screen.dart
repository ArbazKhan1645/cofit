import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../progress/controllers/progress_controller.dart';

class AchievementsScreen extends GetView<ProgressController> {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: const Text('Achievements')),
      body: Obx(() {
        if (controller.isLoadingAchievements.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final displayItems = controller.sortedDisplayItems;
        if (displayItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Iconsax.medal_star,
                  size: 64,
                  color: AppColors.textDisabled,
                ),
                const SizedBox(height: 16),
                Text(
                  'No achievements available yet',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          );
        }

        final inProgress = displayItems.where((i) => i.isInProgress).toList();
        final completed = displayItems.where((i) => i.isCompleted).toList();
        final locked = displayItems.where((i) => i.isLocked).toList();

        return SingleChildScrollView(
          padding: AppPadding.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Summary card
              _buildSummaryCard(context, displayItems.length),
              const SizedBox(height: 24),

              // In Progress section
              if (inProgress.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'In Progress',
                  '${inProgress.length}',
                  AppColors.primary,
                ),
                const SizedBox(height: 12),
                ...inProgress.map(
                  (item) => _buildAchievementCard(context, item),
                ),
                const SizedBox(height: 20),
              ],

              // Completed section
              if (completed.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'Completed',
                  '${completed.length}',
                  AppColors.success,
                ),
                const SizedBox(height: 12),
                ...completed.map(
                  (item) => _buildAchievementCard(context, item),
                ),
                const SizedBox(height: 20),
              ],

              // Locked section
              if (locked.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'Locked',
                  '${locked.length}',
                  AppColors.textMuted,
                ),
                const SizedBox(height: 12),
                ...locked.map((item) => _buildAchievementCard(context, item)),
              ],

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int total) {
    final completed = controller.completedCount;
    final percent = total > 0 ? completed / total : 0.0;

    return Container(
      width: double.infinity,
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.extraLarge,
        boxShadow: AppShadows.primaryGlow,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
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
                Text(
                  '$completed of $total completed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                LinearPercentIndicator(
                  lineHeight: 8,
                  percent: percent.clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  progressColor: Colors.white,
                  barRadius: const Radius.circular(4),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(percent * 100).toInt()}% complete',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String count,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: AppRadius.small,
          ),
          child: Text(
            count,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(BuildContext context, dynamic item) {
    final achievement = item.achievement;
    final bool isCompleted = item.isCompleted;
    final bool isInProgress = item.isInProgress;
    final double progress = item.progressPercentage;
    final int current = item.userProgress?.currentProgress ?? 0;
    final int target = achievement.targetValue;

    Color accentColor;
    if (isCompleted) {
      accentColor = AppColors.success;
    } else if (isInProgress) {
      accentColor = AppColors.primary;
    } else {
      accentColor = AppColors.textDisabled;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
        border: isCompleted
            ? Border.all(
                color: AppColors.success.withValues(alpha: 0.3),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          // Icon circle
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(
              achievement.getIconData(),
              color: accentColor,
              size: 24,
            ),
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
                        achievement.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isCompleted || isInProgress
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      ),
                    if (!isCompleted && !isInProgress)
                      const Icon(
                        Iconsax.lock,
                        color: AppColors.textDisabled,
                        size: 18,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isInProgress || isCompleted) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearPercentIndicator(
                          lineHeight: 6,
                          percent: progress,
                          backgroundColor: accentColor.withValues(alpha: 0.12),
                          progressColor: accentColor,
                          barRadius: const Radius.circular(3),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '$current/$target',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
