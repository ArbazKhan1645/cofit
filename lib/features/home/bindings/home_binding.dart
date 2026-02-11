import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../controllers/navigation_controller.dart';
import '../../workouts/controllers/workouts_controller.dart';
import '../../progress/controllers/progress_controller.dart';
import '../../community/controllers/community_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NavigationController>(() => NavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<WorkoutsController>(() => WorkoutsController());
    Get.lazyPut<ProgressController>(() => ProgressController());
    Get.lazyPut<CommunityController>(() => CommunityController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
