import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'supabase_service.dart';

/// Crashlytics Service — catches all uncaught exceptions and
/// stores them in the Supabase `crash_logs` table.
class CrashlyticsService {
  CrashlyticsService._();
  static final CrashlyticsService _instance = CrashlyticsService._();
  static CrashlyticsService get instance => _instance;

  String? _appVersion;
  String? _platform;
  String? _osVersion;
  String? _deviceModel;

  /// Initialize with device info (call once at startup).
  /// Automatically collects app version, platform, OS version, and device model.
  Future<void> init() async {
    _platform = Platform.isAndroid ? 'android' : 'ios';
    _osVersion = Platform.operatingSystemVersion;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (_) {
      _appVersion = 'unknown';
    }

    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        _deviceModel = '${android.manufacturer} ${android.model}';
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        _deviceModel = ios.utsname.machine;
      }
    } catch (_) {
      _deviceModel = 'unknown';
    }
  }

  /// Record an exception to Supabase
  Future<void> recordError(
    dynamic error,
    StackTrace? stackTrace, {
    bool fatal = false,
    String source = 'dart',
    String? screenRoute,
    Map<String, dynamic>? extraData,
  }) async {
    try {
      // Always log to console in debug mode
      if (kDebugMode) {
        debugPrint('${fatal ? "CRASH" : "Exception"}: $error');
        if (stackTrace != null) debugPrint(stackTrace.toString());
      }

      final supabase = Get.find<SupabaseService>();
      final userId = supabase.userId;

      final errorType = error.runtimeType.toString();
      final errorMessage = error.toString();
      final trace = stackTrace?.toString();

      // Truncate stack trace to 10000 chars to avoid huge payloads
      final truncatedTrace = trace != null && trace.length > 10000
          ? '${trace.substring(0, 10000)}\n... (truncated)'
          : trace;

      await supabase.client.from('crash_logs').insert({
        if (userId != null) 'user_id': userId,
        'error_type': errorType,
        'error_message': errorMessage.length > 2000
            ? errorMessage.substring(0, 2000)
            : errorMessage,
        if (truncatedTrace != null) 'stack_trace': truncatedTrace,
        'fatal': fatal,
        'source': source,
        if (screenRoute != null) 'screen_route': screenRoute,
        'platform': _platform,
        'os_version': _osVersion,
        'app_version': _appVersion,
        if (_deviceModel != null) 'device_model': _deviceModel,
        if (extraData != null && extraData.isNotEmpty) 'extra_data': extraData,
      });
    } catch (e) {
      // Silently fail — we can't let crashlytics itself crash the app
      debugPrint('[Crashlytics] Failed to record error: $e');
    }
  }

  /// Setup Flutter error handler & runZonedGuarded wrapper.
  /// Call this from main() — it runs the app inside a guarded zone.
  static Future<void> runGuarded(Future<void> Function() appRunner) async {
    // Catch Flutter framework errors (rendering, layout, etc.)
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details); // still show in console
      instance.recordError(
        details.exception,
        details.stack,
        fatal: true,
        source: 'flutter',
        extraData: {
          'library': details.library ?? 'unknown',
          if (details.context != null)
            'context': details.context.toString(),
        },
      );
    };

    // Catch errors that happen outside Flutter framework (async, isolate, etc.)
    PlatformDispatcher.instance.onError = (error, stack) {
      instance.recordError(
        error,
        stack,
        fatal: true,
        source: 'platform',
      );
      return true; // handled
    };

    // Run the app inside a guarded zone to catch any remaining async errors
    runZonedGuarded(
      () async {
        await appRunner();
      },
      (error, stackTrace) {
        instance.recordError(
          error,
          stackTrace,
          fatal: false,
          source: 'dart',
        );
      },
    );
  }

  /// Manually log a non-fatal exception (use anywhere in the app)
  static Future<void> logException(
    dynamic error, {
    StackTrace? stackTrace,
    String? screenRoute,
    Map<String, dynamic>? extraData,
  }) async {
    await instance.recordError(
      error,
      stackTrace,
      fatal: false,
      source: 'dart',
      screenRoute: screenRoute,
      extraData: extraData,
    );
  }
}
