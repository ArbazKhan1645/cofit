import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/services/supabase_service.dart';

/// Base Repository - Provides common database operations
abstract class BaseRepository {
  SupabaseService get supabase => Get.find<SupabaseService>();
  SupabaseClient get client => supabase.client;
  String? get userId => supabase.userId;

  /// Execute a query with error handling
  Future<T> executeQuery<T>(Future<T> Function() query) async {
    try {
      return await query();
    } on PostgrestException catch (e) {
      throw RepositoryException(
        message: e.message,
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      throw RepositoryException(message: e.toString());
    }
  }

  /// Execute a function call with error handling
  Future<T> executeFunction<T>(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final response = await client.rpc(functionName, params: params);
      return response as T;
    } on PostgrestException catch (e) {
      throw RepositoryException(
        message: e.message,
        code: e.code,
        details: e.details,
      );
    } catch (e) {
      throw RepositoryException(message: e.toString());
    }
  }
}

/// Repository Exception for handling errors
class RepositoryException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  RepositoryException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'RepositoryException: $message (code: $code)';
}

/// Result wrapper for repository operations
class Result<T> {
  final T? data;
  final RepositoryException? error;
  final bool isSuccess;

  Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) => Result._(data: data, isSuccess: true);

  factory Result.failure(RepositoryException error) =>
      Result._(error: error, isSuccess: false);

  R fold<R>(
    R Function(RepositoryException error) onError,
    R Function(T data) onSuccess,
  ) {
    if (isSuccess && data != null) {
      return onSuccess(data as T);
    }
    return onError(error ?? RepositoryException(message: 'Unknown error'));
  }
}
