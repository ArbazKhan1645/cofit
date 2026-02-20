import 'community_model.dart';

/// Challenge Model - Community fitness challenges
/// Supabase Table: challenges
class ChallengeModel {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final String challengeType; // workout_count, streak, minutes, calories, specific_category
  final String? targetCategory; // For category-specific challenges
  final int targetValue;
  final String targetUnit; // workouts, days, minutes, calories
  final DateTime startDate;
  final DateTime endDate;
  final String status; // upcoming, active, completed
  final String visibility; // public, members_only
  final String? createdBy; // null for system challenges
  final int participantCount;
  final int? maxParticipants;
  final List<String> rules;
  final List<ChallengePrize> prizes;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Client-side flags
  final bool isJoined;
  final int userProgress;
  final int? userRank;

  ChallengeModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.challengeType,
    this.targetCategory,
    required this.targetValue,
    required this.targetUnit,
    required this.startDate,
    required this.endDate,
    this.status = 'active',
    this.visibility = 'public',
    this.createdBy,
    this.participantCount = 0,
    this.maxParticipants,
    this.rules = const [],
    this.prizes = const [],
    this.isFeatured = false,
    required this.createdAt,
    required this.updatedAt,
    this.isJoined = false,
    this.userProgress = 0,
    this.userRank,
  });

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    return ChallengeModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      challengeType: json['challenge_type'] as String,
      targetCategory: json['target_category'] as String?,
      targetValue: json['target_value'] as int,
      targetUnit: json['target_unit'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] as String? ?? 'active',
      visibility: json['visibility'] as String? ?? 'public',
      createdBy: json['created_by'] as String?,
      participantCount: json['participant_count'] as int? ?? 0,
      maxParticipants: json['max_participants'] as int?,
      rules:
          (json['rules'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      prizes: (json['prizes'] as List<dynamic>?)
              ?.map((e) => ChallengePrize.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isFeatured: json['is_featured'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isJoined: json['is_joined'] as bool? ?? false,
      userProgress: json['user_progress'] as int? ?? 0,
      userRank: json['user_rank'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'challenge_type': challengeType,
      'target_category': targetCategory,
      'target_value': targetValue,
      'target_unit': targetUnit,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status,
      'visibility': visibility,
      'created_by': createdBy,
      'participant_count': participantCount,
      'max_participants': maxParticipants,
      'rules': rules,
      'prizes': prizes.map((e) => e.toJson()).toList(),
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Cache-friendly JSON — includes client-side fields (isJoined, userProgress, userRank)
  Map<String, dynamic> toCacheJson() {
    final json = toJson();
    json['is_joined'] = isJoined;
    json['user_progress'] = userProgress;
    json['user_rank'] = userRank;
    return json;
  }

  ChallengeModel copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? challengeType,
    String? targetCategory,
    int? targetValue,
    String? targetUnit,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? visibility,
    String? createdBy,
    int? participantCount,
    int? maxParticipants,
    List<String>? rules,
    List<ChallengePrize>? prizes,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isJoined,
    int? userProgress,
    int? userRank,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      challengeType: challengeType ?? this.challengeType,
      targetCategory: targetCategory ?? this.targetCategory,
      targetValue: targetValue ?? this.targetValue,
      targetUnit: targetUnit ?? this.targetUnit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      createdBy: createdBy ?? this.createdBy,
      participantCount: participantCount ?? this.participantCount,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      rules: rules ?? this.rules,
      prizes: prizes ?? this.prizes,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isJoined: isJoined ?? this.isJoined,
      userProgress: userProgress ?? this.userProgress,
      userRank: userRank ?? this.userRank,
    );
  }

  /// Get days remaining
  int get daysRemaining {
    final diff = endDate.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Get progress percentage
  double get progressPercentage {
    if (targetValue == 0) return 0;
    return (userProgress / targetValue).clamp(0.0, 1.0);
  }

  /// Check if challenge is active
  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Check if challenge is upcoming
  bool get isUpcoming => DateTime.now().isBefore(startDate);

  /// Check if challenge has ended
  bool get hasEnded => DateTime.now().isAfter(endDate);

  /// Check if user completed the challenge
  bool get isCompleted => userProgress >= targetValue;

  /// Get duration in days
  int get durationDays => endDate.difference(startDate).inDays;

  /// Check if spots are limited
  bool get hasLimitedSpots => maxParticipants != null;

  /// Get remaining spots
  int? get remainingSpots =>
      maxParticipants != null ? maxParticipants! - participantCount : null;
}

/// Challenge Prize - Rewards for challenge completion/ranking
class ChallengePrize {
  final int rank; // 1 for first place, 0 for all completers
  final String title;
  final String description;
  final String? badgeId; // Badge awarded
  final int xpReward;

  ChallengePrize({
    required this.rank,
    required this.title,
    required this.description,
    this.badgeId,
    this.xpReward = 0,
  });

  factory ChallengePrize.fromJson(Map<String, dynamic> json) {
    return ChallengePrize(
      rank: json['rank'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      badgeId: json['badge_id'] as String?,
      xpReward: json['xp_reward'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'title': title,
      'description': description,
      'badge_id': badgeId,
      'xp_reward': xpReward,
    };
  }
}

/// User Challenge Model - User's participation in challenges
/// Supabase Table: user_challenges
class UserChallengeModel {
  final String id;
  final String userId;
  final String challengeId;
  final int currentProgress;
  final int rank;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime joinedAt;
  final DateTime lastUpdated;
  final DateTime createdAt;

  // Joined data
  final ChallengeModel? challenge;
  final UserSummary? user;

  UserChallengeModel({
    required this.id,
    required this.userId,
    required this.challengeId,
    this.currentProgress = 0,
    this.rank = 0,
    this.isCompleted = false,
    this.completedAt,
    required this.joinedAt,
    required this.lastUpdated,
    required this.createdAt,
    this.challenge,
    this.user,
  });

  factory UserChallengeModel.fromJson(Map<String, dynamic> json) {
    return UserChallengeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      challengeId: json['challenge_id'] as String,
      currentProgress: json['current_progress'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      challenge: json['challenges'] != null
          ? ChallengeModel.fromJson(json['challenges'] as Map<String, dynamic>)
          : null,
      user: json['users'] != null
          ? UserSummary.fromJson(json['users'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'challenge_id': challengeId,
      'current_progress': currentProgress,
      'rank': rank,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'joined_at': joinedAt.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'challenge_id': challengeId,
      'current_progress': currentProgress,
      'rank': rank,
      'is_completed': isCompleted,
      'completed_at': completedAt?.toIso8601String(),
      'joined_at': joinedAt.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  /// Cache-friendly JSON — includes joined challenge data
  Map<String, dynamic> toCacheJson() {
    final json = toJson();
    if (challenge != null) {
      json['challenges'] = challenge!.toCacheJson();
    }
    if (user != null) {
      json['users'] = user!.toJson();
    }
    return json;
  }

  UserChallengeModel copyWith({
    String? id,
    String? userId,
    String? challengeId,
    int? currentProgress,
    int? rank,
    bool? isCompleted,
    DateTime? completedAt,
    DateTime? joinedAt,
    DateTime? lastUpdated,
    DateTime? createdAt,
    ChallengeModel? challenge,
    UserSummary? user,
  }) {
    return UserChallengeModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      challengeId: challengeId ?? this.challengeId,
      currentProgress: currentProgress ?? this.currentProgress,
      rank: rank ?? this.rank,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      joinedAt: joinedAt ?? this.joinedAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      createdAt: createdAt ?? this.createdAt,
      challenge: challenge ?? this.challenge,
      user: user ?? this.user,
    );
  }

  /// Get progress percentage
  double get progressPercentage {
    if (challenge == null || challenge!.targetValue == 0) return 0.0;
    return (currentProgress / challenge!.targetValue).clamp(0.0, 1.0);
  }
}

/// Challenge Leaderboard Entry - For displaying rankings
class ChallengeLeaderboardEntry {
  final int rank;
  final String userId;
  final String? fullName;
  final String? username;
  final String? avatarUrl;
  final int progress;
  final int progressPercentage;

  ChallengeLeaderboardEntry({
    required this.rank,
    required this.userId,
    this.fullName,
    this.username,
    this.avatarUrl,
    required this.progress,
    required this.progressPercentage,
  });

  factory ChallengeLeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return ChallengeLeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      progress: json['progress'] as int,
      progressPercentage: json['progress_percentage'] as int,
    );
  }

  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    if (username != null && username!.isNotEmpty) return username!;
    return 'User';
  }
}

/// Challenge Participant Model - Enriched participant data for admin views
class ChallengeParticipantModel {
  final String id;
  final String userId;
  final String? fullName;
  final String? username;
  final String? avatarUrl;
  final int currentProgress;
  final int rank;
  final bool isCompleted;
  final DateTime? completedAt;
  final DateTime joinedAt;

  ChallengeParticipantModel({
    required this.id,
    required this.userId,
    this.fullName,
    this.username,
    this.avatarUrl,
    required this.currentProgress,
    this.rank = 0,
    this.isCompleted = false,
    this.completedAt,
    required this.joinedAt,
  });

  factory ChallengeParticipantModel.fromJson(Map<String, dynamic> json) {
    return ChallengeParticipantModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['users']?['full_name'] as String?,
      username: json['users']?['username'] as String?,
      avatarUrl: json['users']?['avatar_url'] as String?,
      currentProgress: json['current_progress'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      joinedAt: DateTime.parse(json['joined_at'] as String),
    );
  }

  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    if (username != null && username!.isNotEmpty) return username!;
    return 'User';
  }
}

/// Challenge Stats Model - Computed analytics for a challenge
class ChallengeStatsModel {
  final int totalParticipants;
  final int completedCount;
  final double avgProgress; // 0.0 - 1.0
  final int activeCount;

  ChallengeStatsModel({
    required this.totalParticipants,
    required this.completedCount,
    required this.avgProgress,
    required this.activeCount,
  });

  double get completionRate =>
      totalParticipants > 0 ? completedCount / totalParticipants : 0.0;
}
