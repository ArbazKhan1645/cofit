import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/services/fitness_calculation_service.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../shared/widgets/widgets.dart';

class JournalController extends BaseController {
  final _storage = GetStorage();
  final _authRepository = AuthRepository();

  // Current page
  final RxInt currentPage = 0.obs;
  final pageController = PageController();

  // Show results page
  final RxBool showResults = false.obs;

  // Personalized plan (calculated)
  final Rx<PersonalizedPlan?> personalizedPlan = Rx<PersonalizedPlan?>(null);

  // 14 Journal Prompts (including body measurements)
  final List<Map<String, dynamic>> prompts = [
    // 1. Goals
    {
      'question': 'What are your fitness goals?',
      'subtitle': 'Select all that apply to you',
      'type': 'multiSelect',
      'icon': 'target',
      'options': [
        'Lose weight',
        'Build muscle',
        'Increase endurance',
        'Improve flexibility',
        'Reduce stress',
        'Feel more energized',
        'Build healthy habits',
        'Get stronger',
        'Improve posture',
        'Better sleep',
      ],
    },
    // 2. Gender
    {
      'question': 'What\'s your gender?',
      'subtitle': 'This helps us personalize your workout recommendations',
      'type': 'singleSelect',
      'icon': 'user',
      'key': 'gender',
      'options': [
        {'title': 'Female', 'description': '', 'emoji': '👩'},
        {'title': 'Male', 'description': '', 'emoji': '👨'},
        {'title': 'Other', 'description': '', 'emoji': '🧑'},
        {'title': 'Prefer not to say', 'description': '', 'emoji': '🤐'},
      ],
    },
    // 3. Date of Birth
    {
      'question': 'What\'s your date of birth?',
      'subtitle': 'Your age helps us customize intensity levels',
      'type': 'datePicker',
      'icon': 'calendar',
      'key': 'dateOfBirth',
    },
    // 4. Height
    {
      'question': 'What\'s your height?',
      'subtitle': 'Used for calculating personalized metrics',
      'type': 'heightPicker',
      'icon': 'ruler',
      'key': 'height',
    },
    // 5. Weight
    {
      'question': 'What\'s your current weight?',
      'subtitle': 'This helps track your progress over time',
      'type': 'weightPicker',
      'icon': 'weight',
      'key': 'weight',
    },
    // 6. Fitness Level
    {
      'question': 'What\'s your current fitness level?',
      'subtitle': 'Be honest - there\'s no judgment here!',
      'type': 'singleSelect',
      'icon': 'level',
      'key': 'fitnessLevel',
      'options': [
        {
          'title': 'Just Starting Out',
          'description': 'New to fitness or haven\'t worked out in a long time',
          'emoji': '🌱',
        },
        {
          'title': 'Getting Back Into It',
          'description': 'Had some experience but took a break',
          'emoji': '🌿',
        },
        {
          'title': 'Somewhat Active',
          'description': 'Exercise occasionally, comfortable with basics',
          'emoji': '🌳',
        },
        {
          'title': 'Regularly Active',
          'description': 'Workout 2-3 times per week consistently',
          'emoji': '💪',
        },
        {
          'title': 'Very Fit',
          'description': 'Exercise is a regular part of my routine',
          'emoji': '🔥',
        },
      ],
    },
    // 7. Workout Days
    {
      'question': 'How many days per week can you commit?',
      'subtitle': 'Be realistic - consistency beats intensity!',
      'type': 'slider',
      'icon': 'calendar',
      'min': 1,
      'max': 7,
      'default': 4,
    },
    // 8. Preferred Time
    {
      'question': 'When do you prefer to workout?',
      'subtitle': 'We\'ll remind you at your best time',
      'type': 'singleSelect',
      'icon': 'time',
      'key': 'preferredTime',
      'options': [
        {
          'title': 'Early Morning',
          'description': '5 AM - 8 AM • Rise and grind!',
          'emoji': '🌅',
        },
        {
          'title': 'Morning',
          'description': '8 AM - 12 PM • Start the day energized',
          'emoji': '☀️',
        },
        {
          'title': 'Afternoon',
          'description': '12 PM - 5 PM • Midday energy boost',
          'emoji': '🌤️',
        },
        {
          'title': 'Evening',
          'description': '5 PM - 9 PM • Unwind after the day',
          'emoji': '🌆',
        },
        {
          'title': 'Night Owl',
          'description': 'After 9 PM • Late night sessions',
          'emoji': '🌙',
        },
      ],
    },
    // 9. Workout Types
    {
      'question': 'What types of workouts excite you?',
      'subtitle': 'Select all that interest you',
      'type': 'multiSelect',
      'icon': 'workout',
      'options': [
        'Strength Training',
        'HIIT / Cardio',
        'Yoga',
        'Pilates',
        'Dance Workouts',
        'Low Impact',
        'Stretching',
        'Core / Abs',
        'Full Body',
        'Barre',
      ],
    },
    // 10. Health Conditions (grouped)
    {
      'question': 'Any health conditions we should know about?',
      'subtitle': 'We\'ll adapt your workouts to keep you safe',
      'type': 'groupedMultiSelect',
      'icon': 'health',
      'allowNone': true,
      'groups': [
        {
          'title': 'Lower Body',
          'options': [
            {'tag': 'knee_issue', 'label': 'Knee Issue'},
            {'tag': 'ankle_issue', 'label': 'Ankle Issue'},
            {'tag': 'hip_issue', 'label': 'Hip Issue'},
            {'tag': 'foot_issue', 'label': 'Foot / Heel Issue'},
          ],
        },
        {
          'title': 'Spine & Back',
          'options': [
            {'tag': 'lower_back_issue', 'label': 'Lower Back Issue'},
            {'tag': 'upper_back_issue', 'label': 'Upper Back / Posture'},
            {'tag': 'neck_issue', 'label': 'Neck / Cervical Issue'},
          ],
        },
        {
          'title': 'Upper Body',
          'options': [
            {'tag': 'shoulder_issue', 'label': 'Shoulder Issue'},
            {'tag': 'elbow_issue', 'label': 'Elbow Issue'},
            {'tag': 'wrist_issue', 'label': 'Wrist Issue'},
          ],
        },
        {
          'title': 'General / Systemic',
          'options': [
            {'tag': 'cardio_limit', 'label': 'Cardio Limitation'},
            {'tag': 'balance_issue', 'label': 'Balance Issue'},
            {'tag': 'overweight_safe', 'label': 'Overweight Modifications'},
            {'tag': 'pregnancy_safe', 'label': 'Pregnancy / Postpartum'},
            {'tag': 'senior_safe', 'label': 'Senior (40+/50+)'},
          ],
        },
        {
          'title': 'Recovery & Special',
          'options': [
            {'tag': 'rehab_mode', 'label': 'Rehab / Physiotherapy'},
            {'tag': 'mobility_only', 'label': 'Mobility / Flexibility Only'},
          ],
        },
      ],
    },
    // 11. Equipment
    {
      'question': 'What equipment do you have access to?',
      'subtitle': 'No equipment? No problem! We have options for everyone',
      'type': 'multiSelect',
      'icon': 'equipment',
      'options': [
        'No equipment (bodyweight only)',
        'Yoga mat',
        'Dumbbells',
        'Resistance bands',
        'Kettlebell',
        'Foam roller',
        'Stability ball',
        'Full gym access',
      ],
    },
    // 12. Biggest Challenge
    {
      'question': 'What\'s your biggest fitness challenge?',
      'subtitle': 'Understanding this helps us support you better',
      'type': 'singleSelect',
      'icon': 'challenge',
      'key': 'biggestChallenge',
      'options': [
        {
          'title': 'Staying consistent',
          'description': 'I start but struggle to keep going',
          'emoji': '📅',
        },
        {
          'title': 'Finding motivation',
          'description': 'I know I should but can\'t get started',
          'emoji': '💭',
        },
        {
          'title': 'Not enough time',
          'description': 'Life gets too busy for workouts',
          'emoji': '⏰',
        },
        {
          'title': 'Not seeing results',
          'description': 'I try but don\'t see progress',
          'emoji': '📊',
        },
        {
          'title': 'Don\'t know what to do',
          'description': 'I need guidance and structure',
          'emoji': '🤔',
        },
        {
          'title': 'Feeling intimidated',
          'description': 'Workouts feel too hard or overwhelming',
          'emoji': '😰',
        },
      ],
    },
    // 13. How you feel
    {
      'question': 'How do you feel about your body right now?',
      'subtitle': 'This is a safe space - your feelings are valid',
      'type': 'singleSelect',
      'icon': 'heart',
      'key': 'currentFeeling',
      'options': [
        {
          'title': 'Ready for a change',
          'description': 'Excited to start this journey!',
          'emoji': '🚀',
        },
        {
          'title': 'Hopeful but cautious',
          'description': 'Want to believe this time will be different',
          'emoji': '🤞',
        },
        {
          'title': 'Frustrated',
          'description': 'Tired of not seeing results',
          'emoji': '😤',
        },
        {
          'title': 'Disconnected',
          'description': 'Haven\'t prioritized myself in a while',
          'emoji': '💫',
        },
        {
          'title': 'Grateful',
          'description': 'Appreciating what my body can do',
          'emoji': '🙏',
        },
      ],
    },
    // 14. Motivation
    {
      'question': 'Why is getting fit important to you?',
      'subtitle': 'Your "why" will keep you going on tough days',
      'type': 'textInput',
      'icon': 'motivation',
      'placeholder': 'Share what drives you to become your best self...',
      'examples': [
        'I want to feel confident and strong in my body',
        'I want more energy to enjoy life with my family',
        'I want to prove to myself that I can do this',
        'I want to build healthy habits for the long term',
      ],
    },
  ];

