import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/navigation_controller.dart';
import '../../workouts/controllers/workouts_controller.dart';
import '../../progress/controllers/progress_controller.dart';
import '../../community/controllers/community_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../recipes/controllers/recipe_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    // HomeController is permanent (set in splash/auth) — refresh after frame
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(HomeController());
    } else {
      // Defer refresh to avoid setState during build phase
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.find<HomeController>().refreshAllData();
      });
    }
    Get.lazyPut<WorkoutsController>(() => WorkoutsController());
    Get.lazyPut<ProgressController>(() => ProgressController());
    Get.put<CommunityController>(CommunityController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<RecipeController>(() => RecipeController());
  }
}
