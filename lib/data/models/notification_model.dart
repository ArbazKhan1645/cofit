/// Notification Type Enum - All notification categories
enum NotificationType {
  // Workout Related
  workoutReminder('workout_reminder'),
  workoutCompleted('workout_completed'),
  newWorkoutAvailable('new_workout_available'),
  weeklyWorkoutsUpdated('weekly_workouts_updated'),

  // Challenge Related
  challengeStarted('challenge_started'),
  challengeEnding('challenge_ending'),
  challengeCompleted('challenge_completed'),
  challengeRankUpdate('challenge_rank_update'),
  newChallengeAvailable('new_challenge_available'),

  // Achievement & Progress
  badgeUnlocked('badge_unlocked'),
  streakMilestone('streak_milestone'),
  progressMilestone('progress_milestone'),

  // Community & Social
  newFollower('new_follower'),
  postLiked('post_liked'),
  postCommented('post_commented'),
  postShared('post_shared'),
  mentionedInPost('mentioned_in_post'),
  recipeShared('recipe_shared'),

  // Subscription & Account
  subscriptionRenewal('subscription_renewal'),
  subscriptionExpiring('subscription_expiring'),
  subscriptionExpired('subscription_expired'),
  paymentFailed('payment_failed'),
  welcomeMessage('welcome_message'),

  // System
  appUpdate('app_update'),
  maintenanceNotice('maintenance_notice'),
  featureAnnouncement('feature_announcement'),
  promotionalOffer('promotional_offer'),
  general('general');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.general,
    );
  }
}

/// Notification Action Type Enum
enum NotificationActionType {
  navigate('navigate'), // Navigate to a screen
  openUrl('open_url'), // Open external URL
  deepLink('deep_link'), // Deep link with arguments
  none('none'); // No action

  final String value;
  const NotificationActionType(this.value);

  static NotificationActionType fromString(String value) {
    return NotificationActionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationActionType.none,
    );
  }
}

/// Notification Priority Enum
enum NotificationPriority {
  low('low'),
  normal('normal'),
  high('high'),
  urgent('urgent');

  final String value;
  const NotificationPriority(this.value);

  static NotificationPriority fromString(String value) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.value == value,
      orElse: () => NotificationPriority.normal,
    );
  }
}

/// Screen Reference for Deep Link Navigation
class NotificationScreenReference {
  final String route; // Route path from AppRoutes
  final String? resourceId; // Optional ID (workoutId, challengeId, postId, etc.)
  final Map<String, dynamic>? extraArgs; // Additional arguments

  const NotificationScreenReference({
    required this.route,
    this.resourceId,
    this.extraArgs,
  });

  factory NotificationScreenReference.fromJson(Map<String, dynamic> json) {
    return NotificationScreenReference(
      route: json['route'] as String,
      resourceId: json['resource_id'] as String?,
      extraArgs: json['extra_args'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'route': route,
      'resource_id': resourceId,
      'extra_args': extraArgs,
    };
  }

  /// Build navigation arguments
  dynamic get navigationArguments {
    if (resourceId != null && extraArgs != null) {
      return {'id': resourceId, ...extraArgs!};
    }
    if (resourceId != null) return resourceId;
    if (extraArgs != null) return extraArgs;
    return null;
  }
}

/// Screen Routes Constants for notifications
/// Use these when creating notifications for type-safe routing
abstract class NotificationRoutes {
  NotificationRoutes._();

  // Workout Routes
  static const workouts = '/workouts';
  static const workoutDetail = '/workout-detail';
  static const workoutPlayer = '/workout-player';
  static const workoutLibrary = '/workout-library';
  static const trainerProfile = '/trainer-profile';

  // Progress Routes
  static const progress = '/progress';
  static const badges = '/badges';
  static const workoutHistory = '/workout-history';

  // Community Routes
  static const community = '/community';
  static const challenges = '/challenges';
  static const challengeDetail = '/challenge-detail';
  static const recipes = '/recipes';
  static const recipeDetail = '/recipe-detail';
  static const postDetail = '/post-detail';
  static const userProfile = '/user-profile';

  // Profile Routes
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const journalEntries = '/journal-entries';
  static const settings = '/settings';
  static const subscriptionManagement = '/subscription-management';

