import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/cofit_avatar.dart';
import 'achievement_controller.dart';

class AchievementDetailScreen extends GetView<AchievementController> {
  const AchievementDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Achievement Details'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit_2),
            onPressed: () {
              final a = controller.selectedAchievement.value;
              if (a != null) {
                controller.initFormForEdit(a);
                Get.toNamed(AppRoutes.adminAchievementForm);
              }
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.trash, color: AppColors.error),
            onPressed: () {
              final a = controller.selectedAchievement.value;
              if (a != null) controller.deleteAchievement(a.id);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value &&
            controller.selectedAchievement.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final achievement = controller.selectedAchievement.value;
        if (achievement == null) {
          return const Center(child: Text('Achievement not found'));
        }

        return SingleChildScrollView(
          padding: AppPadding.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(context, achievement),
              const SizedBox(height: 20),
              _buildStatsCards(context),
              const SizedBox(height: 20),
              _buildUsersList(context, achievement),
              const SizedBox(height: 20),
              _buildConfiguration(context, achievement),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic achievement) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.bgBlush,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Icon(
              achievement.getIconData(),
              color: AppColors.primary,
              size: 34,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            achievement.name,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            achievement.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children: [
              _buildChip(context, achievement.typeLabel, AppColors.lavender),
              _buildChip(
                context,
                achievement.categoryLabel,
                AppColors.mintFresh,
              ),
              _buildChip(
                context,
                achievement.isActive ? 'Active' : 'Inactive',
                achievement.isActive ? AppColors.success : AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context) {
    final stats = controller.achievementStats.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Analytics',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                value: '${stats?.totalUsers ?? 0}',
                label: 'Total Users',
                icon: Iconsax.people,
                color: AppColors.lavender,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                value: '${stats?.completedCount ?? 0}',
                label: 'Completed',
                icon: Iconsax.tick_circle,
                color: AppColors.success,
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
                value: '${stats?.inProgressCount ?? 0}',
                label: 'In Progress',
                icon: Iconsax.timer_1,
                color: AppColors.skyBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                value:
                    '${((stats?.avgProgress ?? 0) * 100).toStringAsFixed(0)}%',
                label: 'Avg Progress',
                icon: Iconsax.chart_2,
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
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppRadius.small,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(BuildContext context, dynamic achievement) {
    final users = controller.achievementUsers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Users (${users.length})',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        if (users.isEmpty)
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
                Icon(Iconsax.people, size: 40, color: AppColors.textDisabled),
                const SizedBox(height: 8),
                Text(
                  'No users tracking this achievement yet',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.large,
              boxShadow: AppShadows.subtle,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: users.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: AppColors.borderLight),
              itemBuilder: (context, index) {
                final ua = users[index];
                return _buildUserRow(context, ua, achievement.targetValue);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildUserRow(BuildContext context, dynamic ua, int targetValue) {
    // Try to get user info from the joined 'users' data
    final progress = ua.currentProgress as int;
    final pct = targetValue > 0
        ? (progress / targetValue).clamp(0.0, 1.0)
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          CofitAvatar(userId: ua.userId, radius: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                LinearPercentIndicator(
                  lineHeight: 8,
                  percent: pct,
                  backgroundColor: AppColors.bgBlush,
                  progressColor: ua.isCompleted
                      ? AppColors.success
                      : AppColors.primary,
                  barRadius: const Radius.circular(4),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$progress/$targetValue',
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (ua.isCompleted)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.successLight,
                    borderRadius: AppRadius.small,
                  ),
                  child: Text(
                    'Done',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfiguration(BuildContext context, dynamic achievement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuration',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.large,
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            children: [
              _buildConfigRow(context, 'Type', achievement.typeLabel),
              _buildConfigRow(
                context,
                'Target',
                '${achievement.targetValue} ${achievement.targetUnit}',
              ),
              if (achievement.targetCategory != null &&
                  achievement.targetCategory!.isNotEmpty)
                _buildConfigRow(
                  context,
                  'Workout Category',
                  achievement.targetCategory!,
                ),
              _buildConfigRow(context, 'Category', achievement.categoryLabel),
              _buildConfigRow(
                context,
                'Sort Order',
                '${achievement.sortOrder}',
              ),
              _buildConfigRow(
                context,
                'Icon Code',
                '0x${achievement.iconCode.toRadixString(16)}',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfigRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
          ),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
