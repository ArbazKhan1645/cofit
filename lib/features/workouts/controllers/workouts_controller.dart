import 'package:get/get.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/mock/mock_data.dart';

class WorkoutsController extends BaseController {
  final RxList<WorkoutModel> weeklyWorkouts = <WorkoutModel>[].obs;
  final RxList<WorkoutModel> savedWorkouts = <WorkoutModel>[].obs;
  final RxInt selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadWorkouts();
  }

  void loadWorkouts() {
    // Load mock data
    weeklyWorkouts.value = MockData.getMockWeeklyWorkouts();
  }

  void toggleSaveWorkout(WorkoutModel workout) {
    if (savedWorkouts.any((w) => w.id == workout.id)) {
      savedWorkouts.removeWhere((w) => w.id == workout.id);
    } else {
      savedWorkouts.add(workout);
    }
  }

  bool isWorkoutSaved(String workoutId) {
    return savedWorkouts.any((w) => w.id == workoutId);
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }
}
