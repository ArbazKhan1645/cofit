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
  }
}
