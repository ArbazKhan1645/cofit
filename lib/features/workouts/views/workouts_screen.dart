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
          IconButton(
            icon: const Icon(Iconsax.search_normal),
            onPressed: () {
              controller.loadAllWorkouts();
              Get.toNamed(AppRoutes.workoutLibrary);
            },
          ),
          IconButton(
            icon: const Icon(Iconsax.filter),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isInitialLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildTrainersSection(context),
                const SizedBox(height: 12),
                _buildThisWeekSection(context),
                const SizedBox(height: 12),
                _buildQuickAccess(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ============================================
  // TRAINERS SECTION
  // ============================================

  static const _trainerAccents = [
    AppColors.primary,
    AppColors.lavender,
    AppColors.mintFresh,
    AppColors.skyBlue,
    AppColors.peach,
    AppColors.sunnyYellow,
  ];

  Widget _buildTrainersSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppRadius.medium,
              ),
              child: const Icon(
                Iconsax.people,
                size: 20,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CoFit Trainers',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Meet your fitness coaches',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.trainers.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.large,
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.bgBlush,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Iconsax.profile_2user,
                      size: 28,
                      color: AppColors.textDisabled,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No trainers available',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return SizedBox(
            height: 190,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: controller.trainers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                final accent = _trainerAccents[index % _trainerAccents.length];
                return _buildTrainerCard(
                  context,
                  controller.trainers[index],
                  accent,
                );
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTrainerCard(
    BuildContext context,
    TrainerModel trainer,
    Color accent,
  ) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.trainer, arguments: trainer),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.small,
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          children: [
            // Top accent strip + avatar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 16, bottom: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: 0.15),
                    accent.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  // Avatar with accent ring
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: accent, width: 2),
                    ),
                    child:
                        trainer.avatarUrl != null &&
                            trainer.avatarUrl!.isNotEmpty
                        ? CofitImage(
                            imageUrl: trainer.avatarUrl!,
                            width: 56,
                            height: 56,
                            borderRadius: BorderRadius.circular(28),
                          )
                        : CircleAvatar(
                            radius: 28,
                            backgroundColor: accent.withValues(alpha: 0.15),
                            child: Text(
                              trainer.fullName.isNotEmpty
                                  ? trainer.fullName[0].toUpperCase()
                                  : '?',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                  ),
                ],
              ),
            ),

            // Info section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    Text(
                      trainer.fullName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    // Specialty chip
                    if (trainer.specialties.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          borderRadius: AppRadius.pill,
                        ),
                        child: Text(
                          trainer.specialties.first,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: accent,
                                fontWeight: FontWeight.w600,
                                fontSize: 10,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    const Spacer(),
                    // Experience + rating row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (trainer.yearsExperience > 0) ...[
                          Icon(Iconsax.medal_star5, size: 11, color: accent),
                          const SizedBox(width: 3),
                          Text(
                            '${trainer.yearsExperience}y',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                          ),
                        ],
                        if (trainer.yearsExperience > 0 &&
                            trainer.averageRating > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: AppColors.textDisabled,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        if (trainer.averageRating > 0) ...[
                          Icon(
                            Iconsax.star5,
                            size: 11,
                            color: AppColors.sunnyYellow,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            trainer.averageRating.toStringAsFixed(1),
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: AppColors.textMuted,
                                  fontSize: 10,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // THIS WEEK SECTION
  // ============================================

  Widget _buildThisWeekSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.small,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadius.medium,
                ),
                child: const Icon(
                  Iconsax.calendar_1,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "This Week's Workouts",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Obx(() {
                      final dayName = WorkoutsController
                          .fullDayNames[controller.selectedDayIndex.value];
                      final isToday =
                          controller.selectedDayIndex.value ==
                          controller.todayIndex;
                      return Text(
                        isToday ? 'Today - $dayName' : dayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Day selector
          Obx(() => _buildDaySelector(context)),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 16),

          // Day's workouts
          Obx(() {
            if (controller.activeSchedule.value == null) {
              return _buildEmptySchedule(context);
            }

            if (controller.isSelectedDayRestDay) {
              return _buildRestDayCard(context);
            }

            final workouts = controller.selectedDayWorkouts;
            if (workouts.isEmpty) {
              return _buildNoDayWorkouts(context);
            }

            return Column(
              children: [
                for (int i = 0; i < workouts.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  _buildWorkoutListItem(context, workouts[i]),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDaySelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.bgBlush.withValues(alpha: 0.5),
        borderRadius: AppRadius.medium,
      ),
      child: Row(
        children: List.generate(7, (index) {
          final isToday = index == controller.todayIndex;
          final isSelected = index == controller.selectedDayIndex.value;
          final isDisabled = controller.isDayDisabled(index);
          final workoutCount = controller.getWorkoutCountForDay(index);

          return Expanded(
            child: GestureDetector(
              onTap: () => controller.selectDay(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      WorkoutsController.dayNames[index],
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        color: isSelected
                            ? Colors.white
                            : isDisabled
                            ? AppColors.textDisabled
                            : AppColors.textSecondary,
                        fontWeight: isToday || isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (isDisabled)
                      Icon(
                        Iconsax.moon5,
                        size: 10,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.7)
                            : AppColors.textDisabled,
                      )
                    else
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: workoutCount > 0
                              ? isSelected
                                    ? Colors.white
                                    : AppColors.success
                              : isSelected
                              ? Colors.white.withValues(alpha: 0.3)
                              : AppColors.borderLight,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptySchedule(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.bgBlush,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.calendar_remove,
              size: 28,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No schedule available',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Weekly workouts will appear here\nonce set up by your trainer',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textDisabled),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRestDayCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.lavender.withValues(alpha: 0.12),
            AppColors.mintFresh.withValues(alpha: 0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.medium,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.lavender.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.moon,
              size: 28,
              color: AppColors.lavender,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Rest Day',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.lavender,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Take it easy today!\nRecovery is part of the journey.',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoDayWorkouts(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.bgBlush,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.activity,
              size: 28,
              color: AppColors.textDisabled,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No workouts assigned',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'No workouts scheduled for this day',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textDisabled),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutListItem(BuildContext context, WorkoutModel workout) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.workoutDetail, arguments: workout),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCream,
          borderRadius: AppRadius.medium,
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: AppRadius.small,
              child: CofitImage(
                imageUrl: workout.thumbnailUrl,
                width: 68,
                height: 68,
                borderRadius: AppRadius.small,
              ),
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 6),
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
            // Save button
            Obx(
              () => GestureDetector(
                onTap: () => controller.toggleSaveWorkout(workout),
                child: Padding(
                  padding: const EdgeInsets.all(4),
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

  Widget _buildTag(BuildContext context, String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
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

  // ============================================
  // QUICK ACCESS
  // ============================================

  Widget _buildQuickAccess(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickAccessButton(
            context,
            icon: Iconsax.heart,
            label: 'Saved',
            subtitle: 'Workouts',
            color: AppColors.primary,
            onTap: () {
              controller.loadSavedWorkouts();
              Get.toNamed(AppRoutes.savedWorkouts);
            },
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildQuickAccessButton(
            context,
            icon: Iconsax.archive_book,
            label: 'Library',
            subtitle: 'All Workouts',
            color: AppColors.lavender,
            onTap: () {
              controller.loadAllWorkouts();
              Get.toNamed(AppRoutes.workoutLibrary);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: AppRadius.small,
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // FILTER BOTTOM SHEET
  // ============================================

  void _showFilterSheet(BuildContext context) {
    controller.loadAllWorkouts();
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

            // Category
            Text(
              'Category',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: WorkoutsController.categories.map((cat) {
                  final isSelected = controller.filterCategory.value == cat;
                  return GestureDetector(
                    onTap: () => controller.setFilterCategory(cat),
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
                        controller.getCategoryLabel(cat),
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

            // Apply button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(AppRoutes.workoutLibrary);
                },
                child: const Text('Show Results'),
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
