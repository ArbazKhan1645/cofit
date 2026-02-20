/// Community Post Model - User posts in the community feed
/// Supabase Table: posts
class PostModel {
  final String id;
  final String userId;
  final String content;
  final List<String> imageUrls;
  final String? videoUrl;
  final String postType; // text, image, video, workout_share, achievement, recipe_share
  final String? linkedWorkoutId;
  final String? linkedRecipeId;
  final String? linkedAchievementId;
  final bool isPublic;
  final String approvalStatus; // pending, approved, rejected
  final String? rejectionReason;
  final Map<String, dynamic> metadata;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final List<String> tags;
  final bool isPinned;
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data
  final UserSummary? author;
  final bool isLikedByMe;
  final bool isSavedByMe;

  PostModel({
    required this.id,
    required this.userId,
    required this.content,
    this.imageUrls = const [],
    this.videoUrl,
    required this.postType,
    this.linkedWorkoutId,
    this.linkedRecipeId,
    this.linkedAchievementId,
    this.isPublic = true,
    this.approvalStatus = 'approved',
    this.rejectionReason,
    this.metadata = const {},
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.tags = const [],
    this.isPinned = false,
    this.isEdited = false,
    this.editedAt,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.isLikedByMe = false,
    this.isSavedByMe = false,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      videoUrl: json['video_url'] as String?,
      postType: json['post_type'] as String,
      linkedWorkoutId: json['linked_workout_id'] as String?,
      linkedRecipeId: json['linked_recipe_id'] as String?,
      linkedAchievementId: json['linked_achievement_id'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      approvalStatus: json['approval_status'] as String? ?? 'approved',
      rejectionReason: json['rejection_reason'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      sharesCount: json['shares_count'] as int? ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      isPinned: json['is_pinned'] as bool? ?? false,
      isEdited: json['is_edited'] as bool? ?? false,
      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      author: json['users'] != null
          ? UserSummary.fromJson(json['users'] as Map<String, dynamic>)
          : null,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      isSavedByMe: json['is_saved_by_me'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'image_urls': imageUrls,
      'video_url': videoUrl,
      'post_type': postType,
      'linked_workout_id': linkedWorkoutId,
      'linked_recipe_id': linkedRecipeId,
      'linked_achievement_id': linkedAchievementId,
      'is_public': isPublic,
      'approval_status': approvalStatus,
      'rejection_reason': rejectionReason,
      'metadata': metadata,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'shares_count': sharesCount,
      'tags': tags,
      'is_pinned': isPinned,
      'is_edited': isEdited,
      'edited_at': editedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'content': content,
      'image_urls': imageUrls,
      'video_url': videoUrl,
      'post_type': postType,
      'linked_workout_id': linkedWorkoutId,
      'linked_recipe_id': linkedRecipeId,
      'linked_achievement_id': linkedAchievementId,
      'is_public': isPublic,
      'tags': tags,
      if (metadata.isNotEmpty) 'metadata': metadata,
    };
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? content,
    List<String>? imageUrls,
    String? videoUrl,
    String? postType,
    String? linkedWorkoutId,
    String? linkedRecipeId,
    String? linkedAchievementId,
    bool? isPublic,
    String? approvalStatus,
    String? rejectionReason,
    Map<String, dynamic>? metadata,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    List<String>? tags,
    bool? isPinned,
    bool? isEdited,
    DateTime? editedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserSummary? author,
    bool? isLikedByMe,
    bool? isSavedByMe,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      postType: postType ?? this.postType,
      linkedWorkoutId: linkedWorkoutId ?? this.linkedWorkoutId,
      linkedRecipeId: linkedRecipeId ?? this.linkedRecipeId,
      linkedAchievementId: linkedAchievementId ?? this.linkedAchievementId,
      isPublic: isPublic ?? this.isPublic,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      metadata: metadata ?? this.metadata,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      isSavedByMe: isSavedByMe ?? this.isSavedByMe,
    );
  }

  /// Check if post has media
  bool get hasMedia => imageUrls.isNotEmpty || videoUrl != null;

  /// Get author name
  String get authorName => author?.displayName ?? 'Anonymous';

  /// Get author avatar
  String? get authorAvatar => author?.avatarUrl;

  /// Get formatted time ago
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Approval status helpers
  bool get isPending => approvalStatus == 'pending';
  bool get isApproved => approvalStatus == 'approved';
  bool get isRejected => approvalStatus == 'rejected';

  // Structured post type helpers
  bool get isChallengePost => metadata.containsKey('challenge_title');
  bool get isWorkoutRecipePost => metadata.containsKey('recipe_title');

  ChallengePostMetadata? get challengeMetadata =>
      isChallengePost ? ChallengePostMetadata.fromJson(metadata) : null;

  WorkoutRecipeMetadata? get workoutRecipeMetadata =>
      isWorkoutRecipePost ? WorkoutRecipeMetadata.fromJson(metadata) : null;
}

/// User Summary - Minimal user info for joins
class UserSummary {
  final String id;
  final String? fullName;
  final String? username;
  final String? avatarUrl;

  UserSummary({
    required this.id,
    this.fullName,
    this.username,
    this.avatarUrl,
  });

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
    };
  }

  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    if (username != null && username!.isNotEmpty) return username!;
    return 'User';
  }
}

