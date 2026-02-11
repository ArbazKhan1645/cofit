import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/navigation_controller.dart';
import 'home_screen.dart';
import '../../workouts/views/workouts_screen.dart';
import '../../progress/views/progress_screen.dart';
import '../../community/views/community_screen.dart';
import '../../profile/views/profile_screen.dart';

class MainNavigationScreen extends GetView<NavigationController> {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeScreen(),
              WorkoutsScreen(),
              ProgressScreen(),
              CommunityScreen(),
              ProfileScreen(),
            ],
          )),
      bottomNavigationBar: Obx(() => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: AppShadows.bottomNav,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      index: 0,
                      icon: Iconsax.home_2,
                      activeIcon: Iconsax.home_15,
                      label: 'Home',
                    ),
                    _buildNavItem(
                      index: 1,
                      icon: Iconsax.weight,
                      activeIcon: Iconsax.weight,
                      label: 'Workouts',
                    ),
                    _buildNavItem(
                      index: 2,
                      icon: Iconsax.chart_2,
                      activeIcon: Iconsax.chart_21,
                      label: 'Progress',
                    ),
                    _buildNavItem(
                      index: 3,
                      icon: Iconsax.people,
                      activeIcon: Iconsax.people,
                      label: 'Community',
                    ),
                    _buildNavItem(
                      index: 4,
                      icon: Iconsax.profile_circle,
                      activeIcon: Iconsax.profile_circle,
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = controller.currentIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changePage(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bgBlush : Colors.transparent,
          borderRadius: AppRadius.pill,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
