// ============================================================
// fcm_notification_sender.dart
// Firebase Admin SDK approach - OAuth2 access token se
// Service Account key use karta hai (secure)
// ============================================================

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:cofit_collective/core/services/supabase_service.dart';
import 'package:cofit_collective/notifications/types.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

/// FCM Notification Sender - Firebase Admin SDK
/// Service Account credentials se OAuth2 token generate karta hai
class FcmNotificationSender {
  FcmNotificationSender._internal();
  static final FcmNotificationSender _instance =
      FcmNotificationSender._internal();
  factory FcmNotificationSender() => _instance;

  // FCM v1 API endpoint
  static const String _fcmScope =
      'https://www.googleapis.com/auth/firebase.messaging';

  String get _projectId => dotenv.env['FIREBASE_PROJECT_ID']!;

  String get _fcmEndpoint =>
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

  /// Build service account JSON from .env variables
  Map<String, dynamic> get _serviceAccountJson => {
    "type": "service_account",
    "project_id": dotenv.env['FIREBASE_PROJECT_ID']!,
    "private_key_id": dotenv.env['FCM_PRIVATE_KEY_ID']!,
    "private_key": dotenv.env['FCM_PRIVATE_KEY']!.replaceAll(r'\n', '\n'),
    "client_email": dotenv.env['FCM_CLIENT_EMAIL']!,
    "client_id": dotenv.env['FCM_CLIENT_ID']!,
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/${Uri.encodeComponent(dotenv.env['FCM_CLIENT_EMAIL']!)}",
    "universe_domain": "googleapis.com",
  };

  // OAuth2 access token cache
  String? _accessToken;
  DateTime? _tokenExpiry;

  // ============================================================
  // ACCESS TOKEN MANAGEMENT
  // ============================================================

  /// OAuth2 access token generate karo service account se
  Future<String> _getAccessToken() async {
    // Agar token valid hai to reuse karo
    if (_accessToken != null && _tokenExpiry != null) {
      if (DateTime.now().isBefore(
        _tokenExpiry!.subtract(const Duration(minutes: 5)),
      )) {
        return _accessToken!;
      }
    }

    try {
      // Service account credentials se client banao
      final accountCredentials = auth.ServiceAccountCredentials.fromJson(
        _serviceAccountJson,
      );

      // Access token fetch karo
      final client = await auth.clientViaServiceAccount(accountCredentials, [
        _fcmScope,
      ]);

      final accessToken = client.credentials.accessToken.data;
      _accessToken = accessToken;
      _tokenExpiry = client.credentials.accessToken.expiry;

      client.close();

      developer.log('OAuth2 access token generated', name: 'FCMSender');
      return accessToken;
    } catch (e) {
      developer.log(
        'Access token generation failed: $e',
        name: 'FCMSender',
        level: 900,
      );
      rethrow;
    }
  }

  // ============================================================
  // 👍 SOCIAL NOTIFICATIONS - Like, Comment, Follow, etc.
  // ============================================================

  /// Post like notification bhejo post creator ko
  /// Facebook-style: "Arbaz and 26 others liked your post"
  Future<void> sendPostLikeNotification({
    required String postOwnerId,
    required String postId,
    required String likerName,
    String? postPreview,
    int totalLikes = 1,
  }) async {
    // Facebook-style body
    String body;
    if (totalLikes <= 1) {
      body = postPreview != null
          ? '$likerName liked your post: "$postPreview"'
          : '$likerName liked your post';
    } else {
      final othersCount = totalLikes - 1;
      final othersText = othersCount == 1 ? '1 other' : '$othersCount others';
      body = postPreview != null
          ? '$likerName and $othersText liked your post: "$postPreview"'
          : '$likerName and $othersText liked your post';
    }

    await _sendToUser(
      userId: postOwnerId,
      notification: {
        'title': '❤️ Post Liked!',
        'body': body,
      },
      data: {
        'channel': NotificationChannel.socialActivity.channelId,
        'social_type': SocialNotificationType.like.name,
        'post_id': postId,
        'actor_name': likerName,
        'action_route': '/community/post/$postId',
      },
      settingField: 'social_notifications',
    );
  }

