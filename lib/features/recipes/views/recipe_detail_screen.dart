import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/diet_plan_model.dart';
import '../../../shared/widgets/cofit_image.dart';
import '../controllers/recipe_controller.dart';

class RecipeDetailScreen extends GetView<RecipeController> {
  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: Obx(() {
        if (controller.isLoadingDetail.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final plan = controller.selectedPlan.value;
        if (plan == null) {
          return const Center(child: Text('Plan not found'));
        }
        return CustomScrollView(
          slivers: [
            _buildSliverAppBar(context, plan),
            SliverToBoxAdapter(child: _buildPlanInfo(context, plan)),
            SliverToBoxAdapter(child: _buildNutritionOverview(context, plan)),
            if (plan.days.isNotEmpty) ...[
              SliverToBoxAdapter(child: _buildDaySelector(context, plan)),
              SliverToBoxAdapter(child: _buildDayContent(context)),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        );
      }),
    );
  }

  // ============================================
  // SLIVER APP BAR WITH COVER IMAGE
  // ============================================

  Widget _buildSliverAppBar(BuildContext context, DietPlanModel plan) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      stretch: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          plan.title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (plan.coverImageUrl != null && plan.coverImageUrl!.isNotEmpty)
              CofitImage(
                imageUrl: plan.coverImageUrl!,
                width: double.infinity,
                height: 240,
              )
            else
              Container(
                decoration: BoxDecoration(gradient: AppColors.primaryGradient),
              ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // PLAN INFO CARD
  // ============================================

  Widget _buildPlanInfo(BuildContext context, DietPlanModel plan) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tags
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildTag(plan.categoryLabel, AppColors.primary),
              _buildTag(plan.planTypeLabel, AppColors.skyBlue),
              _buildTag(plan.difficultyLabel, AppColors.lavender),
            ],
          ),
          if (plan.description != null && plan.description!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              plan.description!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoStat(
                context,
                '${plan.durationDays}',
                'Days',
                Iconsax.calendar_1,
              ),
              if (plan.caloriesPerDay != null)
                _buildInfoStat(
                  context,
                  '${plan.caloriesPerDay}',
                  'Cal/Day',
                  Iconsax.flash_1,
                ),
              _buildInfoStat(
                context,
                plan.difficultyLabel,
                'Level',
                Iconsax.ranking_1,
              ),
              _buildInfoStat(
                context,
                '${plan.days.length}',
                'Configured',
                Iconsax.tick_circle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStat(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 22, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  // ============================================
  // NUTRITION OVERVIEW
  // ============================================

  Widget _buildNutritionOverview(BuildContext context, DietPlanModel plan) {
    if (plan.days.isEmpty) return const SizedBox.shrink();

    // Calculate average macros across all days
    int totalCal = 0;
    double totalP = 0, totalC = 0, totalF = 0;
    int daysWithMeals = 0;
    for (final day in plan.days) {
      if (day.hasMeals) {
        daysWithMeals++;
        totalCal += day.computedCalories;
        totalP += day.totalProteinG;
        totalC += day.totalCarbsG;
        totalF += day.totalFatG;
      }
    }
    if (daysWithMeals == 0) return const SizedBox.shrink();

    final avgCal = (totalCal / daysWithMeals).round();
    final avgP = (totalP / daysWithMeals).round();
    final avgC = (totalC / daysWithMeals).round();
    final avgF = (totalF / daysWithMeals).round();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.softPeachGradient,
        borderRadius: AppRadius.large,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Average Daily Nutrition',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroCircle(
                context,
                'Calories',
                '$avgCal',
                'cal',
                AppColors.primary,
              ),
              _buildMacroCircle(
                context,
                'Protein',
                '$avgP',
                'g',
                AppColors.success,
              ),
              _buildMacroCircle(
                context,
                'Carbs',
                '$avgC',
                'g',
                AppColors.skyBlue,
              ),
              _buildMacroCircle(
                context,
                'Fat',
                '$avgF',
                'g',
                AppColors.sunnyYellow,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCircle(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                Text(unit, style: TextStyle(fontSize: 9, color: color)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  // ============================================
  // DAY SELECTOR
  // ============================================

  Widget _buildDaySelector(BuildContext context, DietPlanModel plan) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: plan.days.length,
          itemBuilder: (context, index) {
            final day = plan.days[index];
            return Obx(() {
              final isSelected = controller.selectedDayIndex.value == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => controller.selectedDayIndex.value = index,
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
                    child: Center(
                      child: Text(
                        'Day ${day.dayNumber}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  // ============================================
  // DAY CONTENT (meals)
  // ============================================

  Widget _buildDayContent(BuildContext context) {
    return Obx(() {
      final day = controller.selectedDay;
      if (day == null) return const SizedBox.shrink();

      if (!day.hasMeals) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.large,
          ),
          child: Center(
            child: Column(
              children: [
                Icon(Iconsax.note_remove, size: 40, color: AppColors.textMuted),
                const SizedBox(height: 8),
                Text(
                  'No meals for this day',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        );
      }

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day summary
            _buildDaySummary(context, day),
            const SizedBox(height: 12),
            // Meal cards
            ...day.meals.map((meal) => _buildMealCard(context, meal)),
          ],
        ),
      );
    });
  }

  Widget _buildDaySummary(BuildContext context, DietPlanDayModel day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgBlush,
        borderRadius: AppRadius.medium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDaySumItem('Meals', '${day.mealCount}'),
          _buildDaySumItem('Calories', '${day.computedCalories}'),
          _buildDaySumItem(
            'Protein',
            '${day.totalProteinG.toStringAsFixed(0)}g',
          ),
          _buildDaySumItem('Carbs', '${day.totalCarbsG.toStringAsFixed(0)}g'),
          _buildDaySumItem('Fat', '${day.totalFatG.toStringAsFixed(0)}g'),
        ],
      ),
    );
  }

  Widget _buildDaySumItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }

  // ============================================
  // MEAL CARD (user-facing - elegant)
  // ============================================

  Widget _buildMealCard(BuildContext context, DietPlanMealModel meal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _mealTypeColor(meal.mealType).withValues(alpha: 0.12),
              borderRadius: AppRadius.medium,
            ),
            child: Center(
              child: Text(
                meal.mealTypeEmoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          title: Text(
            meal.title,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Row(
            children: [
              Text(
                meal.mealTypeLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: _mealTypeColor(meal.mealType),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${meal.calories} cal',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              if (meal.prepTimeMinutes != null) ...[
                const SizedBox(width: 8),
                Text(
                  '${meal.prepTimeMinutes} min',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ],
          ),
          children: [
            // Macros
            if (meal.hasMacros) ...[
              Row(
                children: [
                  _buildMacroChip(
                    'Protein',
                    '${meal.proteinG.toStringAsFixed(0)}g',
                    AppColors.success,
                  ),
                  const SizedBox(width: 8),
                  _buildMacroChip(
                    'Carbs',
                    '${meal.carbsG.toStringAsFixed(0)}g',
                    AppColors.skyBlue,
                  ),
                  const SizedBox(width: 8),
                  _buildMacroChip(
                    'Fat',
                    '${meal.fatG.toStringAsFixed(0)}g',
                    AppColors.sunnyYellow,
                  ),
                  if (meal.fiberG > 0) ...[
                    const SizedBox(width: 8),
                    _buildMacroChip(
                      'Fiber',
                      '${meal.fiberG.toStringAsFixed(0)}g',
                      AppColors.mintFresh,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
            ],
            // Description
            if (meal.description != null && meal.description!.isNotEmpty) ...[
              Text(
                meal.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Ingredients
            if (meal.ingredients.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Ingredients',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              ...meal.ingredients.map(
                (ing) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ing.display,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            // Instructions
            if (meal.recipeInstructions != null &&
                meal.recipeInstructions!.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Preparation',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                meal.recipeInstructions!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMacroChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.small,
      ),
      child: Text(
        '$label $value',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.small,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _mealTypeColor(String type) {
    switch (type) {
      case 'breakfast':
        return AppColors.sunnyYellow;
      case 'morning_snack':
        return AppColors.peach;
      case 'lunch':
        return AppColors.primary;
      case 'afternoon_snack':
        return AppColors.mintFresh;
      case 'dinner':
        return AppColors.lavender;
      case 'evening_snack':
        return AppColors.skyBlue;
      default:
        return AppColors.textMuted;
    }
  }
}
