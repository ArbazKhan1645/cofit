import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/diet_plan_model.dart';
import '../../../shared/controllers/base_controller.dart';
import '../../../shared/widgets/cofit_image.dart';
import '../controllers/recipe_controller.dart';

class RecipesScreen extends GetView<RecipeController> {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.allPlans.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          return RefreshIndicator(
            onRefresh: controller.refreshPlans,
            color: AppColors.primary,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(child: _buildHeader(context)),
                // Search
                SliverToBoxAdapter(child: _buildSearch(context)),
                // Category filters
                SliverToBoxAdapter(child: _buildCategoryChips(context)),

                // Error state
                if (controller.viewState.value == ViewState.error &&
                    controller.allPlans.isEmpty)
                  SliverFillRemaining(child: _buildErrorState(context)),

                // Empty state — no data at all
                if (controller.viewState.value == ViewState.empty ||
                    (controller.allPlans.isEmpty &&
                        !controller.isLoading.value &&
                        controller.viewState.value != ViewState.error))
                  SliverFillRemaining(child: _buildEmptyState(context)),

                // Normal content
                if (controller.allPlans.isNotEmpty) ...[
                  // Featured section
                  if (controller.featuredPlans.isNotEmpty)
                    SliverToBoxAdapter(
                        child: _buildFeaturedSection(context)),
                  // All plans
                  SliverToBoxAdapter(
                    child: _buildSectionTitle(context, 'All Plans'),
                  ),
                  if (controller.filteredPlans.isNotEmpty)
                    _buildPlansList(context)
                  else
                    SliverToBoxAdapter(
                        child: _buildNoFilterResults(context)),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: AppPadding.screen.copyWith(top: 20, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Diet Plans',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Find the perfect meal plan for your goals',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: AppPadding.screen.copyWith(top: 16, bottom: 8),
      child: TextField(
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
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final categories = [
      {'key': 'all', 'label': 'All'},
      {'key': 'weight_loss', 'label': 'Weight Loss'},
      {'key': 'muscle_gain', 'label': 'Muscle Gain'},
      {'key': 'keto', 'label': 'Keto'},
      {'key': 'vegan', 'label': 'Vegan'},
      {'key': 'high_protein', 'label': 'High Protein'},
      {'key': 'maintenance', 'label': 'Maintenance'},
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Obx(() {
            final isSelected = controller.selectedCategory.value == cat['key'];
            return GestureDetector(
              onTap: () => controller.selectedCategory.value = cat['key']!,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.white,
                  borderRadius: AppRadius.pill,
                  boxShadow: isSelected
                      ? AppShadows.primaryGlow
                      : AppShadows.subtle,
                ),
                child: Text(
                  cat['label']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // ============================================
  // FEATURED SECTION (horizontal scroll)
  // ============================================

  Widget _buildFeaturedSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Featured Plans'),
        SizedBox(
          height: 220,
          child: Obx(
            () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: controller.featuredPlans.length,
              itemBuilder: (context, index) {
                final plan = controller.featuredPlans[index];
                return _buildFeaturedCard(context, plan);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(BuildContext context, DietPlanModel plan) {
    return GestureDetector(
      onTap: () {
        controller.loadPlanDetail(plan.id);
        Get.toNamed(AppRoutes.recipeDetail);
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.medium,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.large,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background
              if (plan.coverImageUrl != null && plan.coverImageUrl!.isNotEmpty)
                CofitImage(
                  imageUrl: plan.coverImageUrl!,
                  width: 280,
                  height: 220,
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: AppRadius.small,
                      ),
                      child: Text(
                        plan.categoryLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plan.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Iconsax.calendar_1,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${plan.durationDays} days',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Iconsax.flash_1,
                          size: 14,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          plan.caloriesPerDay != null
                              ? '${plan.caloriesPerDay} cal/day'
                              : plan.difficultyLabel,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================
  // ALL PLANS LIST
  // ============================================

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: AppPadding.screen.copyWith(top: 20, bottom: 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  SliverList _buildPlansList(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final plans = controller.filteredPlans;
        if (index >= plans.length) return null;
        return _buildPlanListItem(context, plans[index]);
      }, childCount: controller.filteredPlans.length),
    );
  }

  Widget _buildPlanListItem(BuildContext context, DietPlanModel plan) {
    return GestureDetector(
      onTap: () {
        controller.loadPlanDetail(plan.id);
        Get.toNamed(AppRoutes.recipeDetail);
      },
      child: Container(
        margin: EdgeInsets.all(4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: AppRadius.medium,
              child:
                  plan.coverImageUrl != null && plan.coverImageUrl!.isNotEmpty
                  ? CofitImage(
                      imageUrl: plan.coverImageUrl!,
                      width: 80,
                      height: 80,
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: AppColors.softPeachGradient,
                        borderRadius: AppRadius.medium,
                      ),
                      child: const Icon(
                        Iconsax.note_21,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags row
                  Row(
                    children: [
                      _buildTag(plan.categoryLabel, AppColors.primary),
                      const SizedBox(width: 6),
                      _buildTag(plan.planTypeLabel, AppColors.skyBlue),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    plan.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (plan.description != null &&
                      plan.description!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      plan.description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Iconsax.calendar_1,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${plan.durationDays} days',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Iconsax.ranking_1,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        plan.difficultyLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      // if (plan.caloriesPerDay != null) ...[
                      //   const SizedBox(width: 12),
                      //   Icon(
                      //     Iconsax.flash_1,
                      //     size: 13,
                      //     color: AppColors.textMuted,
                      //   ),
                      //   const SizedBox(width: 4),
                      //   Text(
                      //     '${plan.caloriesPerDay} cal',
                      //     style: const TextStyle(
                      //       fontSize: 11,
                      //       color: AppColors.textMuted,
                      //     ),
                      //   ),
                      // ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Iconsax.arrow_right_3,
              size: 18,
              color: AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.small,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================
  // EMPTY / ERROR STATES
  // ============================================

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.note_21, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'No Diet Plans Available',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new meal plans.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.refreshPlans,
              icon: const Icon(Iconsax.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.wifi_square, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              'Something Went Wrong',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection\nand try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: controller.loadPlans,
              icon: const Icon(Iconsax.refresh, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.pill),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFilterResults(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(Iconsax.search_status, size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'No plans found',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try a different search or category.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
