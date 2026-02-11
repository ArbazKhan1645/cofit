import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/workout_model.dart';
import '../../shared/widgets/cofit_image.dart';
import 'workout_controller.dart';

class WorkoutViewScreen extends StatefulWidget {
  const WorkoutViewScreen({super.key});

  @override
  State<WorkoutViewScreen> createState() => _WorkoutViewScreenState();
}

class _WorkoutViewScreenState extends State<WorkoutViewScreen> {
  final controller = Get.find<AdminWorkoutController>();
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _videoError = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    final workout = controller.viewingWorkout.value;
    if (workout == null || workout.videoUrl.isEmpty) return;

    final uri = Uri.tryParse(workout.videoUrl);
    if (uri == null || !uri.hasScheme) return;

    _videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(workout.videoUrl));
    _videoPlayerController!.initialize().then((_) {
      if (!mounted) return;
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        allowPlaybackSpeedChanging: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          handleColor: AppColors.primary,
          bufferedColor: AppColors.primaryLight.withValues(alpha: 0.3),
          backgroundColor: AppColors.textMuted.withValues(alpha: 0.2),
        ),
      );
      setState(() {});
    }).catchError((_) {
      if (mounted) setState(() => _videoError = true);
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: Obx(() {
        final workout = controller.viewingWorkout.value;
        if (workout == null) {
          return const Center(child: Text('Workout not found'));
        }
        return CustomScrollView(
          slivers: [
            _buildAppBar(context, workout),
            SliverToBoxAdapter(child: _buildBody(context, workout)),
          ],
        );
      }),
    );
  }

  Widget _buildAppBar(BuildContext context, WorkoutModel workout) {
    return SliverAppBar(
      expandedHeight: workout.thumbnailUrl.isNotEmpty ? 250 : 0,
      pinned: true,
      title: Text(workout.title),
      flexibleSpace: workout.thumbnailUrl.isNotEmpty
          ? FlexibleSpaceBar(
              background: CofitImage(
                imageUrl: workout.thumbnailUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, WorkoutModel workout) {
    return Padding(
      padding: AppPadding.screenAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player
          if (workout.videoUrl.isNotEmpty) ...[
            _buildVideoSection(context, workout),
            const SizedBox(height: 24),
          ],

          // Title & Trainer
          Text(
            workout.title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Iconsax.user, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'by ${workout.trainerName}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Stats
          _buildStatsRow(context, workout),
          const SizedBox(height: 24),

          // Description
          if (workout.description.isNotEmpty) ...[
            _buildSectionTitle(context, 'Description'),
            const SizedBox(height: 8),
            Text(
              workout.description,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
          ],

          // Details Card
          _buildDetailsCard(context, workout),
          const SizedBox(height: 24),

          // Equipment
          if (workout.equipment.isNotEmpty) ...[
            _buildSectionTitle(context, 'Equipment'),
            const SizedBox(height: 8),
            _buildChipList(workout.equipment, AppColors.lavender),
            const SizedBox(height: 24),
          ],

          // Target Muscles
          if (workout.targetMuscles.isNotEmpty) ...[
            _buildSectionTitle(context, 'Target Muscles'),
            const SizedBox(height: 8),
            _buildChipList(workout.targetMuscles, AppColors.mintFresh),
            const SizedBox(height: 24),
          ],

          // Tags
          if (workout.tags.isNotEmpty) ...[
            _buildSectionTitle(context, 'Tags'),
            const SizedBox(height: 8),
            _buildChipList(workout.tags, AppColors.peach),
            const SizedBox(height: 24),
          ],

          // Exercises
          _buildExercisesSection(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildVideoSection(BuildContext context, WorkoutModel workout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Video'),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: AppRadius.large,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _buildVideoPlayer(context, workout),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayer(BuildContext context, WorkoutModel workout) {
    if (_videoError) {
      return Container(
        color: Colors.black87,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.video_slash, color: Colors.white54, size: 48),
              const SizedBox(height: 12),
              Text(
                'Unable to play this video',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white54),
              ),
              const SizedBox(height: 8),
              Text(
                workout.videoUrl,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: Colors.white38),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    if (_chewieController != null) {
      return Chewie(controller: _chewieController!);
    }

    return Container(
      color: Colors.black87,
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, WorkoutModel workout) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
              context, Iconsax.clock, workout.formattedDuration, 'Duration'),
          _buildStatDivider(),
          _buildStatItem(context, Iconsax.flash_1,
              workout.difficultyLabel, 'Difficulty',
              color: _difficultyColor(workout.difficulty)),
          _buildStatDivider(),
          _buildStatItem(context, Iconsax.strongbox,
              '${workout.caloriesBurned} cal', 'Calories'),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, IconData icon, String value, String label,
      {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 22, color: color ?? AppColors.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w700, color: color),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.borderLight,
    );
  }

  Widget _buildDetailsCard(BuildContext context, WorkoutModel workout) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          _buildDetailRow(context, 'Category',
              workout.category.replaceAll('_', ' ').capitalizeFirst ?? ''),
          const Divider(height: 24),
          _buildDetailRow(
              context, 'Week Number', workout.weekNumber.toString()),
          const Divider(height: 24),
          _buildDetailRow(context, 'Sort Order', workout.sortOrder.toString()),
          const Divider(height: 24),
          _buildDetailRow(
            context,
            'Premium',
            workout.isPremium ? 'Yes' : 'No',
            valueColor: workout.isPremium ? AppColors.warning : null,
          ),
          const Divider(height: 24),
          _buildDetailRow(
            context,
            'Status',
            workout.isActive ? 'Active' : 'Inactive',
            valueColor:
                workout.isActive ? AppColors.success : AppColors.textMuted,
          ),
          const Divider(height: 24),
          _buildDetailRow(context, 'Total Completions',
              workout.totalCompletions.toString()),
          const Divider(height: 24),
          _buildDetailRow(context, 'Average Rating',
              workout.averageRating.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textMuted),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor ?? AppColors.textPrimary,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildChipList(List<String> items, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: AppRadius.pill,
          ),
          child: Text(
            item.replaceAll('_', ' ').capitalizeFirst ?? item,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExercisesSection(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingView.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        );
      }

      final exerciseList = controller.currentViewVariantExercises;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, 'Exercises'),
          const SizedBox(height: 12),
          // Variant tabs
          if (controller.viewVariants.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: const Text('Default'),
                        selected:
                            controller.selectedViewVariant.value == null,
                        onSelected: (_) =>
                            controller.selectViewVariant(null),
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color:
                              controller.selectedViewVariant.value == null
                                  ? Colors.white
                                  : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    ...controller.viewVariants.map((v) {
                      final isSelected =
                          controller.selectedViewVariant.value?.id == v.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(v.label),
                          selected: isSelected,
                          onSelected: (_) =>
                              controller.selectViewVariant(v),
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          if (exerciseList.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.large,
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                children: [
                  const Icon(Iconsax.weight,
                      size: 40, color: AppColors.textMuted),
                  const SizedBox(height: 8),
                  Text(
                    'No exercises added',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          else
            ...exerciseList.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return _buildExerciseCard(context, exercise, index);
            }),
        ],
      );
    });
  }

  Widget _buildExerciseCard(
      BuildContext context, WorkoutExerciseModel exercise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Index badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: AppRadius.pill,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    _buildExerciseTypeBadge(context, exercise.exerciseType),
                  ],
                ),
                if (exercise.description != null &&
                    exercise.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    exercise.description!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    if (exercise.exerciseType == 'reps') ...[
                      if (exercise.sets != null)
                        _buildExerciseDetail(
                            Iconsax.repeat, '${exercise.sets} sets'),
                      if (exercise.reps != null)
                        _buildExerciseDetail(
                            Iconsax.flash_1, '${exercise.reps} reps'),
                    ] else ...[
                      _buildExerciseDetail(
                          Iconsax.clock, '${exercise.durationSeconds}s'),
                    ],
                    if (exercise.restSeconds != null)
                      _buildExerciseDetail(
                          Iconsax.pause, '${exercise.restSeconds}s rest'),
                  ],
                ),
                // Alternatives
                if (exercise.alternatives.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Text(
                    'Alternatives',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: exercise.alternatives.entries.map((entry) {
                      final condition = entry.key;
                      final data = entry.value as Map<String, dynamic>;
                      final label = AdminWorkoutController.conditionTags
                          .firstWhere(
                            (t) => t['tag'] == condition,
                            orElse: () => {'label': condition},
                          )['label']!;
                      return Tooltip(
                        message: data['name'] ?? '',
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.lavender.withValues(alpha: 0.12),
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            '$label: ${data['name'] ?? ''}',
                            style: TextStyle(
                              color: AppColors.lavender,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseTypeBadge(BuildContext context, String type) {
    Color color;
    switch (type) {
      case 'timed':
        color = AppColors.info;
        break;
      case 'reps':
        color = AppColors.success;
        break;
      case 'rest':
        color = AppColors.warning;
        break;
      default:
        color = AppColors.textMuted;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        type.capitalizeFirst ?? type,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildExerciseDetail(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'advanced':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }
}
