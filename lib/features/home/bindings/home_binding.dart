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
    // HomeController is permanent (set in splash) — refresh data on re-entry
    if (!Get.isRegistered<HomeController>()) {
      Get.put<HomeController>(HomeController());
    } else {
      // Already exists (permanent) — refresh all data so admin changes are visible
      Get.find<HomeController>().refreshAllData();
    }
    Get.lazyPut<WorkoutsController>(() => WorkoutsController());
    Get.lazyPut<ProgressController>(() => ProgressController());
    Get.put<CommunityController>(CommunityController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<RecipeController>(() => RecipeController());
  }
}
