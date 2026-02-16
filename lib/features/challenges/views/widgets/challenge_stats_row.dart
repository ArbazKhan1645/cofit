import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class ChallengeStatsRow extends StatelessWidget {
  final List<ChallengeStat> stats;

  const ChallengeStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: stats.asMap().entries.map((entry) {
          final stat = entry.value;
          final isLast = entry.key == stats.length - 1;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: stat.color.withValues(alpha: 0.12),
                          borderRadius: AppRadius.small,
                        ),
                        child: Icon(stat.icon, color: stat.color, size: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        stat.value,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stat.label,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 1,
                    height: 40,
                    color: AppColors.borderLight,
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class ChallengeStat {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const ChallengeStat({
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppColors.primary,
  });
}
