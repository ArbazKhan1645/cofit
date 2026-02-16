import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/cofit_image.dart';
import '../../../data/models/workout_model.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/workouts_controller.dart';

class WorkoutLibraryScreen extends StatelessWidget {
  const WorkoutLibraryScreen({super.key});

  WorkoutsController get controller => Get.find<WorkoutsController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: Obx(
          () => controller.isSearching.value
              ? TextField(
                  controller: controller.searchController,
                  autofocus: true,
                  onChanged: controller.onSearchChanged,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Search workouts...',
                    hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textDisabled,
                    ),
                    border: InputBorder.none,
                  ),
                )
              : const Text('Workout Library'),
        ),
        actions: [
          IconButton(
            icon: Obx(
              () => Icon(
                controller.isSearching.value
                    ? Icons.close
                    : Iconsax.search_normal,
              ),
            ),
            onPressed: controller.toggleSearch,
          ),
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          _buildCategoryChips(context),

          // Workout list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.allWorkouts.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final workouts = controller.filteredWorkouts;

              if (workouts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppColors.bgBlush,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.search_status,
                            size: 32,
                            color: AppColors.textDisabled,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No workouts found',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textDisabled),
                        ),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: controller.clearFilters,
                          icon: const Icon(Icons.clear_all, size: 18),
                          label: const Text('Clear Filters'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                itemCount: workouts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  return _buildWorkoutCard(context, workouts[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: WorkoutsController.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = WorkoutsController.categories[index];
          return Obx(() {
            final isSelected = controller.filterCategory.value == cat;
            return GestureDetector(
              onTap: () => controller.setFilterCategory(cat),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: AppRadius.pill,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.borderLight,
                  ),
                ),
                child: Center(
                  child: Text(
                    controller.getCategoryLabel(cat),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, WorkoutModel workout) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.workoutDetail, arguments: workout),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.small,
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            // Thumbnail
            Stack(
              children: [
                CofitImage(
                  imageUrl: workout.thumbnailUrl,
                  width: 80,
                  height: 80,
                  borderRadius: AppRadius.medium,
                ),
                // Duration badge
                Positioned(
                  bottom: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${workout.durationMinutes}m',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
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
                  const SizedBox(height: 3),
                  Text(
                    'with ${workout.trainerName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        workout.difficultyLabel,
                        Iconsax.flash_1,
                      ),
                      const SizedBox(width: 6),
                      _buildInfoChip(
                        context,
                        controller.getCategoryLabel(workout.category),
                        Iconsax.category,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Save button
            Obx(
              () => GestureDetector(
                onTap: () => controller.toggleSaveWorkout(workout),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    controller.isWorkoutSaved(workout.id)
                        ? Iconsax.heart5
                        : Iconsax.heart,
                    size: 20,
                    color: controller.isWorkoutSaved(workout.id)
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String text, IconData icon) {
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
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Workouts',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () {
                    controller.clearFilters();
                    Get.back();
                  },
                  child: const Text('Clear All'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Difficulty
            Text(
              'Difficulty',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WorkoutsController.difficulties.map((diff) {
                  final isSelected = controller.filterDifficulty.value == diff;
                  return GestureDetector(
                    onTap: () => controller.setFilterDifficulty(diff),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.bgBlush,
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        diff == 'all'
                            ? 'All'
                            : diff[0].toUpperCase() + diff.substring(1),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Apply'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