  /// Comment notification bhejo
  /// Facebook-style: "Arbaz and 5 others commented on your post"
  Future<void> sendCommentNotification({
    required String postOwnerId,
    required String postId,
    required String commenterName,
    required String commentText,
    String? postPreview,
    int totalComments = 1,
  }) async {
    // Facebook-style title
    String title;
    if (totalComments <= 1) {
      title = '💬 $commenterName commented on your post';
    } else {
      final othersCount = totalComments - 1;
      final othersText = othersCount == 1 ? '1 other' : '$othersCount others';
      title = '💬 $commenterName and $othersText commented on your post';
    }

    final truncatedComment = commentText.length > 100
        ? '${commentText.substring(0, 97)}...'
        : commentText;

    await _sendToUser(
      userId: postOwnerId,
      notification: {
        'title': title,
        'body': '"$truncatedComment"',
      },
      data: {
        'channel': NotificationChannel.socialActivity.channelId,
        'social_type': SocialNotificationType.comment.name,
        'post_id': postId,
        'actor_name': commenterName,
        'comment_text': commentText,
        'action_route': '/community/post/$postId',
      },
      settingField: 'social_notifications',
    );
  }

  /// Post save/bookmark notification bhejo post creator ko
  Future<void> sendPostSavedNotification({
    required String postOwnerId,
    required String postId,
    required String saverName,
    String? postPreview,
  }) async {
    final body = postPreview != null
        ? '$saverName saved your post: "$postPreview"'
        : '$saverName saved your post';

    await _sendToUser(
      userId: postOwnerId,
      notification: {
        'title': '🔖 Post Saved!',
        'body': body,
      },
      data: {
        'channel': NotificationChannel.socialActivity.channelId,
        'social_type': SocialNotificationType.postShare.name,
        'post_id': postId,
        'actor_name': saverName,
        'action_route': '/community/post/$postId',
      },
      settingField: 'social_notifications',
    );
  }

  /// Follow notification bhejo
  Future<void> sendFollowNotification({
    required String followedUserId,
    required String followerName,
    required String followerAvatar,
  }) async {
    await _sendToUser(
      userId: followedUserId,
      notification: {
        'title': '👤 $followerName',
        'body': 'Ab tumhe follow karta/karti hai!',
      },
      data: {
        'channel': NotificationChannel.socialActivity.channelId,
        'social_type': SocialNotificationType.follow.name,
        'actor_name': followerName,
        'action_route': '/profile/$followerName',
      },
      settingField: 'social_notifications',
    );
  }

  /// New post notification - followers ko bhejo
  Future<void> sendNewPostNotification({
    required List<String> followerIds,
    required String posterName,
    required String postId,
    String? postPreview,
    String? imageUrl,
  }) async {
    final tokens = await _getMultipleUserTokens(
      followerIds,
      settingField: 'social_notifications',
    );
    if (tokens.isEmpty) return;

    await _sendMulticastMessage(
      tokens: tokens,
      notification: {
        'title': '📸 $posterName',
        'body': postPreview ?? 'Ne naya post share kiya hai!',
      },
      data: {
        'channel': NotificationChannel.socialActivity.channelId,
        'social_type': SocialNotificationType.newPost.name,
        'post_id': postId,
        'actor_name': posterName,
        'action_route': '/community/post/$postId',
      },
      imageUrl: imageUrl,
    );
  }

  /// Mention notification - tagged users ko bhejo
  Future<void> sendMentionNotification({
    required List<String> mentionedUserIds,
    required String mentionerName,
    required String postId,
    required String context,
  }) async {
    final tokens = await _getMultipleUserTokens(
      mentionedUserIds,
      settingField: 'social_notifications',
    );
    if (tokens.isEmpty) return;

    await _sendMulticastMessage(
      tokens: tokens,
      notification: {
        'title': '🔔 $mentionerName ne mention kiya',
        'body': context,
      },
      data: {
        'channel': NotificationChannel.socialActivity.channelId,
        'social_type': SocialNotificationType.mention.name,
        'post_id': postId,
        'actor_name': mentionerName,
        'action_route': '/community/post/$postId',
      },
    );
  }

  // ============================================================
  // 🏁 CHALLENGE NOTIFICATIONS
  // ============================================================

