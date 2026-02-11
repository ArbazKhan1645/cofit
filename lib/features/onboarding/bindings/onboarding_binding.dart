import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/subscription_controller.dart';
import '../controllers/journal_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubscriptionController>(() => SubscriptionController());
  }
}

class JournalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JournalController>(() => JournalController());
  }
}
