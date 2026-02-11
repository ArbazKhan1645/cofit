import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/community_model.dart';

/// Structured workout plan card for recipe_share posts.
/// Shows title, goal/difficulty/duration chips, exercise list, and notes.
class WorkoutRecipeCard extends StatelessWidget {
  final WorkoutRecipeMetadata metadata;

  const WorkoutRecipeCard({
    super.key,
    required this.metadata,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with gradient
          _buildHeader(),

          // Exercise list
          _buildExerciseList(),

          // Notes
          if (metadata.notes != null && metadata.notes!.isNotEmpty)
            _buildNotes(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFFFAB91)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              const Icon(Iconsax.weight5, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  metadata.recipeTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Chips row
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _buildChip(metadata.goalLabel, Icons.track_changes),
              _buildChip(
                metadata.difficultyLabel,
                Iconsax.flash_1,
                color: _getDifficultyColor(),
              ),
              if (metadata.totalDurationMinutes > 0)
                _buildChip(metadata.formattedDuration, Iconsax.timer_1),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color ?? Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    final exercises = metadata.exercises;
    final showCount = exercises.length > 4 ? 4 : exercises.length;
    final remaining = exercises.length - showCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < showCount; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      exercises[i].name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    exercises[i].displayFormat,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          if (remaining > 0)
            Padding(
              padding: const EdgeInsets.only(left: 14, top: 2),
              child: Text(
                '+$remaining more exercises',
                style: TextStyle(
                  color: AppColors.primary.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgCream,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          metadata.notes!,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Color _getDifficultyColor() {
    switch (metadata.difficulty) {
      case 'beginner':
        return const Color(0xFF81C784); // green
      case 'intermediate':
        return const Color(0xFFFFB74D); // orange
      case 'advanced':
        return const Color(0xFFE57373); // red
      default:
        return Colors.white;
    }
  }
}
