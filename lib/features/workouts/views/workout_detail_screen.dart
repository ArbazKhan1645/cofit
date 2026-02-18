import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:chewie/chewie.dart';
import '../../../shared/widgets/cofit_image.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/workout_model.dart';
import '../controllers/workout_detail_controller.dart';

class WorkoutDetailScreen extends GetView<WorkoutDetailController> {
  const WorkoutDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: CustomScrollView(
        slivers: [
          _WorkoutVideoAppBar(workout: controller.workout),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppPadding.screen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildTitleSection(context),
                  const SizedBox(height: 20),
                  _buildStatsRow(context),
                  const SizedBox(height: 20),
                  Obx(() {
                    final variant = controller.activeVariant.value;
                    if (variant == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildVariantBadge(context, variant),
                    );
                  }),
                  _buildDescriptionSection(context),
                  const SizedBox(height: 24),
                  _buildEquipmentSection(context),
                  const SizedBox(height: 24),
                  _buildExerciseListSection(context),
                  const SizedBox(height: 24),
                  _buildWhatToExpect(context),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildStartButton(context),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    final workout = controller.workout;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          workout.title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            if (workout.trainer != null) {
              Get.toNamed('/trainer', arguments: workout.trainer);
            }
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.bgBlush,
                backgroundImage: workout.trainerAvatar != null
                    ? NetworkImage(workout.trainerAvatar!)
                    : null,
                child: workout.trainerAvatar == null
                    ? Text(
                        workout.trainerName[0],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Text(
                'with ${workout.trainerName}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Iconsax.arrow_right_3,
                size: 16,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final workout = controller.workout;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _buildStatItem(
                context,
                icon: Iconsax.clock,
                value: '${workout.durationMinutes}',
                label: 'Minutes',
                color: AppColors.primary,
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.borderLight),
            Expanded(
              child: _buildStatItem(
                context,
                icon: Iconsax.flash_1,
                value: workout.difficulty,
                label: 'Level',
                color: AppColors.sunnyYellow,
              ),
            ),
            Container(width: 1, height: 40, color: AppColors.borderLight),
            Expanded(
              child: _buildStatItem(
                context,
                icon: Iconsax.activity,
                value: '${controller.exerciseCount}',
                label: 'Exercises',
                color: AppColors.lavender,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildVariantBadge(BuildContext context, WorkoutVariantModel variant) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.mintFresh.withValues(alpha: 0.15),
        borderRadius: AppRadius.pill,
        border: Border.all(color: AppColors.mintFresh.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.shield_tick, size: 18, color: AppColors.mintFresh),
          const SizedBox(width: 8),
          Text(
            variant.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.mintFresh,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About This Workout',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Text(
          controller.workout.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentSection(BuildContext context) {
    final equipment = controller.workout.equipment;
    if (equipment.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Equipment Needed',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: equipment.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.pill,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.tick_circle,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatEquipmentName(item),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatEquipmentName(String key) {
    return key
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  // ============================================
  // EXERCISE LIST
  // ============================================

  Widget _buildExerciseListSection(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingExercises.value) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exercises',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          ],
        );
      }

      final exercises = controller.resolvedExercises;
      if (exercises.isEmpty) return const SizedBox.shrink();

      final hasResume = controller.hasResumeData;
      final resumeIndex = controller.resumeExerciseIndex;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Exercises',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.bgBlush,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  '${controller.exerciseCount}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          // Progress indicator when resume data exists
          if (hasResume) ...[
            const SizedBox(height: 12),
            _buildProgressIndicator(context),
          ],
          const SizedBox(height: 16),
          ...exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            final isCompleted = hasResume && index < resumeIndex;
            final isCurrent = hasResume && index == resumeIndex;
            return _buildExerciseTile(
              context,
              exercise,
              index,
              isCompleted: isCompleted,
              isCurrent: isCurrent,
            );
          }),
        ],
      );
    });
  }

