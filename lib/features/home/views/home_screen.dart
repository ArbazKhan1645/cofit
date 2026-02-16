import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../shared/widgets/cofit_image.dart';
import '../../../shared/widgets/cofit_avatar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/challenge_model.dart';
import '../../../data/models/workout_model.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/home_controller.dart';
import '../controllers/navigation_controller.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(context).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 20),
              _buildTodaysWorkoutBanner(context).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 16),
              _buildExercisePreview(context).animate().fadeIn(delay: 150.ms, duration: 400.ms),
              const SizedBox(height: 24),
              Padding(
                padding: AppPadding.horizontal,
                child: _buildProgressSection(context).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              ),
              const SizedBox(height: 24),
              _buildUpNextSection(context).animate().fadeIn(delay: 300.ms, duration: 400.ms),
              const SizedBox(height: 24),
              Padding(
                padding: AppPadding.horizontal,
                child: _buildActiveChallenges(context).animate().fadeIn(delay: 400.ms, duration: 400.ms),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: AppPadding.horizontal,
                child: _buildMotivationCard(context).animate().fadeIn(delay: 500.ms, duration: 400.ms),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: AppPadding.horizontal,
      child: Row(
        children: [
          // Avatar
          Obx(() {
            final user = AuthService.to.currentUser;
            return CofitAvatar(
              imageUrl: user?.avatarUrl,
              userId: user?.id,
              userName: controller.userName.value,
              radius: 26,
            );
          }),
          const SizedBox(width: 14),
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.getGreeting(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
                Obx(() => Text(
                      controller.userName.value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    )),
              ],
            ),
          ),
          // Notification
          GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.notifications),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.medium,
                boxShadow: AppShadows.subtle,
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Iconsax.notification, color: AppColors.textPrimary),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // TODAY'S WORKOUT BANNER
  // ============================================

  Widget _buildTodaysWorkoutBanner(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingSchedule.value) {
        return _buildBannerShimmer(context);
      }

      // State 1: Rest day
      if (controller.isTodayRestDay) {
        return _buildRestDayBanner(context);
      }

      // State 2: All workouts completed
      if (controller.allTodayCompleted) {
        return _buildAllCompleteBanner(context);
      }

      // State 3: Current workout available
      final workout = controller.currentWorkout;
      if (workout != null) {
        return _buildCurrentWorkoutBanner(context, workout);
      }

      // State 4: No schedule / no workouts assigned
      return _buildNoWorkoutBanner(context);
    });
  }

  Widget _buildCurrentWorkoutBanner(BuildContext context, WorkoutModel workout) {
    final completedCount = controller.completedTodayIds.length;
    final totalCount = controller.todayItems.length;

    return Container(
      margin: AppPadding.horizontal,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.extraLarge,
        boxShadow: AppShadows.primaryGlow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppRadius.pill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Iconsax.calendar_tick, size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            completedCount > 0
                                ? 'Workout ${completedCount + 1} of $totalCount'
                                : "Today's Workout",
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.small,
                      ),
                      child: Text(
                        '${workout.durationMinutes} min',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  workout.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'with ${workout.trainerName} • ${workout.difficulty}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed(AppRoutes.workoutDetail, arguments: workout),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.medium,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Iconsax.play_circle, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Start Workout',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Obx(() {
                      final isSaved = controller.isWorkoutSaved(workout.id);
                      return Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: AppRadius.medium,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isSaved ? Iconsax.heart5 : Iconsax.heart,
                            color: isSaved ? Colors.red : Colors.white,
                          ),
                          onPressed: () => controller.toggleSaveWorkout(workout.id),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestDayBanner(BuildContext context) {
    return Container(
      margin: AppPadding.horizontal,
      decoration: BoxDecoration(
        gradient: AppColors.calmGradient,
        borderRadius: AppRadius.extraLarge,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -25,
            right: -25,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: AppRadius.medium,
                  ),
                  child: const Icon(Iconsax.moon, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rest Day',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your body recovers and grows stronger on rest days. Enjoy!',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCompleteBanner(BuildContext context) {
    final count = controller.todayItems.length;
    final lastWorkout = controller.lastCompletedWorkout;

    return Container(
      margin: AppPadding.horizontal,
      decoration: BoxDecoration(
        gradient: AppColors.mintGradient,
        borderRadius: AppRadius.extraLarge,
        boxShadow: [
          BoxShadow(
            color: AppColors.mintFresh.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppRadius.pill,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Iconsax.medal_star, size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'All ${count == 1 ? 'Workout' : '$count Workouts'} Completed',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Iconsax.tick_circle, color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (lastWorkout != null) ...[
                  Text(
                    lastWorkout.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'with ${lastWorkout.trainerName} • ${lastWorkout.difficulty}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                ] else ...[
                  Text(
                    'All Done!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  'You crushed ${count == 1 ? 'your workout' : 'all $count workouts'} today. Amazing work!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoWorkoutBanner(BuildContext context) {
    final navController = Get.find<NavigationController>();

    return Container(
      margin: AppPadding.horizontal,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.extraLarge,
        boxShadow: AppShadows.subtle,
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.bgBlush,
              borderRadius: AppRadius.medium,
            ),
            child: const Icon(Iconsax.calendar_add, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No Workout Scheduled',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Browse workouts to find one you love',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => navController.goToWorkouts(),
            icon: const Icon(Iconsax.arrow_right_3, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerShimmer(BuildContext context) {
    return Container(
      margin: AppPadding.horizontal,
      height: 180,
      decoration: BoxDecoration(
        color: AppColors.bgBlush,
        borderRadius: AppRadius.extraLarge,
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  // ============================================
  // EXERCISE PREVIEW SECTION
  // ============================================

  Widget _buildExercisePreview(BuildContext context) {
    return Obx(() {
      final exercises = controller.resolvedExercises;
      final variant = controller.activeVariant.value;
      final workout = controller.currentWorkout;

      // Hide when no workout or no exercises
      if (workout == null || exercises.isEmpty) return const SizedBox.shrink();
      if (controller.isLoadingExercises.value) {
        return Padding(
          padding: AppPadding.horizontal,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.bgBlush,
              borderRadius: AppRadius.large,
            ),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        );
      }

      final workingExercises =
          exercises.where((e) => e.exerciseType != 'rest').toList();

      return Padding(
        padding: AppPadding.horizontal,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.large,
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    Text(
                      'Today\'s Exercises',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.bgBlush,
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        '${workingExercises.length} exercises',
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                    const Spacer(),
                    if (variant != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.mintFresh.withValues(alpha: 0.15),
                          borderRadius: AppRadius.pill,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.shield_tick,
                                size: 12, color: AppColors.mintFresh),
                            const SizedBox(width: 4),
                            Text(
                              variant.label,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color: AppColors.mintFresh,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Exercise list
              ...workingExercises.asMap().entries.map((entry) {
                final index = entry.key;
                final exercise = entry.value;
                final isLast = index == workingExercises.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // Number badge
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.bgBlush,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Name
                          Expanded(
                            child: Text(
                              exercise.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Duration/reps badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: exercise.exerciseType == 'reps'
                                  ? AppColors.sunnyYellow
                                      .withValues(alpha: 0.15)
                                  : AppColors.lavender
                                      .withValues(alpha: 0.15),
                              borderRadius: AppRadius.small,
                            ),
                            child: Text(
                              exercise.exerciseType == 'reps'
                                  ? '${exercise.reps ?? 0} reps'
                                  : '${exercise.durationSeconds}s',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                    color:
                                        exercise.exerciseType == 'reps'
                                            ? AppColors.sunnyYellow
                                            : AppColors.lavender,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        indent: 56,
                        endIndent: 16,
                        color: AppColors.borderLight,
                      ),
                  ],
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    });
  }

  // ============================================
  // PROGRESS SECTION
  // ============================================

  Widget _buildProgressSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          // Progress circle
          Obx(() => CircularPercentIndicator(
                radius: 45,
                lineWidth: 10,
                percent: (controller.workoutsThisWeek.value / 8).clamp(0.0, 1.0),
                center: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${controller.workoutsThisWeek.value}/8',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      'done',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                    ),
                  ],
                ),
                progressColor: AppColors.primary,
                backgroundColor: AppColors.bgBlush,
                circularStrokeCap: CircularStrokeCap.round,
              )),
          const SizedBox(width: 20),
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                _buildMiniStat(context, Iconsax.flash_1, '${controller.currentStreak.value} day streak', AppColors.sunnyYellow),
                const SizedBox(height: 6),
                _buildMiniStat(context, Iconsax.timer_1, '${controller.totalWorkoutsThisMonth.value * 30} min this week', AppColors.mintFresh),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ],
    );
  }

  // ============================================
  // UP NEXT SECTION
  // ============================================

  Widget _buildUpNextSection(BuildContext context) {
    return Obx(() {
      final upNext = controller.upNextWorkouts;
      final hotWorkouts = controller.hotWorkouts;
      final isHotMode = upNext.isEmpty;
      final workoutsToShow = isHotMode ? hotWorkouts : upNext;

      if (workoutsToShow.isEmpty) return const SizedBox.shrink();

      final navController = Get.find<NavigationController>();

      return Column(
        children: [
          Padding(
            padding: AppPadding.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (isHotMode)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(Iconsax.flash_1, size: 20, color: AppColors.sunnyYellow),
                      ),
                    Text(
                      isHotMode ? 'Hot Workouts' : 'Up Next',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => navController.goToWorkouts(),
                  child: const Row(
                    children: [
                      Text('See All'),
                      SizedBox(width: 4),
                      Icon(Iconsax.arrow_right_3, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: AppPadding.horizontal,
              itemCount: workoutsToShow.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final workout = workoutsToShow[index];
                return _buildWorkoutCard(context, workout, index);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildWorkoutCard(BuildContext context, WorkoutModel workout, int index) {
    final colors = [AppColors.bgBlush, AppColors.bgLavender, AppColors.mintFresh.withValues(alpha: 0.2), AppColors.sunnyYellow.withValues(alpha: 0.2)];
    final accentColors = [AppColors.primary, AppColors.lavender, AppColors.mintFresh, AppColors.sunnyYellow];

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.workoutDetail, arguments: workout),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with overlay
            Stack(
              children: [
                CofitImage(
                  imageUrl: workout.thumbnailUrl,
                  height: 90,
                  width: double.infinity,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: AppRadius.small,
                    ),
                    child: Text(
                      '${workout.durationMinutes}m',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: colors[index % colors.length],
                        child: Text(
                          workout.trainerName[0],
                          style: TextStyle(
                            fontSize: 10,
                            color: accentColors[index % accentColors.length],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          workout.trainerName,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // CHALLENGES SECTION
  // ============================================

  Widget _buildActiveChallenges(BuildContext context) {
    return Obx(() {
      final myChallenges = controller.myChallenges;
      final activeChallenges = controller.activeChallenges;
      final hasContent = myChallenges.isNotEmpty || activeChallenges.isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Challenges',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (hasContent)
                TextButton(
                  onPressed: () => Get.toNamed(AppRoutes.challenges),
                  child: const Row(
                    children: [
                      Text('See All'),
                      SizedBox(width: 4),
                      Icon(Iconsax.arrow_right_3, size: 16),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Show user's joined challenges first, then active ones
          if (myChallenges.isNotEmpty)
            ...myChallenges.take(2).toList().asMap().entries.map((entry) {
              final uc = entry.value;
              final challenge = uc.challenge;
              if (challenge == null) return const SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(bottom: entry.key < myChallenges.length - 1 ? 10 : 0),
                child: _buildChallengePreviewCard(
                  context,
                  challenge: challenge,
                  userProgress: uc.currentProgress,
                  gradient: _challengeGradients[entry.key % _challengeGradients.length],
                  isJoined: true,
                ),
              );
            })
          else if (activeChallenges.isNotEmpty)
            ...activeChallenges.take(2).toList().asMap().entries.map((entry) {
              final challenge = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: entry.key < activeChallenges.length - 1 ? 10 : 0),
                child: _buildChallengePreviewCard(
                  context,
                  challenge: challenge,
                  gradient: _challengeGradients[entry.key % _challengeGradients.length],
                  isJoined: false,
                ),
              );
            })
          else
            _buildEmptyChallengeCard(context),
        ],
      );
    });
  }

  static const List<LinearGradient> _challengeGradients = [
    AppColors.mintGradient,
    AppColors.primaryGradient,
    AppColors.calmGradient,
    AppColors.energyGradient,
  ];

  Widget _buildChallengePreviewCard(
    BuildContext context, {
    required ChallengeModel challenge,
    required LinearGradient gradient,
    required bool isJoined,
    int? userProgress,
  }) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.challengeDetail, arguments: challenge.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: AppRadius.large,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: AppRadius.medium,
              ),
              child: const Icon(Iconsax.cup, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isJoined
                        ? '${userProgress ?? 0}/${challenge.targetValue} ${challenge.targetUnit} • ${challenge.participantCount} joined'
                        : '${challenge.daysRemaining}d left • ${challenge.participantCount} participants',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                  ),
                  if (isJoined) ...[
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: challenge.targetValue > 0
                          ? ((userProgress ?? 0) / challenge.targetValue).clamp(0.0, 1.0)
                          : 0.0,
                      backgroundColor: Colors.white.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Iconsax.arrow_right_3, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChallengeCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.challenges),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: AppColors.bgBlush,
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.cup, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Challenges',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Join a challenge and compete with others!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Iconsax.arrow_right_3, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildMotivationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgLavender,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.lavender.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.lavender.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.lovely, color: AppColors.lavender, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Reminder',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.lavender,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '"Progress, not perfection, is what matters. You\'re doing amazing!"',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
