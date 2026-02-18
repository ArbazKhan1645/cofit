import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/models.dart';
import 'supabase_service.dart';

/// Auth Service - Manages authentication state and user data
class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final SupabaseService _supabase = Get.find<SupabaseService>();
  final _storage = GetStorage();

  // Cache key for local-first user data
  static const String _userCacheKey = 'cached_current_user';

  // ============================================
  // REACTIVE STATE
  // ============================================

  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isInitialized = false.obs;
  final Rx<String?> _error = Rx<String?>(null);

  // Getters
  UserModel? get currentUser => _currentUser.value;
  Rx<UserModel?> get currentUserRx => _currentUser;
  bool get isAuthenticated => _supabase.isAuthenticated;
  bool get isLoading => _isLoading.value;
  bool get isInitialized => _isInitialized.value;
  String? get error => _error.value;
  String? get userId => _supabase.userId;

  // Stream for listening to user changes
  Stream<UserModel?> get userStream => _currentUser.stream;

  StreamSubscription<AuthState>? _authSubscription;

  // ============================================
  // INITIALIZATION
  // ============================================

  /// Initialize auth service and listen to auth changes
  Future<AuthService> init() async {
    _isLoading.value = true;

    // Load cached user immediately (local-first, no loading spinner)
    _currentUser.value = _loadCachedUser();

    // Listen to auth state changes
    _authSubscription = _supabase.authStateChanges.listen(_onAuthStateChanged);

    // Fetch fresh user data from network
    if (_supabase.isAuthenticated) {
      await _fetchCurrentUser();
    }

    _isInitialized.value = true;
    _isLoading.value = false;
    return this;
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  /// Fetch any user profile by userId (not current user)
  Future<UserModel?> fetchUserById(String userId) async {
    try {
      final response = await _supabase.client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserModel.fromJson(response);
    } catch (e) {
      _error.value = e.toString();
      return null;
    }
  }

  /// Handle auth state changes
  Future<void> _onAuthStateChanged(AuthState state) async {
    switch (state.event) {
      case AuthChangeEvent.signedIn:
      case AuthChangeEvent.tokenRefreshed:
      case AuthChangeEvent.userUpdated:
        await _fetchCurrentUser();
        break;
      case AuthChangeEvent.signedOut:
        _currentUser.value = null;
        _cacheUser(null);
        break;
      case AuthChangeEvent.passwordRecovery:
      case AuthChangeEvent.mfaChallengeVerified:
      case AuthChangeEvent.initialSession:
        if (_supabase.isAuthenticated) {
          await _fetchCurrentUser();
        }
        break;
      default:
        // Handle any other events (userDeleted, etc.)
        if (!_supabase.isAuthenticated) {
          _currentUser.value = null;
          _cacheUser(null);
        }
        break;
    }
  }

  /// Fetch current user profile from database
  Future<void> _fetchCurrentUser() async {
    if (_supabase.userId == null) return;

    try {
      final response = await _supabase.client
          .from('users')
          .select()
          .eq('id', _supabase.userId!)
          .maybeSingle();

      if (response != null) {
        _currentUser.value = UserModel.fromJson(response);
        _cacheUser(_currentUser.value);
      }
    } catch (e) {
      _error.value = e.toString();
    }
  }

  // ============================================
  // LOCAL CACHE (local-first user data)
  // ============================================

  /// Save user to GetStorage for instant loading on next app start
  void _cacheUser(UserModel? user) {
    try {
      if (user != null) {
        _storage.write(_userCacheKey, jsonEncode(user.toJson()));
      } else {
        _storage.remove(_userCacheKey);
      }
    } catch (_) {
      // Silently fail - caching is optional
    }
  }

  /// Load cached user from GetStorage
  UserModel? _loadCachedUser() {
    try {
      final cached = _storage.read<String>(_userCacheKey);
      if (cached == null) return null;
      return UserModel.fromJson(jsonDecode(cached) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  /// Clear the local user cache (used by settings)
  void clearUserCache() {
    _storage.remove(_userCacheKey);
  }

  // ============================================
  // SIGN UP
  // ============================================

  /// Sign up with email and password
  Future<AuthResult> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final response = await _supabase.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      if (response.user != null) {
        // Update users table with full_name and auto-generated username
        if (fullName != null && fullName.isNotEmpty) {
          final username = _generateUsername(fullName);
          await _supabase.client
              .from('users')
              .update({
                'full_name': fullName,
                'username': username,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', response.user!.id);
        }

        // Fetch user profile
        await _fetchCurrentUser();
        _isLoading.value = false;
        return AuthResult.success();
      }

      _isLoading.value = false;
      return AuthResult.failure('Sign up failed');
    } on AuthException catch (e) {
      _isLoading.value = false;
      _error.value = e.message;
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      _isLoading.value = false;
      _error.value = e.toString();
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  /// Generate a unique username from full name
  String _generateUsername(String fullName) {
    // Remove special characters and convert to lowercase
    final cleanName = fullName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(' ', '_');
    // Add random suffix for uniqueness
    final suffix = DateTime.now().millisecondsSinceEpoch.toString().substring(
      8,
    );
    return '${cleanName}_$suffix';
  }

  // ============================================
  // SIGN IN
  // ============================================

  /// Sign in with email and password
  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final response = await _supabase.signIn(email: email, password: password);

      if (response.user != null) {
        await _fetchCurrentUser();
        _isLoading.value = false;
        return AuthResult.success();
      }

      _isLoading.value = false;
      return AuthResult.failure('Sign in failed');
    } on AuthException catch (e) {
      _isLoading.value = false;
      _error.value = e.message;
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      _isLoading.value = false;
      _error.value = e.toString();
      return AuthResult.failure('An unexpected error occurred');
    }
  }

  /// Sign in with Google
  Future<AuthResult> signInWithGoogle() async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final success = await _supabase.signInWithGoogle();
      _isLoading.value = false;

      if (success) {
        return AuthResult.success();
      }
      return AuthResult.failure('Google sign in cancelled');
    } catch (e) {
      _isLoading.value = false;
      _error.value = e.toString();
      return AuthResult.failure('Google sign in failed');
    }
  }

  /// Sign in with Apple
  Future<AuthResult> signInWithApple() async {
    _isLoading.value = true;
    _error.value = null;

    try {
      final success = await _supabase.signInWithApple();
      _isLoading.value = false;

      if (success) {
        return AuthResult.success();
      }
      return AuthResult.failure('Apple sign in cancelled');
    } catch (e) {
      _isLoading.value = false;
      _error.value = e.toString();
      return AuthResult.failure('Apple sign in failed');
    }
  }

  // ============================================
  // SIGN OUT
  // ============================================

  /// Sign out current user
  Future<void> signOut() async {
    _isLoading.value = true;
    try {
      await _supabase.signOut();
      _currentUser.value = null;
      _cacheUser(null);
    } catch (e) {
      _error.value = e.toString();
    }
    _isLoading.value = false;
  }

  // ============================================
  // PASSWORD RESET
  // ============================================

  /// Send password reset email
  Future<AuthResult> resetPassword(String email) async {
    _isLoading.value = true;
    _error.value = null;

    try {
      await _supabase.resetPassword(email);
      _isLoading.value = false;
      return AuthResult.success();
    } on AuthException catch (e) {
      _isLoading.value = false;
      _error.value = e.message;
      return AuthResult.failure(_getAuthErrorMessage(e));
    } catch (e) {
      _isLoading.value = false;
      _error.value = e.toString();
      return AuthResult.failure('Failed to send reset email');
    }
  }

  // ============================================
  // USER PROFILE
  // ============================================

  /// Check if user has completed onboarding prompts
  bool get hasCompletedOnboarding =>
      _currentUser.value?.onboardingCompleted ?? false;

  /// Check if user has active subscription
  bool get hasActiveSubscription =>
      _currentUser.value?.hasActiveSubscription ?? false;

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? username,
    String? avatarUrl,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? fitnessLevel,
    int? workoutDaysPerWeek,
    String? preferredWorkoutTime,
    String? fcm_token,
  }) async {
    if (_supabase.userId == null) return false;

    try {
      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (username != null) updates['username'] = username;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (bio != null) updates['bio'] = bio;
      if (dateOfBirth != null) {
        updates['date_of_birth'] = dateOfBirth.toIso8601String();
      }
      if (gender != null) updates['gender'] = gender;
      if (heightCm != null) updates['height_cm'] = heightCm;
      if (weightKg != null) updates['weight_kg'] = weightKg;
      if (fitnessLevel != null) updates['fitness_level'] = fitnessLevel;
      if (workoutDaysPerWeek != null) {
        updates['workout_days_per_week'] = workoutDaysPerWeek;
      }
      if (preferredWorkoutTime != null) {
        updates['preferred_workout_time'] = preferredWorkoutTime;
      }
      if (fcm_token != null) updates['fcm_token'] = fcm_token;

      await _supabase.client
          .from('users')
          .update(updates)
          .eq('id', _supabase.userId!);

      await _fetchCurrentUser();
      return true;
    } catch (e) {
      _error.value = e.toString();
      return false;
    }
  }

  /// Save onboarding responses and mark as completed
  Future<bool> completeOnboarding({
    required String fitnessLevel,
    required List<String> fitnessGoals,
    required int workoutDaysPerWeek,
    required String motivation,
  }) async {
    if (_supabase.userId == null) return false;

    try {
      // Update user profile with onboarding data
      await _supabase.client
          .from('users')
          .update({
            'fitness_level': fitnessLevel,
            'fitness_goals': fitnessGoals,
            'workout_days_per_week': workoutDaysPerWeek,
            'onboarding_completed': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', _supabase.userId!);

      // Save onboarding responses
      await _supabase.client.from('onboarding_responses').upsert({
        'user_id': _supabase.userId!,
        'fitness_level': fitnessLevel,
        'fitness_goals': fitnessGoals,
        'workout_days_per_week': workoutDaysPerWeek,
        'motivation': motivation,
        'completed_at': DateTime.now().toIso8601String(),
      });

      await _fetchCurrentUser();
      return true;
    } catch (e) {
      _error.value = e.toString();
      return false;
    }
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    await _fetchCurrentUser();
  }

  // ============================================
  // HELPERS
  // ============================================

  /// Get user-friendly error message
  String _getAuthErrorMessage(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid email or password')) {
      return 'Invalid email or password';
    }
    if (message.contains('email not confirmed')) {
      return 'Please verify your email before signing in';
    }
    if (message.contains('user already registered')) {
      return 'An account with this email already exists';
    }
    if (message.contains('invalid email')) {
      return 'Please enter a valid email address';
    }
    if (message.contains('weak password') || message.contains('password')) {
      return 'Password must be at least 6 characters';
    }
    if (message.contains('network') || message.contains('connection')) {
      return 'Network error. Please check your connection';
    }
    if (message.contains('too many requests') ||
        message.contains('rate limit')) {
      return 'Too many attempts. Please try again later';
    }

    return e.message;
  }

  /// Clear error
  void clearError() {
    _error.value = null;
  }
}

/// Auth Result wrapper
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;

  AuthResult._({required this.isSuccess, this.errorMessage});

  factory AuthResult.success() => AuthResult._(isSuccess: true);
  factory AuthResult.failure(String message) =>
      AuthResult._(isSuccess: false, errorMessage: message);
}
