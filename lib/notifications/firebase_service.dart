// ============================================================
// firebase_notification_service.dart
// Firebase Cloud Messaging - server se aane wale notifications
// Social, Challenges, Achievements, Subscription
// ============================================================

import 'dart:developer' as developer;
import 'package:cofit_collective/notifications/local_service.dart';
import 'package:cofit_collective/notifications/types.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Top-level background message handler (Firebase requirement)
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  developer.log(
    'Background FCM message received: ${message.messageId}',
    name: 'FCM',
  );

  // Background mein local notification show karo
  final localService = LocalNotificationService();
  await localService.initialize();
  await _handleFirebaseMessage(message, localService);
}

Future<void> _handleFirebaseMessage(
  RemoteMessage message,
  LocalNotificationService localService,
) async {
  final data = message.data;
  final channelStr = data['channel'] as String?;
  final notifType = _parseChannel(channelStr);

  if (notifType == null) return;

  final payload = NotificationPayload(
    title: message.notification?.title ?? data['title'] ?? '',
    body: message.notification?.body ?? data['body'] ?? '',
    channel: notifType,
    data: data,
    imageUrl:
        message.notification?.android?.imageUrl ??
        message.notification?.apple?.imageUrl,
    actionRoute: data['action_route'] as String?,
  );

  await localService.showImmediate(
    id: DateTime.now().millisecondsSinceEpoch % 100000,
    payload: payload,
  );
}

NotificationChannel? _parseChannel(String? channelStr) {
  if (channelStr == null) return null;
  for (final channel in NotificationChannel.values) {
    if (channel.channelId == channelStr) return channel;
  }
  return null;
}

// ============================================================
// Firebase Notification Service Class
// ============================================================

class FirebaseNotificationService {
  FirebaseNotificationService._internal();
  static final FirebaseNotificationService _instance =
      FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final LocalNotificationService _localService = LocalNotificationService();

  String? _fcmToken;
  bool _initialized = false;

  // Token change callback - Supabase mein save karne k liye
  void Function(String token)? onTokenRefresh;
  // App open hone par notification tap callback
  void Function(Map<String, dynamic> data, String? route)? onNotificationTap;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  Future<void> initialize({
    void Function(String token)? onTokenRefresh,
    void Function(Map<String, dynamic> data, String? route)? onNotificationTap,
  }) async {
    if (_initialized) return;

    this.onTokenRefresh = onTokenRefresh;
    this.onNotificationTap = onNotificationTap;

    // Background handler register karo
    FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

    // Permission request
    await _requestPermission();

    // FCM Token lo
    await _initializeToken();

    // Foreground messages handle karo
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // App background se open hone par
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // App completely closed thi aur notification se khuli
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }

    _initialized = true;
    developer.log('FirebaseNotificationService initialized', name: 'FCM');
  }

  // ============================================================
  // PERMISSIONS
  // ============================================================

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    developer.log(
      'FCM Permission: ${settings.authorizationStatus}',
      name: 'FCM',
    );
  }

  // ============================================================
  // TOKEN MANAGEMENT
  // ============================================================

  Future<String?> _initializeToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      developer.log('FCM Token: $_fcmToken', name: 'FCM');

      if (_fcmToken != null) {
        onTokenRefresh?.call(_fcmToken!);
      }

      // Token refresh listener
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        onTokenRefresh?.call(newToken);
        developer.log('FCM Token refreshed', name: 'FCM');
      });

      return _fcmToken;
    } catch (e) {
      developer.log('FCM token error: $e', name: 'FCM', level: 900);
      return null;
    }
  }

  String? get fcmToken => _fcmToken;

  Future<String?> refreshToken() async {
    await _messaging.deleteToken();
    _fcmToken = await _messaging.getToken();
    return _fcmToken;
  }

  // ============================================================
  // MESSAGE HANDLERS
  // ============================================================

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    developer.log(
      'Foreground FCM: ${message.notification?.title}',
      name: 'FCM',
    );

    // Foreground mein local notification show karo (Firebase auto-show nahi karta)
    await _handleFirebaseMessage(message, _localService);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    developer.log('App opened from notification: ${message.data}', name: 'FCM');

    final route = message.data['action_route'] as String?;
    onNotificationTap?.call(message.data, route);
  }

  // ============================================================
  // TOPIC SUBSCRIPTIONS
  // Specific notification categories subscribe/unsubscribe karo
  // ============================================================

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    developer.log('Subscribed to topic: $topic', name: 'FCM');
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    developer.log('Unsubscribed from topic: $topic', name: 'FCM');
  }

  /// User ki settings k mutabiq topics subscribe karo
  Future<void> syncTopicSubscriptions({
    required bool challengeUpdates,
    required bool socialNotifications,
    required bool achievementAlerts,
    required bool communityNotifications,
    required bool marketingNotifications,
    String? userId,
  }) async {
    // Challenge topics
    if (challengeUpdates) {
      await subscribeToTopic('challenge_updates');
    } else {
      await unsubscribeFromTopic('challenge_updates');
    }

    // Social topics
    if (socialNotifications) {
      await subscribeToTopic('social_activity');
    } else {
      await unsubscribeFromTopic('social_activity');
    }

    // Achievement topics
    if (achievementAlerts) {
      await subscribeToTopic('achievements');
    } else {
      await unsubscribeFromTopic('achievements');
    }

    // Community topics
    if (communityNotifications) {
      await subscribeToTopic('community');
    } else {
      await unsubscribeFromTopic('community');
    }

    // Marketing
    if (marketingNotifications) {
      await subscribeToTopic('marketing');
    } else {
      await unsubscribeFromTopic('marketing');
    }

    // User-specific topic
    if (userId != null) {
      await subscribeToTopic('user_$userId');
    }
  }

  // ============================================================
  // SETTINGS SYNC
  // ============================================================

  Future<void> setAutoInitEnabled(bool enabled) async {
    await _messaging.setAutoInitEnabled(enabled);
  }

  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    _fcmToken = null;
  }
}
