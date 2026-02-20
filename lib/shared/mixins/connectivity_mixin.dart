import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Mixin for checking internet connectivity before admin operations.
mixin ConnectivityMixin {
  Future<bool> hasInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Returns true if internet is available, false + snackbar if not.
  Future<bool> ensureConnectivity() async {
    if (await hasInternet()) return true;
    Get.snackbar(
      'No Internet',
      'Please check your internet connection and try again.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
    return false;
  }
}
