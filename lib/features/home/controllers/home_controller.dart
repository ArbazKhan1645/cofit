import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../shared/controllers/base_controller.dart';

class HomeController extends BaseController {
  final _storage = GetStorage();

  // User data
  final RxString userName = ''.obs;
  final RxInt workoutsThisWeek = 0.obs;
  final RxInt currentStreak = 0.obs;
  final RxInt totalWorkoutsThisMonth = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadWorkoutStats();
  }

  void loadUserData() {
    userName.value = _storage.read<String>('userName') ?? 'Fitness Friend';
  }

  void loadWorkoutStats() {
    // Load from storage or API
    workoutsThisWeek.value = _storage.read<int>('workoutsThisWeek') ?? 3;
    currentStreak.value = _storage.read<int>('currentStreak') ?? 5;
    totalWorkoutsThisMonth.value = _storage.read<int>('totalWorkoutsThisMonth') ?? 12;
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String getFormattedDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}
