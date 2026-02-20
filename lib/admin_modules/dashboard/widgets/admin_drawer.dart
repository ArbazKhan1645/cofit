import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.bgWhite,
      shape: const RoundedRectangleBorder(),
      child: SafeArea(
        child: Column(
          children: [
            _buildDrawerHeader(context),
            const SizedBox(height: 4),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildSectionLabel(context, 'MANAGE'),
                  _buildDrawerItem(
                    context,
                    title: 'Users',
                    icon: Iconsax.people,
                    color: AppColors.peach,
                    route: AppRoutes.adminUserList,
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Community',
                    icon: Iconsax.message_text_1,
                    color: AppColors.softRose,
                    route: AppRoutes.adminCommunity,
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Challenges',
                    icon: Iconsax.cup,
                    color: AppColors.sunnyYellow,
                    route: AppRoutes.adminChallangeList,
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Achievements',
                    icon: Iconsax.medal_star,
                    color: AppColors.mintFresh,
                    route: AppRoutes.adminAchievementList,
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Trainers',
                    icon: Iconsax.personalcard,
                    color: AppColors.lavender,
                    route: AppRoutes.adminTrainerList,
                  ),
                  const SizedBox(height: 8),
                  _buildSectionLabel(context, 'CONTENT'),
                  _buildDrawerItem(
                    context,
                    title: 'Workouts',
                    icon: Iconsax.weight,
                    color: AppColors.primary,
                    route: AppRoutes.adminWorkoutList,
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'This Week',
                    icon: Iconsax.calendar_1,
                    color: AppColors.mintFresh,
                    route: AppRoutes.adminWeeklySchedule,
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Daily Plan',
                    icon: Iconsax.task_square,
                    color: AppColors.skyBlue,
                    route: AppRoutes.adminDailyPlan,
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Diet Plans',
                    icon: Iconsax.note_21,
                    color: AppColors.sunnyYellow,
                    route: AppRoutes.adminRecipeList,
                  ),
                  const SizedBox(height: 8),
                  _buildSectionLabel(context, 'SUPPORT'),
                  _buildDrawerItem(
                    context,
                    title: 'Support Tickets',
                    icon: Iconsax.message_question,
                    color: AppColors.peach,
                    route: AppRoutes.adminSupport,
                  ),
                  _buildDrawerItem(
                    context,
                    title: 'Crashlytics',
                    icon: Iconsax.danger,
                    color: AppColors.error,
                    route: AppRoutes.adminCrashlytics,
                  ),
                ],
              ),
            ),
            // Footer — "Back to App" clears admin stack & refreshes user data
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _buildBackToAppItem(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    final adminName = AuthService.to.currentUser?.fullName ?? 'Admin';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.primaryGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: AppRadius.medium,
            ),
            child: const Icon(
              Iconsax.shield_tick,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'CoFit Admin',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            adminName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 0, 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildBackToAppItem(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.medium,
        child: InkWell(
          borderRadius: AppRadius.medium,
          onTap: () {
            Get.back(); // close drawer
            // Clear entire admin route stack, dispose admin controllers,
            // navigate fresh to main — MainBinding will refresh HomeController
            Get.offAllNamed(AppRoutes.main);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.12),
                    borderRadius: AppRadius.medium,
                  ),
                  child: const Icon(Iconsax.home_2, color: AppColors.textMuted, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Back to App',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Iconsax.arrow_right_3,
                  size: 16,
                  color: AppColors.textDisabled,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.medium,
        child: InkWell(
          borderRadius: AppRadius.medium,
          onTap: () {
            Get.back(); // close drawer
            Get.toNamed(route);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: AppRadius.medium,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(
                  Iconsax.arrow_right_3,
                  size: 16,
                  color: AppColors.textDisabled,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
