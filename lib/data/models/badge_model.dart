/// Badge Model - Achievement badge definitions
/// Supabase Table: badges
class BadgeModel {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String category; // streak, workout, community, milestone, special
  final String requirementType; // workouts_completed, streak_days, challenges_won, etc.
  final int requiredCount;
  final int xpReward;
  final String rarity; // common, rare, epic, legendary
  final bool isActive;
  final int sortOrder;
  final DateTime createdAt;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.category,
    required this.requirementType,
    this.requiredCount = 1,
    this.xpReward = 0,
    this.rarity = 'common',
    this.isActive = true,
    this.sortOrder = 0,
    required this.createdAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['icon_url'] as String,
      category: json['category'] as String,
      requirementType: json['requirement_type'] as String,
      requiredCount: json['required_count'] as int? ?? 1,
      xpReward: json['xp_reward'] as int? ?? 0,
      rarity: json['rarity'] as String? ?? 'common',
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_url': iconUrl,
      'category': category,
      'requirement_type': requirementType,
      'required_count': requiredCount,
      'xp_reward': xpReward,
      'rarity': rarity,
      'is_active': isActive,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  BadgeModel copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    String? category,
    String? requirementType,
    int? requiredCount,
    int? xpReward,
    String? rarity,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
  }) {
    return BadgeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      category: category ?? this.category,
      requirementType: requirementType ?? this.requirementType,
      requiredCount: requiredCount ?? this.requiredCount,
      xpReward: xpReward ?? this.xpReward,
      rarity: rarity ?? this.rarity,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// User Achievement Model - Tracks which badges users have earned
/// Supabase Table: user_achievements
class UserAchievementModel {
  final String id;
  final String userId;
  final String badgeId;
  final DateTime earnedAt;
  final int currentProgress;
  final bool isNew; // Flag for showing notification
  final DateTime createdAt;

  // Joined data (optional, populated from joins)
  final BadgeModel? badge;

  UserAchievementModel({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.earnedAt,
    this.currentProgress = 0,
    this.isNew = true,
    required this.createdAt,
    this.badge,
  });

  factory UserAchievementModel.fromJson(Map<String, dynamic> json) {
    return UserAchievementModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      badgeId: json['badge_id'] as String,
      earnedAt: DateTime.parse(json['earned_at'] as String),
      currentProgress: json['current_progress'] as int? ?? 0,
      isNew: json['is_new'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      badge: json['badges'] != null
          ? BadgeModel.fromJson(json['badges'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'badge_id': badgeId,
      'earned_at': earnedAt.toIso8601String(),
      'current_progress': currentProgress,
      'is_new': isNew,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'badge_id': badgeId,
      'earned_at': earnedAt.toIso8601String(),
      'current_progress': currentProgress,
      'is_new': isNew,
    };
  }

  UserAchievementModel copyWith({
    String? id,
    String? userId,
    String? badgeId,
    DateTime? earnedAt,
    int? currentProgress,
    bool? isNew,
    DateTime? createdAt,
    BadgeModel? badge,
  }) {
    return UserAchievementModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      badgeId: badgeId ?? this.badgeId,
      earnedAt: earnedAt ?? this.earnedAt,
      currentProgress: currentProgress ?? this.currentProgress,
      isNew: isNew ?? this.isNew,
      createdAt: createdAt ?? this.createdAt,
      badge: badge ?? this.badge,
    );
  }

  /// Check if achievement is complete
  bool get isComplete => badge != null ? currentProgress >= badge!.requiredCount : false;

  /// Get progress percentage
  double get progressPercentage {
    if (badge == null || badge!.requiredCount == 0) return 0.0;
    return (currentProgress / badge!.requiredCount).clamp(0.0, 1.0);
  }
}

/// Achievement Progress Model - Tracks progress towards locked achievements
/// Supabase Table: achievement_progress
class AchievementProgressModel {
  final String id;
  final String userId;
  final String badgeId;
  final int currentProgress;
  final DateTime lastUpdated;
  final DateTime createdAt;

  // Joined data
  final BadgeModel? badge;

  AchievementProgressModel({
    required this.id,
    required this.userId,
    required this.badgeId,
    required this.currentProgress,
    required this.lastUpdated,
    required this.createdAt,
    this.badge,
  });

  factory AchievementProgressModel.fromJson(Map<String, dynamic> json) {
    return AchievementProgressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      badgeId: json['badge_id'] as String,
      currentProgress: json['current_progress'] as int,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      badge: json['badges'] != null
          ? BadgeModel.fromJson(json['badges'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'badge_id': badgeId,
      'current_progress': currentProgress,
      'last_updated': lastUpdated.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'badge_id': badgeId,
      'current_progress': currentProgress,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  double get progressPercentage {
    if (badge == null || badge!.requiredCount == 0) return 0.0;
    return (currentProgress / badge!.requiredCount).clamp(0.0, 1.0);
  }

  bool get isComplete => badge != null ? currentProgress >= badge!.requiredCount : false;
}
