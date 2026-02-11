/// Journal Entry Model - User's personal journal/reflection entries
/// Supabase Table: journal_entries
class JournalEntryModel {
  final String id;
  final String userId;
  final String title;
  final String content;
  final String mood; // energized, happy, neutral, tired, stressed
  final int energyLevel; // 1-5
  final List<String> tags;
  final String? linkedWorkoutId;
  final String? linkedChallengeId;
  final List<String> imageUrls;
  final bool isPrivate;
  final DateTime entryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  JournalEntryModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    required this.mood,
    this.energyLevel = 3,
    this.tags = const [],
    this.linkedWorkoutId,
    this.linkedChallengeId,
    this.imageUrls = const [],
    this.isPrivate = true,
    required this.entryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      mood: json['mood'] as String,
      energyLevel: json['energy_level'] as int? ?? 3,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              [],
      linkedWorkoutId: json['linked_workout_id'] as String?,
      linkedChallengeId: json['linked_challenge_id'] as String?,
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isPrivate: json['is_private'] as bool? ?? true,
      entryDate: DateTime.parse(json['entry_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'mood': mood,
      'energy_level': energyLevel,
      'tags': tags,
      'linked_workout_id': linkedWorkoutId,
      'linked_challenge_id': linkedChallengeId,
      'image_urls': imageUrls,
      'is_private': isPrivate,
      'entry_date': entryDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'title': title,
      'content': content,
      'mood': mood,
      'energy_level': energyLevel,
      'tags': tags,
      'linked_workout_id': linkedWorkoutId,
      'linked_challenge_id': linkedChallengeId,
      'image_urls': imageUrls,
      'is_private': isPrivate,
      'entry_date': entryDate.toIso8601String(),
    };
  }

  JournalEntryModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? mood,
    int? energyLevel,
    List<String>? tags,
    String? linkedWorkoutId,
    String? linkedChallengeId,
    List<String>? imageUrls,
    bool? isPrivate,
    DateTime? entryDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      energyLevel: energyLevel ?? this.energyLevel,
      tags: tags ?? this.tags,
      linkedWorkoutId: linkedWorkoutId ?? this.linkedWorkoutId,
      linkedChallengeId: linkedChallengeId ?? this.linkedChallengeId,
      imageUrls: imageUrls ?? this.imageUrls,
      isPrivate: isPrivate ?? this.isPrivate,
      entryDate: entryDate ?? this.entryDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get mood emoji
  String get moodEmoji {
    switch (mood.toLowerCase()) {
      case 'energized':
        return '⚡';
      case 'happy':
        return '😊';
      case 'neutral':
        return '😐';
      case 'tired':
        return '😴';
      case 'stressed':
        return '😰';
      default:
        return '😊';
    }
  }

  /// Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final diff = now.difference(entryDate);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    return '${entryDate.day}/${entryDate.month}/${entryDate.year}';
  }

  /// Check if entry has images
  bool get hasImages => imageUrls.isNotEmpty;

  /// Check if entry is linked to workout
  bool get isLinkedToWorkout => linkedWorkoutId != null;
}

/// Onboarding Response Model - Stores user's onboarding questionnaire responses
/// Supabase Table: onboarding_responses
class OnboardingResponseModel {
  final String id;
  final String userId;
  final List<String> fitnessGoals;
  final String fitnessLevel;
  final int workoutDaysPerWeek;
  final String preferredTime;
  final int sessionDuration;
  final List<String> preferredWorkoutTypes;
  final List<String> physicalLimitations;
  final List<String> availableEquipment;
  final String biggestChallenge;
  final String currentFeeling;
  final String timeline;
  final String motivation;
  final Map<String, dynamic>? additionalData;
  final DateTime completedAt;
  final DateTime createdAt;

  OnboardingResponseModel({
    required this.id,
    required this.userId,
    this.fitnessGoals = const [],
    required this.fitnessLevel,
    this.workoutDaysPerWeek = 3,
    required this.preferredTime,
    this.sessionDuration = 30,
    this.preferredWorkoutTypes = const [],
    this.physicalLimitations = const [],
    this.availableEquipment = const [],
    required this.biggestChallenge,
    required this.currentFeeling,
    required this.timeline,
    required this.motivation,
    this.additionalData,
    required this.completedAt,
    required this.createdAt,
  });

