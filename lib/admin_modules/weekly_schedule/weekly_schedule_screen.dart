import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/weekly_schedule_model.dart';
import '../../shared/widgets/cofit_image.dart';
import 'weekly_schedule_controller.dart';

class WeeklyScheduleScreen extends GetView<WeeklyScheduleController> {
  const WeeklyScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('This Week'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add_circle),
            onPressed: controller.createNewWeek,
            tooltip: 'New Week',
          ),
          Obx(() => TextButton(
                onPressed: controller.isSaving.value
                    ? null
                    : controller.saveSchedule,
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
              _buildScheduleHeader(context),
              const SizedBox(height: 20),
              _buildSummaryBar(context),
              const SizedBox(height: 20),
              ...List.generate(7, (day) => _buildDaySection(context, day)),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  // ============================================
  // SCHEDULE HEADER
  // ============================================
  Widget _buildScheduleHeader(BuildContext context) {
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
          labelText: 'Week Title',
          hintText: 'e.g. Week of Feb 10 - Power Week',
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
              '${7 - controller.disabledDays.length}',
              'Active Days',
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
  Widget _buildDaySection(BuildContext context, int day) {
    return Obx(() {
      final isDisabled = controller.isDayDisabled(day);
      final items = controller.getItemsForDay(day);

      return AnimatedOpacity(
        opacity: isDisabled ? 0.45 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: AppPadding.card,
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey.shade100 : Colors.white,
            borderRadius: AppRadius.large,
            boxShadow: AppShadows.subtle,
            border: isDisabled
                ? Border.all(color: Colors.grey.shade300)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Day header
              Row(
                children: [
                  Text(
                    WeeklyScheduleController.dayNames[day],
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          decoration:
                              isDisabled ? TextDecoration.lineThrough : null,
                          color: isDisabled
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                        ),
                  ),
                  if (isDisabled) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: AppRadius.small,
                      ),
                      child: Text('Rest Day',
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w600,
                              )),
                    ),
                  ],
                  const Spacer(),
                  Switch(
                    value: !isDisabled,
                    onChanged: (_) => controller.toggleDay(day),
                    activeTrackColor: AppColors.primary,
                  ),
                ],
              ),

              // Workout tiles
              if (!isDisabled) ...[
                if (items.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...items.map((item) => _buildWorkoutTile(context, day, item)),
                ],
                const SizedBox(height: 8),
                // Add workout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showWorkoutPicker(context, day),
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
            ],
          ),
        ),
      );
    });
  }

  // ============================================
  // WORKOUT TILE
  // ============================================
  Widget _buildWorkoutTile(
    BuildContext context,
    int day,
    WeeklyScheduleItemModel item,
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
            onPressed: () => controller.removeWorkoutFromDay(day, item.id),
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
  void _showWorkoutPicker(BuildContext context, int day) {
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
                'Add Workout to ${WeeklyScheduleController.dayNames[day]}',
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
                        controller.addWorkoutToDay(day, workout);
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
