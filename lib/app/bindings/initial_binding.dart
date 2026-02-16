import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../core/services/achievement_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Storage Service
    Get.put<GetStorage>(GetStorage(), permanent: true);

    // Achievement Service
    Get.lazyPut<AchievementService>(() => AchievementService(), fenix: true);

    // ProgressService is created as permanent in splash/auth BEFORE HomeController
    // to guarantee initialized data. Do NOT lazyPut here — non-permanent instances
    // get disposed on route transitions, causing all stats to reset to zero.
  }
}