  // User responses
  final RxList<String> selectedGoals = <String>[].obs;
  final RxInt workoutDaysPerWeek = 4.obs;
  final RxString fitnessLevel = ''.obs;
  final RxString preferredTime = ''.obs;
  final RxString sessionDuration = ''.obs;
  final RxList<String> workoutTypes = <String>[].obs;
  final RxList<String> limitations = <String>[].obs;
  final RxList<String> medicalConditions = <String>[].obs;
  final RxList<String> equipment = <String>[].obs;
  final RxString biggestChallenge = ''.obs;
  final RxString currentFeeling = ''.obs;
  final RxString timeline = ''.obs;
  final motivationController = TextEditingController();

  // Body measurements
  final RxString gender = ''.obs;
  final Rx<DateTime?> dateOfBirth = Rx<DateTime?>(null);
  final RxDouble heightCm = 165.0.obs; // Default height in cm
  final RxDouble weightKg = 65.0.obs; // Default weight in kg

  int get totalPages => prompts.length;

  void toggleGoal(String goal) {
    if (selectedGoals.contains(goal)) {
      selectedGoals.remove(goal);
    } else {
      selectedGoals.add(goal);
    }
  }

  void toggleMultiSelect(int pageIndex, String option) {
    switch (pageIndex) {
      case 0: // Goals
        toggleGoal(option);
        break;
      case 8: // Workout types
        if (workoutTypes.contains(option)) {
          workoutTypes.remove(option);
        } else {
          workoutTypes.add(option);
        }
        break;
      case 9: // Medical conditions (grouped)
        if (medicalConditions.contains(option)) {
          medicalConditions.remove(option);
        } else {
          medicalConditions.add(option);
        }
        break;
      case 10: // Equipment
        if (equipment.contains(option)) {
          equipment.remove(option);
        } else {
          equipment.add(option);
        }
        break;
    }
  }

