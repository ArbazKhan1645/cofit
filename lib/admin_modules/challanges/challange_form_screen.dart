import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/cofit_image.dart';
import 'challange_controller.dart';

class ChallangeFormScreen extends GetView<ChallangeController> {
  const ChallangeFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: Obx(() => Text(controller.editingChallenge.value != null
            ? 'Edit Challenge'
            : 'Add Challenge')),
        actions: [
          Obx(() => TextButton(
                onPressed: controller.isSaving.value
                    ? null
                    : controller.saveChallenge,
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
              _buildConfigSection(context),
              const SizedBox(height: 24),
              _buildDatesSection(context),
              const SizedBox(height: 24),
              _buildRulesSection(context),
              const SizedBox(height: 24),
              _buildPrizesSection(context),
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
        ],
      ),
    );
  }

  Widget _buildConfigSection(BuildContext context) {
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
          Text('Configuration',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.challengeType.value,
                decoration: const InputDecoration(
                  labelText: 'Challenge Type',
                  prefixIcon: Icon(Iconsax.category),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'workout_count', child: Text('Workout Count')),
                  DropdownMenuItem(value: 'streak', child: Text('Streak')),
                  DropdownMenuItem(value: 'minutes', child: Text('Minutes')),
                  DropdownMenuItem(
                      value: 'calories', child: Text('Calories')),
                  DropdownMenuItem(
                      value: 'specific_category',
                      child: Text('Specific Category')),
                ],
                onChanged: (v) => controller.challengeType.value = v ?? '',
              )),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.challengeType.value == 'specific_category') {
              return Column(
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: controller.targetCategory.value.isNotEmpty
                        ? controller.targetCategory.value
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Target Category',
                      prefixIcon: Icon(Iconsax.filter),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'full_body', child: Text('Full Body')),
                      DropdownMenuItem(
                          value: 'upper_body', child: Text('Upper Body')),
                      DropdownMenuItem(
                          value: 'lower_body', child: Text('Lower Body')),
                      DropdownMenuItem(value: 'core', child: Text('Core')),
                      DropdownMenuItem(
                          value: 'cardio', child: Text('Cardio')),
                      DropdownMenuItem(value: 'hiit', child: Text('HIIT')),
                      DropdownMenuItem(value: 'yoga', child: Text('Yoga')),
                      DropdownMenuItem(
                          value: 'pilates', child: Text('Pilates')),
                    ],
                    onChanged: (v) =>
                        controller.targetCategory.value = v ?? '',
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          TextFormField(
            controller: controller.targetValueController,
            decoration: const InputDecoration(
              labelText: 'Target Value *',
              prefixIcon: Icon(Iconsax.chart),
            ),
            keyboardType: TextInputType.number,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'Target value is required'
                : null,
          ),
          const SizedBox(height: 16),
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.targetUnit.value,
                decoration: const InputDecoration(
                  labelText: 'Target Unit',
                  prefixIcon: Icon(Iconsax.ruler),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'workouts', child: Text('Workouts')),
                  DropdownMenuItem(value: 'days', child: Text('Days')),
                  DropdownMenuItem(
                      value: 'minutes', child: Text('Minutes')),
                  DropdownMenuItem(
                      value: 'calories', child: Text('Calories')),
                ],
                onChanged: (v) => controller.targetUnit.value = v ?? '',
              )),
        ],
      ),
    );
  }

  Widget _buildDatesSection(BuildContext context) {
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
          Text('Dates',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.startDateController,
            decoration: const InputDecoration(
              labelText: 'Start Date',
              prefixIcon: Icon(Iconsax.calendar_1),
            ),
            readOnly: true,
            onTap: controller.pickStartDate,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.endDateController,
            decoration: const InputDecoration(
              labelText: 'End Date',
              prefixIcon: Icon(Iconsax.calendar_2),
            ),
            readOnly: true,
            onTap: controller.pickEndDate,
          ),
        ],
      ),
    );
  }

  Widget _buildRulesSection(BuildContext context) {
    final ruleController = TextEditingController();
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
          Text('Rules',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ruleController,
                  decoration: const InputDecoration(hintText: 'Add a rule...'),
                  onSubmitted: (v) {
                    if (v.trim().isNotEmpty) {
                      controller.addRule(v);
                      ruleController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon:
                    const Icon(Iconsax.add_circle, color: AppColors.primary),
                onPressed: () {
                  if (ruleController.text.trim().isNotEmpty) {
                    controller.addRule(ruleController.text);
                    ruleController.clear();
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => Column(
                children: controller.rules.asMap().entries.map((entry) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.bgBlush,
                      child: Text('${entry.key + 1}',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.primary)),
                    ),
                    title: Text(entry.value),
                    trailing: IconButton(
                      icon: const Icon(Icons.close,
                          size: 18, color: AppColors.error),
                      onPressed: () => controller.removeRule(entry.key),
                    ),
                  );
                }).toList(),
              )),
        ],
      ),
    );
  }

  Widget _buildPrizesSection(BuildContext context) {
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
              Text('Prizes',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: controller.showAddPrizeDialog,
                icon: const Icon(Iconsax.add, size: 18),
                label: const Text('Add Prize'),
              ),
            ],
          ),
          Obx(() => Column(
                children:
                    controller.prizes.asMap().entries.map((entry) {
                  final prize = entry.value;
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.bgBlush,
                      child: Text(
                          prize.rank == 0 ? 'All' : '#${prize.rank}',
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600)),
                    ),
                    title: Text(prize.title),
                    subtitle: Text('${prize.xpReward} XP'),
                    trailing: IconButton(
                      icon: const Icon(Icons.close,
                          size: 18, color: AppColors.error),
                      onPressed: () => controller.removePrize(entry.key),
                    ),
                  );
                }).toList(),
              )),
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
          const SizedBox(height: 16),
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.visibility.value,
                decoration: const InputDecoration(
                  labelText: 'Visibility',
                  prefixIcon: Icon(Iconsax.eye),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'public', child: Text('Public')),
                  DropdownMenuItem(
                      value: 'members_only', child: Text('Members Only')),
                ],
                onChanged: (v) => controller.visibility.value = v ?? '',
              )),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.maxParticipantsController,
            decoration: const InputDecoration(
              labelText: 'Max Participants (optional)',
              prefixIcon: Icon(Iconsax.people),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Obx(() => DropdownButtonFormField<String>(
                initialValue: controller.status.value,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  prefixIcon: Icon(Iconsax.status),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'upcoming', child: Text('Upcoming')),
                  DropdownMenuItem(
                      value: 'active', child: Text('Active')),
                  DropdownMenuItem(
                      value: 'completed', child: Text('Completed')),
                ],
                onChanged: (v) => controller.status.value = v ?? '',
              )),
          Obx(() => SwitchListTile(
                title: const Text('Featured'),
                value: controller.isFeatured.value,
                onChanged: (v) => controller.isFeatured.value = v,
              )),
        ],
      ),
    );
  }
}
