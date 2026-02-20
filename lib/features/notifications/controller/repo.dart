import 'dart:async';
import 'package:cofit_collective/data/models/notification_model.dart';
import 'package:cofit_collective/features/notifications/controller/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Custom exception for type-safe error handling
class NotificationException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const NotificationException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'NotificationException: $message';
}

/// Abstract contract — easy to mock in tests
abstract class INotificationRepository {
  Future<List<NotificationModel>> fetchNotifications({
    required String userId,
    int limit = 30,
    int offset = 0,
  });

  Future<int> fetchUnreadCount(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  Future<void> deleteNotification(String notificationId);
  Stream<NotificationModel> newNotificationStream(String userId);
  Stream<int> unreadCountStream(String userId);
  void dispose();
}

class NotificationRepository implements INotificationRepository {
  final SupabaseClient _supabase;

  RealtimeChannel? _notificationChannel;
  RealtimeChannel? _unreadCountChannel;

  final StreamController<NotificationModel> _newNotifController =
      StreamController<NotificationModel>.broadcast();
  final StreamController<int> _unreadCountController =
      StreamController<int>.broadcast();

  static const String _table = 'notifications';
  static const String _tag = 'NotificationRepository';

  NotificationRepository({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  // ─── FETCH ────────────────────────────────────────────────────────────────

  @override
  Future<List<NotificationModel>> fetchNotifications({
    required String userId,
    int limit = 30,
    int offset = 0,
  }) async {
    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      AppLogger.e(_tag, 'fetchNotifications failed', e);
      throw NotificationException(
        'Failed to load notifications',
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      AppLogger.e(_tag, 'fetchNotifications unexpected error', e);
      throw NotificationException('Unexpected error', originalError: e);
    }
  }

  @override
  Future<int> fetchUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from(_table)
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);
      return (response as List<dynamic>).length;
    } on PostgrestException catch (e) {
      AppLogger.e(_tag, 'fetchUnreadCount failed', e);
      throw NotificationException(
        'Failed to fetch unread count',
        code: e.code,
        originalError: e,
      );
    }
  }

  // ─── WRITE ────────────────────────────────────────────────────────────────

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from(_table)
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId)
          .eq('is_read', false); // idempotent
    } on PostgrestException catch (e) {
      AppLogger.e(_tag, 'markAsRead failed: $notificationId', e);
      throw NotificationException(
        'Failed to mark as read',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from(_table)
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('is_read', false);
    } on PostgrestException catch (e) {
      AppLogger.e(_tag, 'markAllAsRead failed: $userId', e);
      throw NotificationException(
        'Failed to mark all as read',
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase.from(_table).delete().eq('id', notificationId);
    } on PostgrestException catch (e) {
      AppLogger.e(_tag, 'deleteNotification failed: $notificationId', e);
      throw NotificationException(
        'Failed to delete notification',
        code: e.code,
        originalError: e,
      );
    }
  }

  // ─── REALTIME ─────────────────────────────────────────────────────────────

  /// Emits fully-parsed [NotificationModel] on every INSERT for this user
  @override
  Stream<NotificationModel> newNotificationStream(String userId) {
    _notificationChannel?.unsubscribe();

    _notificationChannel = _supabase
        .channel('notif_insert:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            try {
              final model = NotificationModel.fromJson(payload.newRecord);
              if (!_newNotifController.isClosed) {
                _newNotifController.add(model);
              }
            } catch (e) {
              AppLogger.e(_tag, 'Realtime parse error', e);
            }
          },
        )
        .subscribe((status, [error]) {
          if (error != null) {
            AppLogger.e(_tag, 'newNotificationStream subscribe error', error);
          } else {
            AppLogger.d(_tag, 'newNotificationStream: $status');
          }
        });

    return _newNotifController.stream;
  }

  /// Refreshes and emits unread count on INSERT or UPDATE events
  @override
  Stream<int> unreadCountStream(String userId) {
    _unreadCountChannel?.unsubscribe();

    Future<void> refresh() async {
      try {
        final count = await fetchUnreadCount(userId);
        if (!_unreadCountController.isClosed) {
          _unreadCountController.add(count);
        }
      } catch (_) {}
    }

    _unreadCountChannel = _supabase
        .channel('notif_count:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: _table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => refresh(),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: _table,
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => refresh(),
        )
        .subscribe();

    return _unreadCountController.stream;
  }

  // ─── CLEANUP ──────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _notificationChannel?.unsubscribe();
    _unreadCountChannel?.unsubscribe();
    _newNotifController.close();
    _unreadCountController.close();
    AppLogger.d(_tag, 'NotificationRepository disposed');
  }
}
