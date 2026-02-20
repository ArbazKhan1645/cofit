import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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

}