  /// Challenge invite notification
  Future<void> sendChallengeInvite({
    required List<String> invitedUserIds,
    required String challengeId,
    required String challengeName,
    required String inviterName,
  }) async {
    final tokens = await _getMultipleUserTokens(
      invitedUserIds,
      settingField: 'challenge_updates',
    );
    if (tokens.isEmpty) return;

    await _sendMulticastMessage(
      tokens: tokens,
      notification: {
        'title': '🏁 Challenge Invite!',
        'body':
            '$inviterName ne tumhe "$challengeName" challenge mein invite kiya!',
      },
      data: {
        'channel': NotificationChannel.challengeUpdate.channelId,
        'challenge_id': challengeId,
        'challenge_type': ChallengeNotificationType.invited.name,
        'actor_name': inviterName,
        'action_route': '/challenges/$challengeId',
      },
    );
  }

  /// Challenge start notification - participants ko
  Future<void> sendChallengeStarted({
    required List<String> participantIds,
    required String challengeId,
    required String challengeName,
  }) async {
    final tokens = await _getMultipleUserTokens(
      participantIds,
      settingField: 'challenge_updates',
    );
    if (tokens.isEmpty) return;

    await _sendMulticastMessage(
      tokens: tokens,
      notification: {
        'title': '🚀 Challenge Shuru!',
        'body':
            '"$challengeName" ab start ho gaya hai. Apni best performance do!',
      },
      data: {
        'channel': NotificationChannel.challengeUpdate.channelId,
        'challenge_id': challengeId,
        'challenge_type': ChallengeNotificationType.started.name,
        'action_route': '/challenges/$challengeId',
      },
    );
  }

  /// Leaderboard change notification
  Future<void> sendLeaderboardUpdate({
    required String userId,
    required String challengeId,
    required String challengeName,
    required int newRank,
    required int totalParticipants,
  }) async {
    await _sendToUser(
      userId: userId,
      notification: {
        'title': '📈 Leaderboard Update!',
        'body':
            '"$challengeName": Tumhari rank #$newRank/$totalParticipants ho gayi!',
      },
      data: {
        'channel': NotificationChannel.challengeUpdate.channelId,
        'challenge_id': challengeId,
        'challenge_type': ChallengeNotificationType.leaderboardChange.name,
        'current_rank': newRank.toString(),
        'total_participants': totalParticipants.toString(),
        'action_route': '/challenges/$challengeId',
      },
      settingField: 'challenge_updates',
    );
  }

  /// Challenge complete notification
  Future<void> sendChallengeCompleted({
    required List<String> participantIds,
    required String challengeId,
    required String challengeName,
    required Map<String, int> userRanks, // userId -> rank
  }) async {
    for (final userId in participantIds) {
      final rank = userRanks[userId] ?? 0;
      await _sendToUser(
        userId: userId,
        notification: {
          'title': '🎉 Challenge Complete!',
          'body': '"$challengeName" complete! Final rank: #$rank 🏆',
        },
        data: {
          'channel': NotificationChannel.challengeUpdate.channelId,
          'challenge_id': challengeId,
          'challenge_type': ChallengeNotificationType.completed.name,
          'current_rank': rank.toString(),
          'action_route': '/challenges/$challengeId',
        },
        settingField: 'challenge_updates',
      );
    }
  }

  // ============================================================
  // 🏆 ACHIEVEMENT NOTIFICATIONS
  // ============================================================

  /// Achievement unlock notification (if needed server-side)
  Future<void> sendAchievementUnlock({
    required String userId,
    required String achievementId,
    required String achievementTitle,
    required String achievementBody,
  }) async {
    await _sendToUser(
      userId: userId,
      notification: {'title': achievementTitle, 'body': achievementBody},
      data: {
        'channel': NotificationChannel.achievementAlert.channelId,
        'achievement_id': achievementId,
        'action_route': '/achievements/$achievementId',
      },
      settingField: 'achievement_alerts',
    );
  }

  // ============================================================
  // 💳 SUBSCRIPTION NOTIFICATIONS (Server-side cron job se call hoga)
  // ============================================================

