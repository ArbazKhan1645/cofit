import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:uuid/uuid.dart';

/// Provides a stable device identifier and device metadata.
/// The device_id persists across app restarts (stored in GetStorage)
/// but resets on app reinstall.
class DeviceService {
  DeviceService._();
  static final DeviceService instance = DeviceService._();

  final _storage = GetStorage();
  static const _key = 'device_id';

  String? _deviceId;
  String? _platform;
  String? _deviceModel;

  String get deviceId => _deviceId!;
  String get platform => _platform ?? (Platform.isAndroid ? 'android' : 'ios');
  String? get deviceModel => _deviceModel;

  /// Call once at app startup (after GetStorage.init).
  Future<void> init() async {
    // Stable device id — generated once per install
    _deviceId = _storage.read<String>(_key);
    if (_deviceId == null) {
      _deviceId = const Uuid().v4();
      _storage.write(_key, _deviceId);
    }

    _platform = Platform.isAndroid ? 'android' : 'ios';

    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        _deviceModel = '${android.manufacturer} ${android.model}';
      } else if (Platform.isIOS) {
        final ios = await info.iosInfo;
        _deviceModel = ios.utsname.machine;
      }
    } catch (_) {
      _deviceModel = null;
    }
  }
}
