import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/challenge_model.dart';

class ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback onTap;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onTap,
  });

  String _typeLabel(String type) {
    switch (type) {
      case 'workout_count':
        return 'Workouts';
      case 'streak':
        return 'Streak';
      case 'minutes':
        return 'Minutes';
      case 'calories':
        return 'Calories';
      case 'specific_category':
        return challenge.targetCategory?.replaceAll('_', ' ') ?? 'Category';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            if (challenge.imageUrl != null &&
                challenge.imageUrl!.isNotEmpty)
              Stack(
                children: [
                  // Challenge image
                  Container(
                    height: 130,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.bgBlush,
                      image: DecorationImage(
                        image: NetworkImage(challenge.imageUrl!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                  // Status chip
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: challenge.status == 'active'
                            ? AppColors.success
                            : AppColors.info,
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        challenge.status[0].toUpperCase() +
                            challenge.status.substring(1),
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  ),
                  // Featured badge
                  if (challenge.isFeatured)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.sunnyYellow,
                          borderRadius: AppRadius.pill,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.star5,
                                size: 12, color: AppColors.textPrimary),
                            SizedBox(width: 4),
                            Text('Featured',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                )),
                          ],
                        ),
                      ),
                    ),
                ],
              )
            else
              // No image — colored header
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: Stack(
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: -10,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                    ),
                    // Center icon
                    Center(
                      child: Icon(
                        Iconsax.cup5,
                        color: Colors.white.withValues(alpha: 0.6),
                        size: 36,
                      ),
                    ),
                    // Status chip
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: AppRadius.pill,
                        ),
                        child: Text(
                          challenge.status[0].toUpperCase() +
                              challenge.status.substring(1),
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Content
            Padding(
              padding: AppPadding.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    challenge.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Description
                  Text(
                    challenge.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Info row
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        Iconsax.people,
                        '${challenge.participantCount}',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        context,
                        Iconsax.calendar_1,
                        challenge.hasEnded
                            ? 'Ended'
                            : '${challenge.daysRemaining}d left',
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        context,
                        Iconsax.chart,
                        '${challenge.targetValue} ${_typeLabel(challenge.challengeType)}',
                      ),
                    ],
                  ),

                  // Progress bar (if joined)
                  if (challenge.isJoined) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: AppRadius.pill,
                      child: LinearProgressIndicator(
                        value: challenge.progressPercentage,
                        minHeight: 6,
                        backgroundColor: AppColors.bgBlush,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          challenge.isCompleted
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${challenge.userProgress}/${challenge.targetValue}',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                        ),
                        if (challenge.isCompleted)
                          Text(
                            'Completed!',
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppColors.success,
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
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