  factory OnboardingResponseModel.fromJson(Map<String, dynamic> json) {
    return OnboardingResponseModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fitnessGoals: (json['fitness_goals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      fitnessLevel: json['fitness_level'] as String,
      workoutDaysPerWeek: json['workout_days_per_week'] as int? ?? 3,
      preferredTime: json['preferred_time'] as String,
      sessionDuration: json['session_duration'] as int? ?? 30,
      preferredWorkoutTypes: (json['preferred_workout_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      physicalLimitations: (json['physical_limitations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      availableEquipment: (json['available_equipment'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      biggestChallenge: json['biggest_challenge'] as String,
      currentFeeling: json['current_feeling'] as String,
      timeline: json['timeline'] as String,
      motivation: json['motivation'] as String,
      additionalData: json['additional_data'] as Map<String, dynamic>?,
      completedAt: DateTime.parse(json['completed_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'fitness_goals': fitnessGoals,
      'fitness_level': fitnessLevel,
      'workout_days_per_week': workoutDaysPerWeek,
      'preferred_time': preferredTime,
      'session_duration': sessionDuration,
      'preferred_workout_types': preferredWorkoutTypes,
      'physical_limitations': physicalLimitations,
      'available_equipment': availableEquipment,
      'biggest_challenge': biggestChallenge,
      'current_feeling': currentFeeling,
      'timeline': timeline,
      'motivation': motivation,
      'additional_data': additionalData,
      'completed_at': completedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'fitness_goals': fitnessGoals,
      'fitness_level': fitnessLevel,
      'workout_days_per_week': workoutDaysPerWeek,
      'preferred_time': preferredTime,
      'session_duration': sessionDuration,
      'preferred_workout_types': preferredWorkoutTypes,
      'physical_limitations': physicalLimitations,
      'available_equipment': availableEquipment,
      'biggest_challenge': biggestChallenge,
      'current_feeling': currentFeeling,
      'timeline': timeline,
      'motivation': motivation,
      'additional_data': additionalData,
      'completed_at': completedAt.toIso8601String(),
    };
  }
}

/// Subscription Model - User subscription details
/// Supabase Table: subscriptions
class SubscriptionModel {
  final String id;
  final String userId;
  final String plan; // free, monthly, annual
  final String status; // active, cancelled, expired, pending
  final String? stripeCustomerId;
  final String? stripeSubscriptionId;
  final DateTime? currentPeriodStart;
  final DateTime? currentPeriodEnd;
  final DateTime? cancelAt;
  final DateTime? cancelledAt;
  final bool cancelAtPeriodEnd;
  final double? amount;
  final String? currency;
  final String? paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    this.stripeCustomerId,
    this.stripeSubscriptionId,
    this.currentPeriodStart,
    this.currentPeriodEnd,
    this.cancelAt,
    this.cancelledAt,
    this.cancelAtPeriodEnd = false,
    this.amount,
    this.currency,
    this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      plan: json['plan'] as String,
      status: json['status'] as String,
      stripeCustomerId: json['stripe_customer_id'] as String?,
      stripeSubscriptionId: json['stripe_subscription_id'] as String?,
      currentPeriodStart: json['current_period_start'] != null
          ? DateTime.parse(json['current_period_start'] as String)
          : null,
      currentPeriodEnd: json['current_period_end'] != null
          ? DateTime.parse(json['current_period_end'] as String)
          : null,
      cancelAt: json['cancel_at'] != null
          ? DateTime.parse(json['cancel_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      paymentMethod: json['payment_method'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'plan': plan,
      'status': status,
      'stripe_customer_id': stripeCustomerId,
      'stripe_subscription_id': stripeSubscriptionId,
      'current_period_start': currentPeriodStart?.toIso8601String(),
      'current_period_end': currentPeriodEnd?.toIso8601String(),
      'cancel_at': cancelAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
      'cancel_at_period_end': cancelAtPeriodEnd,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if subscription is active
  bool get isActive => status == 'active';

  /// Check if subscription is premium (not free)
  bool get isPremium => plan != 'free' && isActive;

  /// Get days until expiration
  int? get daysUntilExpiration {
    if (currentPeriodEnd == null) return null;
    return currentPeriodEnd!.difference(DateTime.now()).inDays;
  }

  /// Check if subscription is about to expire (within 7 days)
  bool get isAboutToExpire {
    final days = daysUntilExpiration;
    return days != null && days <= 7 && days > 0;
  }
}
