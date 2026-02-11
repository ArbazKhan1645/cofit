import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../data/models/community_model.dart';

/// Elegant gradient card for challenge winning posts.
/// Rank-based gradient: Gold for #1, Silver for #2, Bronze for #3.
class WinningCard extends StatelessWidget {
  final ChallengePostMetadata metadata;

  const WinningCard({
    super.key,
    required this.metadata,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = _getRankGradient();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _getRankColor().withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Rank badge + Title + Trophy
            Row(
              children: [
                _buildRankBadge(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        metadata.challengeTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        metadata.rankLabel,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Iconsax.cup5,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Stats bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    'Progress',
                    '${metadata.totalProgress}/${metadata.targetValue}',
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  _buildStat('Unit', metadata.targetUnit),
                  if (metadata.completedAt != null) ...[
                    Container(
                      width: 1,
                      height: 24,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    _buildStat(
                      'Completed',
                      DateFormat('MMM d').format(metadata.completedAt!),
                    ),
                  ],
                ],
              ),
            ),

            // Personal message
            if (metadata.personalMessage != null &&
                metadata.personalMessage!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                metadata.personalMessage!,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRankBadge() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
      ),
      child: Center(
        child: Text(
          metadata.rankDisplay,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _getRankColor() {
    switch (metadata.userRank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return const Color(0xFFFF6B6B);
    }
  }

  LinearGradient _getRankGradient() {
    switch (metadata.userRank) {
      case 1: // Gold
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF8F00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 2: // Silver
        return const LinearGradient(
          colors: [Color(0xFFE0E0E0), Color(0xFF9E9E9E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 3: // Bronze
        return const LinearGradient(
          colors: [Color(0xFFCD7F32), Color(0xFFA0522D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default: // App primary
        return const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFFAB91)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }
}
