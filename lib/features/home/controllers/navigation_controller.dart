import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  // Double-tap-to-exit tracking
  DateTime? _lastBackPress;

  void changePage(int index) {
    currentIndex.value = index;
  }

  /// Handles back press on main navigation screen.
  /// Returns true if the app should exit, false otherwise.
  bool handleBackPress() {
    // If not on home tab, go to home first
    if (currentIndex.value != 0) {
      goToHome();
      return false;
    }

    // On home tab — double tap to exit
    final now = DateTime.now();
    if (_lastBackPress != null &&
        now.difference(_lastBackPress!) < const Duration(seconds: 2)) {
      SystemNavigator.pop(); // exit app
      return true;
    }

    _lastBackPress = now;
    Get.showSnackbar(const GetSnackBar(
      message: 'Press back again to exit',
      duration: Duration(seconds: 2),
    ));
    return false;
  }

  void goToHome() => changePage(0);
  void goToWorkouts() => changePage(1);
  void goToRecipes() => changePage(2);
  void goToProgress() => changePage(3);
  void goToCommunity() => changePage(4);
  void goToProfile() => changePage(5);
}
