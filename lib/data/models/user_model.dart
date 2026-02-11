/// User Model - Core user profile and authentication data
/// Supabase Table: users
class UserModel {
  final String id; // UUID from Supabase Auth
  final String email;
  final String? fullName;
  final String? username;
  final String? avatarUrl;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? fitnessLevel; // beginner, intermediate, advanced
  final List<String> fitnessGoals;
  final int workoutDaysPerWeek;
  final String? preferredWorkoutTime; // morning, afternoon, evening
  final int? preferredSessionDuration; // in minutes
  final List<String> preferredWorkoutTypes;
  final List<String> physicalLimitations;
  final List<String> medicalConditions;
  final List<String> availableEquipment;
  final String? biggestChallenge;
  final String? currentFeeling;
  final String? timeline;
  final String? motivation;
  final String? subscriptionStatus; // free, active, cancelled, expired
  final String? subscriptionPlan; // monthly, annual
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final int totalWorkoutsCompleted;
  final int totalMinutesWorkedOut;
  final int totalCaloriesBurned;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastWorkoutDate;
  final bool onboardingCompleted;
  final bool notificationsEnabled;
  final String? fcmToken;
  final bool isBanned;
  final String userType; // user, admin
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.username,
    this.avatarUrl,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.fitnessLevel,
    this.fitnessGoals = const [],
    this.workoutDaysPerWeek = 3,
    this.preferredWorkoutTime,
    this.preferredSessionDuration,
    this.preferredWorkoutTypes = const [],
    this.physicalLimitations = const [],
    this.medicalConditions = const [],
    this.availableEquipment = const [],
    this.biggestChallenge,
    this.currentFeeling,
    this.timeline,
    this.motivation,
    this.subscriptionStatus,
    this.subscriptionPlan,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.totalWorkoutsCompleted = 0,
    this.totalMinutesWorkedOut = 0,
    this.totalCaloriesBurned = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastWorkoutDate,
    this.onboardingCompleted = false,
    this.notificationsEnabled = true,
    this.fcmToken,
    this.isBanned = false,
    this.userType = 'user',
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      username: json['username'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      gender: json['gender'] as String?,
      heightCm: (json['height_cm'] as num?)?.toDouble(),
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      fitnessLevel: json['fitness_level'] as String?,
      fitnessGoals: (json['fitness_goals'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      workoutDaysPerWeek: json['workout_days_per_week'] as int? ?? 3,
      preferredWorkoutTime: json['preferred_workout_time'] as String?,
      preferredSessionDuration: json['preferred_session_duration'] as int?,
      preferredWorkoutTypes: (json['preferred_workout_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      physicalLimitations: (json['physical_limitations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      medicalConditions: (json['medical_conditions'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      availableEquipment: (json['available_equipment'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      biggestChallenge: json['biggest_challenge'] as String?,
      currentFeeling: json['current_feeling'] as String?,
      timeline: json['timeline'] as String?,
      motivation: json['motivation'] as String?,
      subscriptionStatus: json['subscription_status'] as String?,
      subscriptionPlan: json['subscription_plan'] as String?,
      subscriptionStartDate: json['subscription_start_date'] != null
          ? DateTime.parse(json['subscription_start_date'] as String)
          : null,
      subscriptionEndDate: json['subscription_end_date'] != null
          ? DateTime.parse(json['subscription_end_date'] as String)
          : null,
      totalWorkoutsCompleted: json['total_workouts_completed'] as int? ?? 0,
      totalMinutesWorkedOut: json['total_minutes_worked_out'] as int? ?? 0,
      totalCaloriesBurned: json['total_calories_burned'] as int? ?? 0,
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
      lastWorkoutDate: json['last_workout_date'] != null
          ? DateTime.parse(json['last_workout_date'] as String)
          : null,
      onboardingCompleted: json['onboarding_completed'] as bool? ?? false,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
      fcmToken: json['fcm_token'] as String?,
      isBanned: json['is_banned'] as bool? ?? false,
      userType: json['user_type'] as String? ?? 'user',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'fitness_level': fitnessLevel,
      'fitness_goals': fitnessGoals,
      'workout_days_per_week': workoutDaysPerWeek,
      'preferred_workout_time': preferredWorkoutTime,
      'preferred_session_duration': preferredSessionDuration,
      'preferred_workout_types': preferredWorkoutTypes,
      'physical_limitations': physicalLimitations,
      'medical_conditions': medicalConditions,
      'available_equipment': availableEquipment,
      'biggest_challenge': biggestChallenge,
      'current_feeling': currentFeeling,
      'timeline': timeline,
      'motivation': motivation,
      'subscription_status': subscriptionStatus,
      'subscription_plan': subscriptionPlan,
      'subscription_start_date': subscriptionStartDate?.toIso8601String(),
      'subscription_end_date': subscriptionEndDate?.toIso8601String(),
      'total_workouts_completed': totalWorkoutsCompleted,
      'total_minutes_worked_out': totalMinutesWorkedOut,
      'total_calories_burned': totalCaloriesBurned,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_workout_date': lastWorkoutDate?.toIso8601String(),
      'onboarding_completed': onboardingCompleted,
      'notifications_enabled': notificationsEnabled,
      'fcm_token': fcmToken,
      'is_banned': isBanned,
      'user_type': userType,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// For inserting new user (excludes id, created_at, updated_at - handled by Supabase)
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('created_at');
    json.remove('updated_at');
    return json;
  }

  /// For updating user profile
  Map<String, dynamic> toUpdateJson() {
    return {
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'fitness_level': fitnessLevel,
      'fitness_goals': fitnessGoals,
      'workout_days_per_week': workoutDaysPerWeek,
      'preferred_workout_time': preferredWorkoutTime,
      'preferred_session_duration': preferredSessionDuration,
      'preferred_workout_types': preferredWorkoutTypes,
      'physical_limitations': physicalLimitations,
      'medical_conditions': medicalConditions,
      'available_equipment': availableEquipment,
      'biggest_challenge': biggestChallenge,
      'current_feeling': currentFeeling,
      'timeline': timeline,
      'motivation': motivation,
      'notifications_enabled': notificationsEnabled,
      'fcm_token': fcmToken,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? username,
    String? avatarUrl,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? fitnessLevel,
    List<String>? fitnessGoals,
    int? workoutDaysPerWeek,
    String? preferredWorkoutTime,
    int? preferredSessionDuration,
    List<String>? preferredWorkoutTypes,
    List<String>? physicalLimitations,
    List<String>? medicalConditions,
    List<String>? availableEquipment,
    String? biggestChallenge,
    String? currentFeeling,
    String? timeline,
    String? motivation,
    String? subscriptionStatus,
    String? subscriptionPlan,
    DateTime? subscriptionStartDate,
    DateTime? subscriptionEndDate,
    int? totalWorkoutsCompleted,
    int? totalMinutesWorkedOut,
    int? totalCaloriesBurned,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastWorkoutDate,
    bool? onboardingCompleted,
    bool? notificationsEnabled,
    String? fcmToken,
    bool? isBanned,
    String? userType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      fitnessGoals: fitnessGoals ?? this.fitnessGoals,
      workoutDaysPerWeek: workoutDaysPerWeek ?? this.workoutDaysPerWeek,
      preferredWorkoutTime: preferredWorkoutTime ?? this.preferredWorkoutTime,
      preferredSessionDuration:
          preferredSessionDuration ?? this.preferredSessionDuration,
      preferredWorkoutTypes:
          preferredWorkoutTypes ?? this.preferredWorkoutTypes,
      physicalLimitations: physicalLimitations ?? this.physicalLimitations,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      availableEquipment: availableEquipment ?? this.availableEquipment,
      biggestChallenge: biggestChallenge ?? this.biggestChallenge,
      currentFeeling: currentFeeling ?? this.currentFeeling,
      timeline: timeline ?? this.timeline,
      motivation: motivation ?? this.motivation,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      subscriptionPlan: subscriptionPlan ?? this.subscriptionPlan,
      subscriptionStartDate:
          subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionEndDate: subscriptionEndDate ?? this.subscriptionEndDate,
      totalWorkoutsCompleted:
          totalWorkoutsCompleted ?? this.totalWorkoutsCompleted,
      totalMinutesWorkedOut:
          totalMinutesWorkedOut ?? this.totalMinutesWorkedOut,
      totalCaloriesBurned: totalCaloriesBurned ?? this.totalCaloriesBurned,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastWorkoutDate: lastWorkoutDate ?? this.lastWorkoutDate,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      fcmToken: fcmToken ?? this.fcmToken,
      isBanned: isBanned ?? this.isBanned,
      userType: userType ?? this.userType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if user has active subscription
  bool get hasActiveSubscription {
    if (subscriptionStatus != 'active') return false;
    if (subscriptionEndDate == null) return false;
    return subscriptionEndDate!.isAfter(DateTime.now());
  }

  /// Check if user is admin
  bool get isAdmin => userType == 'admin';

  /// Get display name (full name or username or email)
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) return fullName!;
    if (username != null && username!.isNotEmpty) return username!;
    return email.split('@').first;
  }
}