  // Main Routes
  static const main = '/main';
  static const home = '/home';
  static const notifications = '/notifications';
}

/// Notification Model - Push notifications and in-app notifications
/// Supabase Table: notifications
class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String? imageUrl; // Optional image/icon URL
  final NotificationType type;
  final NotificationActionType actionType;
  final NotificationScreenReference? screenReference;
  final String? externalUrl; // For open_url action type
  final NotificationPriority priority;
  final bool isRead;
  final DateTime? readAt;
  final DateTime scheduledFor;
  final bool isSent;
  final DateTime? sentAt;
  final Map<String, dynamic>? metadata; // Additional data
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.imageUrl,
    required this.type,
    this.actionType = NotificationActionType.none,
    this.screenReference,
    this.externalUrl,
    this.priority = NotificationPriority.normal,
    this.isRead = false,
    this.readAt,
    required this.scheduledFor,
    this.isSent = false,
    this.sentAt,
    this.metadata,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      imageUrl: json['image_url'] as String?,
      type: NotificationType.fromString(json['notification_type'] as String),
      actionType:
          NotificationActionType.fromString(json['action_type'] as String? ?? 'none'),
      screenReference: json['screen_reference'] != null
          ? NotificationScreenReference.fromJson(
              json['screen_reference'] as Map<String, dynamic>)
          : null,
      externalUrl: json['external_url'] as String?,
      priority:
          NotificationPriority.fromString(json['priority'] as String? ?? 'normal'),
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      scheduledFor: DateTime.parse(json['scheduled_for'] as String),
      isSent: json['is_sent'] as bool? ?? false,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'image_url': imageUrl,
      'notification_type': type.value,
      'action_type': actionType.value,
      'screen_reference': screenReference?.toJson(),
      'external_url': externalUrl,
      'priority': priority.value,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'scheduled_for': scheduledFor.toIso8601String(),
      'is_sent': isSent,
      'sent_at': sentAt?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'title': title,
      'body': body,
      'image_url': imageUrl,
      'notification_type': type.value,
      'action_type': actionType.value,
      'screen_reference': screenReference?.toJson(),
      'external_url': externalUrl,
      'priority': priority.value,
      'is_read': isRead,
      'scheduled_for': scheduledFor.toIso8601String(),
      'is_sent': isSent,
      'metadata': metadata,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? body,
    String? imageUrl,
    NotificationType? type,
    NotificationActionType? actionType,
    NotificationScreenReference? screenReference,
    String? externalUrl,
    NotificationPriority? priority,
    bool? isRead,
    DateTime? readAt,
    DateTime? scheduledFor,
    bool? isSent,
    DateTime? sentAt,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      actionType: actionType ?? this.actionType,
      screenReference: screenReference ?? this.screenReference,
      externalUrl: externalUrl ?? this.externalUrl,
      priority: priority ?? this.priority,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      isSent: isSent ?? this.isSent,
      sentAt: sentAt ?? this.sentAt,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Get formatted time ago
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  /// Check if notification has navigation action
  bool get hasNavigation =>
      actionType == NotificationActionType.navigate ||
      actionType == NotificationActionType.deepLink;

  /// Check if notification opens external URL
  bool get hasExternalUrl =>
      actionType == NotificationActionType.openUrl && externalUrl != null;

  /// Get notification icon name based on type
  String get iconName {
    switch (type) {
      case NotificationType.workoutReminder:
      case NotificationType.workoutCompleted:
      case NotificationType.newWorkoutAvailable:
      case NotificationType.weeklyWorkoutsUpdated:
        return 'activity';
      case NotificationType.challengeStarted:
      case NotificationType.challengeEnding:
      case NotificationType.challengeCompleted:
      case NotificationType.challengeRankUpdate:
      case NotificationType.newChallengeAvailable:
        return 'cup';
      case NotificationType.badgeUnlocked:
        return 'medal';
      case NotificationType.streakMilestone:
        return 'flash';
      case NotificationType.progressMilestone:
        return 'chart';
      case NotificationType.newFollower:
      case NotificationType.postLiked:
      case NotificationType.postCommented:
      case NotificationType.postShared:
      case NotificationType.mentionedInPost:
        return 'people';
      case NotificationType.recipeShared:
        return 'book';
      case NotificationType.subscriptionRenewal:
      case NotificationType.subscriptionExpiring:
      case NotificationType.subscriptionExpired:
      case NotificationType.paymentFailed:
        return 'card';
      case NotificationType.welcomeMessage:
        return 'gift';
      case NotificationType.appUpdate:
      case NotificationType.maintenanceNotice:
      case NotificationType.featureAnnouncement:
        return 'notification';
      case NotificationType.promotionalOffer:
        return 'tag';
      case NotificationType.general:
        return 'notification';
    }
  }

