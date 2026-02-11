import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/cofit_image.dart';
import 'workout_controller.dart';

class WorkoutListScreen extends GetView<AdminWorkoutController> {
  const WorkoutListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: const Text('Workouts')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.initFormForCreate();
          Get.toNamed(AppRoutes.adminWorkoutForm);
        },
        child: const Icon(Iconsax.add),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search workouts...',
                prefixIcon: const Icon(Iconsax.search_normal),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.medium,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Filter tabs
          Padding(
            padding: AppPadding.horizontal,
            child: Obx(() => Row(
                  children: [
                    _buildFilterChip(context, 'All', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Active', 'active'),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Inactive', 'inactive'),
                  ],
                )),
          ),
          const SizedBox(height: 12),
          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.workouts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = controller.filteredWorkouts;
              if (items.isEmpty) return _buildEmptyState(context);
              return RefreshIndicator(
                onRefresh: controller.refreshWorkouts,
                child: ListView.separated(
                  padding: AppPadding.screen,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _buildWorkoutCard(context, items[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String value) {
    final selected = controller.filterStatus.value == value;
    return GestureDetector(
      onTap: () => controller.filterStatus.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: AppRadius.pill,
          boxShadow: selected ? [] : AppShadows.subtle,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
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

  Widget _buildWorkoutCard(BuildContext context, dynamic workout) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: AppRadius.medium,
            child: workout.thumbnailUrl.isNotEmpty
                ? CofitImage(
                    imageUrl: workout.thumbnailUrl,
                    width: 80,
                    height: 80,
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: AppColors.bgBlush,
                    child: const Icon(Iconsax.video,
                        color: AppColors.primary, size: 32),
                  ),
          ),
          const SizedBox(width: 16),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('by ${workout.trainerName}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.primary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Iconsax.clock, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${workout.durationMinutes} min',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.textMuted)),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _difficultyColor(workout.difficulty)
                            .withValues(alpha: 0.12),
                        borderRadius: AppRadius.small,
                      ),
                      child: Text(
                        workout.difficultyLabel,
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color:
                                      _difficultyColor(workout.difficulty),
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Menu
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'edit') {
                controller.initFormForEdit(workout);
                Get.toNamed(AppRoutes.adminWorkoutForm);
              } else if (val == 'delete') {
                controller.deleteWorkout(workout.id);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Iconsax.edit_2, size: 18),
                    SizedBox(width: 8),
                    Text('Edit')
                  ])),
              const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Iconsax.trash, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete',
                        style: TextStyle(color: AppColors.error))
                  ])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.weight, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('No workouts found',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              controller.initFormForCreate();
              Get.toNamed(AppRoutes.adminWorkoutForm);
            },
            icon: const Icon(Iconsax.add),
            label: const Text('Add Workout'),
          ),
        ],
      ),
    );
  }
}
