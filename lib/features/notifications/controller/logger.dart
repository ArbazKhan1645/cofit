import 'package:flutter/foundation.dart';

/// Centralized logger for the app.
/// - Debug/Info/Warning logs are suppressed in release mode automatically.
/// - Error logs always print (even in release) for crash visibility.
/// - Each log line includes timestamp, level tag, and optional error/stacktrace.
class AppLogger {
  AppLogger._();

  // Set to false to silence ALL logs including errors (not recommended)
  static bool _enabled = true;

  static void enable() => _enabled = true;
  static void disable() => _enabled = false;

  // ─── PUBLIC API ───────────────────────────────────────────────────────────

  /// Verbose debug info — suppressed in release builds
  static void d(String tag, String message, [dynamic extra]) {
    if (!kDebugMode) return;
    _log(_Level.debug, tag, message, extra);
  }

  /// General info — suppressed in release builds
  static void i(String tag, String message, [dynamic extra]) {
    if (!kDebugMode) return;
    _log(_Level.info, tag, message, extra);
  }

  /// Warnings — suppressed in release builds
  static void w(String tag, String message, [dynamic extra]) {
    if (!kDebugMode) return;
    _log(_Level.warning, tag, message, extra);
  }

  /// Errors — always printed regardless of build mode
  static void e(
    String tag,
    String message, [
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (!_enabled) return;
    _log(_Level.error, tag, message, error, stackTrace);
  }

  // ─── INTERNAL ─────────────────────────────────────────────────────────────

  static void _log(
    _Level level,
    String tag,
    String message, [
    dynamic extra,
    StackTrace? stackTrace,
  ]) {
    if (!_enabled) return;

    final time = _timestamp();
    final prefix = '${level.emoji} [$time] [$tag]';

    // ignore: avoid_print — intentional dev logging utility
    debugPrint('$prefix $message');

    if (extra != null) {
      debugPrint('   ↳ $extra');
    }

    if (stackTrace != null) {
      debugPrint('   StackTrace:\n$stackTrace');
    }
  }

  static String _timestamp() {
    final now = DateTime.now();
    return '${_pad(now.hour)}:${_pad(now.minute)}:${_pad(now.second)}'
        '.${now.millisecond.toString().padLeft(3, '0')}';
  }

  static String _pad(int v) => v.toString().padLeft(2, '0');
}

enum _Level {
  debug('🔍'),
  info('ℹ️ '),
  warning('⚠️ '),
  error('🔴');

  final String emoji;
  const _Level(this.emoji);
}
