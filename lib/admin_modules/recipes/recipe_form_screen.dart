import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/cofit_image.dart';
import 'recipe_controller.dart';

class RecipeFormScreen extends GetView<AdminRecipeController> {
  const RecipeFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: Obx(() => Text(controller.editingPlan.value != null
            ? 'Edit Diet Plan'
            : 'New Diet Plan')),
        actions: [
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
      body: Form(
        key: controller.formKey,
        child: SingleChildScrollView(
          padding: AppPadding.screen,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildImageSection(context),
              const SizedBox(height: 24),
              _buildBasicInfoSection(context),
              const SizedBox(height: 24),
              _buildPlanConfigSection(context),
              const SizedBox(height: 24),
              _buildNutritionSection(context),
              const SizedBox(height: 24),
              _buildSettingsSection(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return GestureDetector(
      onTap: controller.pickImage,
      child: Obx(() {
        final hasBytes = controller.selectedImageBytes.value != null;
        final hasUrl = controller.imageUrl.value.isNotEmpty;
        return Container(
          width: double.infinity,
          height: 200,
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
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: AppRadius.large,
                      child: Image.memory(
                          controller.selectedImageBytes.value!,
                          fit: BoxFit.cover),
                    ),
                    _buildRemoveButton(),
                  ],
                )
              : hasUrl
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.large,
                          child: CofitImage(
                              imageUrl: controller.imageUrl.value,
                              width: double.infinity,
                              height: 200),
                        ),
                        _buildRemoveButton(),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.gallery_add,
                            color: AppColors.primary, size: 40),
                        const SizedBox(height: 8),
                        Text('Add Cover Image',
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
        onTap: controller.removeImage,
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
      padding: const EdgeInsets.all(20),
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
              labelText: 'Plan Title *',
              prefixIcon: Icon(Iconsax.text),
              hintText: 'e.g. 7-Day Weight Loss Plan',
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Title is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Iconsax.document_text),
              alignLabelWithHint: true,
              hintText: 'Describe the diet plan...',
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanConfigSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Plan Configuration',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          // Plan type
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.planType.value,
                decoration: const InputDecoration(
                  labelText: 'Plan Type',
                  prefixIcon: Icon(Iconsax.calendar_1),
                ),
                items: const [
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly (7 days)')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly (30 days)')),
                  DropdownMenuItem(value: 'custom', child: Text('Custom Duration')),
                ],
                onChanged: (v) => controller.onPlanTypeChanged(v ?? 'custom'),
              )),
          const SizedBox(height: 16),
          // Duration
          Obx(() => TextFormField(
                controller: controller.durationController,
                decoration: const InputDecoration(
                  labelText: 'Duration (days) *',
                  prefixIcon: Icon(Iconsax.timer_1),
                ),
                keyboardType: TextInputType.number,
                readOnly: controller.planType.value != 'custom',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final n = int.tryParse(v);
                  if (n == null || n < 1) return 'Enter a valid number';
                  return null;
                },
              )),
          const SizedBox(height: 16),
          // Category
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.category.value,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Iconsax.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'general', child: Text('General')),
                  DropdownMenuItem(value: 'weight_loss', child: Text('Weight Loss')),
                  DropdownMenuItem(value: 'muscle_gain', child: Text('Muscle Gain')),
                  DropdownMenuItem(value: 'maintenance', child: Text('Maintenance')),
                  DropdownMenuItem(value: 'keto', child: Text('Keto')),
                  DropdownMenuItem(value: 'vegan', child: Text('Vegan')),
                  DropdownMenuItem(value: 'high_protein', child: Text('High Protein')),
                ],
                onChanged: (v) => controller.category.value = v ?? 'general',
              )),
          const SizedBox(height: 16),
          // Difficulty
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.difficultyLevel.value,
                decoration: const InputDecoration(
                  labelText: 'Difficulty Level',
                  prefixIcon: Icon(Iconsax.ranking_1),
                ),
                items: const [
                  DropdownMenuItem(value: 'beginner', child: Text('Beginner')),
                  DropdownMenuItem(value: 'intermediate', child: Text('Intermediate')),
                  DropdownMenuItem(value: 'advanced', child: Text('Advanced')),
                ],
                onChanged: (v) =>
                    controller.difficultyLevel.value = v ?? 'beginner',
              )),
        ],
      ),
    );
  }

  Widget _buildNutritionSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nutrition Target',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.caloriesController,
            decoration: const InputDecoration(
              labelText: 'Target Calories / Day (optional)',
              prefixIcon: Icon(Iconsax.flash_1),
              suffixText: 'cal',
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const SizedBox(height: 8),
          Obx(() => SwitchListTile(
                title: const Text('Published'),
                subtitle: const Text('Visible to users'),
                value: controller.isPublished.value,
                onChanged: (v) => controller.isPublished.value = v,
                activeTrackColor: AppColors.primary,
              )),
          Obx(() => SwitchListTile(
                title: const Text('Featured'),
                subtitle: const Text('Show on home screen'),
                value: controller.isFeatured.value,
                onChanged: (v) => controller.isFeatured.value = v,
                activeTrackColor: AppColors.primary,
              )),
        ],
      ),
    );
  }
}
