import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'achievement_controller.dart';

class AchievementFormScreen extends GetView<AchievementController> {
  const AchievementFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.editingAchievement.value != null
                ? 'Edit Achievement'
                : 'Add Achievement',
          ),
        ),
        actions: [
          Obx(
            () => TextButton(
              onPressed: controller.isSaving.value
                  ? null
                  : controller.saveAchievement,
              child: controller.isSaving.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: AppPadding.screen,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildIconSection(context),
              const SizedBox(height: 24),
              _buildBasicInfoSection(context),
              const SizedBox(height: 24),
              _buildConfigSection(context),
              const SizedBox(height: 24),
              _buildSettingsSection(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconSection(BuildContext context) {
    return GestureDetector(
      onTap: controller.showIconPicker,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
        ),
        child: Obx(() {
          final iconData = IconData(
            controller.selectedIconCode.value,
            fontFamily: 'MaterialIcons',
          );
          return Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.bgBlush,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Icon(iconData, color: AppColors.primary, size: 36),
              ),
              const SizedBox(height: 10),
              Text(
                'Tap to change icon',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildBasicInfoSection(BuildContext context) {
    return Container(
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Info',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. First Steps',
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'e.g. Complete your first workout',
            ),
            maxLines: 3,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Description is required'
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSection(BuildContext context) {
    return Container(
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuration',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Achievement Type
            DropdownButtonFormField<String>(
              initialValue: controller.achievementType.value,
              decoration: const InputDecoration(labelText: 'Type'),
              items: const [
                DropdownMenuItem(
                  value: 'workout_count',
                  child: Text('Workout Count'),
                ),
                DropdownMenuItem(
                  value: 'workout_minutes',
                  child: Text('Workout Minutes'),
                ),
                DropdownMenuItem(
                  value: 'streak_days',
                  child: Text('Streak Days'),
                ),
                DropdownMenuItem(
                  value: 'category_workouts',
                  child: Text('Category Workouts'),
                ),
                DropdownMenuItem(
                  value: 'calories_burned',
                  child: Text('Calories Burned'),
                ),
                DropdownMenuItem(
                  value: 'consecutive_days',
                  child: Text('Consecutive Days'),
                ),
                DropdownMenuItem(
                  value: 'first_workout',
                  child: Text('First Workout'),
                ),
                DropdownMenuItem(
                  value: 'first_challenge',
                  child: Text('First Challenge'),
                ),
                DropdownMenuItem(
                  value: 'challenge_completions',
                  child: Text('Challenge Completions'),
                ),
              ],
              onChanged: (v) {
                if (v != null) controller.onTypeChanged(v);
              },
            ),
            const SizedBox(height: 16),

            // Target Value
            TextFormField(
              controller: controller.targetValueController,
              decoration: InputDecoration(
                labelText: 'Target Value',
                suffixText: controller.targetUnit.value,
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Target value is required';
                }
                if (int.tryParse(v) == null || int.parse(v) <= 0) {
                  return 'Must be a positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Target Unit (read-only, auto-set)
            DropdownButtonFormField<String>(
              initialValue: controller.targetUnit.value,
              decoration: const InputDecoration(labelText: 'Target Unit'),
              items: const [
                DropdownMenuItem(value: 'workouts', child: Text('Workouts')),
                DropdownMenuItem(value: 'minutes', child: Text('Minutes')),
                DropdownMenuItem(value: 'days', child: Text('Days')),
                DropdownMenuItem(value: 'calories', child: Text('Calories')),
                DropdownMenuItem(
                  value: 'challenges',
                  child: Text('Challenges'),
                ),
              ],
              onChanged: (v) {
                if (v != null) controller.targetUnit.value = v;
              },
            ),

            // Target Category (only for category_workouts)
            if (controller.achievementType.value == 'category_workouts') ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: controller.targetCategory.value.isEmpty
                    ? null
                    : controller.targetCategory.value,
                decoration: const InputDecoration(
                  labelText: 'Workout Category',
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'full_body',
                    child: Text('Full Body'),
                  ),
                  DropdownMenuItem(
                    value: 'upper_body',
                    child: Text('Upper Body'),
                  ),
                  DropdownMenuItem(
                    value: 'lower_body',
                    child: Text('Lower Body'),
                  ),
                  DropdownMenuItem(value: 'core', child: Text('Core')),
                  DropdownMenuItem(value: 'cardio', child: Text('Cardio')),
                  DropdownMenuItem(value: 'hiit', child: Text('HIIT')),
                  DropdownMenuItem(value: 'yoga', child: Text('Yoga')),
                  DropdownMenuItem(value: 'pilates', child: Text('Pilates')),
                ],
                onChanged: (v) => controller.targetCategory.value = v ?? '',
                validator: (v) =>
                    v == null ? 'Select a workout category' : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              initialValue: controller.category.value,
              decoration: const InputDecoration(
                labelText: 'Achievement Category',
              ),
              items: const [
                DropdownMenuItem(value: 'workout', child: Text('Workout')),
                DropdownMenuItem(value: 'streak', child: Text('Streak')),
                DropdownMenuItem(value: 'milestone', child: Text('Milestone')),
                DropdownMenuItem(value: 'community', child: Text('Community')),
                DropdownMenuItem(value: 'special', child: Text('Special')),
              ],
              onChanged: (v) {
                if (v != null) controller.category.value = v;
              },
            ),
            const SizedBox(height: 16),

            // Sort Order
            TextFormField(
              controller: controller.sortOrderController,
              decoration: const InputDecoration(
                labelText: 'Sort Order',
                hintText: '0',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Is Active
            SwitchListTile(
              title: const Text('Active'),
              subtitle: const Text('Show this achievement to users'),
              value: controller.isActive.value,
              onChanged: (v) => controller.isActive.value = v,
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
