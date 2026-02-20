import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/media/media_service.dart';
import '../../../core/services/progress_service.dart';
import '../../../data/models/user_model.dart';
import '../../../app/routes/app_routes.dart';

class ProfileController extends BaseController {
  final AuthService _authService = AuthService.to;
  final _storage = GetStorage();

  // User data (synced from AuthService)
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userAvatar = ''.obs;
  final RxString userId = ''.obs;
  final RxString memberSince = ''.obs;

  // Stats
  final RxInt totalWorkouts = 0.obs;
  final RxInt currentStreak = 0.obs;
  final RxInt totalMinutes = 0.obs;

  // Subscription
  final RxBool hasActiveSub = false.obs;
  final RxString subscriptionStatus = 'free'.obs;

  // Admin
  final RxBool isAdmin = false.obs;

  // Profile image upload
  final RxBool isUploadingImage = false.obs;

  // Settings (local only)
  final RxBool notificationsEnabled = true.obs;
  final RxBool workoutReminders = true.obs;
  final RxString reminderTime = '07:00'.obs;

  @override
  void onInit() {
    super.onInit();
    _syncFromUser(_authService.currentUser);
    _loadSettings();
    // React to user changes from AuthService
    ever(_authService.currentUserRx, _syncFromUser);
    // React to ProgressService for realtime stats after workout completion
    if (Get.isRegistered<ProgressService>()) {
      final ps = Get.find<ProgressService>();
      ever(ps.totalWorkouts, (_) => totalWorkouts.value = ps.totalWorkouts.value);
      ever(ps.currentStreak, (_) => currentStreak.value = ps.currentStreak.value);
      ever(ps.totalMinutes, (_) => totalMinutes.value = ps.totalMinutes.value);
    }
  }

  /// Sync all reactive fields from the UserModel
  void _syncFromUser(UserModel? user) {
    userName.value = user?.displayName ?? 'Fitness Friend';
    userEmail.value = user?.email ?? '';
    userAvatar.value = user?.avatarUrl ?? '';
    userId.value = user?.id ?? '';
    totalWorkouts.value = user?.totalWorkoutsCompleted ?? 0;
    currentStreak.value = user?.currentStreak ?? 0;
    totalMinutes.value = user?.totalMinutesWorkedOut ?? 0;
    hasActiveSub.value = user?.hasActiveSubscription ?? false;
    subscriptionStatus.value = user?.subscriptionStatus ?? 'free';
    isAdmin.value = user?.isAdmin ?? false;
    if (user != null) {
      memberSince.value = DateFormat('MMMM yyyy').format(user.createdAt);
    }
  }

  void _loadSettings() {
    notificationsEnabled.value =
        _storage.read<bool>('notificationsEnabled') ?? true;
    workoutReminders.value = _storage.read<bool>('workoutReminders') ?? true;
    reminderTime.value = _storage.read<String>('reminderTime') ?? '07:00';
  }

  // ============================================
  // PROFILE IMAGE
  // ============================================

  Future<void> uploadProfileImage() async {
    final bytes = await MediaService.to.pickImageFromGallery();
    if (bytes == null) return;

    isUploadingImage.value = true;
    try {
      final url = await MediaService.to.uploadProfileImage(bytes);
      await _authService.updateProfile(avatarUrl: url);
    } catch (_) {
      // Upload failed silently — user can retry
    }
    isUploadingImage.value = false;
  }

  // ============================================
  // SETTINGS
  // ============================================

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

  // ============================================
  // AUTH
  // ============================================

  Future<void> refreshUser() async {
    await _authService.refreshUser();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    Get.offAllNamed(AppRoutes.signIn);
  }
}
