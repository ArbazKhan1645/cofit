import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'challange_controller.dart';

class ChallangeDetailScreen extends GetView<ChallangeController> {
  const ChallangeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Challenge Details'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.edit_2),
            onPressed: () {
              final c = controller.selectedChallenge.value;
              if (c != null) {
                controller.initFormForEdit(c);
                Get.toNamed(AppRoutes.adminChallangeForm);
              }
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.trash, color: AppColors.error),
            onPressed: () {
              final c = controller.selectedChallenge.value;
              if (c != null) controller.deleteChallenge(c.id);
            },
          ),
        ],
      ),
      body: Obx(() {
        final challenge = controller.selectedChallenge.value;
        final stats = controller.challengeStats.value;

        if (controller.isLoadingDetail.value && challenge == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (challenge == null) {
          return const Center(child: Text('Challenge not found'));
        }

        final df = DateFormat('MMM d, yyyy');

        return RefreshIndicator(
          onRefresh: () => controller.loadChallengeDetail(challenge.id),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppPadding.screenAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Challenge Header
                _buildHeader(context, challenge, df),
                const SizedBox(height: 16),

                // Stats Cards
                if (stats != null) _buildStatsCards(context, stats),
                if (stats != null) const SizedBox(height: 16),

                // Leaderboard
                _buildLeaderboard(context, challenge),
                const SizedBox(height: 16),

                // Participants
                _buildParticipants(context, challenge),
                const SizedBox(height: 16),

                // Configuration
                _buildConfiguration(context, challenge),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHeader(
      BuildContext context, dynamic challenge, DateFormat df) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (challenge.imageUrl != null && challenge.imageUrl!.isNotEmpty)
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(challenge.imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              height: 100,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: Center(
                child: Icon(Iconsax.cup5,
                    size: 40,
                    color: Colors.white.withValues(alpha: 0.5)),
              ),
            ),
          Padding(
            padding: AppPadding.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                // Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _chip(
                      context,
                      challenge.status[0].toUpperCase() +
                          challenge.status.substring(1),
                      challenge.status == 'active'
                          ? AppColors.success
                          : challenge.status == 'upcoming'
                              ? AppColors.info
                              : AppColors.textMuted,
                    ),
                    _chip(
                      context,
                      challenge.challengeType.replaceAll('_', ' '),
                      AppColors.lavender,
                    ),
                    _chip(
                      context,
                      challenge.visibility,
                      AppColors.skyBlue,
                    ),
                    if (challenge.isFeatured)
                      _chip(context, 'Featured', AppColors.sunnyYellow,
                          textColor: AppColors.textPrimary),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${df.format(challenge.startDate)} - ${df.format(challenge.endDate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

  Widget _buildStatsCards(BuildContext context, dynamic stats) {
    return Row(
      children: [
        Expanded(
            child: _statCard(context, 'Participants',
                '${stats.totalParticipants}', Iconsax.people, AppColors.skyBlue)),
        const SizedBox(width: 10),
        Expanded(
            child: _statCard(context, 'Completed', '${stats.completedCount}',
                Iconsax.tick_circle, AppColors.success)),
        const SizedBox(width: 10),
        Expanded(
            child: _statCard(
                context,
                'Rate',
                '${(stats.completionRate * 100).toInt()}%',
                Iconsax.chart,
                AppColors.primary)),
        const SizedBox(width: 10),
        Expanded(
            child: _statCard(
                context,
                'Avg Progress',
                '${(stats.avgProgress * 100).toInt()}%',
                Iconsax.activity,
                AppColors.lavender)),
      ],
    );
  }

  Widget _statCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.medium,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: AppRadius.small,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context, dynamic challenge) {
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
          Text('Leaderboard',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.leaderboard.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text('No participants yet',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textMuted)),
                ),
              );
            }

            return Column(
              children: controller.leaderboard.map((entry) {
                final isCompleted = entry.progressPercentage >= 100;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      // Rank
                      SizedBox(
                        width: 30,
                        child: Text(
                          '#${entry.rank}',
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: entry.rank <= 3
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                              ),
                        ),
                      ),
                      // Avatar
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.bgBlush,
                        backgroundImage: entry.avatarUrl != null
                            ? NetworkImage(entry.avatarUrl!)
                            : null,
                        child: entry.avatarUrl == null
                            ? Text(entry.displayName[0].toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary))
                            : null,
                      ),
                      const SizedBox(width: 10),
                      // Name
                      Expanded(
                        child: Text(
                          entry.displayName,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Progress bar
                      SizedBox(
                        width: 80,
                        child: ClipRRect(
                          borderRadius: AppRadius.pill,
                          child: LinearProgressIndicator(
                            value:
                                (entry.progressPercentage / 100).clamp(0.0, 1.0),
                            minHeight: 6,
                            backgroundColor: AppColors.bgBlush,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isCompleted
                                  ? AppColors.success
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Percentage
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${entry.progressPercentage}%',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isCompleted
                                    ? AppColors.success
                                    : AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildParticipants(BuildContext context, dynamic challenge) {
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
          Obx(() => Text(
                'Participants (${controller.participants.length})',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              )),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.participants.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text('No participants yet',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textMuted)),
                ),
              );
            }

            final targetValue = challenge.targetValue as int;

            return Column(
              children: controller.participants.map((p) {
                final progress = targetValue > 0
                    ? (p.currentProgress / targetValue).clamp(0.0, 1.0)
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.bgBlush,
                        backgroundImage: p.avatarUrl != null
                            ? NetworkImage(p.avatarUrl!)
                            : null,
                        child: p.avatarUrl == null
                            ? Text(p.displayName[0].toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary))
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    p.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (p.isCompleted)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.successLight,
                                      borderRadius: AppRadius.pill,
                                    ),
                                    child: Text('Completed',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppColors.success,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                            )),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: AppRadius.pill,
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 5,
                                      backgroundColor: AppColors.bgBlush,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        p.isCompleted
                                            ? AppColors.success
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${p.currentProgress}/$targetValue',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildConfiguration(BuildContext context, dynamic challenge) {
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
          Text('Configuration',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _configRow(context, 'Type',
              challenge.challengeType.toString().replaceAll('_', ' ')),
          _configRow(context, 'Target', '${challenge.targetValue}'),
          _configRow(context, 'Unit', challenge.targetUnit),
          if (challenge.targetCategory != null)
            _configRow(context, 'Category', challenge.targetCategory!),
          if (challenge.maxParticipants != null)
            _configRow(
                context, 'Max Participants', '${challenge.maxParticipants}'),
          _configRow(context, 'Visibility', challenge.visibility),
          _configRow(
              context, 'Featured', challenge.isFeatured ? 'Yes' : 'No'),
          _configRow(
              context, 'Rules', '${challenge.rules.length} rule(s)'),
          _configRow(
              context, 'Prizes', '${challenge.prizes.length} prize(s)'),
        ],
      ),
    );
  }

  Widget _configRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textMuted)),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, Color color,
      {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color == AppColors.sunnyYellow ? textColor : color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
