import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/mock/mock_data.dart';

class TrainerProfileScreen extends StatelessWidget {
  const TrainerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String trainerName = Get.arguments as String? ?? 'Jess';
    final isJess = trainerName.toLowerCase().contains('jess');

    final trainer = isJess
        ? _TrainerData(
            name: 'Jess',
            title: 'Strength & HIIT Specialist',
            bio: 'Hey beautiful! I\'m Jess, your go-to trainer for all things strength and HIIT. I believe fitness should be fun, challenging, and totally empowering. Let\'s crush those goals together!',
            specialties: ['Strength Training', 'HIIT', 'Full Body', 'Core'],
            experience: '8+ years',
            certifications: ['NASM Certified', 'CrossFit L2', 'TRX Certified'],
            quote: '"Strong is the new beautiful. Let\'s build that strength together!"',
            color: AppColors.primary,
          )
        : _TrainerData(
            name: 'Nadine',
            title: 'Yoga & Pilates Expert',
            bio: 'Namaste! I\'m Nadine, and I\'m here to guide you through mindful movement and inner peace. My classes focus on flexibility, strength, and connecting with your body.',
            specialties: ['Yoga', 'Pilates', 'Stretching', 'Meditation'],
            experience: '10+ years',
            certifications: ['RYT-500', 'Pilates Certified', 'Meditation Teacher'],
            quote: '"Movement is medicine for the mind, body, and soul."',
            color: AppColors.lavender,
          );

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: trainer.color,
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
                    colors: [trainer.color, trainer.color.withValues(alpha: 0.7)],
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
                      Container(
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
                            trainer.name[0],
                            style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  color: trainer.color,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        trainer.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        trainer.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                      ),
                      const SizedBox(height: 16),
                      // Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildMiniStat(context, trainer.experience, 'Experience'),
                          Container(
                            width: 1,
                            height: 30,
                            margin: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          _buildMiniStat(context, '50+', 'Workouts'),
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

                  // Quote
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: trainer.color.withValues(alpha: 0.1),
                      borderRadius: AppRadius.large,
                      border: Border.all(color: trainer.color.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.quote_up, color: trainer.color, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            trainer.quote,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: trainer.color,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // About
                  Text(
                    'About ${trainer.name}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    trainer.bio,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                  ),

                  const SizedBox(height: 24),

                  // Specialties
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: trainer.color.withValues(alpha: 0.1),
                          borderRadius: AppRadius.pill,
                        ),
                        child: Text(
                          specialty,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: trainer.color,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Certifications
                  _buildCertificationsSection(context, trainer),

                  const SizedBox(height: 24),

                  // Workouts by this trainer
                  _buildWorkoutsSection(context, trainer),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
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

  Widget _buildCertificationsSection(BuildContext context, _TrainerData trainer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  child: const Icon(Iconsax.verify, size: 16, color: AppColors.success),
                ),
                const SizedBox(width: 12),
                Text(
                  cert,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildWorkoutsSection(BuildContext context, _TrainerData trainer) {
    final workouts = MockData.getMockWeeklyWorkouts()
        .where((w) => w.trainerName.toLowerCase().contains(trainer.name.toLowerCase()))
        .take(4)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Workouts by ${trainer.name}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...workouts.map((workout) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.large,
              boxShadow: AppShadows.subtle,
            ),
            child: InkWell(
              onTap: () => Get.toNamed('/workout-detail', arguments: workout),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: trainer.color.withValues(alpha: 0.1),
                      borderRadius: AppRadius.medium,
                    ),
                    child: Icon(Iconsax.play_circle, color: trainer.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.title,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${workout.durationMinutes} min • ${workout.difficulty}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Iconsax.arrow_right_3, color: AppColors.textMuted),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _TrainerData {
  final String name;
  final String title;
  final String bio;
  final List<String> specialties;
  final String experience;
  final List<String> certifications;
  final String quote;
  final Color color;

  _TrainerData({
    required this.name,
    required this.title,
    required this.bio,
    required this.specialties,
    required this.experience,
    required this.certifications,
    required this.quote,
    required this.color,
  });
}
