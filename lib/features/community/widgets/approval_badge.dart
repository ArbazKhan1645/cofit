import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_colors.dart';

/// Small pill badge for pending/rejected post status.
/// Only shown on user's own posts that aren't approved.
class ApprovalBadge extends StatelessWidget {
  final String status;
  final String? rejectionReason;

  const ApprovalBadge({
    super.key,
    required this.status,
    this.rejectionReason,
  });

  @override
  Widget build(BuildContext context) {
    if (status == 'approved') return const SizedBox.shrink();

    final isPending = status == 'pending';
    final color = isPending ? AppColors.warning : AppColors.error;
    final bgColor = isPending ? AppColors.warningLight : AppColors.errorLight;
    final icon = isPending ? Iconsax.clock : Iconsax.close_circle;
    final label = isPending ? 'Pending Approval' : 'Rejected';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (!isPending && rejectionReason != null && rejectionReason!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              rejectionReason!,
              style: TextStyle(
                color: AppColors.error.withValues(alpha: 0.8),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
