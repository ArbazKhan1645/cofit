import 'package:fl_chart/fl_chart.dart';

/// Fitness Calculation Service
/// Provides smart calculations for personalized fitness plans based on user data
class FitnessCalculationService {
  FitnessCalculationService._();

  // ============================================
  // FITNESS LEVEL MAPPINGS
  // ============================================

  static const Map<String, int> fitnessLevelMultiplier = {
    'Just Starting Out': 1,
    'Getting Back Into It': 2,
    'Somewhat Active': 3,
    'Regularly Active': 4,
    'Very Fit': 5,
  };

  static const Map<String, double> fitnessLevelCalorieMultiplier = {
    'Just Starting Out': 5.0,
    'Getting Back Into It': 6.0,
    'Somewhat Active': 7.0,
    'Regularly Active': 8.0,
    'Very Fit': 9.0,
  };

  // ============================================
  // SESSION DURATION MAPPINGS
  // ============================================

  static int getSessionMinutes(String sessionDuration) {
    switch (sessionDuration) {
      case '15-20 minutes':
        return 18;
      case '25-35 minutes':
        return 30;
      case '40-50 minutes':
        return 45;
      case '60+ minutes':
        return 65;
      default:
        return 30;
    }
  }

  // ============================================
  // TIMELINE MAPPINGS
  // ============================================

  static int getWeeksToGoal(String timeline) {
    switch (timeline) {
      case '2-4 weeks':
        return 4;
      case '1-2 months':
        return 8;
      case '3-6 months':
        return 16;
      case '6+ months':
        return 24;
      case 'No rush':
        return 20;
      default:
        return 12;
    }
  }

  // ============================================
  // CALORIE CALCULATIONS
  // ============================================

  /// Calculate estimated calories burned per session
  /// Based on fitness level, workout types, and duration
  static int calculateCaloriesPerSession({
    required String fitnessLevel,
    required List<String> workoutTypes,
    required int sessionMinutes,
  }) {
    double baseCalorieRate = fitnessLevelCalorieMultiplier[fitnessLevel] ?? 6.0;

    // Workout type intensity multipliers
    double workoutIntensity = 1.0;
    if (workoutTypes.contains('HIIT / Cardio')) workoutIntensity += 0.3;
    if (workoutTypes.contains('Strength Training')) workoutIntensity += 0.2;
    if (workoutTypes.contains('Dance Workouts')) workoutIntensity += 0.15;
    if (workoutTypes.contains('Full Body')) workoutIntensity += 0.1;
    if (workoutTypes.contains('Core / Abs')) workoutIntensity += 0.05;
    if (workoutTypes.contains('Yoga')) workoutIntensity -= 0.1;
    if (workoutTypes.contains('Stretching')) workoutIntensity -= 0.2;
    if (workoutTypes.contains('Low Impact')) workoutIntensity -= 0.15;

    // Normalize intensity
    workoutIntensity = workoutIntensity.clamp(0.6, 1.8);

    return (baseCalorieRate * sessionMinutes * workoutIntensity).round();
  }

  /// Calculate weekly calories burned
  static int calculateWeeklyCalories({
    required String fitnessLevel,
    required List<String> workoutTypes,
    required int sessionMinutes,
    required int workoutDaysPerWeek,
  }) {
    final caloriesPerSession = calculateCaloriesPerSession(
      fitnessLevel: fitnessLevel,
      workoutTypes: workoutTypes,
      sessionMinutes: sessionMinutes,
    );
    return caloriesPerSession * workoutDaysPerWeek;
  }

  // ============================================
  // PROGRESS PREDICTION
  // ============================================

