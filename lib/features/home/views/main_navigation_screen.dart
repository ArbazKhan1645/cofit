import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:workmanager/workmanager.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../main.dart' show callbackDispatcher;
import '../../../notifications/service.dart';
import '../controllers/navigation_controller.dart';
import 'home_screen.dart';
import '../../workouts/views/workouts_screen.dart';
import '../../progress/views/progress_screen.dart';
import '../../community/views/community_screen.dart';
import '../../profile/views/profile_screen.dart';
import '../../recipes/views/recipes_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  final controller = Get.find<NavigationController>();

  @override
  void initState() {
    super.initState();
    // Notification + Workmanager — home view load hone ke baad init
    _initBackgroundServices();
  }

  Future<void> _initBackgroundServices() async {
    try {
      final authService = Get.find<AuthService>();

      await NotificationService().initialize(
        onNavigate: (route) {
          debugPrint('notification route: $route');
        },
        onFcmTokenReceived: (token) async {
          await authService.saveDeviceToken(token);
        },
      );

      await Workmanager().initialize(callbackDispatcher);
      await Workmanager().registerPeriodicTask(
        'streak-check',
        'streakCheckTask',
        frequency: const Duration(hours: 3),
        constraints: Constraints(networkType: NetworkType.notRequired),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
      await Workmanager().registerPeriodicTask(
        'weekly-report',
        'weeklyReportTask',
        frequency: const Duration(days: 7),
        constraints: Constraints(networkType: NetworkType.connected),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      );
    } catch (e) {
      debugPrint('Background services init error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        controller.handleBackPress();
      },
      child: Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.currentIndex.value,
            children: const [
              HomeScreen(),
              WorkoutsScreen(),
              RecipesScreen(),
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
                      icon: Iconsax.note_21,
                      activeIcon: Iconsax.note_21,
                      label: 'Recipes',
                    ),
                    _buildNavItem(
                      index: 3,
                      icon: Iconsax.chart_2,
                      activeIcon: Iconsax.chart_21,
                      label: 'Progress',
                    ),
                    _buildNavItem(
                      index: 4,
                      icon: Iconsax.people,
                      activeIcon: Iconsax.people,
                      label: 'Community',
                    ),
                    _buildNavItem(
                      index: 5,
                      icon: Iconsax.profile_circle,
                      activeIcon: Iconsax.profile_circle,
                      label: 'Profile',
                    ),
                  ],
                ),
              ),
            ),
          )),
    ),
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
          horizontal: isSelected ? 12 : 8,
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
