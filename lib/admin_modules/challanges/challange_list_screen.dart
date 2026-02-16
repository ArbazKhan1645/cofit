import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'challange_controller.dart';

class ChallangeListScreen extends GetView<ChallangeController> {
  const ChallangeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: const Text('Challenges')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.initFormForCreate();
          Get.toNamed(AppRoutes.adminChallangeForm);
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
                hintText: 'Search challenges...',
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
            child: Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(context, 'All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, 'Active', 'active'),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, 'Upcoming', 'upcoming'),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, 'Completed', 'completed'),
                    ],
                  ),
                )),
          ),
          const SizedBox(height: 12),
          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.challenges.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = controller.filteredChallenges;
              if (items.isEmpty) return _buildEmptyState(context);
              return RefreshIndicator(
                onRefresh: controller.refreshChallenges,
                child: ListView.separated(
                  padding: AppPadding.screen,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _buildChallengeCard(context, items[index]),
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

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'upcoming':
        return AppColors.info;
      default:
        return AppColors.textMuted;
    }
  }

  Widget _buildChallengeCard(BuildContext context, dynamic challenge) {
    final df = DateFormat('MMM d');
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.bgBlush,
            borderRadius: AppRadius.small,
          ),
          child: const Icon(Iconsax.cup, color: AppColors.primary, size: 22),
        ),
        title: Text(challenge.title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${df.format(challenge.startDate)} - ${df.format(challenge.endDate)}  •  ${challenge.participantCount} joined',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppColors.textMuted),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(challenge.status).withValues(alpha: 0.12),
                borderRadius: AppRadius.small,
              ),
              child: Text(
                challenge.status[0].toUpperCase() +
                    challenge.status.substring(1),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _statusColor(challenge.status),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (val) {
                if (val == 'view') {
                  controller.loadChallengeDetail(challenge.id);
                  Get.toNamed(AppRoutes.adminChallangeDetail);
                } else if (val == 'edit') {
                  controller.initFormForEdit(challenge);
                  Get.toNamed(AppRoutes.adminChallangeForm);
                } else if (val == 'delete') {
                  controller.deleteChallenge(challenge.id);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                    value: 'view',
                    child: Row(children: [
                      Icon(Iconsax.eye, size: 18),
                      SizedBox(width: 8),
                      Text('View Details')
                    ])),
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
          const Icon(Iconsax.cup, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('No challenges found',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              controller.initFormForCreate();
              Get.toNamed(AppRoutes.adminChallangeForm);
            },
            icon: const Icon(Iconsax.add),
            label: const Text('Add Challenge'),
          ),
        ],
      ),
    );
  }
}