  /// Calculate expected progress percentage at different weeks
  /// Based on fitness science principles:
  /// - Beginners see faster initial gains
  /// - Progress follows logarithmic curve
  /// - Consistency is key factor
  static List<FlSpot> calculateProgressCurve({
    required String fitnessLevel,
    required int workoutDaysPerWeek,
    required List<String> goals,
    required int weeksToGoal,
  }) {
    final List<FlSpot> progressPoints = [];

    // Base progress rate based on fitness level
    // Beginners gain faster initially, advanced slower but steadier
    double baseRate = fitnessLevel == 'Just Starting Out'
        ? 1.4
        : fitnessLevel == 'Getting Back Into It'
            ? 1.2
            : fitnessLevel == 'Somewhat Active'
                ? 1.0
                : fitnessLevel == 'Regularly Active'
                    ? 0.9
                    : 0.8;

    // Consistency multiplier (more days = faster progress, but diminishing returns)
    double consistencyMultiplier = 0.7 + (workoutDaysPerWeek * 0.1);
    consistencyMultiplier = consistencyMultiplier.clamp(0.8, 1.3);

    // Goal complexity affects progress perception
    double goalMultiplier = 1.0;
    if (goals.contains('Build muscle')) goalMultiplier -= 0.1; // Slower visible progress
    if (goals.contains('Lose weight')) goalMultiplier += 0.1; // Faster initial visible progress
    if (goals.contains('Increase endurance')) goalMultiplier += 0.05;

    // Calculate progress at key milestones
    final milestones = [0, 4, 8, 12, 16]; // Weeks

    for (int i = 0; i < milestones.length; i++) {
      int week = milestones[i];
      double progress;

      if (week == 0) {
        // Starting point - based on current fitness
        progress = (fitnessLevelMultiplier[fitnessLevel] ?? 1) * 5.0;
      } else {
        // Logarithmic progress curve
        // Progress = initial + log(1 + week * rate) * multipliers * 25
        double logProgress = _logarithmicProgress(
          week: week.toDouble(),
          baseRate: baseRate,
          consistencyMultiplier: consistencyMultiplier,
          goalMultiplier: goalMultiplier,
        );

        progress = ((fitnessLevelMultiplier[fitnessLevel] ?? 1) * 5.0) + logProgress;
      }

      // Cap at reasonable maximum
      progress = progress.clamp(5.0, 95.0);

      progressPoints.add(FlSpot(i.toDouble(), progress));
    }

    return progressPoints;
  }

  static double _logarithmicProgress({
    required double week,
    required double baseRate,
    required double consistencyMultiplier,
    required double goalMultiplier,
  }) {
    // Logarithmic curve with diminishing returns
    // ln(1 + x) gives smooth curve that flattens over time
    double logValue = _ln(1 + week * baseRate);
    return logValue * consistencyMultiplier * goalMultiplier * 22;
  }

  // Natural logarithm approximation
  static double _ln(double x) {
    if (x <= 0) return 0;
    // Using dart:math would be better, but keeping it simple
    double result = 0;
    double term = (x - 1) / (x + 1);
    double termSquared = term * term;
    double currentTerm = term;

    for (int i = 1; i <= 20; i += 2) {
      result += currentTerm / i;
      currentTerm *= termSquared;
    }

    return 2 * result;
  }

  // ============================================
  // WEEKLY SCHEDULE GENERATION
  // ============================================

  /// Generate optimal weekly workout schedule
  /// Based on:
  /// - Number of workout days
  /// - Rest and recovery principles
  /// - User's preferred workout types
  static List<ScheduleDay> generateWeeklySchedule({
    required int workoutDaysPerWeek,
    required List<String> workoutTypes,
    required String fitnessLevel,
    required List<String> limitations,
  }) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<ScheduleDay> schedule = [];

    // Determine workout days based on count
    List<bool> workoutDays = _getOptimalWorkoutDays(workoutDaysPerWeek);

    // Distribute workout types across days
    List<String> availableTypes = _filterWorkoutTypes(workoutTypes, limitations);

    for (int i = 0; i < 7; i++) {
      if (workoutDays[i]) {
        // Assign workout type based on day and recovery needs
        String workoutType = _assignWorkoutType(
          dayIndex: i,
          previousDayWorkout: i > 0 && workoutDays[i - 1],
          availableTypes: availableTypes,
          fitnessLevel: fitnessLevel,
        );

        schedule.add(ScheduleDay(
          day: days[i],
          isWorkoutDay: true,
          workoutType: workoutType,
          intensity: _getIntensityForDay(i, workoutDaysPerWeek, fitnessLevel),
        ));
      } else {
        schedule.add(ScheduleDay(
          day: days[i],
          isWorkoutDay: false,
          workoutType: 'Rest & Recovery',
          intensity: 'rest',
        ));
      }
    }