  Future<void> sendSubscriptionExpiring({
    required String userId,
    required int daysLeft,
    required String planName,
  }) async {
    String title;
    String body;

    if (daysLeft == 1) {
      title = '🚨 Plan Kal Expire!';
      body = 'Kal tumhara $planName plan khatam hoga. Abhi renew karo!';
    } else {
      title = '⚠️ Plan Expiring Soon';
      body = 'Tumhara $planName plan $daysLeft din mein expire hoga.';
    }

    await _sendToUser(
      userId: userId,
      notification: {'title': title, 'body': body},
      data: {
        'channel': NotificationChannel.subscriptionAlert.channelId,
        'subscription_type': 'expiring',
        'days_remaining': daysLeft.toString(),
        'action_route': '/settings/subscription',
      },
      settingField: 'subscription_alerts',
    );
  }

  // ============================================================
  // 👥 COMMUNITY NOTIFICATIONS
  // ============================================================

  /// Community join notification - community admin ko
  Future<void> sendCommunityJoinNotification({
    required String communityOwnerId,
    required String communityId,
    required String communityName,
    required String newMemberName,
  }) async {
    await _sendToUser(
      userId: communityOwnerId,
      notification: {
        'title': '🎉 New Member!',
        'body': '$newMemberName ne $communityName join kar li!',
      },
      data: {
        'channel': NotificationChannel.socialActivity.channelId,
        'social_type': SocialNotificationType.communityJoin.name,
        'community_id': communityId,
        'actor_name': newMemberName,
        'action_route': '/community/$communityId',
      },
      settingField: 'social_notifications',
    );
  }

  // ============================================================
  // 📋 ADMIN - POST APPROVAL / REJECTION NOTIFICATIONS
  // ============================================================

  /// Post approved - post creator ko notify + community topic par broadcast
  Future<void> sendPostApprovedNotification({
    required String postOwnerId,
    required String postId,
    required String postAuthorName,
    String? postPreview,
  }) async {
    // 1. Post creator ko notify karo
    await _sendToUser(
      userId: postOwnerId,
      notification: {
        'title': '✅ Post Approved!',
        'body': 'Your post has been approved and is now live!',
      },
      data: {
        'channel': NotificationChannel.socialActivity.channelId,
        'social_type': 'post_approved',
        'post_id': postId,
        'action_route': '/community/post/$postId',
      },
      settingField: 'social_notifications',
    );

    // 2. Sab community subscribers ko notify karo via topic
    final body = postPreview != null
        ? '$postAuthorName shared a new post: "$postPreview"'
        : '$postAuthorName shared a new post!';

    await _sendFcmTopicMessage(
      topic: 'community',
      notification: {
        'title': '📢 New Post Available!',
        'body': body,
      },
      data: {
        'channel': NotificationChannel.socialActivity.channelId,
        'social_type': SocialNotificationType.newPost.name,
        'post_id': postId,
        'actor_name': postAuthorName,
        'action_route': '/community/post/$postId',
      },
    );
  }

  /// Post rejected - sirf post creator ko notify karo
  Future<void> sendPostRejectedNotification({
    required String postOwnerId,
    required String postId,
    String? rejectionReason,
  }) async {
    final body = rejectionReason != null && rejectionReason.isNotEmpty
        ? 'Your post was not approved. Reason: $rejectionReason'
        : 'Your post was not approved. Please review community guidelines.';

    await _sendToUser(
      userId: postOwnerId,
      notification: {
        'title': '❌ Post Not Approved',
        'body': body,
      },
      data: {
        'channel': NotificationChannel.socialActivity.channelId,
        'social_type': 'post_rejected',
        'post_id': postId,
        'action_route': '/community/post/$postId',
      },
      settingField: 'social_notifications',
    );
  }

  // ============================================================
  // PRIVATE HELPER METHODS
  // ============================================================

  /// Fetch a recipient's notification settings from Supabase.
  /// Returns null on failure (fail-open: allow the notification).
  Future<Map<String, dynamic>?> _getUserSettings(String userId) async {
    try {
      final row = await SupabaseService.to.client
          .from('user_notification_settings')
          .select(
            'push_enabled, social_notifications, challenge_updates, achievement_alerts, subscription_alerts, marketing_notifications',
          )
          .eq('user_id', userId)
          .maybeSingle();
      return row;
    } catch (_) {
      return null;
    }
  }

