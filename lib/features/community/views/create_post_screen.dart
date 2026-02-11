import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/community_model.dart';
import '../controllers/community_controller.dart';
import '../widgets/winning_card.dart';

class CreatePostScreen extends GetView<CommunityController> {
  const CreatePostScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Create Post'),
        leading: IconButton(
          icon: const Icon(Iconsax.close_circle),
          onPressed: () {
            controller.clearPostForm();
            Get.back();
          },
        ),
        actions: [
          Obx(() => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: TextButton(
                  onPressed: controller.isCreatingPost.value
                      ? null
                      : () async {
                          final success = await controller.createPost();
                          if (success) {
                            Get.back();
                          }
                        },
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  child: controller.isCreatingPost.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Post'),
                ),
              )),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screenAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post type selector
            _buildPostTypeSelector(context),
            const SizedBox(height: 16),

            // Dynamic content based on post type
            Obx(() {
              switch (controller.selectedPostType.value) {
                case 'recipe_share':
                  return _buildRecipeForm(context);
                case 'achievement':
                  return _buildChallengeForm(context);
                default:
                  return _buildStandardForm(context);
              }
            }),

            const SizedBox(height: 16),

            // Selected image preview
            _buildImagePreview(),
            const SizedBox(height: 16),

            // Add image button
            _buildAddImageButton(context),
            const SizedBox(height: 24),