  void setSingleSelect(String key, String value) {
    switch (key) {
      case 'gender':
        gender.value = value;
        break;
      case 'fitnessLevel':
        fitnessLevel.value = value;
        break;
      case 'preferredTime':
        preferredTime.value = value;
        break;
      case 'sessionDuration':
        sessionDuration.value = value;
        break;
      case 'biggestChallenge':
        biggestChallenge.value = value;
        break;
      case 'currentFeeling':
        currentFeeling.value = value;
        break;
    }
  }

  void setWorkoutDays(int days) {
    workoutDaysPerWeek.value = days;
  }

  void setFitnessLevel(String level) {
    fitnessLevel.value = level;
  }

  void setDateOfBirth(DateTime date) {
    dateOfBirth.value = date;
  }

  void setHeight(double cm) {
    heightCm.value = cm;
  }

  void setWeight(double kg) {
    weightKg.value = kg;
  }

  RxList<String> getMultiSelectList(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return selectedGoals;
      case 8: // Workout types
        return workoutTypes;
      case 9: // Medical conditions
        return medicalConditions;
      case 10: // Equipment
        return equipment;
      default:
        return <String>[].obs;
    }
  }

  String getSingleSelectValue(String key) {
    switch (key) {
      case 'gender':
        return gender.value;
      case 'fitnessLevel':
        return fitnessLevel.value;
      case 'preferredTime':
        return preferredTime.value;
      case 'sessionDuration':
        return sessionDuration.value;
      case 'biggestChallenge':
        return biggestChallenge.value;
      case 'currentFeeling':
        return currentFeeling.value;
      default:
        return '';
    }
  }

  bool canProceed() {
    switch (currentPage.value) {
      case 0: // Goals
        return selectedGoals.isNotEmpty;
      case 1: // Gender
        return gender.value.isNotEmpty;
      case 2: // Date of Birth
        return dateOfBirth.value != null;
      case 3: // Height
        return heightCm.value > 0;
      case 4: // Weight
        return weightKg.value > 0;
      case 5: // Fitness level
        return fitnessLevel.value.isNotEmpty;
      case 6: // Days per week
        return true;
      case 7: // Preferred time
        return preferredTime.value.isNotEmpty;
      case 8: // Workout types
        return workoutTypes.isNotEmpty;
      case 9: // Medical conditions (optional)
        return true;
      case 10: // Equipment
        return equipment.isNotEmpty;
      case 11: // Biggest challenge
        return biggestChallenge.value.isNotEmpty;
      case 12: // Current feeling
        return currentFeeling.value.isNotEmpty;
      case 13: // Motivation (optional)
        return true;
      default:
        return true;
    }
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value++;
    } else {
      // Complete onboarding directly (no plan page)
      completeOnboarding();
    }
  }

  void previousPage() {
    if (showResults.value) {
      showResults.value = false;
      return;
    }
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value--;
    }
  }

  /// Generate personalized plan using FitnessCalculationService
  void _generatePersonalizedPlan() {
    personalizedPlan.value = FitnessCalculationService.generatePlan(
      goals: selectedGoals.toList(),
      fitnessLevel: fitnessLevel.value,
      workoutDaysPerWeek: workoutDaysPerWeek.value,
      preferredTime: preferredTime.value,
      sessionDuration: sessionDuration.value,
      workoutTypes: workoutTypes.toList(),
      limitations: limitations.toList(),
      equipment: equipment.toList(),
      biggestChallenge: biggestChallenge.value,
      currentFeeling: currentFeeling.value,
      timeline: timeline.value,
      motivation: motivationController.text,
    );
  }

  /// Get the personalized plan (for backwards compatibility)
  PersonalizedPlan? getPersonalizedPlan() {
    if (personalizedPlan.value == null) {
      _generatePersonalizedPlan();
    }
    return personalizedPlan.value;
  }

  /// Check if device has internet connectivity
  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet,
    );
  }

  /// Map user-friendly fitness level to database value
  String _mapFitnessLevelToDb(String level) {
    switch (level) {
      case 'Just Starting Out':
        return 'beginner';
      case 'Getting Back Into It':
        return 'beginner';
      case 'Somewhat Active':
        return 'intermediate';
      case 'Regularly Active':
        return 'intermediate';
      case 'Very Fit':
        return 'advanced';
      default:
        return 'beginner';
    }
  }

  /// Map user-friendly preferred time to database value
  String _mapPreferredTimeToDb(String time) {
    switch (time) {
      case 'Early Morning':
        return 'morning';
      case 'Morning':
        return 'morning';
      case 'Afternoon':
        return 'afternoon';
      case 'Evening':
        return 'evening';
      case 'Night Owl':
        return 'evening';
      default:
        return 'morning';
    }
  }

  /// Map gender to database value
  String _mapGenderToDb(String genderValue) {
    switch (genderValue) {
      case 'Female':
        return 'female';
      case 'Male':
        return 'male';
      case 'Other':
        return 'other';
      case 'Prefer not to say':
        return 'not_specified';
      default:
        return 'not_specified';
    }
  }

  /// Complete onboarding and save to Supabase
  /// Internet is required - this is a one-time setup
  Future<void> completeOnboarding() async {
    setLoading(true);

    try {
      // Check internet connectivity first - it's mandatory for onboarding
      final hasInternet = await _hasInternetConnection();
      if (!hasInternet) {
        if (Get.context != null) {
          AppSnackbar.error(
            Get.context!,
            message: 'Please connect to the internet to complete setup.',
            title: 'No Internet',
          );
        }
        return;
      }

      // Get session duration in minutes
      final sessionMinutes = FitnessCalculationService.getSessionMinutes(
        sessionDuration.value,
      );

      // Save to Supabase - this is mandatory, no local fallback
      // Map user-friendly values to database-compatible values
      final result = await _authRepository.completeOnboarding(
        fitnessLevel: _mapFitnessLevelToDb(fitnessLevel.value),
        fitnessGoals: selectedGoals.toList(),
        workoutDaysPerWeek: workoutDaysPerWeek.value,
        preferredWorkoutTime: _mapPreferredTimeToDb(preferredTime.value),
        preferredSessionDuration: sessionMinutes,
        preferredWorkoutTypes: workoutTypes.toList(),
        physicalLimitations: limitations.toList(),
        availableEquipment: equipment.toList(),
        biggestChallenge: biggestChallenge.value,
        currentFeeling: currentFeeling.value,
        timeline: timeline.value,
        motivation: motivationController.text,
        // Body measurements
        gender: _mapGenderToDb(gender.value),
        dateOfBirth: dateOfBirth.value,
        heightCm: heightCm.value,
        weightKg: weightKg.value,
        // Medical conditions
        medicalConditions: medicalConditions.toList(),
      );

      if (result.isSuccess) {
        if (Get.context != null) {
          AppSnackbar.success(
            Get.context!,
            message: 'Your personalized plan is ready!',
            title: 'Welcome',
          );
        }

        // Check if user has active subscription
        Get.offAllNamed(AppRoutes.subscription);
      } else {
        // Show actual error - don't proceed
        final errorMessage =
            result.error?.message ?? 'Failed to save your preferences';
        if (Get.context != null) {
          AppSnackbar.error(
            Get.context!,
            message: errorMessage,
            title: 'Setup Failed',
          );
        }
      }
    } catch (e) {
      // Show error - don't proceed
      if (Get.context != null) {
        AppSnackbar.error(
          Get.context!,
          message: 'Something went wrong. Please try again.',
          title: 'Error',
        );
      }
    } finally {
      setLoading(false);
    }
  }

  void skipOnboarding() {
    _storage.write('hasCompletedOnboarding', true);
    Get.offAllNamed(AppRoutes.main);
  }

  @override
  void onClose() {
    pageController.dispose();
    motivationController.dispose();
    super.onClose();
  }
}