  /// Send notification to ALL devices of a single user.
  /// [settingField] — if provided, checks recipient's settings before sending.
  Future<void> _sendToUser({
    required String userId,
    required Map<String, String> notification,
    required Map<String, String> data,
    String? imageUrl,
    String? settingField,
  }) async {
    // Check recipient's settings before sending
    if (settingField != null) {
      final settings = await _getUserSettings(userId);
      if (settings != null) {
        if (settings['push_enabled'] == false) return;
        if (settings[settingField] == false) return;
      }
    }

    final tokens = await _getUserFcmTokens(userId);
    if (tokens.isEmpty) return;
    await _sendMulticastMessage(
      tokens: tokens,
      notification: notification,
      data: data,
      imageUrl: imageUrl,
    );
  }

  /// Get ALL FCM tokens for a user (multi-device support).
  /// Queries `user_devices` table, filters out devices inactive for 30+ days.
  Future<List<String>> _getUserFcmTokens(String userId) async {
    try {
      final cutoff =
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String();

      final rows = await SupabaseService.to.client
          .from('user_devices')
          .select('fcm_token')
          .eq('user_id', userId)
          .gte('last_active', cutoff);

      return (rows as List)
          .map((r) => r['fcm_token'] as String)
          .where((t) => t.isNotEmpty)
          .toList();
    } catch (e) {
      developer.log(
        'FCM tokens fetch failed: $e',
        name: 'FCMSender',
        level: 900,
      );
      return [];
    }
  }

  /// Multiple users ke tokens ek saath lo (batch via Supabase .in_())
  /// [settingField] — if provided, filters out users who have that setting or
  /// push_enabled set to false.
  Future<List<String>> _getMultipleUserTokens(
    List<String> userIds, {
    String? settingField,
  }) async {
    try {
      var filteredIds = userIds;

      // Filter out users who disabled this notification type
      if (settingField != null && userIds.isNotEmpty) {
        final settingsRows = await SupabaseService.to.client
            .from('user_notification_settings')
            .select('user_id, push_enabled, $settingField')
            .inFilter('user_id', userIds);

        final disabledIds = (settingsRows as List)
            .where(
              (r) =>
                  r['push_enabled'] == false || r[settingField] == false,
            )
            .map((r) => r['user_id'] as String)
            .toSet();

        filteredIds =
            userIds.where((id) => !disabledIds.contains(id)).toList();
        if (filteredIds.isEmpty) return [];
      }

      final cutoff =
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String();

      final rows = await SupabaseService.to.client
          .from('user_devices')
          .select('fcm_token')
          .inFilter('user_id', filteredIds)
          .gte('last_active', cutoff);

      return (rows as List)
          .map((r) => r['fcm_token'] as String)
          .where((t) => t.isNotEmpty)
          .toList();
    } catch (e) {
      developer.log(
        'Batch token fetch failed: $e',
        name: 'FCMSender',
        level: 900,
      );
      return [];
    }
  }

