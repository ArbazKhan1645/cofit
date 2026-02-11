import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/services/auth_service.dart';

class SettingsController extends GetxController {
  final _storage = GetStorage();

  // Notifications
  final RxBool notificationsEnabled = true.obs;
  final RxBool workoutReminders = true.obs;
  final RxString reminderTime = '07:00'.obs;

  // Cache
  final RxString cacheSize = '0 KB'.obs;

  // App
  final String appVersion = '1.0.0';

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    notificationsEnabled.value =
        _storage.read<bool>('notificationsEnabled') ?? true;
    workoutReminders.value =
        _storage.read<bool>('workoutReminders') ?? true;
    reminderTime.value =
        _storage.read<String>('reminderTime') ?? '07:00';
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    _storage.write('notificationsEnabled', value);
  }

  void toggleWorkoutReminders(bool value) {
    workoutReminders.value = value;
    _storage.write('workoutReminders', value);
  }

  void setReminderTime(String time) {
    reminderTime.value = time;
    _storage.write('reminderTime', time);
  }

  Future<void> clearCache() async {
    try {
      AuthService.to.clearUserCache();
      cacheSize.value = '0 KB';
      Get.snackbar('Success', 'Cache cleared',
          snackPosition: SnackPosition.BOTTOM);
    } catch (_) {
      Get.snackbar('Error', 'Failed to clear cache',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