  /// Check if notification is high priority
  bool get isHighPriority =>
      priority == NotificationPriority.high ||
      priority == NotificationPriority.urgent;

  /// Get notification category for grouping
  String get category {
    switch (type) {
      case NotificationType.workoutReminder:
      case NotificationType.workoutCompleted:
      case NotificationType.newWorkoutAvailable:
      case NotificationType.weeklyWorkoutsUpdated:
        return 'Workouts';
      case NotificationType.challengeStarted:
      case NotificationType.challengeEnding:
      case NotificationType.challengeCompleted:
      case NotificationType.challengeRankUpdate:
      case NotificationType.newChallengeAvailable:
        return 'Challenges';
      case NotificationType.badgeUnlocked:
      case NotificationType.streakMilestone:
      case NotificationType.progressMilestone:
        return 'Achievements';
      case NotificationType.newFollower:
      case NotificationType.postLiked:
      case NotificationType.postCommented:
      case NotificationType.postShared:
      case NotificationType.mentionedInPost:
      case NotificationType.recipeShared:
        return 'Community';
      case NotificationType.subscriptionRenewal:
      case NotificationType.subscriptionExpiring:
      case NotificationType.subscriptionExpired:
      case NotificationType.paymentFailed:
        return 'Subscription';
      case NotificationType.welcomeMessage:
      case NotificationType.appUpdate:
      case NotificationType.maintenanceNotice:
      case NotificationType.featureAnnouncement:
      case NotificationType.promotionalOffer:
      case NotificationType.general:
        return 'General';
    }
  }
}

/// Factory class for creating common notification types
class NotificationFactory {
  NotificationFactory._();

  /// Create workout reminder notification
  static NotificationModel workoutReminder({
    required String id,
    required String userId,
    required String workoutId,
    required String workoutTitle,
    required DateTime scheduledFor,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: 'Time to workout!',
      body: 'Your scheduled workout "$workoutTitle" is waiting for you.',
      type: NotificationType.workoutReminder,
      actionType: NotificationActionType.navigate,
      screenReference: NotificationScreenReference(
        route: NotificationRoutes.workoutDetail,
        resourceId: workoutId,
      ),
      priority: NotificationPriority.high,
      scheduledFor: scheduledFor,
      createdAt: DateTime.now(),
    );
  }

