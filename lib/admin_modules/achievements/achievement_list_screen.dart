import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'achievement_controller.dart';

class AchievementListScreen extends GetView<AchievementController> {
  const AchievementListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: const Text('Achievements')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.initFormForCreate();
          Get.toNamed(AppRoutes.adminAchievementForm);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search achievements...',
                prefixIcon: const Icon(Iconsax.search_normal, size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.medium,
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (v) => controller.searchQuery.value = v,
            ),
          ),

          // Filter chips
          SizedBox(
            height: 44,
            child: Obx(
              () => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildFilterChip(context, 'All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Workout', 'workout'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Streak', 'streak'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Milestone', 'milestone'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Community', 'community'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, 'Special', 'special'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = controller.filteredAchievements;
              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.medal_star,
                        size: 56,
                        color: AppColors.textDisabled,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No achievements found',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshAchievements,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _buildAchievementCard(context, items[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String value) {
    final isSelected = controller.filterCategory.value == value;
    return GestureDetector(
      onTap: () => controller.filterCategory.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: AppRadius.pill,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, dynamic achievement) {
    final a = achievement;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bgBlush,
              borderRadius: AppRadius.medium,
            ),
            child: Icon(a.getIconData(), color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        a.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: a.isActive
                            ? AppColors.successLight
                            : AppColors.errorLight,
                        borderRadius: AppRadius.small,
                      ),
                      child: Text(
                        a.isActive ? 'Active' : 'Inactive',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: a.isActive
                              ? AppColors.success
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${a.typeLabel} \u2022 ${a.targetValue} ${a.targetUnit}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'detail') {
                controller.loadAchievementDetail(a.id);
                Get.toNamed(AppRoutes.adminAchievementDetail);
              } else if (val == 'edit') {
                controller.initFormForEdit(a);
                Get.toNamed(AppRoutes.adminAchievementForm);
              } else if (val == 'delete') {
                controller.deleteAchievement(a.id);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'detail', child: Text('View Details')),
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
