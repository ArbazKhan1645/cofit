import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/cofit_image.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/workouts_controller.dart';

class SavedWorkoutsScreen extends StatelessWidget {
  const SavedWorkoutsScreen({super.key});

  WorkoutsController get controller => Get.find<WorkoutsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: const Text('Saved Workouts')),
      body: Obx(() {
        if (controller.isLoadingSaved.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (controller.savedWorkouts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.bgBlush,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.heart,
                      size: 36,
                      color: AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No saved workouts yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the heart icon on any workout\nto save it here for quick access',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textDisabled,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: ListView.separated(
            itemCount: controller.savedWorkouts.length,
            separatorBuilder: (_, _) => const SizedBox(height: 6),
            itemBuilder: (context, index) {
              final saved = controller.savedWorkouts[index];
              final workout = saved.workout;
              if (workout == null) return const SizedBox.shrink();

              return GestureDetector(
                onTap: () =>
                    Get.toNamed(AppRoutes.workoutDetail, arguments: workout),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.small,
                    boxShadow: AppShadows.subtle,
                  ),
                  child: Row(
                    children: [
                      CofitImage(
                        imageUrl: workout.thumbnailUrl,
                        width: 72,
                        height: 72,
                        borderRadius: AppRadius.medium,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.title,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'with ${workout.trainerName}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildTag(
                                  context,
                                  '${workout.durationMinutes} min',
                                  Iconsax.clock,
                                ),
                                const SizedBox(width: 6),
                                _buildTag(
                                  context,
                                  workout.difficultyLabel,
                                  Iconsax.flash_1,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.toggleSaveWorkout(workout),
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Iconsax.heart5,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildTag(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.bgBlush,
        borderRadius: AppRadius.small,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.textMuted),
          const SizedBox(width: 3),
          Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}
