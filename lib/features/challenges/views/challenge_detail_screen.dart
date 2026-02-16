import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/challenge_controller.dart';
import 'widgets/challenge_stats_row.dart';
import 'widgets/leaderboard_tile.dart';
import 'widgets/prize_card.dart';
import 'widgets/progress_ring.dart';

class ChallengeDetailScreen extends GetView<ChallengeController> {
  const ChallengeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: Obx(() {
        final challenge = controller.selectedChallenge.value;

        if (controller.isLoadingDetail.value && challenge == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (challenge == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.warning_2,
                    size: 48, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text('Challenge not found',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: AppColors.textMuted)),
              ],
            ),
          );
        }

        final df = DateFormat('MMM d, yyyy');

        return CustomScrollView(
          slivers: [
            // SliverAppBar with hero image
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image or gradient
                    if (challenge.imageUrl != null &&
                        challenge.imageUrl!.isNotEmpty)
                      Image.network(
                        challenge.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: const BoxDecoration(
                            gradient: AppColors.primaryGradient,
                          ),
                        ),
                      )
                    else
                      Container(
                        decoration: const BoxDecoration(
                          gradient: AppColors.sunsetGradient,
                        ),
                      ),
                    // Gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                    // Decorative circles
                    Positioned(
                      right: -40,
                      top: -40,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    // Bottom content
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status + type chips
                          Row(
                            children: [
                              _buildChip(
                                context,
                                challenge.status[0].toUpperCase() +
                                    challenge.status.substring(1),
                                challenge.status == 'active'
                                    ? AppColors.success
                                    : AppColors.info,
                              ),
                              const SizedBox(width: 8),
                              _buildChip(
                                context,
                                _typeLabel(challenge.challengeType),
                                Colors.white.withValues(alpha: 0.25),
                                textColor: Colors.white,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            challenge.title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: AppPadding.screenAll,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Container(
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
                          Text(
                            challenge.description,
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.5,
                                    ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${df.format(challenge.startDate)} - ${df.format(challenge.endDate)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
                    const SizedBox(height: 16),

                    // Stats Row
                    ChallengeStatsRow(
                      stats: [
                        ChallengeStat(
                          icon: Iconsax.chart,
                          value: '${challenge.targetValue}',
                          label: challenge.targetUnit,
                          color: AppColors.primary,
                        ),
                        ChallengeStat(
                          icon: Iconsax.calendar_1,
                          value: '${challenge.durationDays}',
                          label: 'days',
                          color: AppColors.lavender,
                        ),
                        ChallengeStat(
                          icon: Iconsax.people,
                          value: '${challenge.participantCount}',
                          label: 'joined',
                          color: AppColors.skyBlue,
                        ),
                        ChallengeStat(
                          icon: Iconsax.clock,
                          value: challenge.hasEnded
                              ? '0'
                              : '${challenge.daysRemaining}',
                          label: 'days left',
                          color: AppColors.mintFresh,
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 100.ms, duration: 400.ms)
                        .slideY(begin: 0.05),
                    const SizedBox(height: 16),

                    // Progress Section (if joined)
                    if (challenge.isJoined) ...[
                      _buildProgressSection(context, challenge),
                      const SizedBox(height: 16),
                    ],

                    // Rules Section
                    if (challenge.rules.isNotEmpty) ...[
                      _buildRulesSection(context, challenge),
                      const SizedBox(height: 16),
                    ],

                    // Prizes Section
                    if (challenge.prizes.isNotEmpty) ...[
                      _buildPrizesSection(context, challenge),
                      const SizedBox(height: 16),
                    ],

                    // Leaderboard Section
                    _buildLeaderboardSection(context, challenge),
                    const SizedBox(height: 100), // space for bottom button
                  ],
                ),
              ),
            ),
          ],
        );
      }),

      // Bottom action button
      bottomNavigationBar: Obx(() {
        final challenge = controller.selectedChallenge.value;
        if (challenge == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: AppShadows.bottomNav,
          ),
          child: challenge.isJoined
              ? _buildLeaveButton(context, challenge)
              : _buildJoinButton(context, challenge),
        );
      }),
    );
  }

  // ============================================
  // SECTIONS
  // ============================================

  Widget _buildProgressSection(BuildContext context, dynamic challenge) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.primaryGlow,
      ),
      child: Row(
        children: [
          ProgressRing(
            percent: challenge.progressPercentage,
            radius: 50,
            lineWidth: 8,
            progressColor: Colors.white,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(challenge.progressPercentage * 100).toInt()}%',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${challenge.userProgress} / ${challenge.targetValue} ${challenge.targetUnit}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
                const SizedBox(height: 8),
                if (controller.myRank.value != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text(
                      'Rank #${controller.myRank.value}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.05);
  }

  Widget _buildRulesSection(BuildContext context, dynamic challenge) {
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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.bgBlush,
                  borderRadius: AppRadius.small,
                ),
                child: const Icon(Iconsax.document_text,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                'Rules',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(challenge.rules.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10,
                                ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      challenge.rules[index],
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _buildPrizesSection(BuildContext context, dynamic challenge) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.sunnyYellow.withValues(alpha: 0.3),
                borderRadius: AppRadius.small,
              ),
              child:
                  const Icon(Iconsax.gift, color: Color(0xFFFFA000), size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              'Prizes',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: challenge.prizes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return PrizeCard(prize: challenge.prizes[index]);
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 350.ms, duration: 400.ms).slideY(begin: 0.05);
  }

  Widget _buildLeaderboardSection(BuildContext context, dynamic challenge) {
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
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.bgLavender,
                  borderRadius: AppRadius.small,
                ),
                child: const Icon(Iconsax.ranking,
                    color: AppColors.lavender, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                'Leaderboard',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Obx(() => Text(
                    '${controller.leaderboard.length} participants',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  )),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (controller.isLoadingLeaderboard.value) {
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            if (controller.leaderboard.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'No participants yet',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ),
              );
            }

            // Show top 10 entries
            final entries = controller.leaderboard.take(10).toList();
            final currentUserId = controller.myRank.value;

            return Column(
              children: [
                ...entries.map((entry) => LeaderboardTile(
                      entry: entry,
                      targetUnit: challenge.targetUnit,
                      isCurrentUser: currentUserId != null &&
                          entry.rank == currentUserId,
                    )),
                // If user's rank is beyond top 10, show separator + their entry
                if (controller.myRank.value != null &&
                    controller.myRank.value! > 10) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(
                            child: Divider(color: AppColors.borderLight)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('...',
                              style:
                                  TextStyle(color: AppColors.textMuted)),
                        ),
                        Expanded(
                            child: Divider(color: AppColors.borderLight)),
                      ],
                    ),
                  ),
                  // Find user's entry
                  ...controller.leaderboard
                      .where((e) =>
                          e.rank == controller.myRank.value)
                      .map((entry) => LeaderboardTile(
                            entry: entry,
                            targetUnit: challenge.targetUnit,
                            isCurrentUser: true,
                          )),
                ],
              ],
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.05);
  }

  // ============================================
  // ACTION BUTTONS
  // ============================================

  Widget _buildJoinButton(BuildContext context, dynamic challenge) {
    final hasEnded = challenge.hasEnded;
    final isFull = challenge.hasLimitedSpots &&
        (challenge.remainingSpots ?? 0) <= 0;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Obx(() => ElevatedButton(
            onPressed: (hasEnded || isFull || controller.isJoining.value)
                ? null
                : () => controller.joinChallenge(challenge.id),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.large,
              ),
              elevation: 0,
            ),
            child: controller.isJoining.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.flag, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        hasEnded
                            ? 'Challenge Ended'
                            : isFull
                                ? 'Challenge Full'
                                : 'Join Challenge',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
          )),
    );
  }

  Widget _buildLeaveButton(BuildContext context, dynamic challenge) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Obx(() => OutlinedButton(
            onPressed: controller.isLeaving.value
                ? null
                : () => _showLeaveConfirmation(context, challenge.id),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.borderMedium),
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.large,
              ),
            ),
            child: controller.isLeaving.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Text(
                    'Leave Challenge',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
          )),
    );
  }

  void _showLeaveConfirmation(BuildContext context, String challengeId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Leave Challenge?'),
        content: const Text(
            'Your progress will be lost. Are you sure you want to leave?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.leaveChallenge(challengeId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child:
                const Text('Leave', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ============================================
  // HELPERS
  // ============================================

  Widget _buildChip(BuildContext context, String label, Color color,
      {Color textColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'workout_count':
        return 'Workout Count';
      case 'streak':
        return 'Streak';
      case 'minutes':
        return 'Minutes';
      case 'calories':
        return 'Calories';
      case 'specific_category':
        return 'Category';
      default:
        return type;
    }
  }
}