  /// Create badge unlocked notification
  static NotificationModel badgeUnlocked({
    required String id,
    required String userId,
    required String badgeId,
    required String badgeName,
    String? badgeImageUrl,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: 'Badge Unlocked!',
      body: 'Congratulations! You earned the "$badgeName" badge.',
      imageUrl: badgeImageUrl,
      type: NotificationType.badgeUnlocked,
      actionType: NotificationActionType.navigate,
      screenReference: NotificationScreenReference(
        route: NotificationRoutes.badges,
        resourceId: badgeId,
      ),
      priority: NotificationPriority.normal,
      scheduledFor: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Create challenge notification
  static NotificationModel challengeUpdate({
    required String id,
    required String userId,
    required String challengeId,
    required String challengeTitle,
    required NotificationType type,
    required String message,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: challengeTitle,
      body: message,
      type: type,
      actionType: NotificationActionType.navigate,
      screenReference: NotificationScreenReference(
        route: NotificationRoutes.challengeDetail,
        resourceId: challengeId,
      ),
      priority: NotificationPriority.normal,
      scheduledFor: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Create social notification (like, comment, follow)
  static NotificationModel socialActivity({
    required String id,
    required String userId,
    required NotificationType type,
    required String actorName,
    String? postId,
    String? actorAvatarUrl,
  }) {
    String title;
    String body;
    String route;
    String? resourceId;

    switch (type) {
      case NotificationType.newFollower:
        title = 'New Follower';
        body = '$actorName started following you.';
        route = NotificationRoutes.profile;
        resourceId = null;
        break;
      case NotificationType.postLiked:
        title = 'Post Liked';
        body = '$actorName liked your post.';
        route = NotificationRoutes.postDetail;
        resourceId = postId;
        break;
      case NotificationType.postCommented:
        title = 'New Comment';
        body = '$actorName commented on your post.';
        route = NotificationRoutes.postDetail;
        resourceId = postId;
        break;
      case NotificationType.postShared:
        title = 'Post Shared';
        body = '$actorName shared your post.';
        route = NotificationRoutes.postDetail;
        resourceId = postId;
        break;
      default:
        title = 'Activity';
        body = 'You have new activity.';
        route = NotificationRoutes.community;
        resourceId = null;
    }

    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: body,
      imageUrl: actorAvatarUrl,
      type: type,
      actionType: NotificationActionType.navigate,
      screenReference: NotificationScreenReference(
        route: route,
        resourceId: resourceId,
      ),
      priority: NotificationPriority.normal,
      scheduledFor: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Create streak milestone notification
  static NotificationModel streakMilestone({
    required String id,
    required String userId,
    required int streakDays,
  }) {
    return NotificationModel(
      id: id,
      userId: userId,
      title: '$streakDays Day Streak!',
      body: 'Amazing! You\'ve maintained a $streakDays day workout streak. Keep going!',
      type: NotificationType.streakMilestone,
      actionType: NotificationActionType.navigate,
      screenReference: const NotificationScreenReference(
        route: NotificationRoutes.progress,
      ),
      priority: NotificationPriority.high,
      scheduledFor: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Create subscription notification
  static NotificationModel subscriptionNotice({
    required String id,
    required String userId,
    required NotificationType type,
    required String message,
    int? daysRemaining,
  }) {
    String title;
    NotificationPriority priority;

    switch (type) {
      case NotificationType.subscriptionExpiring:
        title = 'Subscription Expiring Soon';
        priority = NotificationPriority.high;
        break;
      case NotificationType.subscriptionExpired:
        title = 'Subscription Expired';
        priority = NotificationPriority.urgent;
        break;
      case NotificationType.subscriptionRenewal:
        title = 'Subscription Renewed';
        priority = NotificationPriority.normal;
        break;
      case NotificationType.paymentFailed:
        title = 'Payment Failed';
        priority = NotificationPriority.urgent;
        break;
      default:
        title = 'Subscription Update';
        priority = NotificationPriority.normal;
    }

    return NotificationModel(
      id: id,
      userId: userId,
      title: title,
      body: message,
      type: type,
      actionType: NotificationActionType.navigate,
      screenReference: const NotificationScreenReference(
        route: NotificationRoutes.subscriptionManagement,
      ),
      priority: priority,
      scheduledFor: DateTime.now(),
      createdAt: DateTime.now(),
      metadata: daysRemaining != null ? {'days_remaining': daysRemaining} : null,
    );
  }
}

/// User Notification Settings Model
/// Supabase Table: user_notification_settings
class UserNotificationSettingsModel {
  final String id;
  final String userId;

  // Push notification toggles
  final bool pushEnabled;
  final bool workoutReminders;
  final bool challengeUpdates;
  final bool achievementAlerts;
  final bool socialNotifications;
  final bool subscriptionAlerts;
  final bool marketingNotifications;

  // Email notification toggles
  final bool emailEnabled;
  final bool emailWeeklySummary;
  final bool emailChallengeUpdates;
  final bool emailPromotions;

  // Quiet hours
  final bool quietHoursEnabled;
  final String? quietHoursStart; // "22:00"
  final String? quietHoursEnd; // "07:00"

  final DateTime createdAt;
  final DateTime updatedAt;

  UserNotificationSettingsModel({
    required this.id,
    required this.userId,
    this.pushEnabled = true,
    this.workoutReminders = true,
    this.challengeUpdates = true,
    this.achievementAlerts = true,
    this.socialNotifications = true,
    this.subscriptionAlerts = true,
    this.marketingNotifications = false,
    this.emailEnabled = true,
    this.emailWeeklySummary = true,
    this.emailChallengeUpdates = true,
    this.emailPromotions = false,
    this.quietHoursEnabled = false,
    this.quietHoursStart,
    this.quietHoursEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserNotificationSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserNotificationSettingsModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      pushEnabled: json['push_enabled'] as bool? ?? true,
      workoutReminders: json['workout_reminders'] as bool? ?? true,
      challengeUpdates: json['challenge_updates'] as bool? ?? true,
      achievementAlerts: json['achievement_alerts'] as bool? ?? true,
      socialNotifications: json['social_notifications'] as bool? ?? true,
      subscriptionAlerts: json['subscription_alerts'] as bool? ?? true,
      marketingNotifications: json['marketing_notifications'] as bool? ?? false,
      emailEnabled: json['email_enabled'] as bool? ?? true,
      emailWeeklySummary: json['email_weekly_summary'] as bool? ?? true,
      emailChallengeUpdates: json['email_challenge_updates'] as bool? ?? true,
      emailPromotions: json['email_promotions'] as bool? ?? false,
      quietHoursEnabled: json['quiet_hours_enabled'] as bool? ?? false,
      quietHoursStart: json['quiet_hours_start'] as String?,
      quietHoursEnd: json['quiet_hours_end'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'push_enabled': pushEnabled,
      'workout_reminders': workoutReminders,
      'challenge_updates': challengeUpdates,
      'achievement_alerts': achievementAlerts,
      'social_notifications': socialNotifications,
      'subscription_alerts': subscriptionAlerts,
      'marketing_notifications': marketingNotifications,
      'email_enabled': emailEnabled,
      'email_weekly_summary': emailWeeklySummary,
      'email_challenge_updates': emailChallengeUpdates,
      'email_promotions': emailPromotions,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'push_enabled': pushEnabled,
      'workout_reminders': workoutReminders,
      'challenge_updates': challengeUpdates,
      'achievement_alerts': achievementAlerts,
      'social_notifications': socialNotifications,
      'subscription_alerts': subscriptionAlerts,
      'marketing_notifications': marketingNotifications,
      'email_enabled': emailEnabled,
      'email_weekly_summary': emailWeeklySummary,
      'email_challenge_updates': emailChallengeUpdates,
      'email_promotions': emailPromotions,
      'quiet_hours_enabled': quietHoursEnabled,
      'quiet_hours_start': quietHoursStart,
      'quiet_hours_end': quietHoursEnd,
    };
  }

  UserNotificationSettingsModel copyWith({
    String? id,
    String? userId,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserNotificationSettingsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      workoutReminders: workoutReminders ?? this.workoutReminders,
      challengeUpdates: challengeUpdates ?? this.challengeUpdates,
      achievementAlerts: achievementAlerts ?? this.achievementAlerts,
      socialNotifications: socialNotifications ?? this.socialNotifications,
      subscriptionAlerts: subscriptionAlerts ?? this.subscriptionAlerts,
      marketingNotifications: marketingNotifications ?? this.marketingNotifications,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      emailWeeklySummary: emailWeeklySummary ?? this.emailWeeklySummary,
      emailChallengeUpdates: emailChallengeUpdates ?? this.emailChallengeUpdates,
      emailPromotions: emailPromotions ?? this.emailPromotions,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if a notification type should be shown based on settings
  bool shouldShowNotification(NotificationType type) {
    if (!pushEnabled) return false;

    switch (type) {
      case NotificationType.workoutReminder:
      case NotificationType.workoutCompleted:
      case NotificationType.newWorkoutAvailable:
      case NotificationType.weeklyWorkoutsUpdated:
        return workoutReminders;

      case NotificationType.challengeStarted:
      case NotificationType.challengeEnding:
      case NotificationType.challengeCompleted:
      case NotificationType.challengeRankUpdate:
      case NotificationType.newChallengeAvailable:
        return challengeUpdates;

      case NotificationType.badgeUnlocked:
      case NotificationType.streakMilestone:
      case NotificationType.progressMilestone:
        return achievementAlerts;

      case NotificationType.newFollower:
      case NotificationType.postLiked:
      case NotificationType.postCommented:
      case NotificationType.postShared:
      case NotificationType.mentionedInPost:
      case NotificationType.recipeShared:
        return socialNotifications;

      case NotificationType.subscriptionRenewal:
      case NotificationType.subscriptionExpiring:
      case NotificationType.subscriptionExpired:
      case NotificationType.paymentFailed:
        return subscriptionAlerts;

      case NotificationType.promotionalOffer:
        return marketingNotifications;

      case NotificationType.welcomeMessage:
      case NotificationType.appUpdate:
      case NotificationType.maintenanceNotice:
      case NotificationType.featureAnnouncement:
      case NotificationType.general:
        return true; // Always show system notifications
    }
  }
}
