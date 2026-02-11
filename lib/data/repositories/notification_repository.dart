import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import 'base_repository.dart';

/// Notification Repository - Handles notification operations
class NotificationRepository extends BaseRepository {
  // ============================================
  // NOTIFICATIONS
  // ============================================

  /// Get user's notifications with pagination
  Future<Result<List<NotificationModel>>> getNotifications({
    int limit = 50,
    int offset = 0,
    bool unreadOnly = false,
  }) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      var query = client
          .from('notifications')
          .select()
          .eq('user_id', userId!);

      if (unreadOnly) {
        query = query.eq('is_read', false);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      final notifications = (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      return Result.success(notifications);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get unread notification count
  Future<Result<int>> getUnreadCount() async {
    try {
      if (userId == null) return Result.success(0);

      final response = await client
          .from('notifications')
          .select('id')
          .eq('user_id', userId!)
          .eq('is_read', false);

      return Result.success((response as List).length);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Mark notification as read
  Future<Result<void>> markAsRead(String notificationId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId)
          .eq('user_id', userId!);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Mark all notifications as read
  Future<Result<void>> markAllAsRead() async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId!)
          .eq('is_read', false);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Delete a notification
  Future<Result<void>> deleteNotification(String notificationId) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', userId!);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Delete all read notifications
  Future<Result<void>> deleteAllRead() async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client
          .from('notifications')
          .delete()
          .eq('user_id', userId!)
          .eq('is_read', true);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // NOTIFICATION SETTINGS
  // ============================================

  /// Get user's notification settings
  Future<Result<UserNotificationSettingsModel>> getSettings() async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final response = await client
          .from('user_notification_settings')
          .select()
          .eq('user_id', userId!)
          .maybeSingle();

      if (response == null) {
        // Return default settings if not found
        final now = DateTime.now();
        return Result.success(UserNotificationSettingsModel(
          id: '',
          userId: userId!,
          pushEnabled: true,
          emailEnabled: true,
          workoutReminders: true,
          challengeUpdates: true,
          achievementAlerts: true,
          socialNotifications: true,
          subscriptionAlerts: true,
          marketingNotifications: false,
          emailWeeklySummary: true,
          emailChallengeUpdates: true,
          emailPromotions: false,
          quietHoursEnabled: false,
          createdAt: now,
          updatedAt: now,
        ));
      }

      return Result.success(UserNotificationSettingsModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Update notification settings
  Future<Result<UserNotificationSettingsModel>> updateSettings({
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
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      final updates = <String, dynamic>{
        'user_id': userId!,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (pushEnabled != null) updates['push_enabled'] = pushEnabled;
      if (emailEnabled != null) updates['email_enabled'] = emailEnabled;
      if (workoutReminders != null) updates['workout_reminders'] = workoutReminders;
      if (challengeUpdates != null) updates['challenge_updates'] = challengeUpdates;
      if (achievementAlerts != null) updates['achievement_alerts'] = achievementAlerts;
      if (socialNotifications != null) updates['social_notifications'] = socialNotifications;
      if (subscriptionAlerts != null) updates['subscription_alerts'] = subscriptionAlerts;
      if (marketingNotifications != null) updates['marketing_notifications'] = marketingNotifications;
      if (emailWeeklySummary != null) updates['email_weekly_summary'] = emailWeeklySummary;
      if (emailChallengeUpdates != null) updates['email_challenge_updates'] = emailChallengeUpdates;
      if (emailPromotions != null) updates['email_promotions'] = emailPromotions;
      if (quietHoursEnabled != null) updates['quiet_hours_enabled'] = quietHoursEnabled;
      if (quietHoursStart != null) updates['quiet_hours_start'] = quietHoursStart;
      if (quietHoursEnd != null) updates['quiet_hours_end'] = quietHoursEnd;

      final response = await client
          .from('user_notification_settings')
          .upsert(updates)
          .select()
          .single();

      return Result.success(UserNotificationSettingsModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  // ============================================
  // REALTIME SUBSCRIPTIONS
  // ============================================

  RealtimeChannel? _notificationChannel;

  /// Subscribe to new notifications
  void subscribeToNotifications(
    void Function(NotificationModel notification) onNotification,
  ) {
    if (userId == null) return;

    _notificationChannel = supabase.subscribeToTable(
      table: 'notifications',
      callback: (payload) {
        final newRecord = payload.newRecord;
        if (newRecord.isNotEmpty) {
          final notification = NotificationModel.fromJson(newRecord);
          if (notification.userId == userId) {
            onNotification(notification);
          }
        }
      },
      event: PostgresChangeEvent.insert,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId!,
      ),
    );
  }

  /// Unsubscribe from notifications
  Future<void> unsubscribeFromNotifications() async {
    if (_notificationChannel != null) {
      await supabase.unsubscribe(_notificationChannel!);
      _notificationChannel = null;
    }
  }
}
