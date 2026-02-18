// ============================================================
// fcm_notification_sender.dart
// Firebase Admin SDK approach - OAuth2 access token se
// Service Account key use karta hai (secure)
// ============================================================

import 'dart:convert';
import 'dart:developer' as developer;
import 'package:cofit_collective/core/services/auth_service.dart';
import 'package:cofit_collective/notifications/types.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

/// FCM Notification Sender - Firebase Admin SDK
/// Service Account credentials se OAuth2 token generate karta hai
class FcmNotificationSender {
  FcmNotificationSender._internal();
  static final FcmNotificationSender _instance =
      FcmNotificationSender._internal();
  factory FcmNotificationSender() => _instance;

  // Firebase Service Account credentials
  // Firebase Console > Project Settings > Service Accounts > Generate new private key
  static const String _projectId = 'cofit-400b2';
  static const Map<String, dynamic> _serviceAccountJson = {
    "type": "service_account",
    "project_id": "cofit-400b2",
    "private_key_id": "d400e38b8bb757e9605be8a05193280764c7e3c5",
    "private_key":
        "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDDWl6L+Tdsvjgo\nwmHWbnITjedtUcuWauNd3ZXGzSPF50wwmSHrtF4xlgMYjXNmSXIQorEZIJin9/NZ\nJnlrV/SzawR421MX5Ps2gmC8TTFK+OQTfE4nLfJuCSd/Eb5y8PZQED4GKl6QCqCD\nvcN6+vNMyVRVG0c+KIs2I9YWyocOc1fKbL0A5AA1x7Ylr4fvK3U6d/xnzass5veJ\ngJ9oUS1c1v1j2GA75Ljh3W7X2ewtqN/QH8ilaFGzbAMWAfI0xNV5/LyN0wgKJfw+\nLHH6ShGI3o7d1pP2paNDsoXI/Kxw9Jo2vFBvmLACZALgN30ZOIf4XzEFfhP4M1H3\nCQBwhFy/AgMBAAECggEABGgr/NkcYFdUM1TKLzw33oVkj0uKlU2qDmhlcQQpfhC5\n4Av8UDYC3ucpVh4oYP1f5rtwCLot9DrAwC54ciRPg8TH+JzK0MhYP2BALFfTdDae\n1K6iXRwaVw+Y8IhV6F2PSf7BI7WZtnHP/pSP1ENMRmQTpWMwUJ1KiAGza1MRstUm\nMoM6f3rU8N4/Xt09DW547X5I4tJ8glVgx/+vVfM6hli6qTH6EBQBwJBYYo//hBfP\nguV63PX178q48dx1XZ8LsCaj7cfEcJCg55ZTdYOH5e+R39+c/5APR9IDUxtDxfAC\nhbAtDL4gtcBVbKQ9XD6UVDT8xSRutFXpNT1bhHAd2QKBgQDiW44Xd6FaDWRrOTSj\nIQPAMvuaViNm0Dy4NkFUi1bv/4wL25Jg5uABeOj4rC6ndDVx6P5wzQLUQKoy7kEd\nMIQcPGTsVt4ZDNJAWnnLyx7S0ZWz2CURQBB4EsilP/3Te1g/vu/iKtNQ3M5i5SXZ\nrP94FbeAZUfZ6ab3NRJaBmFU9wKBgQDc72kimwJtdexojfVP9yGRMRxI8V1c6ASE\nVnZWrwcq0ty+21dslwflsyE2y0adzyAeB8n+KR4mbCBifJlpSzjKml1/cIDG4A1G\nsc5kb4nj31XdE0bYb3x5k5umGmKWyk0xfOyeo7XvMAYlZWqJVixYbzb2oi90PLKQ\nBH2F7O1seQKBgQCO8VY3x5ojLhXeCFAPPAgMVaXBfuf4Q0Q06D41T5DlGjGsQ0qa\n2vFWvK4Sa1lC8gXWG1aikTRaKUPRyddgwYSL+C+bd/flRc14Sipj4a9jXmr1GWe/\nDv/Xc7U1dcWqyVefWcpOvtCXXfkPRrmyTqc9hClPcaYAHKcNsXwXUbQhXQKBgQDI\n+X/J2vf6WqsS8Q+WDliamvH/6I/lU6nIOF6tu8npSqdDdoOwZDLq4Gf2UDOMmj29\nE5jLetvSV8mdzXpALg0bQBCNPOnn/ygUhuoYst3cS+zvjfmEKOYyMfQExTupr51I\nxzr3lDSLwEPXAMpI4/qy93goIqDIO+6y02Lb0QqpAQKBgFCW3pIjRvgvL95gRVx3\nnplLCxS3pITUO8NRoK9NrEavsUlPr1ZwUAvToieARqQET/Tqnex3TwZU6BGXyF1t\nJ04574AHz/2sppIEB5cusTMyDxvEfqYNFedPJupgg9/iRFZLENKjBq+nviJhyHqC\nc/uhaNjCA0l3VOyIAEuR2Qg2\n-----END PRIVATE KEY-----\n",
    "client_email":
        "firebase-adminsdk-fbsvc@cofit-400b2.iam.gserviceaccount.com",
    "client_id": "113079221388089212701",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_x509_cert_url":
        "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40cofit-400b2.iam.gserviceaccount.com",
    "universe_domain": "googleapis.com",
  };

