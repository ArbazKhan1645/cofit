import 'package:get/get.dart';

class NavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
  }

  void goToHome() => changePage(0);
  void goToWorkouts() => changePage(1);
  void goToRecipes() => changePage(2);
  void goToProgress() => changePage(3);
  void goToCommunity() => changePage(4);
  void goToProfile() => changePage(5);
}
