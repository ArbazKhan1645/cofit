import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../app/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Padding(
        padding: AppPadding.screenAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text('Manage',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            _buildModuleCard(
              context,
              title: 'Challenges',
              subtitle: 'Create and manage fitness challenges',
              icon: Iconsax.cup,
              color: AppColors.sunnyYellow,
              onTap: () => Get.toNamed(AppRoutes.adminChallangeList),
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              context,
              title: 'Trainers',
              subtitle: 'Manage trainer profiles',
              icon: Iconsax.personalcard,
              color: AppColors.lavender,
              onTap: () => Get.toNamed(AppRoutes.adminTrainerList),
            ),
            const SizedBox(height: 12),
            _buildModuleCard(
              context,
              title: 'Workouts',
              subtitle: 'Create and manage workout content',
              icon: Iconsax.weight,
              color: AppColors.primary,
              onTap: () => Get.toNamed(AppRoutes.adminWorkoutList),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppPadding.cardLarge,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: AppRadius.medium,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}
