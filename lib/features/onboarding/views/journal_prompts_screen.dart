import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/journal_controller.dart';

class JournalPromptsScreen extends GetView<JournalController> {
  const JournalPromptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Obx(
          () => controller.currentPage.value > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: controller.previousPage,
                )
              : const SizedBox.shrink(),
        ),
        title: Obx(
          () => Text(
            'Question ${controller.currentPage.value + 1} of ${controller.totalPages}',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.skipOnboarding,
            child: Text(
              'Skip',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
      body: _buildQuestionsPage(context),
    );
  }

  Widget _buildQuestionsPage(BuildContext context) {
    return Column(
      children: [
        // Progress bar
        Obx(
          () => LinearProgressIndicator(
            value: (controller.currentPage.value + 1) / controller.totalPages,
            backgroundColor: AppColors.bgBlush,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            minHeight: 4,
          ),
        ),

        // Page content
        Expanded(
          child: PageView.builder(
            controller: controller.pageController,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.totalPages,
            itemBuilder: (context, index) {
              final prompt = controller.prompts[index];
              return _buildPromptPage(context, prompt, index);
            },
          ),
        ),

        // Navigation buttons
        Padding(
          padding: AppPadding.screenAll,
          child: Row(
            children: [
              Obx(
                () => controller.currentPage.value > 0
                    ? Expanded(
                        child: OutlinedButton(
                          onPressed: controller.previousPage,
                          child: const Text('Back'),
                        ),
                      )
                    : const Spacer(),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.canProceed()
                        ? controller.nextPage
                        : null,
                    child: Obx(
                      () => controller.isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              controller.currentPage.value ==
                                      controller.totalPages - 1
                                  ? 'Complete Setup'
                                  : 'Continue',
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPromptPage(
    BuildContext context,
    Map<String, dynamic> prompt,
    int index,
  ) {
    return SingleChildScrollView(
      padding: AppPadding.screenAll,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          // Icon
          Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: AppRadius.medium,
                    ),
                    child: Icon(
                      _getIconForPrompt(prompt['icon'] as String?),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child:
                        Text(
                              prompt['question'] as String,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            )
                            .animate()
                            .fadeIn(delay: 100.ms, duration: 400.ms)
                            .slideX(begin: -0.1, end: 0),
                  ),
                ],
              )
              .animate()
              .fadeIn(duration: 400.ms)
              .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),

          const SizedBox(height: 4),
          Text(
            prompt['subtitle'] as String,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 18),
          _buildPromptContent(
            context,
            prompt,
            index,
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
        ],
      ),
    );
  }

  IconData _getIconForPrompt(String? iconName) {
    switch (iconName) {
      case 'target':
        return Iconsax.direct_up;
      case 'level':
        return Iconsax.chart_2;
      case 'calendar':
        return Iconsax.calendar;
      case 'time':
        return Iconsax.clock;
      case 'duration':
        return Iconsax.timer_1;
      case 'workout':
        return Iconsax.activity;
      case 'health':
        return Iconsax.health;
      case 'equipment':
        return Iconsax.weight;
      case 'challenge':
        return Iconsax.flag;
      case 'heart':
        return Iconsax.heart;
      case 'timeline':
        return Iconsax.calendar_tick;
      case 'motivation':
        return Iconsax.star;
      case 'user':
        return Iconsax.user;
      case 'ruler':
        return Iconsax.ruler;
      case 'weight':
        return Iconsax.weight_1;
      default:
        return Iconsax.message_question;
    }
  }

  Widget _buildPromptContent(
    BuildContext context,
    Map<String, dynamic> prompt,
    int index,
  ) {
    switch (prompt['type']) {
      case 'multiSelect':
        return _buildMultiSelect(context, prompt, index);
      case 'slider':
        return _buildSlider(context, prompt);
      case 'singleSelect':
        return _buildSingleSelect(context, prompt);
      case 'textInput':
        return _buildTextInput(context, prompt);
      case 'datePicker':
        return _buildDatePicker(context);
      case 'heightPicker':
        return _buildHeightPicker(context);
      case 'weightPicker':
        return _buildWeightPicker(context);
      case 'groupedMultiSelect':
        return _buildGroupedMultiSelect(context, prompt, index);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildDatePicker(BuildContext context) {
    return Obx(() {
      final selectedDate = controller.dateOfBirth.value;
      final age = selectedDate != null
          ? DateTime.now().year - selectedDate.year
          : null;

      return Column(
        children: [
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime(2000, 1, 1),
                firstDate: DateTime(1940),
                lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: AppColors.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                controller.setDateOfBirth(picked);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.large,
                border: Border.all(
                  color: selectedDate != null
                      ? AppColors.primary
                      : AppColors.borderLight,
                  width: selectedDate != null ? 2 : 1,
                ),
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                children: [
                  Icon(
                    Iconsax.calendar_1,
                    size: 48,
                    color: selectedDate != null
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    selectedDate != null
                        ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                        : 'Tap to select date',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selectedDate != null
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                        ),
                  ),
                  if (age != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.bgBlush,
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(
                        '$age years old',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHeightPicker(BuildContext context) {
    return Obx(() {
      final heightCm = controller.heightCm.value;
      final feet = (heightCm / 30.48).floor();
      final inches = ((heightCm / 2.54) % 12).round();

      return Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppShadows.primaryGlow,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${heightCm.round()}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                  ),
                  Text(
                    'cm',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$feet\' $inches"',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 32),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.bgBlush,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: heightCm,
              min: 120,
              max: 220,
              divisions: 100,
              onChanged: (value) => controller.setHeight(value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('120 cm', style: Theme.of(context).textTheme.bodySmall),
                Text('220 cm', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildWeightPicker(BuildContext context) {
    return Obx(() {
      final weightKg = controller.weightKg.value;
      final weightLbs = (weightKg * 2.20462).round();

      return Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppShadows.primaryGlow,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${weightKg.round()}',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                  ),
                  Text(
                    'kg',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$weightLbs lbs',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
          const SizedBox(height: 32),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.bgBlush,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: weightKg,
              min: 30,
              max: 200,
              divisions: 170,
              onChanged: (value) => controller.setWeight(value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('30 kg', style: Theme.of(context).textTheme.bodySmall),
                Text('200 kg', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgBlush,
              borderRadius: AppRadius.medium,
            ),
            child: Row(
              children: [
                const Icon(Iconsax.shield_tick, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your weight is kept private and only used to personalize your plan.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildMultiSelect(
    BuildContext context,
    Map<String, dynamic> prompt,
    int index,
  ) {
    final options = prompt['options'] as List;
    return Obx(() {
      final selectedList = controller.getMultiSelectList(index);
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: options.map((option) {
          final optionStr = option.toString();
          final isSelected = selectedList.contains(optionStr);
          return GestureDetector(
            onTap: () => controller.toggleMultiSelect(index, optionStr),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: AppRadius.pill,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? AppShadows.primaryGlow
                    : AppShadows.subtle,
              ),
              child: Text(
                optionStr,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildGroupedMultiSelect(
    BuildContext context,
    Map<String, dynamic> prompt,
    int index,
  ) {
    final groups = prompt['groups'] as List;
    return Obx(() {
      final selectedList = controller.getMultiSelectList(index);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "None" chip at top
          GestureDetector(
            onTap: () {
              if (selectedList.isNotEmpty) {
                selectedList.clear();
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: selectedList.isEmpty
                    ? AppColors.primary
                    : Colors.white,
                borderRadius: AppRadius.large,
                border: Border.all(
                  color: selectedList.isEmpty
                      ? AppColors.primary
                      : AppColors.borderLight,
                  width: selectedList.isEmpty ? 2 : 1,
                ),
                boxShadow: selectedList.isEmpty
                    ? AppShadows.primaryGlow
                    : AppShadows.subtle,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.tick_circle,
                    size: 20,
                    color: selectedList.isEmpty
                        ? Colors.white
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'None - I\'m good to go!',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selectedList.isEmpty
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
          // Grouped ExpansionTiles
          ...groups.map((group) {
            final title = group['title'] as String;
            final options = group['options'] as List;
            final hasSelection = options.any(
              (o) => selectedList.contains(o['tag']),
            );
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.medium,
                border: Border.all(
                  color: hasSelection
                      ? AppColors.primary.withValues(alpha: 0.4)
                      : AppColors.borderLight,
                ),
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  initiallyExpanded: hasSelection,
                  tilePadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  title: Row(
                    children: [
                      Text(
                        title,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      if (hasSelection) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            '${options.where((o) => selectedList.contains(o['tag'])).length}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: options.map((option) {
                          final tag = option['tag'] as String;
                          final label = option['label'] as String;
                          final isSelected = selectedList.contains(tag);
                          return GestureDetector(
                            onTap: () => controller.toggleMultiSelect(
                                index, tag),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.bgCream,
                                borderRadius: AppRadius.pill,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.borderLight,
                                ),
                              ),
                              child: Text(
                                label,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }

  Widget _buildSlider(BuildContext context, Map<String, dynamic> prompt) {
    return Obx(
      () => Column(
        children: [
          const SizedBox(height: 30),
          // Big number display
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppShadows.primaryGlow,
            ),
            child: Center(
              child: Text(
                '${controller.workoutDaysPerWeek.value}',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'days per week',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 40),
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.bgBlush,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.2),
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            ),
            child: Slider(
              value: controller.workoutDaysPerWeek.value.toDouble(),
              min: (prompt['min'] as int).toDouble(),
              max: (prompt['max'] as int).toDouble(),
              divisions: (prompt['max'] as int) - (prompt['min'] as int),
              onChanged: (value) => controller.setWorkoutDays(value.round()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${prompt['min']} day',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${prompt['max']} days',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Tip card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgBlush,
              borderRadius: AppRadius.medium,
            ),
            child: Row(
              children: [
                const Icon(Iconsax.lamp_on, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.workoutDaysPerWeek.value >= 5
                        ? 'Amazing commitment! Remember to schedule rest days for recovery.'
                        : controller.workoutDaysPerWeek.value >= 3
                        ? 'Perfect! 3-4 days is ideal for building lasting habits.'
                        : 'Great start! Even 1-2 days makes a real difference.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleSelect(BuildContext context, Map<String, dynamic> prompt) {
    final options = prompt['options'] as List<Map<String, String>>;
    final key = prompt['key'] as String;

    return Obx(() {
      final currentValue = controller.getSingleSelectValue(key);
      return Column(
        children: options.map((option) {
          final isSelected = currentValue == option['title'];
          final hasEmoji = option['emoji'] != null;

          return GestureDetector(
            onTap: () => controller.setSingleSelect(key, option['title']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.bgBlush : Colors.white,
                borderRadius: AppRadius.large,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.borderLight,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? AppShadows.primaryGlow
                    : AppShadows.subtle,
              ),
              child: Row(
                children: [
                  if (hasEmoji) ...[
                    Text(
                      option['emoji']!,
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option['title']!,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          option['description']!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.white,
                      ),
                    )
                  else
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.borderMedium,
                          width: 2,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildTextInput(BuildContext context, Map<String, dynamic> prompt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.large,
            boxShadow: AppShadows.subtle,
          ),
          child: TextField(
            controller: controller.motivationController,
            maxLines: 5,
            style: Theme.of(context).textTheme.bodyLarge,
            decoration: InputDecoration(
              hintText: prompt['placeholder'] as String,
              hintStyle: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textMuted),
              border: OutlineInputBorder(
                borderRadius: AppRadius.large,
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Need inspiration? Tap to use:',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...(prompt['examples'] as List<String>).map(
          (example) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                controller.motivationController.text = example;
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.medium,
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.bgBlush,
                        borderRadius: AppRadius.small,
                      ),
                      child: const Icon(
                        Iconsax.quote_up,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        example,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}

