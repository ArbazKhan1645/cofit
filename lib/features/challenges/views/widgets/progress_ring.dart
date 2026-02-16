import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../core/theme/app_colors.dart';

class ProgressRing extends StatelessWidget {
  final double percent; // 0.0 - 1.0
  final double radius;
  final double lineWidth;
  final Color? progressColor;
  final Color? backgroundColor;
  final Widget? center;
  final bool showPercentText;

  const ProgressRing({
    super.key,
    required this.percent,
    this.radius = 60,
    this.lineWidth = 10,
    this.progressColor,
    this.backgroundColor,
    this.center,
    this.showPercentText = true,
  });

  @override
  Widget build(BuildContext context) {
    final pColor = progressColor ?? AppColors.primary;
    final bgColor =
        backgroundColor ?? pColor.withValues(alpha: 0.15);

    return CircularPercentIndicator(
      radius: radius,
      lineWidth: lineWidth,
      percent: percent.clamp(0.0, 1.0),
      center: center ??
          (showPercentText
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(percent * 100).toInt()}%',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: pColor,
                          ),
                    ),
                    Text(
                      'complete',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                )
              : null),
      progressColor: pColor,
      backgroundColor: bgColor,
      circularStrokeCap: CircularStrokeCap.round,
      animation: true,
      animationDuration: 1200,
    );
  }
}
