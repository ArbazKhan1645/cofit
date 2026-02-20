import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/feed_cache_service.dart';
import '../../../core/services/media/media_service.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/today_workout_cache_service.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

class SettingsController extends GetxController {
  final _repo = NotificationRepository();

  // ============================================
  // STATE
  // ============================================

  final RxBool isLoading = true.obs;

  // Push notification toggles
  final RxBool pushEnabled = true.obs;
  final RxBool workoutReminders = true.obs;
  final RxBool challengeUpdates = true.obs;
  final RxBool achievementAlerts = true.obs;
  final RxBool socialNotifications = true.obs;
  final RxBool subscriptionAlerts = true.obs;
  final RxBool marketingNotifications = false.obs;

  // Email toggles
  final RxBool emailEnabled = true.obs;
  final RxBool emailWeeklySummary = true.obs;
  final RxBool emailChallengeUpdates = true.obs;
  final RxBool emailPromotions = false.obs;

  // Quiet hours
  final RxBool quietHoursEnabled = false.obs;
  final RxString quietHoursStart = '22:00'.obs;
  final RxString quietHoursEnd = '07:00'.obs;

  // Cache
  final RxString cacheSize = '0 KB'.obs;

  // App
  final RxString appVersion = '1.0.0'.obs;

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  // ============================================
  // LOAD SETTINGS FROM SUPABASE
  // ============================================

  Future<void> _loadSettings() async {
    isLoading.value = true;

    final result = await _repo.getSettings();
    result.fold(
      (error) => debugPrint('Settings load error: $error'),
      (data) => _applyToObservables(data),
    );

    isLoading.value = false;
  }

  void _applyToObservables(UserNotificationSettingsModel data) {
    pushEnabled.value = data.pushEnabled;
    workoutReminders.value = data.workoutReminders;
    challengeUpdates.value = data.challengeUpdates;
    achievementAlerts.value = data.achievementAlerts;
    socialNotifications.value = data.socialNotifications;
    subscriptionAlerts.value = data.subscriptionAlerts;
    marketingNotifications.value = data.marketingNotifications;

    emailEnabled.value = data.emailEnabled;
    emailWeeklySummary.value = data.emailWeeklySummary;
    emailChallengeUpdates.value = data.emailChallengeUpdates;
    emailPromotions.value = data.emailPromotions;

    quietHoursEnabled.value = data.quietHoursEnabled;
    quietHoursStart.value = data.quietHoursStart ?? '22:00';
    quietHoursEnd.value = data.quietHoursEnd ?? '07:00';
  }

  // ============================================
  // TOGGLE METHODS — optimistic update + Supabase save
  // ============================================

  void togglePushEnabled(bool value) {
    pushEnabled.value = value;
    _saveToSupabase(pushEnabled: value);
    _syncNotificationsToUser(value);
  }

  void toggleWorkoutReminders(bool value) {
    workoutReminders.value = value;
    _saveToSupabase(workoutReminders: value);
  }

  void toggleChallengeUpdates(bool value) {
    challengeUpdates.value = value;
    _saveToSupabase(challengeUpdates: value);
  }

  void toggleAchievementAlerts(bool value) {
    achievementAlerts.value = value;
    _saveToSupabase(achievementAlerts: value);
  }

  void toggleSocialNotifications(bool value) {
    socialNotifications.value = value;
    _saveToSupabase(socialNotifications: value);
  }

  void toggleSubscriptionAlerts(bool value) {
    subscriptionAlerts.value = value;
    _saveToSupabase(subscriptionAlerts: value);
  }

  void toggleMarketingNotifications(bool value) {
    marketingNotifications.value = value;
    _saveToSupabase(marketingNotifications: value);
  }

  void toggleEmailEnabled(bool value) {
    emailEnabled.value = value;
    _saveToSupabase(emailEnabled: value);
  }

  void toggleEmailWeeklySummary(bool value) {
    emailWeeklySummary.value = value;
    _saveToSupabase(emailWeeklySummary: value);
  }

  void toggleEmailChallengeUpdates(bool value) {
    emailChallengeUpdates.value = value;
    _saveToSupabase(emailChallengeUpdates: value);
  }

  void toggleEmailPromotions(bool value) {
    emailPromotions.value = value;
    _saveToSupabase(emailPromotions: value);
  }

  void toggleQuietHours(bool value) {
    quietHoursEnabled.value = value;
    _saveToSupabase(quietHoursEnabled: value);
  }

  void setQuietHoursStart(String time) {
    quietHoursStart.value = time;
    _saveToSupabase(quietHoursStart: time);
  }

  void setQuietHoursEnd(String time) {
    quietHoursEnd.value = time;
    _saveToSupabase(quietHoursEnd: time);
  }

  // ============================================
  // SAVE TO SUPABASE (fire-and-forget)
  // ============================================

