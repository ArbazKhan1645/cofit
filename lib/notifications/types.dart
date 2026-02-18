// ============================================================
// notification_types.dart
// Sare notification types, enums, aur payload models
// ============================================================

enum NotificationChannel {
  // Firebase + Local dono
  challengeUpdate,
  achievementAlert,
  subscriptionAlert,
  socialActivity, // like, comment, follow, new post
  // Sirf Local (background service calculate karta hai)
  workoutReminder,
  dailyGoalReminder,
  streakWarning,
  hydrationReminder,
  restDayReminder,
  progressUpdate,
  communityChallenge,
}

enum NotificationDeliveryType { firebaseOnly, localOnly, both }

// Har channel ki delivery type
extension NotificationChannelExtension on NotificationChannel {
  NotificationDeliveryType get deliveryType {
    switch (this) {
      // Sirf Local - background service ya schedule
      case NotificationChannel.workoutReminder:
      case NotificationChannel.dailyGoalReminder:
      case NotificationChannel.streakWarning:
      case NotificationChannel.hydrationReminder:
      case NotificationChannel.restDayReminder:
      case NotificationChannel.progressUpdate:
        return NotificationDeliveryType.localOnly;

      // Dono - server bhi bhejta hai, local bhi show kar sakte
      case NotificationChannel.challengeUpdate:
      case NotificationChannel.achievementAlert:
      case NotificationChannel.subscriptionAlert:
      case NotificationChannel.socialActivity:
      case NotificationChannel.communityChallenge:
        return NotificationDeliveryType.both;
    }
  }

  String get channelId {
    switch (this) {
      case NotificationChannel.workoutReminder:
        return 'workout_reminders';
      case NotificationChannel.dailyGoalReminder:
        return 'daily_goal_reminders';
      case NotificationChannel.streakWarning:
        return 'streak_warnings';
      case NotificationChannel.hydrationReminder:
        return 'hydration_reminders';
      case NotificationChannel.restDayReminder:
        return 'rest_day_reminders';
      case NotificationChannel.progressUpdate:
        return 'progress_updates';
      case NotificationChannel.challengeUpdate:
        return 'challenge_updates';
      case NotificationChannel.achievementAlert:
        return 'achievement_alerts';
      case NotificationChannel.subscriptionAlert:
        return 'subscription_alerts';
      case NotificationChannel.socialActivity:
        return 'social_activity';
      case NotificationChannel.communityChallenge:
        return 'community_challenges';
    }
  }

  String get channelName {
    switch (this) {
      case NotificationChannel.workoutReminder:
        return 'Workout Reminders';
      case NotificationChannel.dailyGoalReminder:
        return 'Daily Goal Reminders';
      case NotificationChannel.streakWarning:
        return 'Streak Warnings';
      case NotificationChannel.hydrationReminder:
        return 'Hydration Reminders';
      case NotificationChannel.restDayReminder:
        return 'Rest Day Reminders';
      case NotificationChannel.progressUpdate:
        return 'Progress Updates';
      case NotificationChannel.challengeUpdate:
        return 'Challenge Updates';
      case NotificationChannel.achievementAlert:
        return 'Achievement Alerts';
      case NotificationChannel.subscriptionAlert:
        return 'Subscription Alerts';
      case NotificationChannel.socialActivity:
        return 'Social Activity';
      case NotificationChannel.communityChallenge:
        return 'Community Challenges';
    }
  }
}

// ============================================================
// Notification Payload Models
// ============================================================

class NotificationPayload {
  final String title;
  final String body;
  final NotificationChannel channel;
  final Map<String, dynamic> data;
  final String? imageUrl;
  final String? actionRoute; // App mai navigate karne k liye

  const NotificationPayload({
    required this.title,
    required this.body,
    required this.channel,
    this.data = const {},
    this.imageUrl,
    this.actionRoute,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'body': body,
    'channel': channel.channelId,
    'data': data,
    if (imageUrl != null) 'imageUrl': imageUrl,
    if (actionRoute != null) 'actionRoute': actionRoute,
  };
}

// ============================================================
// Scheduled Notification Model (Local only)
// ============================================================

class ScheduledNotificationConfig {
  final int id;
  final NotificationPayload payload;
  final DateTime scheduledTime;
  final bool repeating;
  final RepeatInterval? repeatInterval;

  const ScheduledNotificationConfig({
    required this.id,
    required this.payload,
    required this.scheduledTime,
    this.repeating = false,
    this.repeatInterval,
  });
}

enum RepeatInterval { daily, weekly, custom }

// ============================================================
// Social Notification Types
// ============================================================

enum SocialNotificationType {
  like,
  comment,
  newPost,
  follow,
  mention,
  communityJoin,
  postShare,
}

extension SocialNotificationTypeExtension on SocialNotificationType {
  String get displayName {
    switch (this) {
      case SocialNotificationType.like:
        return 'liked your post';
      case SocialNotificationType.comment:
        return 'commented on your post';
      case SocialNotificationType.newPost:
        return 'shared a new post';
      case SocialNotificationType.follow:
        return 'started following you';
      case SocialNotificationType.mention:
        return 'mentioned you';
      case SocialNotificationType.communityJoin:
        return 'joined your community';
      case SocialNotificationType.postShare:
        return 'shared your post';
    }
  }
}

// ============================================================
// Challenge Notification Types
// ============================================================

enum ChallengeNotificationType {
  invited,
  started,
  progressUpdate,
  completed,
  leaderboardChange,
  deadline,
  newParticipant,
}

// ============================================================
// Achievement Types
// ============================================================

enum AchievementType {
  firstWorkout,
  streak7Days,
  streak30Days,
  streak100Days,
  goalReached,
  personalBest,
  communityMilestone,
  challengeWon,
  caloriesMilestone,
  workoutCountMilestone,
}

extension AchievementTypeExtension on AchievementType {
  String get title {
    switch (this) {
      case AchievementType.firstWorkout:
        return '🎉 First Workout Complete!';
      case AchievementType.streak7Days:
        return '🔥 7 Day Streak!';
      case AchievementType.streak30Days:
        return '💪 30 Day Streak!';
      case AchievementType.streak100Days:
        return '🏆 100 Day Streak Legend!';
      case AchievementType.goalReached:
        return '✅ Goal Reached!';
      case AchievementType.personalBest:
        return '🚀 New Personal Best!';
      case AchievementType.communityMilestone:
        return '👥 Community Milestone!';
      case AchievementType.challengeWon:
        return '🥇 Challenge Won!';
      case AchievementType.caloriesMilestone:
        return '🔥 Calorie Milestone!';
      case AchievementType.workoutCountMilestone:
        return '💯 Workout Milestone!';
    }
  }
}
