import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../data/models/challenge_model.dart';

class LeaderboardTile extends StatelessWidget {
  final ChallengeLeaderboardEntry entry;
  final String targetUnit;
  final bool isCurrentUser;

  const LeaderboardTile({
    super.key,
    required this.entry,
    this.targetUnit = '',
    this.isCurrentUser = false,
  });

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppColors.bgBlush;
    }
  }

  IconData? _rankIcon(int rank) {
    if (rank <= 3) return Iconsax.cup5;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isTop3 = entry.rank <= 3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? AppColors.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: AppRadius.small,
      ),
      child: Row(
        children: [
          // Rank badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isTop3
                  ? _rankColor(entry.rank).withValues(alpha: 0.2)
                  : AppColors.bgBlush,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isTop3
                  ? Icon(_rankIcon(entry.rank),
                      size: 16, color: _rankColor(entry.rank))
                  : Text(
                      '${entry.rank}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.bgBlush,
            backgroundImage: entry.avatarUrl != null
                ? NetworkImage(entry.avatarUrl!)
                : null,
            child: entry.avatarUrl == null
                ? Text(
                    entry.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Name + progress text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isCurrentUser
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${entry.progress} $targetUnit',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),

          // Progress percentage
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: entry.progressPercentage >= 100
                  ? AppColors.success.withValues(alpha: 0.12)
                  : AppColors.bgBlush,
              borderRadius: AppRadius.pill,
            ),
            child: Text(
              '${entry.progressPercentage}%',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: entry.progressPercentage >= 100
                        ? AppColors.success
                        : AppColors.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
