import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/cofit_avatar.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileScreen extends GetView<EditProfileController> {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !controller.hasChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && controller.hasChanges) {
          _showUnsavedChangesDialog();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.bgCream,
        appBar: AppBar(
          title: const Text('Edit Profile'),
          actions: [
            Obx(() => TextButton(
                  onPressed:
                      controller.isSaving.value ? null : controller.saveProfile,
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
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
                _buildPhotoSection(context),
                const SizedBox(height: 24),
                _buildPersonalInfoSection(context),
                const SizedBox(height: 24),
                _buildBodyMetricsSection(context),
                const SizedBox(height: 24),
                _buildFitnessSection(context),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showUnsavedChangesDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Discard them?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.back();
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.extraLarge,
        boxShadow: AppShadows.subtle,
      ),
      child: Center(
        child: Obx(() {
          final user = AuthService.to.currentUser;
          return Stack(
            alignment: Alignment.center,
            children: [
              CofitAvatar(
                imageUrl: user?.avatarUrl,
                userId: user?.id,
                userName: user?.displayName,
                radius: 50,
                showEditIcon: true,
                onTap: () => controller.uploadProfileImage(),
              ),
              if (controller.isUploadingImage.value)
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context) {
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
          Text('Personal Info',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name',
              prefixIcon: Icon(Iconsax.user),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Iconsax.user_tag),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.bioController,
            decoration: const InputDecoration(
              labelText: 'Bio',
              prefixIcon: Icon(Iconsax.edit_2),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
            maxLength: 200,
          ),
        ],
      ),
    );
  }

  Widget _buildBodyMetricsSection(BuildContext context) {
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
          Text('Body Metrics',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.gender.value.isNotEmpty
                    ? controller.gender.value
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Iconsax.people),
                ),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Male')),
                  DropdownMenuItem(value: 'female', child: Text('Female')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                  DropdownMenuItem(
                      value: 'prefer_not_to_say',
                      child: Text('Prefer not to say')),
                ],
                onChanged: (v) => controller.gender.value = v ?? '',
              )),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.dobController,
            decoration: const InputDecoration(
              labelText: 'Date of Birth',
              prefixIcon: Icon(Iconsax.calendar_1),
            ),
            readOnly: true,
            onTap: controller.pickDateOfBirth,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.heightController,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    prefixIcon: Icon(Iconsax.ruler),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller.weightController,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    prefixIcon: Icon(Iconsax.weight),
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

  Widget _buildFitnessSection(BuildContext context) {
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
          Text('Fitness',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.fitnessLevel.value.isNotEmpty
                    ? controller.fitnessLevel.value
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Fitness Level',
                  prefixIcon: Icon(Iconsax.activity),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'beginner', child: Text('Beginner')),
                  DropdownMenuItem(
                      value: 'intermediate', child: Text('Intermediate')),
                  DropdownMenuItem(
                      value: 'advanced', child: Text('Advanced')),
                ],
                onChanged: (v) => controller.fitnessLevel.value = v ?? '',
              )),
          const SizedBox(height: 20),
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Workout Days Per Week: ${controller.workoutDaysPerWeek.value}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Slider(
                    value: controller.workoutDaysPerWeek.value.toDouble(),
                    min: 1,
                    max: 7,
                    divisions: 6,
                    label: '${controller.workoutDaysPerWeek.value}',
                    onChanged: (v) =>
                        controller.workoutDaysPerWeek.value = v.round(),
                  ),
                ],
              )),
          const SizedBox(height: 8),
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.preferredWorkoutTime.value.isNotEmpty
                    ? controller.preferredWorkoutTime.value
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Preferred Workout Time',
                  prefixIcon: Icon(Iconsax.clock),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'morning', child: Text('Morning')),
                  DropdownMenuItem(
                      value: 'afternoon', child: Text('Afternoon')),
                  DropdownMenuItem(
                      value: 'evening', child: Text('Evening')),
                ],
                onChanged: (v) =>
                    controller.preferredWorkoutTime.value = v ?? '',
              )),
        ],
      ),
    );
  }
}
