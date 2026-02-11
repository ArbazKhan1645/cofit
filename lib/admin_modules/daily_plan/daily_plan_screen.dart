import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/daily_plan_model.dart';
import '../../shared/widgets/cofit_image.dart';
import 'daily_plan_controller.dart';

class DailyPlanScreen extends GetView<DailyPlanController> {
  const DailyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Daily Plan'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_circle),
            onPressed: controller.createNewPlan,
            tooltip: 'New Plan',
          ),
          Obx(() => TextButton(
                onPressed:
                    controller.isSaving.value ? null : controller.savePlan,
                child: controller.isSaving.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: AppPadding.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildPlanHeader(context),
              const SizedBox(height: 20),
              _buildSummaryBar(context),
              const SizedBox(height: 20),
              // Day sections
              ...List.generate(
                controller.totalDays.value,
                (i) => _buildDaySection(context, i + 1),
              ),
              const SizedBox(height: 16),
              // Add Day button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.addDay,
                  icon: const Icon(Iconsax.add, size: 20),
                  label: Text(
                    controller.totalDays.value == 0
                        ? 'Add First Day'
                        : 'Add Day ${controller.totalDays.value + 1}',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.large),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  // ============================================
  // PLAN HEADER
  // ============================================
  Widget _buildPlanHeader(BuildContext context) {
    return Container(
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: TextField(
        controller: controller.titleController,
        decoration: const InputDecoration(
          labelText: 'Plan Title',
          hintText: 'e.g. 30-Day Shred, Beginner Program',
          prefixIcon: Icon(Iconsax.edit_2),
        ),
      ),
    );
  }

  // ============================================
  // SUMMARY BAR
  // ============================================
  Widget _buildSummaryBar(BuildContext context) {
    return Obx(() => Row(
          children: [
            _buildStatChip(
              context,
              '${controller.totalAssignedWorkouts}',
              'Workouts',
              Iconsax.weight,
            ),
            const SizedBox(width: 12),
            _buildStatChip(
              context,
              '${controller.totalDays.value}',
              'Days',
              Iconsax.calendar_1,
            ),
          ],
        ));
  }

  Widget _buildStatChip(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.medium,
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 10),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(width: 4),
            Flexible(
              child: Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // DAY SECTION
  // ============================================
  Widget _buildDaySection(BuildContext context, int dayNumber) {
    return Obx(() {
      final items = controller.getItemsForDay(dayNumber);

      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: AppPadding.card,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: AppRadius.small,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNumber',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Day $dayNumber',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (items.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${items.length} workout${items.length > 1 ? 's' : ''}',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('EEE, d MMM yyyy')
                            .format(controller.getDateForDay(dayNumber)),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                // Remove day
                IconButton(
                  icon: const Icon(Iconsax.trash,
                      size: 18, color: AppColors.error),
                  onPressed: () => _confirmRemoveDay(context, dayNumber),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  tooltip: 'Remove Day',
                ),
              ],
            ),

            // Workout tiles
            if (items.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...items
                  .map((item) => _buildWorkoutTile(context, dayNumber, item)),
            ],
            const SizedBox(height: 8),

            // Add workout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showWorkoutPicker(context, dayNumber),
                icon: const Icon(Iconsax.add, size: 18),
                label: const Text('Add Workout'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.medium),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _confirmRemoveDay(BuildContext context, int dayNumber) {
    Get.dialog(
      AlertDialog(
        title: Text('Remove Day $dayNumber?'),
        content: const Text(
          'This will remove the day and all its workouts. Days after it will be re-numbered.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.removeDay(dayNumber);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  // ============================================
  // WORKOUT TILE
  // ============================================
  Widget _buildWorkoutTile(
    BuildContext context,
    int dayNumber,
    DailyPlanItemModel item,
  ) {
    final workout = item.workout;
    if (workout == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.bgBlush,
        borderRadius: AppRadius.medium,
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: AppRadius.small,
            child: workout.thumbnailUrl.isNotEmpty
                ? CofitImage(
                    imageUrl: workout.thumbnailUrl,
                    width: 48,
                    height: 48,
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: AppColors.bgCream,
                    child: const Icon(Iconsax.video, size: 20),
                  ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workout.title,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                  '${workout.durationMinutes} min \u2022 ${workout.difficultyLabel}',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          // Remove
          IconButton(
            icon: const Icon(Iconsax.close_circle,
                size: 20, color: AppColors.error),
            onPressed: () =>
                controller.removeWorkoutFromDay(dayNumber, item.id),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  // ============================================
  // WORKOUT PICKER BOTTOM SHEET
  // ============================================
  void _showWorkoutPicker(BuildContext context, int dayNumber) {
    controller.workoutSearchQuery.value = '';
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDisabled,
                borderRadius: AppRadius.pill,
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Add Workout to Day $dayNumber',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (v) => controller.workoutSearchQuery.value = v,
                decoration: InputDecoration(
                  hintText: 'Search workouts...',
                  prefixIcon: const Icon(Iconsax.search_normal),
                  filled: true,
                  fillColor: AppColors.bgCream,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.medium,
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Workout list
            Expanded(
              child: Obx(() {
                final workouts = controller.filteredWorkouts;
                if (workouts.isEmpty) {
                  return Center(
                    child: Text('No workouts found',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textMuted)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: workouts.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      leading: ClipRRect(
                        borderRadius: AppRadius.small,
                        child: workout.thumbnailUrl.isNotEmpty
                            ? CofitImage(
                                imageUrl: workout.thumbnailUrl,
                                width: 48,
                                height: 48,
                              )
                            : Container(
                                width: 48,
                                height: 48,
                                color: AppColors.bgBlush,
                                child: const Icon(Iconsax.video, size: 20),
                              ),
                      ),
                      title: Text(workout.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(
                        '${workout.trainerName} \u2022 ${workout.durationMinutes} min \u2022 ${workout.difficultyLabel}',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                      trailing: const Icon(Iconsax.add_circle,
                          color: AppColors.primary),
                      onTap: () {
                        controller.addWorkoutToDay(dayNumber, workout);
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
