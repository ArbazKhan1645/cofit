// ============================================================
// notification_service.dart
// MAIN SERVICE - Sab kuch yahan se call karo
// Firebase + Local + Repository sab integrate
// ============================================================

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:cofit_collective/data/models/notification_model.dart';
import 'package:cofit_collective/data/repositories/notification_repository.dart';
import 'package:cofit_collective/notifications/background_service.dart';
import 'package:cofit_collective/notifications/firebase_service.dart';
import 'package:cofit_collective/notifications/local_service.dart';
import 'package:cofit_collective/notifications/types.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final LocalNotificationService _local = LocalNotificationService();
  final FirebaseNotificationService _firebase = FirebaseNotificationService();
  final BackgroundNotificationService _background =
      BackgroundNotificationService();
  final NotificationRepository _repo = NotificationRepository();

  bool _initialized = false;
  UserNotificationSettingsModel? _settings;

  // App navigation callback
  void Function(String route)? onNavigate;

  // ============================================================
  // INITIALIZATION - main.dart mein call karo
  // ============================================================

  Future<void> initialize({
    required void Function(String route) onNavigate,
    required void Function(String fcmToken) onFcmTokenReceived,
  }) async {
    if (_initialized) {
      debugPrint('[NotifService] Already initialized, skipping');
      return;
    }

    debugPrint('[NotifService] Starting initialization...');
    this.onNavigate = onNavigate;

    // Local notifications setup
    await _local.initialize(
      onNotificationTap: (response) {
        final route = _extractRoute(response.payload);
        if (route != null) onNavigate(route);
      },
    );
    debugPrint('[NotifService] Local service initialized');

    await _local.requestPermissions();
    debugPrint('[NotifService] Permissions requested');

    // Firebase setup
    await _firebase.initialize(
      onTokenRefresh: onFcmTokenReceived,
      onNotificationTap: (data, route) {
        if (route != null) onNavigate(route);
      },
    );
    debugPrint('[NotifService] Firebase service initialized');

    // User settings load karo
    await _loadSettings();

    _initialized = true;
    debugPrint('[NotifService] Fully initialized');
  }

  // ============================================================
  // SETTINGS MANAGEMENT
  // ============================================================

  Future<void> _loadSettings() async {
    final result = await _repo.getSettings();
    result.fold(
      (error) {
        developer.log('Settings load failed: $error', name: 'Notifications');
      },
      (settings) {
        _settings = settings;
        _syncWithSettings(settings);
      },
    );
  }

  Future<void> _syncWithSettings(UserNotificationSettingsModel settings) async {
    // Firebase topics sync
    await _firebase.syncTopicSubscriptions(
      challengeUpdates: settings.challengeUpdates,
      socialNotifications: settings.socialNotifications,
      achievementAlerts: settings.achievementAlerts,
      communityNotifications: settings.socialNotifications,
      marketingNotifications: settings.marketingNotifications,
      userId: _repo.userId,
    );

    // Quiet hours - local notifications disable karo
    if (!settings.pushEnabled) {
      await _local.cancelAll();
    }
  }

  Future<UserNotificationSettingsModel?> updateSettings({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? workoutReminders,
    bool? challengeUpdates,
    bool? achievementAlerts,
    bool? socialNotifications,
    bool? subscriptionAlerts,
    bool? marketingNotifications,
    bool? emailWeeklySummary,
    bool? emailChallengeUpdates,
    bool? emailPromotions,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
  }) async {
    final result = await _repo.updateSettings(
      pushEnabled: pushEnabled,
      emailEnabled: emailEnabled,
      workoutReminders: workoutReminders,
      challengeUpdates: challengeUpdates,
      achievementAlerts: achievementAlerts,
      socialNotifications: socialNotifications,
      subscriptionAlerts: subscriptionAlerts,
      marketingNotifications: marketingNotifications,
      emailWeeklySummary: emailWeeklySummary,
      emailChallengeUpdates: emailChallengeUpdates,
      emailPromotions: emailPromotions,
      quietHoursEnabled: quietHoursEnabled,
      quietHoursStart: quietHoursStart,
      quietHoursEnd: quietHoursEnd,
    );

    return result.fold((_) => null, (settings) {
      _settings = settings;
      _syncWithSettings(settings);
      return settings;
    });
  }

  // ============================================================
  // REALTIME - Supabase se live notifications
  // ============================================================

  void startRealtimeNotifications() {
    _repo.subscribeToNotifications((notification) {
      // Supabase se naya notification aaya - local show karo agar zaroorat ho
      developer.log(
        'Realtime notification received: ${notification.id}',
        name: 'Notifications',
      );
      _showRealtimeNotification(notification);
    });
  }

  void stopRealtimeNotifications() {
    _repo.unsubscribeFromNotifications();
  }

  Future<void> _showRealtimeNotification(NotificationModel notification) async {
    if (_settings?.pushEnabled == false) return;

    // Quiet hours check
    if (_isQuietHours()) return;

    await _local.showImmediate(
      id: notification.id.hashCode,
      payload: NotificationPayload(
        title: notification.title,
        body: notification.body,
        channel: _mapNotificationTypeToChannel(notification.type.value),
        data: notification.metadata ?? {},
        actionRoute: notification.screenReference?.route,
      ),
    );
  }

  // ============================================================
  // 🏆 ACHIEVEMENT NOTIFICATIONS
  // Firebase + Local dono
  // ============================================================

  Future<void> notifyAchievementUnlocked({
    required AchievementType achievement,
    required String achievementId,
    String? customMessage,
  }) async {
    if (_settings?.achievementAlerts == false) return;

    final title = achievement.title;
    final body = customMessage ?? _getAchievementBody(achievement);

    // Local show karo immediately
    await _local.showImmediate(
      id: achievementId.hashCode,
      payload: NotificationPayload(
        title: title,
        body: body,
        channel: NotificationChannel.achievementAlert,
        data: {
          'achievement_type': achievement.name,
          'achievement_id': achievementId,
        },
        actionRoute: '/achievements/$achievementId',
      ),
    );

    developer.log(
      'Achievement notification: ${achievement.name}',
      name: 'Notifications',
    );
  }

  String _getAchievementBody(AchievementType achievement) {
    switch (achievement) {
      case AchievementType.firstWorkout:
        return 'Pehli workout complete! Ye sirf shuruwat hai! 🎊';
      case AchievementType.streak7Days:
        return '7 din ki streak! Ek hafte ki consistency - kamaal ho tum! 🔥';
      case AchievementType.streak30Days:
        return '30 din lagataar! Aik mahine ki dedication - extraordinary! 💪';
      case AchievementType.streak100Days:
        return '100 din ki streak! Tum ab ek legend ho! 🏆👑';
      case AchievementType.goalReached:
        return 'Aaj ka goal pura ho gaya! Target hit - well done! ✅';
      case AchievementType.personalBest:
        return 'Naya personal record! Khud ko hi peeche chhod diya! 🚀';
      case AchievementType.communityMilestone:
        return 'Community milestone achieve! Tum community ke star ho! 👥⭐';
      case AchievementType.challengeWon:
        return 'Challenge jeet liya! Hard work pays off! 🥇🎉';
      case AchievementType.caloriesMilestone:
        return 'Calorie milestone! Itni mehnat - incredible! 🔥💪';
      case AchievementType.workoutCountMilestone:
        return 'Workout milestone! Consistency hi success hai! 💯';
    }
  }

  // ============================================================
  // 🏁 CHALLENGE NOTIFICATIONS
  // Firebase + Local dono
  // ============================================================

  Future<void> notifyChallengeUpdate({
    required String challengeId,
    required String challengeName,
    required ChallengeNotificationType type,
    String? actorName, // Kisne invite kiya ya participate kiya
    int? currentRank,
    int? totalParticipants,
    int? progressPercent,
    String? deadline,
  }) async {
    if (_settings?.challengeUpdates == false) return;

    final notif = _buildChallengeNotification(
      challengeId: challengeId,
      challengeName: challengeName,
      type: type,
      actorName: actorName,
      currentRank: currentRank,
      totalParticipants: totalParticipants,
      progressPercent: progressPercent,
      deadline: deadline,
    );

    await _local.showImmediate(
      id: '${challengeId}_${type.name}'.hashCode,
      payload: notif,
    );
  }

  NotificationPayload _buildChallengeNotification({
    required String challengeId,
    required String challengeName,
    required ChallengeNotificationType type,
    String? actorName,
    int? currentRank,
    int? totalParticipants,
    int? progressPercent,
    String? deadline,
  }) {
    String title;
    String body;

    switch (type) {
      case ChallengeNotificationType.invited:
        title = '🏁 Challenge Invite!';
        body =
            '${actorName ?? "Kisi"} ne tumhe "$challengeName" challenge mein invite kiya hai. Accept karo!';
        break;
      case ChallengeNotificationType.started:
        title = '🚀 Challenge Shuru!';
        body =
            '"$challengeName" challenge ab start ho gaya hai! Apni best performance do!';
        break;
      case ChallengeNotificationType.progressUpdate:
        title = '📊 Challenge Progress';
        body = currentRank != null
            ? '"$challengeName": Rank #$currentRank/$totalParticipants. ${progressPercent ?? 0}% complete!'
            : '"$challengeName": ${progressPercent ?? 0}% complete!';
        break;
      case ChallengeNotificationType.completed:
        title = '🎉 Challenge Complete!';
        body =
            '"$challengeName" complete ho gaya! Final rank: #${currentRank ?? "?"} 🏆';
        break;
      case ChallengeNotificationType.leaderboardChange:
        title = '📈 Leaderboard Update!';
        body =
            '"$challengeName" mein tumhari rank change ho gayi: #$currentRank/$totalParticipants';
        break;
      case ChallengeNotificationType.deadline:
        title = '⏰ Challenge Deadline!';
        body =
            '"$challengeName" ka waqt khatam hone wala hai! $deadline baaki hai. Jaldi!';
        break;
      case ChallengeNotificationType.newParticipant:
        title = '👥 New Competitor!';
        body =
            '${actorName ?? "Koi"} ne "$challengeName" join kar liya. Competition badh gayi!';
        break;
    }

    return NotificationPayload(
      title: title,
      body: body,
      channel: NotificationChannel.challengeUpdate,
      data: {'challenge_id': challengeId, 'challenge_type': type.name},
      actionRoute: '/challenges/$challengeId',
    );
  }

  // ============================================================
  // 👥 SOCIAL / COMMUNITY NOTIFICATIONS
  // Firebase + Local dono
  // ============================================================

  Future<void> notifySocialActivity({
    required SocialNotificationType type,
    required String actorName,
    String? actorAvatarUrl,
    String? postId,
    String? commentText,
    String? postPreview,
    String? communityId,
    String? communityName,
  }) async {
    if (_settings?.socialNotifications == false) return;
    if (_isQuietHours()) return;

    final notif = _buildSocialNotification(
      type: type,
      actorName: actorName,
      postId: postId,
      commentText: commentText,
      postPreview: postPreview,
      communityId: communityId,
      communityName: communityName,
    );

    await _local.showImmediate(
      id: _generateSocialId(type, postId, actorName),
      payload: notif,
    );
  }

  NotificationPayload _buildSocialNotification({
    required SocialNotificationType type,
    required String actorName,
    String? postId,
    String? commentText,
    String? postPreview,
    String? communityId,
    String? communityName,
  }) {
    String title;
    String body;
    String? route;

    switch (type) {
      case SocialNotificationType.like:
        title = '❤️ $actorName';
        body = postPreview != null
            ? '"$postPreview" - ye post pasand aayi!'
            : 'Tumhari post like ki!';
        route = postId != null ? '/community/post/$postId' : '/community';
        break;

      case SocialNotificationType.comment:
        title = '💬 $actorName';
        body = commentText != null
            ? '"$commentText"'
            : 'Tumhari post par comment kiya';
        route = postId != null ? '/community/post/$postId' : '/community';
        break;

      case SocialNotificationType.newPost:
        title = '📸 $actorName';
        body = postPreview ?? 'Ne naya post share kiya hai!';
        route = postId != null
            ? '/community/post/$postId'
            : communityId != null
            ? '/community/$communityId'
            : '/community/feed';
        break;

      case SocialNotificationType.follow:
        title = '👤 $actorName';
        body = 'Ab tumhe follow karta/karti hai!';
        route = '/profile/$actorName';
        break;

      case SocialNotificationType.mention:
        title = '🔔 $actorName ne mention kiya';
        body = commentText ?? 'Tumhe ek discussion mein tag kiya!';
        route = postId != null ? '/community/post/$postId' : '/community';
        break;

      case SocialNotificationType.communityJoin:
        title = '🎉 New Member!';
        body =
            '$actorName ne ${communityName ?? "tumhari community"} join kar li!';
        route = communityId != null ? '/community/$communityId' : '/community';
        break;

      case SocialNotificationType.postShare:
        title = '🔄 $actorName';
        body = 'Tumhari post share ki - log pasand kar rahe hain!';
        route = postId != null ? '/community/post/$postId' : '/community';
        break;
    }

    return NotificationPayload(
      title: title,
      body: body,
      channel: NotificationChannel.socialActivity,
      data: {
        'social_type': type.name,
        'actor_name': actorName,
        if (postId != null) 'post_id': postId,
        if (communityId != null) 'community_id': communityId,
      },
      actionRoute: route,
    );
  }

  int _generateSocialId(
    SocialNotificationType type,
    String? postId,
    String actorName,
  ) {
    return '${type.name}_${postId ?? ''}_$actorName'.hashCode.abs() % 9000 +
        1000;
  }

  // ============================================================
  // 💳 SUBSCRIPTION NOTIFICATIONS
  // Firebase + Local dono (high priority)
  // ============================================================

  Future<void> notifySubscription({
    required SubscriptionNotificationType type,
    int? daysRemaining,
    String? planName,
    String? amount,
  }) async {
    if (_settings?.subscriptionAlerts == false) return;

    String title;
    String body;
    String route = '/settings/subscription';

    switch (type) {
      case SubscriptionNotificationType.expiringIn7Days:
        title = '⚠️ Plan Expiring Soon';
        body =
            'Tumhara ${planName ?? "Premium"} plan 7 din mein expire ho jayega. Renew karo!';
        break;
      case SubscriptionNotificationType.expiringIn1Day:
        title = '🚨 Plan Kal Expire Ho Raha Hai!';
        body =
            'Kal tumhara ${planName ?? "Premium"} plan khatam hoga. Abhi renew karo premium features keep karne k liye!';
        break;
      case SubscriptionNotificationType.expired:
        title = '❌ Plan Expired';
        body =
            'Tumhara ${planName ?? "Premium"} plan expire ho gaya. Wapas shuru karo - tumhara data safe hai!';
        break;
      case SubscriptionNotificationType.renewed:
        title = '✅ Subscription Renewed!';
        body =
            '${planName ?? "Premium"} plan successfully renew ho gaya${amount != null ? " ($amount)" : ""}. Enjoy!';
        break;
      case SubscriptionNotificationType.paymentFailed:
        title = '💳 Payment Failed!';
        body =
            'Tumhari subscription payment fail ho gayi. Payment update karo access keep karne k liye.';
        break;
      case SubscriptionNotificationType.trialEnding:
        title = '⏳ Trial Khatam Ho Raha Hai';
        body =
            'Sirf ${daysRemaining ?? 3} din baaki hain trial mein. Plan choose karo continue karne k liye!';
        break;
    }

    await _local.showImmediate(
      id: type.name.hashCode,
      payload: NotificationPayload(
        title: title,
        body: body,
        channel: NotificationChannel.subscriptionAlert,
        data: {'subscription_type': type.name},
        actionRoute: route,
      ),
    );
  }

  // ============================================================
  // 💪 WORKOUT REMINDERS SETUP (User settings se)
  // ============================================================

  Future<void> setupWorkoutReminders({
    required Map<int, Map<String, dynamic>> weeklySchedule,
  }) async {
    if (_settings?.workoutReminders == false) {
      await _local.cancelAllWorkoutReminders();
      return;
    }

    await _local.scheduleWeeklyWorkoutPlan(weeklyPlan: weeklySchedule);
  }

  Future<void> setupHydrationReminders({
    required bool enabled,
    int startHour = 8,
    int endHour = 22,
    int intervalMinutes = 90,
  }) async {
    if (!enabled) {
      await _local.cancelHydrationReminders();
      return;
    }

    await _local.scheduleHydrationReminders(
      startHour: startHour,
      endHour: endHour,
      intervalMinutes: intervalMinutes,
    );
  }

  // ============================================================
  // BACKGROUND SERVICE BRIDGE
  // Background service in methods ko call karega
  // ============================================================

  Future<void> runBackgroundChecks({
    required Map<String, dynamic> userStats,
  }) async {
    // Streak check
    if (userStats['current_streak'] != null) {
      await _background.checkAndNotifyStreak(
        currentStreak: userStats['current_streak'] as int,
        lastWorkoutDate: userStats['last_workout_date'] != null
            ? DateTime.parse(userStats['last_workout_date'] as String)
            : null,
        userHasWorkedOutToday: userStats['worked_out_today'] as bool? ?? false,
      );
    }

    // Goal progress
    if (userStats['goal_type'] != null) {
      await _background.checkAndNotifyGoalProgress(
        goalType: userStats['goal_type'] as String,
        currentValue: userStats['current_value'] as int,
        targetValue: userStats['target_value'] as int,
        alreadyNotifiedToday:
            userStats['goal_notified_today'] as bool? ?? false,
      );
    }

    // Rest day check
    if (userStats['consecutive_workout_days'] != null) {
      await _background.checkAndNotifyRestDay(
        consecutiveWorkoutDays: userStats['consecutive_workout_days'] as int,
        recentMuscleGroups: List<String>.from(
          userStats['recent_muscle_groups'] as List? ?? [],
        ),
      );
    }

    // Inactivity check
    if (userStats['last_app_open'] != null) {
      await _background.checkInactivityAndNotify(
        lastAppOpenDate: DateTime.parse(userStats['last_app_open'] as String),
        currentStreak: userStats['current_streak'] as int? ?? 0,
      );
    }
  }

  // ============================================================
  // NOTIFICATION INBOX (Supabase repository)
  // ============================================================

  Future<List<NotificationModel>> getNotifications({
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    final result = await _repo.getNotifications(
      limit: limit,
      offset: offset,
      unreadOnly: unreadOnly,
    );
    return result.fold((_) => [], (list) => list);
  }

  Future<int> getUnreadCount() async {
    final result = await _repo.getUnreadCount();
    return result.fold((_) => 0, (count) => count);
  }

  Future<void> markAsRead(String notificationId) async {
    await _repo.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    await _repo.markAllAsRead();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _repo.deleteNotification(notificationId);
  }

  Future<void> clearReadNotifications() async {
    await _repo.deleteAllRead();
  }

  // ============================================================
  // QUIET HOURS CHECK
  // ============================================================

  bool _isQuietHours() {
    if (_settings?.quietHoursEnabled != true) return false;

    final start = _settings?.quietHoursStart;
    final end = _settings?.quietHoursEnd;

    if (start == null || end == null) return false;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    final startParts = start.split(':');
    final endParts = end.split(':');
    final startMinutes =
        int.parse(startParts[0]) * 60 + int.parse(startParts[1]);
    final endMinutes = int.parse(endParts[0]) * 60 + int.parse(endParts[1]);

    if (startMinutes <= endMinutes) {
      return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
    } else {
      // Midnight cross karta hai (e.g., 22:00 to 07:00)
      return currentMinutes >= startMinutes || currentMinutes <= endMinutes;
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  NotificationChannel _mapNotificationTypeToChannel(String? type) {
    switch (type) {
      case 'challenge':
        return NotificationChannel.challengeUpdate;
      case 'achievement':
        return NotificationChannel.achievementAlert;
      case 'social':
      case 'like':
      case 'comment':
      case 'follow':
        return NotificationChannel.socialActivity;
      case 'subscription':
        return NotificationChannel.subscriptionAlert;
      case 'workout':
        return NotificationChannel.workoutReminder;
      default:
        return NotificationChannel.socialActivity;
    }
  }

  String? _extractRoute(String? payload) {
    if (payload == null) return null;
    try {
      final decoded = Uri.decodeFull(payload);
      final match = RegExp(r"actionRoute: ([^\s,}]+)").firstMatch(decoded);
      return match?.group(1);
    } catch (_) {
      return null;
    }
  }

  String? get fcmToken => _firebase.fcmToken;
  UserNotificationSettingsModel? get settings => _settings;
}

// ============================================================
// Subscription Notification Types
// ============================================================

enum SubscriptionNotificationType {
  expiringIn7Days,
  expiringIn1Day,
  expired,
  renewed,
  paymentFailed,
  trialEnding,
}
