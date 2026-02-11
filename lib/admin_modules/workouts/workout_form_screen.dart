import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/cofit_image.dart';
import 'workout_controller.dart';

class WorkoutFormScreen extends GetView<AdminWorkoutController> {
  const WorkoutFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: Obx(() => Text(controller.editingWorkout.value != null
            ? 'Edit Workout'
            : 'Add Workout')),
        actions: [
          Obx(() => TextButton(
                onPressed:
                    controller.isSaving.value ? null : controller.saveWorkout,
                child: controller.isSaving.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save'),
              )),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: AppPadding.screen,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildThumbnailSection(context),
              const SizedBox(height: 24),
              _buildBasicInfoSection(context),
              const SizedBox(height: 24),
              _buildTrainerSection(context),
              const SizedBox(height: 24),
              _buildDetailsSection(context),
              const SizedBox(height: 24),
              _buildTagsSection(context),
              const SizedBox(height: 24),
              _buildSettingsSection(context),
              const SizedBox(height: 24),
              _buildExercisesSection(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailSection(BuildContext context) {
    return GestureDetector(
      onTap: controller.pickThumbnail,
      child: Obx(() {
        final hasBytes = controller.selectedImageBytes.value != null;
        final hasUrl = controller.thumbnailUrl.value.isNotEmpty;
        return Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.large,
            boxShadow: AppShadows.subtle,
            border: (!hasBytes && !hasUrl)
                ? Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3), width: 2)
                : null,
          ),
          child: hasBytes
              ? Stack(fit: StackFit.expand, children: [
                  ClipRRect(
                      borderRadius: AppRadius.large,
                      child: Image.memory(
                          controller.selectedImageBytes.value!,
                          fit: BoxFit.cover)),
                  _buildRemoveButton(),
                ])
              : hasUrl
                  ? Stack(fit: StackFit.expand, children: [
                      ClipRRect(
                          borderRadius: AppRadius.large,
                          child: CofitImage(
                              imageUrl: controller.thumbnailUrl.value,
                              width: double.infinity,
                              height: 180)),
                      _buildRemoveButton(),
                    ])
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.gallery_add,
                            color: AppColors.primary, size: 40),
                        const SizedBox(height: 8),
                        Text('Add Thumbnail',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.primary)),
                      ],
                    ),
        );
      }),
    );
  }

  Widget _buildRemoveButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: GestureDetector(
        onTap: controller.removeThumbnail,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.close, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic Info',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.titleController,
            decoration: const InputDecoration(
              labelText: 'Title *',
              prefixIcon: Icon(Iconsax.text),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Title is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description *',
              prefixIcon: Icon(Iconsax.document_text),
              alignLabelWithHint: true,
            ),
            maxLines: 4,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Description is required'
                : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.videoUrlController,
            decoration: const InputDecoration(
              labelText: 'Video URL',
              prefixIcon: Icon(Iconsax.video),
              hintText: 'Paste video URL',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainerSection(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trainer & Scheduling',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.selectedTrainerId.value.isNotEmpty
                    ? controller.selectedTrainerId.value
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Trainer *',
                  prefixIcon: Icon(Iconsax.personalcard),
                ),
                items: controller.allTrainers
                    .map((t) => DropdownMenuItem(
                        value: t.id, child: Text(t.fullName)))
                    .toList(),
                onChanged: (v) =>
                    controller.selectedTrainerId.value = v ?? '',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Select a trainer' : null,
              )),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.weekNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Week (1-4)',
                    prefixIcon: Icon(Iconsax.calendar_1),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.sortOrderController,
                  decoration: const InputDecoration(
                    labelText: 'Sort Order',
                    prefixIcon: Icon(Iconsax.sort),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Details',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.durationController,
            decoration: const InputDecoration(
              labelText: 'Duration (minutes) *',
              prefixIcon: Icon(Iconsax.timer_1),
            ),
            keyboardType: TextInputType.number,
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Duration is required' : null,
          ),
          const SizedBox(height: 16),
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.difficulty.value,
                decoration: const InputDecoration(
                  labelText: 'Difficulty',
                  prefixIcon: Icon(Iconsax.flash_1),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'beginner', child: Text('Beginner')),
                  DropdownMenuItem(
                      value: 'intermediate', child: Text('Intermediate')),
                  DropdownMenuItem(
                      value: 'advanced', child: Text('Advanced')),
                ],
                onChanged: (v) => controller.difficulty.value = v ?? '',
              )),
          const SizedBox(height: 16),
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.category.value,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Iconsax.category),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'full_body', child: Text('Full Body')),
                  DropdownMenuItem(
                      value: 'upper_body', child: Text('Upper Body')),
                  DropdownMenuItem(
                      value: 'lower_body', child: Text('Lower Body')),
                  DropdownMenuItem(value: 'core', child: Text('Core')),
                  DropdownMenuItem(value: 'cardio', child: Text('Cardio')),
                  DropdownMenuItem(value: 'hiit', child: Text('HIIT')),
                  DropdownMenuItem(value: 'yoga', child: Text('Yoga')),
                  DropdownMenuItem(
                      value: 'pilates', child: Text('Pilates')),
                ],
                onChanged: (v) => controller.category.value = v ?? '',
              )),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.caloriesController,
            decoration: const InputDecoration(
              labelText: 'Calories Burned',
              prefixIcon: Icon(Iconsax.activity),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tags',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _buildChipInput(context,
              label: 'Equipment',
              items: controller.equipment,
              onAdd: controller.addEquipment,
              onRemove: controller.removeEquipment),
          const SizedBox(height: 16),
          _buildChipInput(context,
              label: 'Target Muscles',
              items: controller.targetMuscles,
              onAdd: controller.addTargetMuscle,
              onRemove: controller.removeTargetMuscle),
          const SizedBox(height: 16),
          _buildChipInput(context,
              label: 'Tags',
              items: controller.tags,
              onAdd: controller.addTag,
              onRemove: controller.removeTag),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Settings',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          Obx(() => SwitchListTile(
                title: const Text('Premium'),
                secondary: const Icon(Iconsax.crown_1),
                value: controller.isPremium.value,
                onChanged: (v) => controller.isPremium.value = v,
              )),
          Obx(() => SwitchListTile(
                title: const Text('Active'),
                value: controller.isActive.value,
                onChanged: (v) => controller.isActive.value = v,
              )),
        ],
      ),
    );
  }

  Widget _buildExercisesSection(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Exercises',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: () => controller.showExerciseDialog(),
                icon: const Icon(Iconsax.add, size: 18),
                label: const Text('Add'),
              ),
            ],
          ),
          Obx(() {
            if (controller.exercises.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No exercises added yet',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textMuted)),
                ),
              );
            }
            return ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: controller.exercises.length,
              onReorder: controller.reorderExercises,
              itemBuilder: (context, index) {
                final ex = controller.exercises[index];
                return Container(
                  key: ValueKey(ex.id),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bgCream,
                    borderRadius: AppRadius.small,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.drag_handle,
                          color: AppColors.textMuted, size: 20),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 14,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.1),
                        child: Text('${index + 1}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.primary)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ex.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w500)),
                            Text(
                              _exerciseTypeLabel(ex),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Iconsax.edit_2, size: 18),
                        onPressed: () =>
                            controller.showExerciseDialog(editIndex: index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            size: 18, color: AppColors.error),
                        onPressed: () => controller.removeExercise(index),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  String _exerciseTypeLabel(dynamic ex) {
    switch (ex.exerciseType) {
      case 'reps':
        return '${ex.sets ?? 0} sets x ${ex.reps ?? 0} reps';
      case 'rest':
        return 'Rest ${ex.durationSeconds}s';
      default:
        return '${ex.durationSeconds}s';
    }
  }

  Widget _buildChipInput(
    BuildContext context, {
    required String label,
    required RxList<String> items,
    required Function(String) onAdd,
    required Function(String) onRemove,
  }) {
    final chipController = TextEditingController();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: chipController,
                decoration: InputDecoration(
                  hintText: 'Add $label...',
                  isDense: true,
                ),
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty) {
                    onAdd(v);
                    chipController.clear();
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Iconsax.add_circle, color: AppColors.primary),
              onPressed: () {
                if (chipController.text.trim().isNotEmpty) {
                  onAdd(chipController.text);
                  chipController.clear();
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items
                  .map((item) => Chip(
                        label: Text(item),
                        onDeleted: () => onRemove(item),
                        backgroundColor: AppColors.bgBlush,
                      ))
                  .toList(),
            )),
      ],
    );
  }
}
