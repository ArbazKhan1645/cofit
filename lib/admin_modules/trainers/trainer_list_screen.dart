import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/cofit_image.dart';
import 'trainer_controller.dart';

class TrainerListScreen extends GetView<TrainerController> {
  const TrainerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: const Text('Trainers')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.initFormForCreate();
          Get.toNamed(AppRoutes.adminTrainerForm);
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
                hintText: 'Search trainers...',
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
              if (controller.isLoading.value && controller.trainers.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = controller.filteredTrainers;
              if (items.isEmpty) {
                return _buildEmptyState(context);
              }
              return RefreshIndicator(
                onRefresh: controller.refreshTrainers,
                child: ListView.separated(
                  padding: AppPadding.screen,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _buildTrainerCard(context, items[index]),
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

  Widget _buildTrainerCard(BuildContext context, dynamic trainer) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: trainer.avatarUrl != null && trainer.avatarUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: CofitImage(
                  imageUrl: trainer.avatarUrl!,
                  width: 48,
                  height: 48,
                ),
              )
            : CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.bgBlush,
                child: Text(
                  trainer.fullName.isNotEmpty
                      ? trainer.fullName[0].toUpperCase()
                      : 'T',
                  style: const TextStyle(
                      color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
        title: Text(trainer.fullName,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: trainer.specialties.isNotEmpty
            ? Text(trainer.specialties.join(', '),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textMuted),
                maxLines: 1,
                overflow: TextOverflow.ellipsis)
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: trainer.isActive
                    ? AppColors.successLight
                    : AppColors.errorLight,
                borderRadius: AppRadius.small,
              ),
              child: Text(
                trainer.isActive ? 'Active' : 'Inactive',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color:
                          trainer.isActive ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'edit') {
                  controller.initFormForEdit(trainer);
                  Get.toNamed(AppRoutes.adminTrainerForm);
                } else if (val == 'delete') {
                  controller.deleteTrainer(trainer.id);
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
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.personalcard, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('No trainers found',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              controller.initFormForCreate();
              Get.toNamed(AppRoutes.adminTrainerForm);
            },
            icon: const Icon(Iconsax.add),
            label: const Text('Add Trainer'),
          ),
        ],
      ),
    );
  }
}