  // FCM v1 API endpoint
  static const String _fcmScope =
      'https://www.googleapis.com/auth/firebase.messaging';
  String get _fcmEndpoint =>
      'https://fcm.googleapis.com/v1/projects/$_projectId/messages:send';

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
  Future<void> sendPostLikeNotification({
    required String postOwnerId,
    required String postId,
    required String likerName,
    String? postPreview,
  }) async {
    final fcmToken = await _getUserFcmToken(postOwnerId);
    if (fcmToken == null) return;

    await _sendFcmMessage(
      token: fcmToken,
      notification: {
        'title': '❤️ $likerName',
        'body': postPreview != null
            ? '"$postPreview" - ye post pasand aayi!'
            : 'Tumhari post like ki!',
      },
      data: {
        'channel': NotificationChannel.socialActivity.channelId,
        'social_type': SocialNotificationType.like.name,
        'post_id': postId,
        'actor_name': likerName,
        'action_route': '/community/post/$postId',
      },
    );
  }

  /// Comment notification bhejo
  Future<void> sendCommentNotification({
    required String postOwnerId,
    required String postId,
    required String commenterName,
    required String commentText,
    String? postPreview,
  }) async {
    final fcmToken = await _getUserFcmToken(postOwnerId);
    if (fcmToken == null) return;

    await _sendFcmMessage(
      token: fcmToken,
      notification: {
        'title': '💬 $commenterName',
        'body': commentText.length > 100
            ? '${commentText.substring(0, 97)}...'
            : commentText,
      },
      data: {
        'channel': NotificationChannel.socialActivity.channelId,
        'social_type': SocialNotificationType.comment.name,
        'post_id': postId,
        'actor_name': commenterName,
        'comment_text': commentText,
        'action_route': '/community/post/$postId',
      },
    );
  }

  /// Follow notification bhejo
  Future<void> sendFollowNotification({
    required String followedUserId,
    required String followerName,
    required String followerAvatar,
  }) async {
    final fcmToken = await _getUserFcmToken(followedUserId);
    if (fcmToken == null) return;

    await _sendFcmMessage(
      token: fcmToken,
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
    final tokens = await _getMultipleUserTokens(followerIds);
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
    final tokens = await _getMultipleUserTokens(mentionedUserIds);
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
    final tokens = await _getMultipleUserTokens(invitedUserIds);
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
    final tokens = await _getMultipleUserTokens(participantIds);
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
    final fcmToken = await _getUserFcmToken(userId);
    if (fcmToken == null) return;

    await _sendFcmMessage(
      token: fcmToken,
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
      final fcmToken = await _getUserFcmToken(userId);
      if (fcmToken == null) continue;

      final rank = userRanks[userId] ?? 0;
      await _sendFcmMessage(
        token: fcmToken,
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
    final fcmToken = await _getUserFcmToken(userId);
    if (fcmToken == null) return;

    await _sendFcmMessage(
      token: fcmToken,
      notification: {'title': achievementTitle, 'body': achievementBody},
      data: {
        'channel': NotificationChannel.achievementAlert.channelId,
        'achievement_id': achievementId,
        'action_route': '/achievements/$achievementId',
      },
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
    final fcmToken = await _getUserFcmToken(userId);
    if (fcmToken == null) return;

    String title;
    String body;

    if (daysLeft == 1) {
      title = '🚨 Plan Kal Expire!';
      body = 'Kal tumhara $planName plan khatam hoga. Abhi renew karo!';
    } else {
      title = '⚠️ Plan Expiring Soon';
      body = 'Tumhara $planName plan $daysLeft din mein expire hoga.';
    }

    await _sendFcmMessage(
      token: fcmToken,
      notification: {'title': title, 'body': body},
      data: {
        'channel': NotificationChannel.subscriptionAlert.channelId,
        'subscription_type': 'expiring',
        'days_remaining': daysLeft.toString(),
        'action_route': '/settings/subscription',
      },
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
    final fcmToken = await _getUserFcmToken(communityOwnerId);
    if (fcmToken == null) return;

    await _sendFcmMessage(
      token: fcmToken,
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
    );
  }

  // ============================================================
  // PRIVATE HELPER METHODS
  // ============================================================

  /// Single user ka FCM token lo
  Future<String?> _getUserFcmToken(String userId) async {
    try {
      // Supabase se user profile fetch karo
      final result = await AuthService.to.fetchUserById(userId);
      if (result != null) {
        return result.fcmToken;
      } else {
        return null;
      }
    } catch (e) {
      developer.log(
        'FCM token fetch failed: $e',
        name: 'FCMSender',
        level: 900,
      );
      return null;
    }
  }

  /// Multiple users ke FCM tokens ek saath lo
  Future<List<String>> _getMultipleUserTokens(List<String> userIds) async {
    final tokens = <String>[];

    try {
      // TODO: Batch fetch optimize karo with Supabase .in() query
      for (final userId in userIds) {
        final token = await _getUserFcmToken(userId);
        if (token != null) tokens.add(token);
      }
    } catch (e) {
      developer.log(
        'Batch token fetch failed: $e',
        name: 'FCMSender',
        level: 900,
      );
    }

    return tokens;
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
        return false;
      }
    } catch (e) {
      developer.log('FCM send error: $e', name: 'FCMSender', level: 900);
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
}