    return schedule;
  }

  static List<bool> _getOptimalWorkoutDays(int workoutDaysPerWeek) {
    // Optimal distribution based on recovery science
    switch (workoutDaysPerWeek) {
      case 1:
        return [false, false, true, false, false, false, false]; // Wed
      case 2:
        return [false, true, false, false, true, false, false]; // Tue, Fri
      case 3:
        return [true, false, true, false, true, false, false]; // Mon, Wed, Fri
      case 4:
        return [true, true, false, true, true, false, false]; // Mon, Tue, Thu, Fri
      case 5:
        return [true, true, false, true, true, false, true]; // Mon, Tue, Thu, Fri, Sun
      case 6:
        return [true, true, true, true, true, false, true]; // All except Sat
      case 7:
        return [true, true, true, true, true, true, true]; // Every day
      default:
        return [true, false, true, false, true, false, false];
    }
  }

  static List<String> _filterWorkoutTypes(
    List<String> workoutTypes,
    List<String> limitations,
  ) {
    List<String> filtered = List.from(workoutTypes);

    // Remove high-impact workouts if user has joint issues
    if (limitations.any((l) => l.contains('Knee') || l.contains('Ankle'))) {
      filtered.remove('HIIT / Cardio');
      filtered.remove('Dance Workouts');
      if (!filtered.contains('Low Impact')) filtered.add('Low Impact');
    }

    // Prioritize core-safe options for back issues
    if (limitations.any((l) => l.contains('back'))) {
      filtered.remove('Core / Abs');
    }

    // Ensure there's at least one type
    if (filtered.isEmpty) {
      filtered.add('Full Body');
    }

    return filtered;
  }

  static String _assignWorkoutType({
    required int dayIndex,
    required bool previousDayWorkout,
    required List<String> availableTypes,
    required String fitnessLevel,
  }) {
    // If worked out yesterday, do lower intensity
    if (previousDayWorkout) {
      if (availableTypes.contains('Yoga')) return 'Yoga';
      if (availableTypes.contains('Stretching')) return 'Stretching';
      if (availableTypes.contains('Low Impact')) return 'Low Impact';
      if (availableTypes.contains('Pilates')) return 'Pilates';
    }

    // Distribute workouts evenly
    int typeIndex = dayIndex % availableTypes.length;
    return availableTypes[typeIndex];
  }

  static String _getIntensityForDay(
    int dayIndex,
    int workoutDaysPerWeek,
    String fitnessLevel,
  ) {
    // Beginners should have more moderate days
    bool isBeginner = fitnessLevel == 'Just Starting Out' ||
        fitnessLevel == 'Getting Back Into It';

    // Pattern: Hard-Moderate-Hard-Light for recovery
    if (dayIndex == 0 || dayIndex == 3) {
      return isBeginner ? 'moderate' : 'high';
    } else if (dayIndex == 2 || dayIndex == 5) {
      return 'moderate';
    } else {
      return isBeginner ? 'light' : 'moderate';
    }
  }

  // ============================================
  // PERSONALIZED PLAN GENERATION
  // ============================================

  /// Generate complete personalized fitness plan
  static PersonalizedPlan generatePlan({
    required List<String> goals,
    required String fitnessLevel,
    required int workoutDaysPerWeek,
    required String preferredTime,
    required String sessionDuration,
    required List<String> workoutTypes,
    required List<String> limitations,
    required List<String> equipment,
    required String biggestChallenge,
    required String currentFeeling,
    required String timeline,
    required String motivation,
  }) {
    final sessionMinutes = getSessionMinutes(sessionDuration);
    final weeksToGoal = getWeeksToGoal(timeline);

    final weeklyCalories = calculateWeeklyCalories(
      fitnessLevel: fitnessLevel,
      workoutTypes: workoutTypes,
      sessionMinutes: sessionMinutes,
      workoutDaysPerWeek: workoutDaysPerWeek,
    );

    final progressCurve = calculateProgressCurve(
      fitnessLevel: fitnessLevel,
      workoutDaysPerWeek: workoutDaysPerWeek,
      goals: goals,
      weeksToGoal: weeksToGoal,
    );

    final schedule = generateWeeklySchedule(
      workoutDaysPerWeek: workoutDaysPerWeek,
      workoutTypes: workoutTypes,
      fitnessLevel: fitnessLevel,
      limitations: limitations,
    );

    final weeklyMinutes = sessionMinutes * workoutDaysPerWeek;
    final expectedImprovement = _calculateExpectedImprovement(
      fitnessLevel: fitnessLevel,
      workoutDaysPerWeek: workoutDaysPerWeek,
      weeksToGoal: weeksToGoal,
    );

    final tips = _generatePersonalizedTips(
      biggestChallenge: biggestChallenge,
      fitnessLevel: fitnessLevel,
      goals: goals,
    );

    return PersonalizedPlan(
      weeklyWorkouts: workoutDaysPerWeek,
      minutesPerSession: sessionMinutes,
      weeklyMinutes: weeklyMinutes,
      weeklyCalories: weeklyCalories,
      weeksToGoal: weeksToGoal,
      expectedImprovement: expectedImprovement,
      progressCurve: progressCurve,
      schedule: schedule,
      primaryGoal: goals.isNotEmpty ? goals.first : 'Get fit',
      personalizedTips: tips,
      fitnessLevel: fitnessLevel,
    );
  }

  static int _calculateExpectedImprovement({
    required String fitnessLevel,
    required int workoutDaysPerWeek,
    required int weeksToGoal,
  }) {
    // Base improvement percentage
    double base = 40.0;

    // Beginners see more improvement
    if (fitnessLevel == 'Just Starting Out') base += 25;
    if (fitnessLevel == 'Getting Back Into It') base += 15;
    if (fitnessLevel == 'Somewhat Active') base += 5;

    // More workout days = more improvement
    base += workoutDaysPerWeek * 3;

    // Longer timeline = more improvement
    base += (weeksToGoal / 4) * 5;

    return base.clamp(30, 90).round();
  }

  static List<String> _generatePersonalizedTips({
    required String biggestChallenge,
    required String fitnessLevel,
    required List<String> goals,
  }) {
    List<String> tips = [];

    // Challenge-based tips
    switch (biggestChallenge) {
      case 'Staying consistent':
        tips.add('Set a specific time each day for your workout - routine builds habits');
        tips.add('Start with shorter workouts and gradually increase duration');
        break;
      case 'Finding motivation':
        tips.add('Remember your "why" - we\'ll remind you of your motivation');
        tips.add('Celebrate small wins - every workout counts!');
        break;
      case 'Not enough time':
        tips.add('Your 15-20 min workouts are designed for busy schedules');
        tips.add('Morning workouts can boost energy for the entire day');
        break;
      case 'Not seeing results':
        tips.add('Track your progress weekly - changes happen gradually');
        tips.add('Focus on how you feel, not just how you look');
        break;
      case 'Don\'t know what to do':
        tips.add('Follow our guided workouts - we\'ve planned everything for you');
        tips.add('Start with the recommended workouts for your level');
        break;
      case 'Feeling intimidated':
        tips.add('Every expert was once a beginner - you\'ve got this!');
        tips.add('Our workouts have modifications for all levels');
        break;
    }

    // Goal-based tips
    if (goals.contains('Lose weight')) {
      tips.add('Combine cardio with strength training for best fat loss results');
    }
    if (goals.contains('Build muscle')) {
      tips.add('Progressive overload is key - gradually increase intensity');
    }
    if (goals.contains('Reduce stress')) {
      tips.add('Include yoga or stretching sessions for mental wellness');
    }

    return tips.take(3).toList();
  }
}

