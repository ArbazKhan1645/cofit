import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

/// Supabase Service - Handles initialization and provides access to Supabase client
class SupabaseService extends GetxService {
  static SupabaseService get to => Get.find();

  late final SupabaseClient _client;
  SupabaseClient get client => _client;

  // Auth shortcuts
  GoTrueClient get auth => _client.auth;
  User? get currentUser => _client.auth.currentUser;
  String? get userId => currentUser?.id;
  bool get isAuthenticated => currentUser != null;

  // Supabase configuration - Replace with your actual values
  static const String _supabaseUrl = 'https://acoagkctohcvejcfzsna.supabase.co';
  static const String _supabaseAnonKey =
      'sb_publishable_qbPwEZc2y1ieI-x64ip-Pg_mEagi7ag';

  /// Initialize Supabase
  Future<SupabaseService> init() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );

    _client = Supabase.instance.client;
    return this;
  }

  // ============================================
  // AUTH METHODS
  // ============================================

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) async {
    return await auth.signUp(email: email, password: password, data: data);
  }

  /// Sign in with email and password
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await auth.signInWithPassword(email: email, password: password);
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    final response = await auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.cofitcollective://login-callback/',
    );
    return response;
  }

  /// Sign in with Apple
  Future<bool> signInWithApple() async {
    final response = await auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'io.supabase.cofitcollective://login-callback/',
    );
    return response;
  }

  /// Sign out
  Future<void> signOut() async {
    await auth.signOut();
  }

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    await auth.resetPasswordForEmail(email);
  }

  /// Update user password
  Future<UserResponse> updatePassword(String newPassword) async {
    return await auth.updateUser(UserAttributes(password: newPassword));
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  // ============================================
  // DATABASE HELPER METHODS
  // ============================================

  /// Get a table reference
  SupabaseQueryBuilder from(String table) => _client.from(table);

  /// Execute a stored function
  Future<dynamic> rpc(String function, {Map<String, dynamic>? params}) async {
    return await _client.rpc(function, params: params);
  }

  // ============================================
  // STORAGE METHODS
  // ============================================

  /// Get storage bucket
  StorageFileApi bucket(String name) => _client.storage.from(name);

  /// Upload file to storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required List<int> fileBytes,
    String? contentType,
  }) async {
    try {
      await _client.storage
          .from(bucket)
          .uploadBinary(
            path,
            fileBytes as dynamic,
            fileOptions: FileOptions(contentType: contentType),
          );

      return _client.storage.from(bucket).getPublicUrl(path);
    } on Exception catch (e) {
      print(e);
      rethrow;
    }
  }

  /// Delete file from storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _client.storage.from(bucket).remove([path]);
  }

  /// Get public URL for a file
  String getPublicUrl({required String bucket, required String path}) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }

  // ============================================
  // REALTIME SUBSCRIPTIONS
  // ============================================

  /// Subscribe to table changes
  RealtimeChannel subscribeToTable({
    required String table,
    required void Function(PostgresChangePayload) callback,
    PostgresChangeEvent? event,
    PostgresChangeFilter? filter,
  }) {
    return _client
        .channel('public:$table')
        .onPostgresChanges(
          event: event ?? PostgresChangeEvent.all,
          schema: 'public',
          table: table,
          filter: filter,
          callback: callback,
        )
        .subscribe();
  }

  /// Unsubscribe from a channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await _client.removeChannel(channel);
  }
}

/// Extension methods for easier Supabase access
extension SupabaseServiceExtension on GetInterface {
  SupabaseService get supabase => Get.find<SupabaseService>();
}