  Widget _buildProgressIndicator(BuildContext context) {
    final completed = controller.completedExerciseCount;
    final total = controller.exerciseCount;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Iconsax.pause_circle, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                '$completed / $total exercises completed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTile(
    BuildContext context,
    WorkoutExerciseModel exercise,
    int index, {
    bool isCompleted = false,
    bool isCurrent = false,
  }) {
    final isRest = exercise.exerciseType == 'rest';
    final isReps = exercise.exerciseType == 'reps';

    if (isRest) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.bgMint.withValues(alpha: 0.5)
                : AppColors.bgMint,
            borderRadius: AppRadius.medium,
          ),
          child: Row(
            children: [
              if (isCompleted)
                const Icon(
                  Iconsax.tick_circle5,
                  size: 20,
                  color: AppColors.success,
                )
              else
                const Icon(
                  Iconsax.pause_circle,
                  size: 20,
                  color: AppColors.mintFresh,
                ),
              const SizedBox(width: 12),
              Text(
                'Rest',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isCompleted ? AppColors.success : AppColors.mintFresh,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${exercise.durationSeconds}s',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isCompleted ? AppColors.success : AppColors.mintFresh,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
          border: isCurrent
              ? Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          children: [
            // Number or checkmark
            if (isCompleted)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: AppRadius.small,
                ),
                child: const Center(
                  child: Icon(
                    Iconsax.tick_circle5,
                    size: 20,
                    color: AppColors.success,
                  ),
                ),
              )
            else
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.bgBlush,
                  borderRadius: AppRadius.small,
                ),
                child: Center(
                  child: isCurrent
                      ? const Icon(
                          Iconsax.play_circle,
                          size: 20,
                          color: AppColors.primary,
                        )
                      : Text(
                          '${index + 1}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                ),
              ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isCompleted ? AppColors.textMuted : null,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _exerciseSubtitle(exercise, isReps),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            // Type badge or current label
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  'Next',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isReps
                      ? AppColors.sunnyYellow.withValues(alpha: 0.15)
                      : AppColors.skyBlue.withValues(alpha: 0.15),
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  isReps ? 'Reps' : 'Timed',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isReps ? AppColors.sunnyYellow : AppColors.skyBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _exerciseSubtitle(WorkoutExerciseModel exercise, bool isReps) {
    final parts = <String>[];
    if (isReps) {
      if (exercise.sets != null && exercise.sets! > 0) {
        parts.add('${exercise.sets} sets');
      }
      if (exercise.reps != null && exercise.reps! > 0) {
        parts.add('${exercise.reps} reps');
      }
    } else {
      final seconds = exercise.durationSeconds;
      if (seconds >= 60) {
        final m = seconds ~/ 60;
        final s = seconds % 60;
        parts.add(s > 0 ? '${m}m ${s}s' : '${m}m');
      } else {
        parts.add('${seconds}s');
      }
    }
    if (exercise.restSeconds != null && exercise.restSeconds! > 0) {
      parts.add('${exercise.restSeconds}s rest');
    }
    return parts.join(' · ');
  }

  // ============================================
  // WHAT TO EXPECT
  // ============================================

  Widget _buildWhatToExpect(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.mintGradient,
        borderRadius: AppRadius.large,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: AppRadius.small,
                ),
                child: const Icon(
                  Iconsax.lovely,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'What to Expect',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildExpectItem(context, 'Warm-up to get your body ready'),
          _buildExpectItem(context, 'Main workout with guided instructions'),
          _buildExpectItem(context, 'Cool-down and stretching'),
          _buildExpectItem(context, 'Positive vibes and encouragement!'),
        ],
      ),
    );
  }

  Widget _buildExpectItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // START / RESUME BUTTON
  // ============================================

  Widget _buildStartButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          final hasResume = controller.hasResumeData;
          final completed = controller.completedExerciseCount;
          final total = controller.exerciseCount;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasResume)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '$completed / $total exercises completed',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: controller.isLoadingExercises.value
                    ? null
                    : controller.startWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primaryLight,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.large),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasResume ? Iconsax.refresh : Iconsax.play_circle,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      hasResume ? 'Resume Workout' : 'Start Workout',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

/// Stateful inner widget for video player lifecycle management
class _WorkoutVideoAppBar extends StatefulWidget {
  final WorkoutModel workout;
  const _WorkoutVideoAppBar({required this.workout});

  @override
  State<_WorkoutVideoAppBar> createState() => _WorkoutVideoAppBarState();
}

class _WorkoutVideoAppBarState extends State<_WorkoutVideoAppBar> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _showVideo = false;

  void _initializeVideo() async {
    setState(() => _showVideo = true);

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.workout.videoUrl),
    );

    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,

      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.primary,
        handleColor: AppColors.primary,
        backgroundColor: Colors.grey.shade300,
        bufferedColor: AppColors.primaryLight,
      ),
    );

    if (mounted) setState(() => _isVideoInitialized = true);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Get.back(),
      ),
      actions: [
        Obx(() {
          final detailCtrl = Get.find<WorkoutDetailController>();
          final isSaved = detailCtrl.isWorkoutSaved.value;
          return IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isSaved ? Iconsax.heart5 : Iconsax.heart,
                color: isSaved ? Colors.red : Colors.white,
              ),
            ),
            onPressed: () => detailCtrl.toggleSaveWorkout(),
          );
        }),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.share, color: Colors.white),
          ),
          onPressed: () => Get.find<WorkoutDetailController>().shareWorkout(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _showVideo && _isVideoInitialized
            ? Chewie(controller: _chewieController!)
            : Stack(
                fit: StackFit.expand,
                children: [
                  CofitImage(
                    imageUrl: widget.workout.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(color: Colors.black.withValues(alpha: 0.3)),
                  Center(
                    child: GestureDetector(
                      onTap: _initializeVideo,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
