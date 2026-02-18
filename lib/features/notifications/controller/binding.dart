import 'package:cofit_collective/core/services/auth_service.dart';
import 'package:cofit_collective/features/notifications/controller/notification_controller.dart';
import 'package:cofit_collective/features/notifications/controller/repo.dart';
import 'package:get/get.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    // Repository as lazy singleton — disposed when controller is destroyed
    Get.lazyPut<INotificationRepository>(
      () => NotificationRepository(),
      fenix: false, // Don't recreate after dispose
    );

    Get.lazyPut<NotificationController>(
      () => NotificationController(
        repository: Get.find<INotificationRepository>(),
      ),
      fenix: false,
    );

    Get.find<NotificationController>().initialize(
      AuthService.to.currentUser?.id ?? '',
    );
  }
}