// ============================================
// DATA CLASSES
// ============================================

class ScheduleDay {
  final String day;
  final bool isWorkoutDay;
  final String workoutType;
  final String intensity;

  ScheduleDay({
    required this.day,
    required this.isWorkoutDay,
    required this.workoutType,
    required this.intensity,
  });
}

class PersonalizedPlan {
  final int weeklyWorkouts;
  final int minutesPerSession;
  final int weeklyMinutes;
  final int weeklyCalories;
  final int weeksToGoal;
  final int expectedImprovement;
  final List<FlSpot> progressCurve;
  final List<ScheduleDay> schedule;
  final String primaryGoal;
  final List<String> personalizedTips;
  final String fitnessLevel;

  PersonalizedPlan({
    required this.weeklyWorkouts,
    required this.minutesPerSession,
    required this.weeklyMinutes,
    required this.weeklyCalories,
    required this.weeksToGoal,
    required this.expectedImprovement,
    required this.progressCurve,
    required this.schedule,
    required this.primaryGoal,
    required this.personalizedTips,
    required this.fitnessLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'weekly_workouts': weeklyWorkouts,
      'minutes_per_session': minutesPerSession,
      'weekly_minutes': weeklyMinutes,
      'weekly_calories': weeklyCalories,
      'weeks_to_goal': weeksToGoal,
      'expected_improvement': expectedImprovement,
      'primary_goal': primaryGoal,
      'fitness_level': fitnessLevel,
    };
  }
}
