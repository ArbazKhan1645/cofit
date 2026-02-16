import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/cofit_image.dart';
import '../../../data/models/workout_model.dart';
import '../../../data/repositories/workout_repository.dart';
import '../../../app/routes/app_routes.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  final WorkoutRepository _repository = WorkoutRepository();
  late TrainerModel trainer;
  List<WorkoutModel> trainerWorkouts = [];
  bool isLoadingWorkouts = true;

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    if (arg is TrainerModel) {
      trainer = arg;
    } else {
      // Fallback — shouldn't happen
      trainer = TrainerModel(
        id: '',
        fullName: 'Unknown',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    _loadTrainerWorkouts();
  }

  Future<void> _loadTrainerWorkouts() async {
    final result = await _repository.getWorkoutsByTrainer(trainer.id);
    result.fold(
      (error) {},
      (data) {
        if (mounted) {
          setState(() {
            trainerWorkouts = data;
          });
        }
      },
    );
    if (mounted) {
      setState(() => isLoadingWorkouts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accentColor = _getTrainerColor();

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: accentColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Avatar
                      _buildAvatar(context, accentColor),
                      const SizedBox(height: 16),
                      Text(
                        trainer.fullName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trainer.specialties.isNotEmpty
                            ? trainer.specialties.join(' | ')
                            : 'Trainer',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMiniStat(
                              context,
                              trainer.yearsExperience > 0
                                  ? '${trainer.yearsExperience}+ years'
                                  : 'N/A',
                              'Experience'),
                          Container(
                            width: 1,
                            height: 30,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          _buildMiniStat(
                              context,
                              isLoadingWorkouts
                                  ? '...'
                                  : '${trainerWorkouts.length}',
                              'Workouts'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: AppPadding.screen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Bio
                  if (trainer.bio != null && trainer.bio!.isNotEmpty) ...[
                    Text(
                      'About ${trainer.fullName}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      trainer.bio!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Specialties
                  if (trainer.specialties.isNotEmpty) ...[
                    Text(
                      'Specialties',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: trainer.specialties.map((specialty) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: AppRadius.pill,
                          ),
                          child: Text(
                            specialty,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: accentColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Certifications
                  if (trainer.certifications.isNotEmpty) ...[
                    Text(
                      'Certifications',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...trainer.certifications.map((cert) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: AppRadius.small,
                              ),
                              child: const Icon(Iconsax.verify,
                                  size: 16, color: AppColors.success),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                cert,
                                style:
                                    Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],

                  // Workouts
                  _buildWorkoutsSection(context, accentColor),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, Color accentColor) {
    if (trainer.avatarUrl != null && trainer.avatarUrl!.isNotEmpty) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
            ),
          ],
        ),
        child: ClipOval(
          child: CofitImage(
            imageUrl: trainer.avatarUrl!,
            width: 120,
            height: 120,
          ),
        ),
      );
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
          ),
        ],
      ),
      child: Center(
        child: Text(
          trainer.fullName.isNotEmpty ? trainer.fullName[0].toUpperCase() : '?',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }

  Widget _buildMiniStat(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
        ),
      ],
    );
  }

  Widget _buildWorkoutsSection(BuildContext context, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workouts by ${trainer.fullName}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        if (isLoadingWorkouts)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          )
        else if (trainerWorkouts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.large,
            ),
            child: Text(
              'No workouts available yet',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textMuted),
            ),
          )
        else
          ...trainerWorkouts.map((workout) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.large,
                boxShadow: AppShadows.subtle,
              ),
              child: InkWell(
                onTap: () => Get.toNamed(AppRoutes.workoutDetail,
                    arguments: workout),
                borderRadius: AppRadius.large,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      CofitImage(
                        imageUrl: workout.thumbnailUrl,
                        width: 60,
                        height: 60,
                        borderRadius: AppRadius.medium,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.title,
                              style: Theme.of(context).textTheme.titleSmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${workout.durationMinutes} min  •  ${workout.difficultyLabel}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Iconsax.arrow_right_3,
                          color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  Color _getTrainerColor() {
    // Assign colors based on trainer index for visual variety
    final name = trainer.fullName.toLowerCase();
    if (name.contains('jess')) return AppColors.primary;
    if (name.contains('nadine')) return AppColors.lavender;
    // Hash-based color for any other trainer
    final colors = [
      AppColors.primary,
      AppColors.lavender,
      AppColors.mintFresh,
      AppColors.skyBlue,
      AppColors.peach,
    ];
    return colors[trainer.fullName.hashCode.abs() % colors.length];
  }
}