/// Comment Model - Comments on posts
/// Supabase Table: comments
class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String? parentCommentId; // For replies
  final String content;
  final int likesCount;
  final int repliesCount;
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data
  final UserSummary? author;
  final bool isLikedByMe;
  final List<CommentModel>? replies;

  CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentCommentId,
    required this.content,
    this.likesCount = 0,
    this.repliesCount = 0,
    this.isEdited = false,
    this.editedAt,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.isLikedByMe = false,
    this.replies,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      parentCommentId: json['parent_comment_id'] as String?,
      content: json['content'] as String,
      likesCount: json['likes_count'] as int? ?? 0,
      repliesCount: json['replies_count'] as int? ?? 0,
      isEdited: json['is_edited'] as bool? ?? false,
      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      author: json['users'] != null
          ? UserSummary.fromJson(json['users'] as Map<String, dynamic>)
          : null,
      isLikedByMe: json['is_liked_by_me'] as bool? ?? false,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'parent_comment_id': parentCommentId,
      'content': content,
      'likes_count': likesCount,
      'replies_count': repliesCount,
      'is_edited': isEdited,
      'edited_at': editedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'post_id': postId,
      'user_id': userId,
      'parent_comment_id': parentCommentId,
      'content': content,
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? parentCommentId,
    String? content,
    int? likesCount,
    int? repliesCount,
    bool? isEdited,
    DateTime? editedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserSummary? author,
    bool? isLikedByMe,
    List<CommentModel>? replies,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      content: content ?? this.content,
      likesCount: likesCount ?? this.likesCount,
      repliesCount: repliesCount ?? this.repliesCount,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      isLikedByMe: isLikedByMe ?? this.isLikedByMe,
      replies: replies ?? this.replies,
    );
  }

  /// Check if this is a reply
  bool get isReply => parentCommentId != null;

  /// Get formatted time ago
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(createdAt);

    if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}mo';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

/// Like Model - Likes on posts and comments
/// Supabase Table: likes
class LikeModel {
  final String id;
  final String userId;
  final String? postId;
  final String? commentId;
  final String likeType; // post, comment
  final DateTime createdAt;

  LikeModel({
    required this.id,
    required this.userId,
    this.postId,
    this.commentId,
    required this.likeType,
    required this.createdAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      postId: json['post_id'] as String?,
      commentId: json['comment_id'] as String?,
      likeType: json['like_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'comment_id': commentId,
      'like_type': likeType,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'post_id': postId,
      'comment_id': commentId,
      'like_type': likeType,
    };
  }
}

/// Share Model - Shares of posts
/// Supabase Table: shares
class ShareModel {
  final String id;
  final String userId;
  final String postId;
  final String shareType; // internal, external (copied link)
  final String? shareMessage;
  final String? platform; // twitter, facebook, instagram, copy_link
  final DateTime createdAt;

  ShareModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.shareType,
    this.shareMessage,
    this.platform,
    required this.createdAt,
  });

  factory ShareModel.fromJson(Map<String, dynamic> json) {
    return ShareModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      postId: json['post_id'] as String,
      shareType: json['share_type'] as String,
      shareMessage: json['share_message'] as String?,
      platform: json['platform'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'share_type': shareType,
      'share_message': shareMessage,
      'platform': platform,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'post_id': postId,
      'share_type': shareType,
      'share_message': shareMessage,
      'platform': platform,
    };
  }
}

/// Saved Post Model - User's saved/bookmarked posts
/// Supabase Table: saved_posts
class SavedPostModel {
  final String id;
  final String userId;
  final String postId;
  final DateTime savedAt;
  final DateTime createdAt;

  // Joined data
  final PostModel? post;

  SavedPostModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.savedAt,
    required this.createdAt,
    this.post,
  });

  factory SavedPostModel.fromJson(Map<String, dynamic> json) {
    return SavedPostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      postId: json['post_id'] as String,
      savedAt: DateTime.parse(json['saved_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      post: json['posts'] != null
          ? PostModel.fromJson(json['posts'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'saved_at': savedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'post_id': postId,
      'saved_at': savedAt.toIso8601String(),
    };
  }
}

/// Follow Model - User following relationships
/// Supabase Table: follows
class FollowModel {
  final String id;
  final String followerId; // The user who is following
  final String followingId; // The user being followed
  final DateTime createdAt;

  // Joined data
  final UserSummary? follower;
  final UserSummary? following;

  FollowModel({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.createdAt,
    this.follower,
    this.following,
  });

  factory FollowModel.fromJson(Map<String, dynamic> json) {
    return FollowModel(
      id: json['id'] as String,
      followerId: json['follower_id'] as String,
      followingId: json['following_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      follower: json['follower'] != null
          ? UserSummary.fromJson(json['follower'] as Map<String, dynamic>)
          : null,
      following: json['following'] != null
          ? UserSummary.fromJson(json['following'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'following_id': followingId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'follower_id': followerId,
      'following_id': followingId,
    };
  }
}

// ============================================
// STRUCTURED POST METADATA CLASSES
// ============================================

/// Metadata for challenge winning posts (postType: 'achievement')
class ChallengePostMetadata {
  final String challengeId;
  final String challengeTitle;
  final String challengeType; // workout_count, streak, minutes, calories
  final int userRank;
  final int totalProgress;
  final int targetValue;
  final String targetUnit; // workouts, days, minutes, calories
  final DateTime? completedAt;
  final String? personalMessage;

  ChallengePostMetadata({
    required this.challengeId,
    required this.challengeTitle,
    required this.challengeType,
    required this.userRank,
    required this.totalProgress,
    required this.targetValue,
    required this.targetUnit,
    this.completedAt,
    this.personalMessage,
  });

  factory ChallengePostMetadata.fromJson(Map<String, dynamic> json) {
    return ChallengePostMetadata(
      challengeId: json['challenge_id'] as String? ?? '',
      challengeTitle: json['challenge_title'] as String? ?? '',
      challengeType: json['challenge_type'] as String? ?? '',
      userRank: json['user_rank'] as int? ?? 0,
      totalProgress: json['total_progress'] as int? ?? 0,
      targetValue: json['target_value'] as int? ?? 0,
      targetUnit: json['target_unit'] as String? ?? '',
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      personalMessage: json['personal_message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'challenge_id': challengeId,
      'challenge_title': challengeTitle,
      'challenge_type': challengeType,
      'user_rank': userRank,
      'total_progress': totalProgress,
      'target_value': targetValue,
      'target_unit': targetUnit,
      if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
      if (personalMessage != null) 'personal_message': personalMessage,
    };
  }

  String get rankDisplay => '#$userRank';

  String get rankLabel {
    switch (userRank) {
      case 1:
        return 'Gold';
      case 2:
        return 'Silver';
      case 3:
        return 'Bronze';
      default:
        return 'Top $userRank';
    }
  }

  double get progressPercentage {
    if (targetValue == 0) return 0;
    return (totalProgress / targetValue).clamp(0.0, 1.0);
  }
}

/// Single exercise in a workout recipe
class WorkoutRecipeExercise {
  final String name;
  final int? reps;
  final int? durationSeconds;
  final int sets;
  final int restSeconds;

  WorkoutRecipeExercise({
    required this.name,
    this.reps,
    this.durationSeconds,
    required this.sets,
    this.restSeconds = 30,
  });

  factory WorkoutRecipeExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutRecipeExercise(
      name: json['name'] as String? ?? '',
      reps: json['reps'] as int?,
      durationSeconds: json['duration_seconds'] as int?,
      sets: json['sets'] as int? ?? 1,
      restSeconds: json['rest_seconds'] as int? ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (reps != null) 'reps': reps,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      'sets': sets,
      'rest_seconds': restSeconds,
    };
  }

  /// Display format: '3x12' for reps or '3x30s' for duration
  String get displayFormat {
    if (reps != null) return '${sets}x$reps';
    if (durationSeconds != null) return '${sets}x${durationSeconds}s';
    return '$sets sets';
  }
}

/// Metadata for workout recipe posts (postType: 'recipe_share')
class WorkoutRecipeMetadata {
  final String recipeTitle;
  final String goal; // fat_loss, muscle_gain, strength, endurance, beginner_friendly
  final List<WorkoutRecipeExercise> exercises;
  final int totalDurationMinutes;
  final String difficulty; // beginner, intermediate, advanced
  final String? notes;

  WorkoutRecipeMetadata({
    required this.recipeTitle,
    required this.goal,
    required this.exercises,
    required this.totalDurationMinutes,
    required this.difficulty,
    this.notes,
  });

  factory WorkoutRecipeMetadata.fromJson(Map<String, dynamic> json) {
    return WorkoutRecipeMetadata(
      recipeTitle: json['recipe_title'] as String? ?? '',
      goal: json['goal'] as String? ?? 'fat_loss',
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) =>
                  WorkoutRecipeExercise.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalDurationMinutes: json['total_duration_minutes'] as int? ?? 0,
      difficulty: json['difficulty'] as String? ?? 'beginner',
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recipe_title': recipeTitle,
      'goal': goal,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      'total_duration_minutes': totalDurationMinutes,
      'difficulty': difficulty,
      if (notes != null) 'notes': notes,
    };
  }

  String get goalLabel {
    switch (goal) {
      case 'fat_loss':
        return 'Fat Loss';
      case 'muscle_gain':
        return 'Muscle Gain';
      case 'strength':
        return 'Strength';
      case 'endurance':
        return 'Endurance';
      case 'beginner_friendly':
        return 'Beginner Friendly';
      default:
        return goal;
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case 'beginner':
        return 'Beginner';
      case 'intermediate':
        return 'Intermediate';
      case 'advanced':
        return 'Advanced';
      default:
        return difficulty;
    }
  }

  String get formattedDuration {
    if (totalDurationMinutes >= 60) {
      final h = totalDurationMinutes ~/ 60;
      final m = totalDurationMinutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${totalDurationMinutes}m';
  }
}
