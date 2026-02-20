import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/feed_cache_service.dart';
import '../../../core/services/media/media_service.dart';
import '../../../core/services/progress_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/today_workout_cache_service.dart';
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

  // Delete account
  final RxBool isDeleting = false.obs;

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

  // ============================================
  // DELETE ACCOUNT
  // ============================================

  void showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Kya aap sure hain? Aapka sara data permanently delete ho jayega. '
          'Yeh action undo nahi ho sakta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _confirmDeleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    Get.dialog(
      AlertDialog(
        title: const Text('Final Confirmation'),
        content: const Text(
          'Last warning! Account delete hone ke baad wapas nahi aayega. '
          'All workouts, progress, streaks — sab khatam.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Keep Account'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Delete Forever'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteAccount() async {
    isDeleting.value = true;

    try {
      // Delete all data + user row via RPC (bypasses RLS)
      await SupabaseService.to.rpc('delete_own_account');

      // 4. Clear all local data
      await _clearAllLocalData();

      // 5. Sign out
      await _authService.signOut();

      isDeleting.value = false;

      // 6. Navigate to sign-in
      Get.offAllNamed(AppRoutes.signIn);

      Get.snackbar(
        'Account Deleted',
        'Your account has been permanently deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      isDeleting.value = false;
      debugPrint('Delete account error: $e');
      Get.snackbar(
        'Error',
        'Failed to delete account. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _clearAllLocalData() async {
    try {
      _authService.clearUserCache();
      await FeedCacheService.to.clearCache();
      TodayWorkoutCacheService().clearCache();
      await MediaService.to.clearImageCache();
      await GetStorage().erase();
    } catch (_) {}
  }
}