  Future<void> _saveToSupabase({
    bool? pushEnabled,
    bool? workoutReminders,
    bool? challengeUpdates,
    bool? achievementAlerts,
    bool? socialNotifications,
    bool? subscriptionAlerts,
    bool? marketingNotifications,
    bool? emailEnabled,
    bool? emailWeeklySummary,
    bool? emailChallengeUpdates,
    bool? emailPromotions,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) async {
    final result = await _repo.updateSettings(
      pushEnabled: pushEnabled,
      workoutReminders: workoutReminders,
      challengeUpdates: challengeUpdates,
      achievementAlerts: achievementAlerts,
      socialNotifications: socialNotifications,
      subscriptionAlerts: subscriptionAlerts,
      marketingNotifications: marketingNotifications,
      emailEnabled: emailEnabled,
      emailWeeklySummary: emailWeeklySummary,
      emailChallengeUpdates: emailChallengeUpdates,
      emailPromotions: emailPromotions,
      quietHoursEnabled: quietHoursEnabled,
      quietHoursStart: quietHoursStart,
      quietHoursEnd: quietHoursEnd,
    );

    result.fold(
      (error) => debugPrint('Settings save error: $error'),
      (_) {},
    );
  }

  /// Push toggle ko users table ki notifications_enabled se bhi sync karo
  Future<void> _syncNotificationsToUser(bool value) async {
    try {
      final userId = SupabaseService.to.userId;
      if (userId == null) return;
      await SupabaseService.to.client
          .from('users')
          .update({
            'notifications_enabled': value,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', userId);
      // Refresh cached user
      await AuthService.to.refreshUser();
    } catch (_) {}
  }

  // ============================================
  // CACHE — sab kuch delete karo
  // ============================================

  Future<void> loadCacheSize() async {
    try {
      final mediaBytes = await MediaService.to.getCacheSizeInBytes();
      cacheSize.value = _formatBytes(mediaBytes);
    } catch (_) {
      cacheSize.value = '0 KB';
    }
  }

  Future<void> clearCache() async {
    try {
      // 1. User cache (AuthService — GetStorage cached_current_user)
      AuthService.to.clearUserCache();

      // 2. Feed cache (FeedCacheService — GetStorage feed posts)
      await FeedCacheService.to.clearCache();

      // 3. Workout schedule cache (TodayWorkoutCacheService — GetStorage)
      TodayWorkoutCacheService().clearCache();

      // 4. Image cache — profile images + network images (disk)
      await MediaService.to.clearImageCache();

      // 5. GetStorage erase — baqi sab keys bhi saaf
      await GetStorage().erase();

      cacheSize.value = '0 KB';
      Get.snackbar('Success', 'All cache cleared',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      debugPrint('Clear cache error: $e');
      Get.snackbar('Error', 'Failed to clear cache',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // ============================================
  // DELETE ACCOUNT
  // ============================================

  final RxBool isDeleting = false.obs;

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
      final supabase = SupabaseService.to;
      final userId = supabase.userId;
      if (userId == null) return;

      // 1. Delete user data from all tables (cascade se bhi hoga lekin safe side)
      await Future.wait([
        supabase.client.from('user_progress').delete().eq('user_id', userId),
        supabase.client.from('month_progress').delete().eq('user_id', userId),
        supabase.client.from('user_challenges').delete().eq('user_id', userId),
        supabase.client
            .from('user_notification_settings')
            .delete()
            .eq('user_id', userId),
        supabase.client.from('notifications').delete().eq('user_id', userId),
        supabase.client
            .from('achievement_progress')
            .delete()
            .eq('user_id', userId),
        supabase.client.from('saved_workouts').delete().eq('user_id', userId),
        supabase.client.from('saved_recipes').delete().eq('user_id', userId),
        supabase.client.from('saved_posts').delete().eq('user_id', userId),
        supabase.client.from('journal_entries').delete().eq('user_id', userId),
        supabase.client
            .from('onboarding_responses')
            .delete()
            .eq('user_id', userId),
      ]);

      // 2. Delete posts, comments, likes, follows (user-generated content)
      await Future.wait([
        supabase.client.from('likes').delete().eq('user_id', userId),
        supabase.client.from('comments').delete().eq('user_id', userId),
        supabase.client.from('shares').delete().eq('user_id', userId),
        supabase.client.from('follows').delete().eq('follower_id', userId),
        supabase.client.from('follows').delete().eq('following_id', userId),
      ]);
      await supabase.client.from('posts').delete().eq('user_id', userId);

      // 3. Delete user row from public.users
      await supabase.client.from('users').delete().eq('id', userId);

      // 4. Clear all local data
      await _clearAllLocalData();

      // 5. Sign out from Supabase auth
      await AuthService.to.signOut();

      isDeleting.value = false;

      // 6. Navigate to sign-in
      Get.offAllNamed(AppRoutes.signIn);

      Get.snackbar('Account Deleted', 'Your account has been permanently deleted',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      isDeleting.value = false;
      debugPrint('Delete account error: $e');
      Get.snackbar('Error', 'Failed to delete account. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _clearAllLocalData() async {
    try {
      AuthService.to.clearUserCache();
      await FeedCacheService.to.clearCache();
      TodayWorkoutCacheService().clearCache();
      await MediaService.to.clearImageCache();
      await GetStorage().erase();
    } catch (_) {}
  }
}
