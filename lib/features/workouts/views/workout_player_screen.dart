import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/workout_model.dart';
import '../controllers/workout_player_controller.dart';

class WorkoutPlayerScreen extends GetView<WorkoutPlayerController> {
  const WorkoutPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) controller.exitWorkout();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Obx(() {
            switch (controller.playerState.value) {
              case PlayerState.countdown:
                return _buildCountdownView(context);
              case PlayerState.playing:
              case PlayerState.paused:
                return _buildPlayingView(context);
              case PlayerState.resting:
                return _buildRestingView(context);
              case PlayerState.completing:
                return _buildCompletingView(context);
              case PlayerState.completed:
                return _buildCompletedView(context);
            }
          }),
        ),
      ),
    );
  }

  // ============================================
  // COUNTDOWN (3, 2, 1)
  // ============================================

  Widget _buildCountdownView(BuildContext context) {
    final exercise = controller.currentExercise;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Get Ready',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: 40),
          Obx(() => Text(
                controller.countdownValue.value > 0
                    ? '${controller.countdownValue.value}'
                    : 'GO!',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 120,
                    ),
              )
                  .animate(
                    onPlay: (c) => c.repeat(),
                  )
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.2, 1.2),
                    duration: 500.ms,
                  )
                  .then()
                  .scale(
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(0.8, 0.8),
                    duration: 500.ms,
                  )),
          const SizedBox(height: 40),
          Text(
            exercise.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${controller.currentExerciseIndex.value + 1} of ${controller.exercises.length}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // PLAYING / PAUSED
  // ============================================

  Widget _buildPlayingView(BuildContext context) {
    final exercise = controller.currentExercise;
    final isPaused = controller.playerState.value == PlayerState.paused;

    return Column(
      children: [
        // Top bar
        _buildTopBar(context),

        // Video / Timer area
        Expanded(
          child: GestureDetector(
            onTap: controller.togglePlayPause,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video or timer placeholder
                Obx(() {
                  if (controller.isVideoInitialized.value &&
                      controller.videoController != null) {
                    return Center(
                      child: AspectRatio(
                        aspectRatio:
                            controller.videoController!.value.aspectRatio,
                        child: VideoPlayer(controller.videoController!),
                      ),
                    );
                  }

                  // Timer-based fallback
                  return _buildTimerFallback(context, exercise);
                }),

                // Pause overlay
                if (isPaused)
                  Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: const Center(
                      child: Icon(
                        Icons.pause_circle_filled,
                        color: Colors.white,
                        size: 80,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Bottom controls
        _buildBottomControls(context, exercise),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () => controller.exitWorkout(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 12),
          // Previous exercise button
          Obx(() => controller.canGoBack
              ? GestureDetector(
                  onTap: controller.goToPreviousExercise,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.arrow_left_2,
                        color: Colors.white, size: 20),
                  ),
                )
              : const SizedBox(width: 40)),
          const SizedBox(width: 12),
          // Exercise title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                      controller.currentExercise.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                Obx(() => Text(
                      '${controller.currentExerciseIndex.value + 1} of ${controller.exercises.length}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                    )),
              ],
            ),
          ),
          // Elapsed time
          Obx(() => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  controller.formattedElapsed,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTimerFallback(
      BuildContext context, WorkoutExerciseModel exercise) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.activity, color: AppColors.primary, size: 64),
            const SizedBox(height: 24),
            Text(
              exercise.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Obx(() => CircularPercentIndicator(
                  radius: 60,
                  lineWidth: 8,
                  percent: controller.videoProgress.value,
                  center: Text(
                    _remainingTimeText(exercise),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  progressColor: AppColors.primary,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  circularStrokeCap: CircularStrokeCap.round,
                )),
          ],
        ),
      ),
    );
  }

  String _remainingTimeText(WorkoutExerciseModel exercise) {
    final total = exercise.durationSeconds > 0 ? exercise.durationSeconds : 30;
    final elapsed = (controller.videoProgress.value * total).round();
    final remaining = total - elapsed;
    return '${remaining}s';
  }

  Widget _buildBottomControls(
      BuildContext context, WorkoutExerciseModel exercise) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Progress bar
          Obx(() => ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: controller.videoProgress.value,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 4,
                ),
              )),
          const SizedBox(height: 16),
          // Controls row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous button
              Obx(() => GestureDetector(
                    onTap: controller.canGoBack
                        ? controller.goToPreviousExercise
                        : null,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: controller.canGoBack
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.previous,
                        color: controller.canGoBack
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                        size: 22,
                      ),
                    ),
                  )),
              const SizedBox(width: 20),
              // Play/Pause
              GestureDetector(
                onTap: controller.togglePlayPause,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Obx(() => Icon(
                        controller.isVideoPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 36,
                      )),
                ),
              ),
            ],
          ),
          // Exercise info
          if (exercise.description != null &&
              exercise.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              exercise.description!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  // ============================================
  // RESTING
  // ============================================

  Widget _buildRestingView(BuildContext context) {
    final next = controller.nextExercise;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D2137), Color(0xFF1A1A2E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Rest',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  letterSpacing: 2,
                ),
          ),
          const SizedBox(height: 32),
          Obx(() {
            final remaining = controller.restTimeRemaining.value;
            final exercise = controller.currentExercise;
            final restSeconds = exercise.restSeconds ?? 5;
            final total = restSeconds > 0 ? restSeconds : 5;
            final percent = (remaining / total).clamp(0.0, 1.0);

            return CircularPercentIndicator(
              radius: 80,
              lineWidth: 10,
              percent: percent,
              center: Text(
                '$remaining',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
              ),
              progressColor: AppColors.mintFresh,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              circularStrokeCap: CircularStrokeCap.round,
            );
          }),
          const SizedBox(height: 40),
          // Up next preview
          if (next != null) ...[
            Text(
              'Up Next',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.5),
                    letterSpacing: 1,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              next.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
          const SizedBox(height: 32),
          // Skip rest
          GestureDetector(
            onTap: controller.skipRest,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Text(
                'Skip Rest',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // COMPLETING (Animation)
  // ============================================

  Widget _buildCompletingView(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D2137), Color(0xFF1A1A2E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Iconsax.medal_star,
            color: AppColors.sunnyYellow,
            size: 80,
          )
              .animate()
              .scale(
                begin: const Offset(0.0, 0.0),
                end: const Offset(1.0, 1.0),
                duration: 600.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(duration: 300.ms),
          const SizedBox(height: 24),
          Text(
            'Workout Complete!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 400.ms)
              .slideY(begin: 0.3, end: 0),
          const SizedBox(height: 8),
          Text(
            'Amazing work!',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.sunnyYellow,
                ),
          ).animate().fadeIn(delay: 800.ms, duration: 400.ms),
        ],
      ),
    );
  }

  // ============================================
  // COMPLETED (Summary)
  // ============================================

  Widget _buildCompletedView(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D2137), Color(0xFF1A1A2E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.medal_star,
                color: AppColors.sunnyYellow, size: 64),
            const SizedBox(height: 20),
            Text(
              'Well Done!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 32),
            // Stats summary
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    context,
                    icon: Iconsax.clock,
                    label: 'Duration',
                    value: controller.formattedElapsed,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    context,
                    icon: Iconsax.activity,
                    label: 'Exercises',
                    value:
                        '${controller.completedExerciseCount.value}/${controller.exercises.length}',
                    color: AppColors.mintFresh,
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryRow(
                    context,
                    icon: Iconsax.flash_1,
                    label: 'Calories',
                    value: '~${controller.workout.caloriesBurned}',
                    color: AppColors.sunnyYellow,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.finishAndGoHome,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Done',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