            // Tips
            _buildTips(context),
          ],
        ),
      ),
    );
  }

  Widget _buildPostTypeSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Obx(() => Row(
            children: [
              _buildTypeChip(
                context,
                type: 'text',
                label: 'Post',
                icon: Iconsax.edit,
              ),
              _buildTypeChip(
                context,
                type: 'recipe_share',
                label: 'Recipe',
                icon: Iconsax.book,
              ),
              _buildTypeChip(
                context,
                type: 'achievement',
                label: 'Challenge',
                icon: Iconsax.cup,
              ),
            ],
          )),
    );
  }

  Widget _buildTypeChip(
    BuildContext context, {
    required String type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = controller.selectedPostType.value == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setPostType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: AppRadius.medium,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isSelected ? Colors.white : AppColors.textMuted,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandardForm(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: TextField(
        controller: controller.postContentController,
        maxLines: 6,
        maxLength: 500,
        decoration: InputDecoration(
          hintText: 'What\'s on your mind?',
          hintStyle: TextStyle(color: AppColors.textMuted),
          border: InputBorder.none,
          counterStyle: TextStyle(color: AppColors.textMuted),
        ),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }

  Widget _buildRecipeForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title + Description
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.large,
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: controller.recipeTitleController,
                decoration: InputDecoration(
                  hintText: 'Workout Title *',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Iconsax.weight, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.small,
                    borderSide: const BorderSide(color: AppColors.bgBlush),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.small,
                    borderSide: const BorderSide(color: AppColors.bgBlush),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.small,
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.postContentController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'Brief description (optional)',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.small,
                    borderSide: const BorderSide(color: AppColors.bgBlush),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.small,
                    borderSide: const BorderSide(color: AppColors.bgBlush),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.small,
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Goal + Difficulty + Duration
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.large,
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goal selector
              Text('Goal', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildSelectableChip(context, 'Fat Loss', 'fat_loss', controller.recipeGoal),
                      _buildSelectableChip(context, 'Muscle Gain', 'muscle_gain', controller.recipeGoal),
                      _buildSelectableChip(context, 'Strength', 'strength', controller.recipeGoal),
                      _buildSelectableChip(context, 'Endurance', 'endurance', controller.recipeGoal),
                      _buildSelectableChip(context, 'Beginner', 'beginner_friendly', controller.recipeGoal),
                    ],
                  )),

              const SizedBox(height: 16),

              // Difficulty selector
              Text('Difficulty', style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Obx(() => Row(
                    children: [
                      _buildSelectableChip(context, 'Beginner', 'beginner', controller.recipeDifficulty, color: AppColors.success),
                      const SizedBox(width: 6),
                      _buildSelectableChip(context, 'Intermediate', 'intermediate', controller.recipeDifficulty, color: AppColors.warning),
                      const SizedBox(width: 6),
                      _buildSelectableChip(context, 'Advanced', 'advanced', controller.recipeDifficulty, color: AppColors.error),
                    ],
                  )),

              const SizedBox(height: 16),

              // Duration
              TextField(
                controller: controller.recipeDurationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Duration (minutes)',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                  prefixIcon: const Icon(Iconsax.timer_1, color: AppColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.small,
                    borderSide: const BorderSide(color: AppColors.bgBlush),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppRadius.small,
                    borderSide: const BorderSide(color: AppColors.bgBlush),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppRadius.small,
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Exercises list
        Container(
          padding: const EdgeInsets.all(16),
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
                  Text('Exercises *', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => _showAddExerciseDialog(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.add, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Add', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.recipeExercises.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgCream,
                      borderRadius: AppRadius.medium,
                    ),
                    child: Center(
                      child: Text(
                        'Tap + Add to add exercises',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ),
                  );
                }

                return Column(
                  children: List.generate(controller.recipeExercises.length, (i) {
                    final ex = controller.recipeExercises[i];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.bgCream,
                        borderRadius: AppRadius.small,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              ex.name,
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                            ),
                          ),
                          Text(
                            ex.displayFormat,
                            style: const TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => controller.removeRecipeExercise(i),
                            child: const Icon(Iconsax.close_circle, size: 18, color: AppColors.error),
                          ),
                        ],
                      ),
                    );
                  }),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Notes
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.large,
            boxShadow: AppShadows.subtle,
          ),
          child: TextField(
            controller: controller.recipeNotesController,
            maxLines: 3,
            maxLength: 300,
            decoration: InputDecoration(
              hintText: 'Additional notes or tips (optional)',
              hintStyle: TextStyle(color: AppColors.textMuted),
              border: InputBorder.none,
              counterStyle: TextStyle(color: AppColors.textMuted),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectableChip(
    BuildContext context,
    String label,
    String value,
    RxString selected, {
    Color? color,
  }) {
    final isSelected = selected.value == value;
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: () => selected.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? chipColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.borderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final setsCtrl = TextEditingController(text: '3');
    final repsCtrl = TextEditingController(text: '12');
    final useReps = true.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Add Exercise'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Exercise name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => useReps.value = true,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: useReps.value ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: useReps.value ? AppColors.primary : AppColors.borderLight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Reps',
                                style: TextStyle(
                                  color: useReps.value ? Colors.white : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => useReps.value = false,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: !useReps.value ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: !useReps.value ? AppColors.primary : AppColors.borderLight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Duration',
                                style: TextStyle(
                                  color: !useReps.value ? Colors.white : AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: setsCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Sets',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Obx(() => TextField(
                          controller: repsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: useReps.value ? 'Reps' : 'Seconds',
                            border: const OutlineInputBorder(),
                          ),
                        )),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;

              final sets = int.tryParse(setsCtrl.text) ?? 3;
              final repsOrDuration = int.tryParse(repsCtrl.text) ?? 12;

              controller.addRecipeExercise(WorkoutRecipeExercise(
                name: name,
                sets: sets,
                reps: useReps.value ? repsOrDuration : null,
                durationSeconds: !useReps.value ? repsOrDuration : null,
              ));

              Get.back();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Won challenges selector
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.large,
            boxShadow: AppShadows.subtle,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Your Achievement',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                if (controller.isLoadingWonChallenges.value) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }

                if (controller.wonChallenges.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.bgBlush,
                      borderRadius: AppRadius.medium,
                    ),
                    child: Column(
                      children: [
                        const Icon(Iconsax.cup, size: 36, color: AppColors.textMuted),
                        const SizedBox(height: 8),
                        Text(
                          'No completed challenges yet',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textMuted,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Complete a challenge to share your win!',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: controller.wonChallenges.map((uc) {
                    final isSelected = controller.selectedWonChallenge.value?.id == uc.id;
                    final challenge = uc.challenge;
                    return GestureDetector(
                      onTap: () => controller.selectWonChallenge(uc),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.bgBlush : AppColors.bgCream,
                          borderRadius: AppRadius.medium,
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.borderLight,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Radio indicator
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                                  width: 2,
                                ),
                                color: isSelected ? AppColors.primary : Colors.transparent,
                              ),
                              child: isSelected
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    challenge?.title ?? 'Challenge',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Rank #${uc.rank} - ${uc.currentProgress}/${challenge?.targetValue ?? 0} ${challenge?.targetUnit ?? ''}',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Rank badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getRankColor(uc.rank),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '#${uc.rank}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Personal message
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.large,
            boxShadow: AppShadows.subtle,
          ),
          child: TextField(
            controller: controller.challengeMessageController,
            maxLines: 3,
            maxLength: 300,
            decoration: InputDecoration(
              hintText: 'Share your experience (optional)...',
              hintStyle: TextStyle(color: AppColors.textMuted),
              border: InputBorder.none,
              counterStyle: TextStyle(color: AppColors.textMuted),
            ),
          ),
        ),

        // Preview card
        Obx(() {
          final selected = controller.selectedWonChallenge.value;
          if (selected == null) return const SizedBox.shrink();

          final challenge = selected.challenge;
          final preview = ChallengePostMetadata(
            challengeId: selected.challengeId,
            challengeTitle: challenge?.title ?? 'Challenge',
            challengeType: challenge?.challengeType ?? '',
            userRank: selected.rank,
            totalProgress: selected.currentProgress,
            targetValue: challenge?.targetValue ?? 0,
            targetUnit: challenge?.targetUnit ?? '',
            completedAt: selected.completedAt,
            personalMessage: controller.challengeMessageController.text.isNotEmpty
                ? controller.challengeMessageController.text
                : null,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Preview',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                ),
              ),
              WinningCard(metadata: preview),
            ],
          );
        }),
      ],
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return AppColors.primary;
    }
  }

  Widget _buildImagePreview() {
    return Obx(() {
      if (controller.selectedImage.value != null) {
        return Stack(
          children: [
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: AppRadius.large,
                boxShadow: AppShadows.subtle,
              ),
              child: ClipRRect(
                borderRadius: AppRadius.large,
                child: Image.memory(
                  controller.selectedImage.value!,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: controller.removeSelectedImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildAddImageButton(BuildContext context) {
    return Obx(() {
      if (controller.selectedImage.value == null) {
        return GestureDetector(
          onTap: controller.pickImage,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.large,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.gallery_add,
                  color: AppColors.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Add Photo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    });
  }

  Widget _buildTips(BuildContext context) {
    return Obx(() {
      String tipText;
      IconData tipIcon;

      switch (controller.selectedPostType.value) {
        case 'recipe_share':
          tipText = 'Share your workout recipes! Add exercises with sets, reps, and goals.';
          tipIcon = Iconsax.weight;
          break;
        case 'achievement':
          tipText = 'Celebrate your fitness achievements and inspire others with your challenge wins!';
          tipIcon = Iconsax.cup;
          break;
        default:
          tipText = 'Share your fitness journey, celebrate wins, or ask for motivation!';
          tipIcon = Iconsax.lamp_on;
      }

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lavender.withValues(alpha: 0.2),
          borderRadius: AppRadius.medium,
        ),
        child: Row(
          children: [
            Icon(
              tipIcon,
              color: AppColors.lavender,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tipText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
