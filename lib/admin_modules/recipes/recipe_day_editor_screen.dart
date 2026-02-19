import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/diet_plan_model.dart';
import 'recipe_controller.dart';

class RecipeDayEditorScreen extends GetView<AdminRecipeController> {
  const RecipeDayEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: Obx(() => Text(controller.currentPlan.value?.title ?? 'Meal Editor')),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: controller.refreshDays,
          ),
        ],
      ),
      floatingActionButton: Obx(() {
        if (controller.selectedDay == null) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: () {
            controller.initMealFormForCreate(controller.selectedDay!.id);
            _showMealFormSheet(context);
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        );
      }),
      body: Obx(() {
        if (controller.isLoadingDays.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.planDays.isEmpty) {
          return const Center(child: Text('No days configured'));
        }
        return Column(
          children: [
            _buildDaySelector(context),
            Expanded(child: _buildDayContent(context)),
          ],
        );
      }),
    );
  }

  // ============================================
  // DAY SELECTOR (horizontal scrollable chips)
  // ============================================

  Widget _buildDaySelector(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 44,
        child: Obx(() => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.planDays.length,
              itemBuilder: (context, index) {
                final day = controller.planDays[index];
                final isSelected = controller.selectedDayIndex.value == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => controller.selectedDayIndex.value = index,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.bgBlush,
                        borderRadius: AppRadius.pill,
                        boxShadow: isSelected ? AppShadows.primaryGlow : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Day ${day.dayNumber}',
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (day.hasMeals) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : AppColors.success,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            )),
      ),
    );
  }

  // ============================================
  // DAY CONTENT (meals list + actions)
  // ============================================

  Widget _buildDayContent(BuildContext context) {
    return Obx(() {
      final day = controller.selectedDay;
      if (day == null) return const SizedBox.shrink();

      return SingleChildScrollView(
        padding: AppPadding.screen.copyWith(top: 16, bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day header with stats + actions
            _buildDayHeader(context, day),
            const SizedBox(height: 16),
            // Copy actions
            _buildCopyActions(context),
            const SizedBox(height: 16),
            // Meals list
            if (day.meals.isEmpty)
              _buildEmptyMeals(context)
            else
              ...day.meals.map((meal) => _buildMealCard(context, meal)),
          ],
        ),
      );
    });
  }

  Widget _buildDayHeader(BuildContext context, DietPlanDayModel day) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.softPeachGradient,
        borderRadius: AppRadius.large,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day.dayLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildDayStat('Meals', '${day.mealCount}', Iconsax.coffee),
              const SizedBox(width: 20),
              _buildDayStat(
                  'Calories', '${day.computedCalories}', Iconsax.flash_1),
              const SizedBox(width: 20),
              _buildDayStat('Protein',
                  '${day.totalProteinG.toStringAsFixed(0)}g', Iconsax.milk),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayStat(String label, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 14)),
            Text(label,
                style: const TextStyle(
                    fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }

  Widget _buildCopyActions(BuildContext context) {
    return Obx(() {
      final dayIndex = controller.selectedDayIndex.value;
      return Row(
        children: [
          if (dayIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => controller.copyFromPreviousDay(dayIndex),
                icon: const Icon(Iconsax.copy, size: 16),
                label: const Text('Same as Previous Day',
                    style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
          if (dayIndex > 0) const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => controller.showCopyFromDayDialog(dayIndex),
              icon: const Icon(Iconsax.document_copy, size: 16),
              label:
                  const Text('Copy From Day...', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.lavender,
                side: BorderSide(
                    color: AppColors.lavender.withValues(alpha: 0.3)),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildEmptyMeals(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.bgBlush, width: 2),
      ),
      child: Column(
        children: [
          Icon(Iconsax.note_add, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('No meals added yet',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 4),
          Text('Tap + to add meals for this day',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textDisabled)),
        ],
      ),
    );
  }

  // ============================================
  // MEAL CARD
  // ============================================

  Widget _buildMealCard(BuildContext context, DietPlanMealModel meal) {
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
          controller.initMealFormForEdit(meal);
          _showMealFormSheet(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Meal type badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _mealTypeColor(meal.mealType).withValues(alpha: 0.12),
                      borderRadius: AppRadius.small,
                    ),
                    child: Text(
                      meal.mealTypeLabel,
                      style: TextStyle(
                        color: _mealTypeColor(meal.mealType),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Actions
                  IconButton(
                    icon: const Icon(Iconsax.edit_2,
                        size: 18, color: AppColors.primary),
                    onPressed: () {
                      controller.initMealFormForEdit(meal);
                      _showMealFormSheet(context);
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Iconsax.trash,
                        size: 18, color: AppColors.error),
                    onPressed: () => controller.deleteMeal(meal),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                meal.title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (meal.description != null && meal.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  meal.description!,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 10),
              // Macros row
              Row(
                children: [
                  _buildMacro('Cal', '${meal.calories}', AppColors.primary),
                  const SizedBox(width: 12),
                  _buildMacro('P', '${meal.proteinG.toStringAsFixed(0)}g',
                      AppColors.success),
                  const SizedBox(width: 12),
                  _buildMacro('C', '${meal.carbsG.toStringAsFixed(0)}g',
                      AppColors.skyBlue),
                  const SizedBox(width: 12),
                  _buildMacro('F', '${meal.fatG.toStringAsFixed(0)}g',
                      AppColors.sunnyYellow),
                  if (meal.prepTimeMinutes != null) ...[
                    const Spacer(),
                    Icon(Iconsax.timer_1, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${meal.prepTimeMinutes} min',
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                  ],
                ],
              ),
              if (meal.ingredients.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: meal.ingredients
                      .take(5)
                      .map((i) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.bgBlush,
                              borderRadius: AppRadius.small,
                            ),
                            child: Text(i.name,
                                style: const TextStyle(fontSize: 10)),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacro(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.small,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(width: 4),
          Text(value, style: const TextStyle(fontSize: 11)),
        ],
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

  // ============================================
  // MEAL FORM BOTTOM SHEET
  // ============================================

  void _showMealFormSheet(BuildContext context) {
    Get.bottomSheet(
      _MealFormSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ============================================
// MEAL FORM BOTTOM SHEET WIDGET
// ============================================

class _MealFormSheet extends StatelessWidget {
  final AdminRecipeController controller;

  const _MealFormSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textDisabled,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => Text(
                        controller.editingMeal.value != null
                            ? 'Edit Meal'
                            : 'Add Meal',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      )),
                ),
                Obx(() => TextButton(
                      onPressed: controller.isSavingMeal.value
                          ? null
                          : controller.saveMeal,
                      child: controller.isSavingMeal.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Save',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                    )),
              ],
            ),
          ),
          const Divider(),
          // Form
          Expanded(
            child: Form(
              key: controller.mealFormKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meal type
                    Obx(() => DropdownButtonFormField<String>(
                          initialValue: controller.mealType.value,
                          decoration: const InputDecoration(
                            labelText: 'Meal Type',
                            prefixIcon: Icon(Iconsax.coffee),
                          ),
                          items: kMealTypes
                              .map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(kMealTypeLabels[t] ?? t)))
                              .toList(),
                          onChanged: (v) =>
                              controller.mealType.value = v ?? 'breakfast',
                        )),
                    const SizedBox(height: 16),
                    // Title
                    TextFormField(
                      controller: controller.mealTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Meal Title *',
                        prefixIcon: Icon(Iconsax.text),
                        hintText: 'e.g. Grilled Chicken Salad',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Title is required'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    // Description
                    TextFormField(
                      controller: controller.mealDescriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        prefixIcon: Icon(Iconsax.document_text),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    // Nutrition section
                    Text('Nutrition',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.mealCaloriesController,
                            decoration: const InputDecoration(
                              labelText: 'Calories',
                              suffixText: 'cal',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: controller.mealProteinController,
                            decoration: const InputDecoration(
                              labelText: 'Protein',
                              suffixText: 'g',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.mealCarbsController,
                            decoration: const InputDecoration(
                              labelText: 'Carbs',
                              suffixText: 'g',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: controller.mealFatController,
                            decoration: const InputDecoration(
                              labelText: 'Fat',
                              suffixText: 'g',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.mealFiberController,
                            decoration: const InputDecoration(
                              labelText: 'Fiber',
                              suffixText: 'g',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: controller.mealPrepTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Prep Time',
                              suffixText: 'min',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Ingredients
                    _buildIngredientsSection(context),
                    const SizedBox(height: 20),
                    // Instructions
                    TextFormField(
                      controller: controller.mealInstructionsController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe Instructions',
                        prefixIcon: Icon(Iconsax.note_text),
                        alignLabelWithHint: true,
                        hintText: 'Step-by-step preparation...',
                      ),
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientsSection(BuildContext context) {
    final nameC = TextEditingController();
    final qtyC = TextEditingController();
    final unitC = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ingredients',
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            TextButton.icon(
              onPressed: () {
                Get.dialog(AlertDialog(
                  title: const Text('Add Ingredient'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameC,
                        decoration:
                            const InputDecoration(labelText: 'Name *'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: qtyC,
                              decoration: const InputDecoration(
                                  labelText: 'Quantity'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: unitC,
                              decoration: const InputDecoration(
                                  labelText: 'Unit',
                                  hintText: 'g, ml, cup...'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () {
                        if (nameC.text.trim().isNotEmpty) {
                          controller.addIngredient(
                            nameC.text,
                            qtyC.text.isNotEmpty ? qtyC.text : null,
                            unitC.text.isNotEmpty ? unitC.text : null,
                          );
                          Get.back();
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ));
              },
              icon: const Icon(Iconsax.add, size: 16),
              label: const Text('Add'),
            ),
          ],
        ),
        Obx(() => Column(
              children: controller.mealIngredients
                  .asMap()
                  .entries
                  .map((entry) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.bgBlush,
                          child: Text('${entry.key + 1}',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.primary)),
                        ),
                        title: Text(entry.value.display,
                            style: const TextStyle(fontSize: 13)),
                        trailing: IconButton(
                          icon: const Icon(Icons.close,
                              size: 16, color: AppColors.error),
                          onPressed: () =>
                              controller.removeIngredient(entry.key),
                        ),
                      ))
                  .toList(),
            )),
      ],
    );
  }
}
