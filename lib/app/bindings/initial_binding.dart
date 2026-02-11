import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Storage Service
    Get.put<GetStorage>(GetStorage(), permanent: true);

    // Add more global services here as needed
    // Get.put<AuthService>(AuthService(), permanent: true);
    // Get.put<ApiClient>(ApiClient(), permanent: true);
  }
}
