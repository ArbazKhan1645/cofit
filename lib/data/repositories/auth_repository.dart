import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'base_repository.dart';

/// Auth Repository - Handles authentication operations
class AuthRepository extends BaseRepository {
  // ============================================
  // AUTHENTICATION
  // ============================================

  /// Sign up with email and password
  Future<Result<UserModel>> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await supabase.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (response.user != null) {
        // Profile is created automatically via trigger
        // Fetch the created profile
        final profile = await getProfile(response.user!.id);
        return profile;
      }

      return Result.failure(RepositoryException(message: 'Sign up failed'));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Sign in with email and password
  Future<Result<UserModel>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabase.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final profile = await getProfile(response.user!.id);
        return profile;
      }

      return Result.failure(RepositoryException(message: 'Sign in failed'));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Sign in with Google
  Future<Result<UserModel>> signInWithGoogle() async {
    try {
      final response = await supabase.signInWithGoogle();
      if (response.user != null) {
        final profile = await getProfile(response.user!.id);
        return profile;
      }
      return Result.failure(
          RepositoryException(message: 'Google sign in failed'));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Sign in with Apple
  Future<Result<bool>> signInWithApple() async {
    try {
      final success = await supabase.signInWithApple();
      if (success) {
        return Result.success(true);
      }
      return Result.failure(
          RepositoryException(message: 'Apple sign in failed'));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Sign out
  Future<Result<void>> signOut() async {
    try {
      await supabase.signOut();
      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Send password reset email
  Future<Result<void>> resetPassword(String email) async {
    try {
      await supabase.resetPassword(email);
      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => supabase.isAuthenticated;

  /// Get current user ID
  String? get currentUserId => supabase.userId;

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => supabase.authStateChanges;

  // ============================================
  // USER PROFILE
  // ============================================

  /// Get user profile
  Future<Result<UserModel>> getProfile(String userId) async {
    try {
      final response = await client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return Result.success(UserModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Get current user profile
  Future<Result<UserModel>> getCurrentProfile() async {
    if (userId == null) {
      return Result.failure(RepositoryException(message: 'Not authenticated'));
    }
    return getProfile(userId!);
  }

  /// Update user profile
  Future<Result<UserModel>> updateProfile(UserModel user) async {
    try {
      final response = await client
          .from('users')
          .update(user.toUpdateJson())
          .eq('id', user.id)
          .select()
          .single();

      return Result.success(UserModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Complete onboarding with all user preferences
  Future<Result<UserModel>> completeOnboarding({
    required String fitnessLevel,
    required List<String> fitnessGoals,
    required int workoutDaysPerWeek,
    required String preferredWorkoutTime,
    required int preferredSessionDuration,
    required List<String> preferredWorkoutTypes,
    required List<String> physicalLimitations,
    required List<String> availableEquipment,
    required String biggestChallenge,
    required String currentFeeling,
    required String timeline,
    required String motivation,
    // Body measurements
    String? gender,
    DateTime? dateOfBirth,
    double? heightCm,
    double? weightKg,
    // Medical conditions
    List<String>? medicalConditions,
  }) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      // 1. Update users table (only columns that exist in users)
      final userData = <String, dynamic>{
        'fitness_level': fitnessLevel,
        'fitness_goals': fitnessGoals,
        'workout_days_per_week': workoutDaysPerWeek,
        'preferred_workout_time': preferredWorkoutTime,
        'preferred_session_duration': preferredSessionDuration,
        'preferred_workout_types': preferredWorkoutTypes,
        'physical_limitations': physicalLimitations,
        'available_equipment': availableEquipment,
        'onboarding_completed': true,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (gender != null) userData['gender'] = gender;
      if (dateOfBirth != null) {
        userData['date_of_birth'] = dateOfBirth.toIso8601String().split('T')[0];
      }
      if (heightCm != null) userData['height_cm'] = heightCm;
      if (weightKg != null) userData['weight_kg'] = weightKg;
      if (medicalConditions != null) {
        userData['medical_conditions'] = medicalConditions;
      }

      final response = await client
          .from('users')
          .update(userData)
          .eq('id', userId!)
          .select()
          .single();

      // 2. Save onboarding responses (journal-specific fields)
      await client.from('onboarding_responses').upsert({
        'user_id': userId!,
        'fitness_level': fitnessLevel,
        'fitness_goals': fitnessGoals,
        'workout_days_per_week': workoutDaysPerWeek,
        'preferred_time': preferredWorkoutTime,
        'session_duration': preferredSessionDuration,
        'preferred_workout_types': preferredWorkoutTypes,
        'physical_limitations': physicalLimitations,
        'available_equipment': availableEquipment,
        'biggest_challenge': biggestChallenge,
        'current_feeling': currentFeeling,
        'timeline': timeline,
        'motivation': motivation,
        'completed_at': DateTime.now().toIso8601String(),
      });

      return Result.success(UserModel.fromJson(response));
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Update FCM token for push notifications
  Future<Result<void>> updateFcmToken(String token) async {
    try {
      if (userId == null) {
        return Result.failure(
            RepositoryException(message: 'Not authenticated'));
      }

      await client.from('users').update({
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId!);

      return Result.success(null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }

  /// Check if username is available
  Future<Result<bool>> isUsernameAvailable(String username) async {
    try {
      final response = await client
          .from('users')
          .select('id')
          .eq('username', username.toLowerCase())
          .maybeSingle();

      return Result.success(response == null);
    } catch (e) {
      return Result.failure(RepositoryException(message: e.toString()));
    }
  }
}
