import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/cofit_image.dart';
import 'trainer_controller.dart';

class TrainerFormScreen extends GetView<TrainerController> {
  const TrainerFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: Obx(() => Text(controller.editingTrainer.value != null
            ? 'Edit Trainer'
            : 'Add Trainer')),
        actions: [
          Obx(() => TextButton(
                onPressed:
                    controller.isSaving.value ? null : controller.saveTrainer,
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
              _buildAvatarSection(context),
              const SizedBox(height: 24),
              _buildBasicInfoSection(context),
              const SizedBox(height: 24),
              _buildProfessionalSection(context),
              const SizedBox(height: 24),
              _buildSocialSection(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.extraLarge,
        boxShadow: AppShadows.subtle,
      ),
      child: Center(
        child: Obx(() {
          final hasImage = controller.selectedImageBytes.value != null ||
              controller.avatarUrl.value.isNotEmpty;
          return GestureDetector(
            onTap: controller.pickImage,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.bgBlush,
                  backgroundImage: controller.selectedImageBytes.value != null
                      ? MemoryImage(controller.selectedImageBytes.value!)
                      : null,
                  child: controller.selectedImageBytes.value == null
                      ? (controller.avatarUrl.value.isNotEmpty
                          ? ClipOval(
                              child: CofitImage(
                                  imageUrl: controller.avatarUrl.value,
                                  width: 100,
                                  height: 100))
                          : const Icon(Iconsax.user,
                              size: 40, color: AppColors.primary))
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Iconsax.camera,
                        size: 16, color: Colors.white),
                  ),
                ),
                if (hasImage)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: controller.removeImage,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
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
            controller: controller.fullNameController,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              prefixIcon: Icon(Iconsax.user),
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Iconsax.sms),
            ),
            keyboardType: TextInputType.emailAddress,
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
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalSection(BuildContext context) {
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
          Text('Professional',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.yearsExperienceController,
            decoration: const InputDecoration(
              labelText: 'Years of Experience',
              prefixIcon: Icon(Iconsax.medal_star),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _buildChipInput(
            context,
            label: 'Specialties',
            items: controller.specialties,
            onAdd: controller.addSpecialty,
            onRemove: controller.removeSpecialty,
          ),
          const SizedBox(height: 20),
          _buildChipInput(
            context,
            label: 'Certifications',
            items: controller.certifications,
            onAdd: controller.addCertification,
            onRemove: controller.removeCertification,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection(BuildContext context) {
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
          Text('Social & Status',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.instagramController,
            decoration: const InputDecoration(
              labelText: 'Instagram Handle',
              prefixIcon: Icon(Iconsax.instagram),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.websiteController,
            decoration: const InputDecoration(
              labelText: 'Website URL',
              prefixIcon: Icon(Iconsax.global),
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 8),
          Obx(() => SwitchListTile(
                title: const Text('Active'),
                value: controller.isActive.value,
                onChanged: (v) => controller.isActive.value = v,
              )),
        ],
      ),
    );
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
