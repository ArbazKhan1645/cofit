import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/challenge_model.dart';
import '../../../data/repositories/challenge_repository.dart';

class HomeController extends BaseController {
  final AuthService _authService = AuthService.to;
  final _storage = GetStorage();
  final ChallengeRepository _challengeRepo = ChallengeRepository();

  // User data
  final RxString userName = ''.obs;
  final RxInt workoutsThisWeek = 0.obs;
  final RxInt currentStreak = 0.obs;
  final RxInt totalWorkoutsThisMonth = 0.obs;

  // Challenges preview for home dashboard
  final RxList<UserChallengeModel> myChallenges = <UserChallengeModel>[].obs;
  final RxList<ChallengeModel> activeChallenges = <ChallengeModel>[].obs;
  final RxBool isLoadingChallenges = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadWorkoutStats();
    loadHomeChallenges();
    // React to user changes from AuthService
    ever(_authService.currentUserRx, (_) {
      loadUserData();
      loadWorkoutStats();
      loadHomeChallenges();
    });
  }

  void loadUserData() {
    final user = _authService.currentUser;
    userName.value = user?.displayName ?? 'Fitness Friend';
  }

  void loadWorkoutStats() {
    final user = _authService.currentUser;
    currentStreak.value = user?.currentStreak ?? 0;
    // These remain from local storage until a dedicated API exists
    workoutsThisWeek.value = _storage.read<int>('workoutsThisWeek') ?? 0;
    totalWorkoutsThisMonth.value = _storage.read<int>('totalWorkoutsThisMonth') ?? 0;
  }

  Future<void> loadHomeChallenges() async {
    isLoadingChallenges.value = true;

    final results = await Future.wait([
      _challengeRepo.getMyActiveChallenges(),
      _challengeRepo.getActiveChallenges(),
    ]);

    results[0].fold(
      (error) {},
      (data) => myChallenges.value = data as List<UserChallengeModel>,
    );

    results[1].fold(
      (error) {},
      (data) => activeChallenges.value = data as List<ChallengeModel>,
    );

    isLoadingChallenges.value = false;
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
