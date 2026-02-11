import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/cofit_image.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/workout_model.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/workouts_controller.dart';

class WorkoutsScreen extends GetView<WorkoutsController> {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Workouts'),
        actions: [
          IconButton(icon: const Icon(Iconsax.search_normal), onPressed: () {}),
          IconButton(icon: const Icon(Iconsax.filter), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildTrainersSection(context),
            const SizedBox(height: 24),
            _buildThisWeekSection(context),
            const SizedBox(height: 24),
            _buildQuickAccess(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CoFit Trainers', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTrainerCard(context, 'Jess', 'Strength & HIIT'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTrainerCard(context, 'Nadine', 'Yoga & Pilates'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTrainerCard(
    BuildContext context,
    String name,
    String specialty,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.bgBlush,
            child: Text(
              name[0],
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(name, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            specialty,
            style: Theme.of(context).textTheme.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildThisWeekSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "This Week's Workouts",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Obx(
          () => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.weeklyWorkouts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final workout = controller.weeklyWorkouts[index];
              return _buildWorkoutListItem(context, workout);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutListItem(BuildContext context, WorkoutModel workout) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.workoutDetail, arguments: workout),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            // Thumbnail
            CofitImage(
              imageUrl: workout.thumbnailUrl,
              width: 80,
              height: 80,
              borderRadius: AppRadius.medium,
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'with ${workout.trainerName}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildTag(
                        context,
                        '${workout.durationMinutes} min',
                        Iconsax.clock,
                      ),
                      const SizedBox(width: 8),
                      _buildTag(context, workout.difficulty, Iconsax.flash_1),
                    ],
                  ),
                ],
              ),
            ),
            // Actions
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    controller.isWorkoutSaved(workout.id)
                        ? Iconsax.heart5
                        : Iconsax.heart,
                    color: controller.isWorkoutSaved(workout.id)
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                  onPressed: () => controller.toggleSaveWorkout(workout),
                ),
                if (workout.isCompleted)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgBlush,
        borderRadius: AppRadius.small,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 4),
          Text(text, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAccessButton(
            context,
            icon: Iconsax.heart,
            label: 'Saved Workouts',
            color: AppColors.primary,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildQuickAccessButton(
            context,
            icon: Iconsax.archive_book,
            label: 'Workout Library',
            color: AppColors.lavender,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: AppRadius.large,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
