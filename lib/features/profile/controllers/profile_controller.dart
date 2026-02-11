import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../app/routes/app_routes.dart';

class ProfileController extends BaseController {
  final _storage = GetStorage();

  // User data
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userAvatar = ''.obs;
  final RxString memberSince = ''.obs;

  // Stats
  final RxInt totalWorkouts = 0.obs;
  final RxInt currentStreak = 0.obs;
  final RxInt badgesEarned = 0.obs;

  // Settings
  final RxBool notificationsEnabled = true.obs;
  final RxBool workoutReminders = true.obs;
  final RxString reminderTime = '07:00'.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
    loadUserStats();
    loadSettings();
  }

  void loadUserProfile() {
    userName.value = _storage.read<String>('userName') ?? 'Fitness Friend';
    userEmail.value = _storage.read<String>('userEmail') ?? 'user@example.com';
    userAvatar.value = _storage.read<String>('userAvatar') ?? '';
    memberSince.value = _storage.read<String>('memberSince') ?? 'January 2024';
  }

  void loadUserStats() {
    totalWorkouts.value = _storage.read<int>('totalWorkouts') ?? 24;
    currentStreak.value = _storage.read<int>('currentStreak') ?? 5;
    badgesEarned.value = _storage.read<int>('badgesEarned') ?? 8;
  }

  void loadSettings() {
    notificationsEnabled.value = _storage.read<bool>('notificationsEnabled') ?? true;
    workoutReminders.value = _storage.read<bool>('workoutReminders') ?? true;
    reminderTime.value = _storage.read<String>('reminderTime') ?? '07:00';
  }

  void updateUserName(String name) {
    userName.value = name;
    _storage.write('userName', name);
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

  Future<void> signOut() async {
    await _storage.write('isLoggedIn', false);
    await _storage.write('hasCompletedOnboarding', false);
    Get.offAllNamed(AppRoutes.signIn);
  }
}
