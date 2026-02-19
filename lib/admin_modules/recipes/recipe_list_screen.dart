import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/diet_plan_model.dart';
import '../../shared/widgets/cofit_image.dart';
import 'recipe_controller.dart';

class RecipeListScreen extends GetView<AdminRecipeController> {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Diet Plans'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: controller.refreshPlans,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          controller.initFormForCreate();
          Get.toNamed(AppRoutes.adminRecipeForm);
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Plan', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.allPlans.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final plans = controller.filteredPlans;
              if (plans.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.note_remove, size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text('No diet plans found',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textMuted)),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshPlans,
                child: ListView.builder(
                  padding: AppPadding.screen.copyWith(top: 8, bottom: 80),
                  itemCount: plans.length,
                  itemBuilder: (context, index) =>
                      _buildPlanCard(context, plans[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Container(
      padding: AppPadding.screen.copyWith(top: 12, bottom: 8),
      child: Column(
        children: [
          // Search
          TextField(
            onChanged: (v) => controller.searchQuery.value = v,
            decoration: InputDecoration(
              hintText: 'Search diet plans...',
              prefixIcon: const Icon(Iconsax.search_normal, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: AppRadius.medium,
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Obx(() => Row(
                  children: [
                    _buildFilterChip(context, 'All', 'all',
                        controller.filterStatus.value == 'all', (v) {
                      controller.filterStatus.value = v ? 'all' : 'all';
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Published', 'published',
                        controller.filterStatus.value == 'published', (v) {
                      controller.filterStatus.value =
                          v ? 'published' : 'all';
                    }),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Draft', 'draft',
                        controller.filterStatus.value == 'draft', (v) {
                      controller.filterStatus.value = v ? 'draft' : 'all';
                    }),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, String value,
      bool isSelected, Function(bool) onSelected) {
    return FilterChip(
      label: Text(label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          )),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary,
      backgroundColor: Colors.white,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.small),
      side: BorderSide.none,
    );
  }

  Widget _buildPlanCard(BuildContext context, DietPlanModel plan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: InkWell(
        borderRadius: AppRadius.large,
        onTap: () {
          controller.loadPlanDays(plan);
          Get.toNamed(AppRoutes.adminRecipeDayEditor);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            if (plan.coverImageUrl != null && plan.coverImageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: CofitImage(
                  imageUrl: plan.coverImageUrl!,
                  width: double.infinity,
                  height: 140,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status + Type badges
                  Row(
                    children: [
                      _buildBadge(
                        plan.isPublished ? 'Published' : 'Draft',
                        plan.isPublished ? AppColors.success : AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      _buildBadge(plan.planTypeLabel, AppColors.skyBlue),
                      const SizedBox(width: 8),
                      _buildBadge(plan.categoryLabel, AppColors.lavender),
                      const Spacer(),
                      PopupMenuButton<String>(
                        icon: const Icon(Iconsax.more, size: 20),
                        onSelected: (v) => _handleMenuAction(v, plan),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: 'edit', child: Text('Edit Info')),
                          const PopupMenuItem(
                              value: 'meals', child: Text('Edit Meals')),
                          PopupMenuItem(
                            value: 'publish',
                            child: Text(plan.isPublished
                                ? 'Unpublish'
                                : 'Publish'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child:
                                Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    plan.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  if (plan.description != null &&
                      plan.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      plan.description!,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),
                  // Stats row
                  Row(
                    children: [
                      _buildStat(Iconsax.calendar_1, '${plan.durationDays} days'),
                      const SizedBox(width: 16),
                      _buildStat(Iconsax.ranking_1, plan.difficultyLabel),
                      if (plan.caloriesPerDay != null) ...[
                        const SizedBox(width: 16),
                        _buildStat(
                            Iconsax.flash_1, '${plan.caloriesPerDay} cal/day'),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.small,
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  void _handleMenuAction(String action, DietPlanModel plan) {
    switch (action) {
      case 'edit':
        controller.initFormForEdit(plan);
        Get.toNamed(AppRoutes.adminRecipeForm);
        break;
      case 'meals':
        controller.loadPlanDays(plan);
        Get.toNamed(AppRoutes.adminRecipeDayEditor);
        break;
      case 'publish':
        controller.togglePublish(plan);
        break;
      case 'delete':
        controller.deletePlan(plan.id);
        break;
    }
  }
}