  /// Single device ko notification bhejo (FCM v1 API)
  Future<bool> _sendFcmMessage({
    required String token,
    required Map<String, String> notification,
    required Map<String, String> data,
    String? imageUrl,
  }) async {
    try {
      final accessToken = await _getAccessToken();

      final message = {
        'message': {
          'token': token,
          'notification': {
            'title': notification['title'],
            'body': notification['body'],
            if (imageUrl != null) 'image': imageUrl,
          },
          'data': data,
          'android': {
            'priority': 'high',
            'notification': {
              'channel_id': data['channel'] ?? 'social_activity',
              'sound': 'default',
              'default_vibrate_timings': true,
            },
          },
          'apns': {
            'payload': {
              'aps': {'sound': 'default', 'badge': 1},
            },
            'fcm_options': {'image': imageUrl},
          },
        },
      };

      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        developer.log('FCM sent successfully', name: 'FCMSender');
        return true;
      } else {
        developer.log(
          'FCM send failed: ${response.statusCode} - ${response.body}',
          name: 'FCMSender',
          level: 900,
        );

        // Token invalid/unregistered — remove stale device row
        final bodyStr = response.body.toLowerCase();
        if (response.statusCode == 404 ||
            bodyStr.contains('unregistered') ||
            bodyStr.contains('not_found')) {
          _removeStaleToken(token);
        }

        return false;
      }
    } catch (e) {
      developer.log('FCM send error: $e', name: 'FCMSender', level: 900);
      return false;
    }
  }

  /// Remove a stale FCM token from user_devices (fire-and-forget)
  void _removeStaleToken(String token) {
    SupabaseService.to.client
        .from('user_devices')
        .delete()
        .eq('fcm_token', token)
        .then((_) {
      developer.log('Stale token removed', name: 'FCMSender');
    }).catchError((_) {});
  }

  /// Firebase topic par notification bhejo (sab subscribers ko)
  Future<bool> _sendFcmTopicMessage({
    required String topic,
    required Map<String, String> notification,
    required Map<String, String> data,
    String? imageUrl,
  }) async {
    try {
      final accessToken = await _getAccessToken();

      final message = {
        'message': {
          'topic': topic,
          'notification': {
            'title': notification['title'],
            'body': notification['body'],
            if (imageUrl != null) 'image': imageUrl,
          },
          'data': data,
          'android': {
            'priority': 'high',
            'notification': {
              'channel_id': data['channel'] ?? 'social_activity',
              'sound': 'default',
            },
          },
          'apns': {
            'payload': {
              'aps': {'sound': 'default', 'badge': 1},
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        developer.log(
          'FCM topic message sent to: $topic',
          name: 'FCMSender',
        );
        return true;
      } else {
        developer.log(
          'FCM topic send failed: ${response.statusCode} - ${response.body}',
          name: 'FCMSender',
          level: 900,
        );
        return false;
      }
    } catch (e) {
      developer.log('FCM topic send error: $e', name: 'FCMSender', level: 900);
      return false;
    }
  }

  /// Multiple devices ko notification bhejo (batch send)
  Future<void> _sendMulticastMessage({
    required List<String> tokens,
    required Map<String, String> notification,
    required Map<String, String> data,
    String? imageUrl,
  }) async {
    // FCM v1 API mein batch send nahi hai directly
    // Parallel requests bhejo efficiently
    final futures = tokens.map(
      (token) => _sendFcmMessage(
        token: token,
        notification: notification,
        data: data,
        imageUrl: imageUrl,
      ),
    );

    await Future.wait(futures);
  }

  // ============================================================
  // 📢 ADMIN BROADCAST — Marketing / Promotional Notifications
  // ============================================================

  /// Get ALL active FCM tokens from user_devices (for broadcast).
  /// Filters out users who have push_enabled = false.
  Future<List<String>> _getAllActiveTokens() async {
    try {
      final cutoff =
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String();

      // Get all active device tokens with user_id
      final rows = await SupabaseService.to.client
          .from('user_devices')
          .select('fcm_token, user_id')
          .gte('last_active', cutoff);

      if ((rows as List).isEmpty) return [];

      // Get users who have push disabled
      final disabledRows = await SupabaseService.to.client
          .from('user_notification_settings')
          .select('user_id')
          .eq('push_enabled', false);

      final disabledIds = (disabledRows as List)
          .map((r) => r['user_id'] as String)
          .toSet();

      return rows
          .where((r) => !disabledIds.contains(r['user_id']))
          .map((r) => r['fcm_token'] as String)
          .where((t) => t.isNotEmpty)
          .toList();
    } catch (e) {
      developer.log(
        'All tokens fetch failed: $e',
        name: 'FCMSender',
        level: 900,
      );
      return [];
    }
  }

  /// Admin broadcast — send to all users or specific user IDs.
  /// Returns the number of tokens the notification was sent to.
  Future<int> sendAdminBroadcast({
    required String title,
    required String body,
    String? imageUrl,
    List<String>? targetUserIds,
  }) async {
    List<String> tokens;
    if (targetUserIds != null && targetUserIds.isNotEmpty) {
      tokens = await _getMultipleUserTokens(targetUserIds);
    } else {
      tokens = await _getAllActiveTokens();
    }

    if (tokens.isEmpty) return 0;

    // Send in chunks of 500 (parallel within each chunk)
    for (int i = 0; i < tokens.length; i += 500) {
      final end = (i + 500 < tokens.length) ? i + 500 : tokens.length;
      final chunk = tokens.sublist(i, end);
      await _sendMulticastMessage(
        tokens: chunk,
        notification: {'title': title, 'body': body},
        data: {
          'channel': NotificationChannel.subscriptionAlert.channelId,
          'type': 'admin_broadcast',
        },
        imageUrl: imageUrl,
      );
    }

    return tokens.length;
  }
}
