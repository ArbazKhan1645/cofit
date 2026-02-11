import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:chewie/chewie.dart';
import '../../../shared/widgets/cofit_image.dart';
import 'package:video_player/video_player.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/models/workout_model.dart';

class WorkoutDetailScreen extends StatefulWidget {
  const WorkoutDetailScreen({super.key});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  late WorkoutModel workout;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _showVideo = false;

  @override
  void initState() {
    super.initState();
    workout = Get.arguments as WorkoutModel;
  }

  void _initializeVideo() async {
    setState(() => _showVideo = true);

    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(workout.videoUrl),
    );

    await _videoController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      placeholder: Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      materialProgressColors: ChewieProgressColors(
        playedColor: AppColors.primary,
        handleColor: AppColors.primary,
        backgroundColor: Colors.grey.shade300,
        bufferedColor: AppColors.primaryLight,
      ),
    );

    setState(() => _isVideoInitialized = true);
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      body: CustomScrollView(
        slivers: [
          // App Bar with Video/Image
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.black,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Get.back(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.heart, color: Colors.white),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.share, color: Colors.white),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _showVideo && _isVideoInitialized
                  ? Chewie(controller: _chewieController!)
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        CofitImage(
                          imageUrl: workout.thumbnailUrl,
                          fit: BoxFit.cover,
                        ),
                        Container(
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: _initializeVideo,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.4),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                  const SizedBox(height: 20),

                  // Title & Trainer
                  Text(
                    workout.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => Get.toNamed('/trainer', arguments: workout.trainerName),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.bgBlush,
                          child: Text(
                            workout.trainerName[0],
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'with ${workout.trainerName}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        const Icon(Iconsax.arrow_right_3, size: 16, color: AppColors.primary),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Stats Row
                  _buildStatsRow(context),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'About This Workout',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    workout.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                  ),

                  const SizedBox(height: 24),

                  // Equipment
                  _buildEquipmentSection(context),

                  const SizedBox(height: 24),

                  // What to Expect
                  _buildWhatToExpect(context),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildStartButton(context),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              icon: Iconsax.clock,
              value: '${workout.durationMinutes}',
              label: 'Minutes',
              color: AppColors.primary,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.borderLight),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Iconsax.flash_1,
              value: workout.difficulty,
              label: 'Level',
              color: AppColors.sunnyYellow,
            ),
          ),
          Container(width: 1, height: 40, color: AppColors.borderLight),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Iconsax.strongbox,
              value: '${workout.caloriesBurned}',
              label: 'Calories',
              color: AppColors.lavender,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
      ],
    );
  }

  Widget _buildEquipmentSection(BuildContext context) {
    final equipment = ['Yoga Mat', 'Light Weights', 'Water Bottle'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Equipment Needed',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: equipment.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.pill,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Iconsax.tick_circle, size: 16, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    item,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWhatToExpect(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.mintGradient,
        borderRadius: AppRadius.large,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: AppRadius.small,
                ),
                child: const Icon(Iconsax.lovely, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'What to Expect',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildExpectItem(context, 'Warm-up to get your body ready'),
          _buildExpectItem(context, 'Main workout with guided instructions'),
          _buildExpectItem(context, 'Cool-down and stretching'),
          _buildExpectItem(context, 'Positive vibes and encouragement!'),
        ],
      ),
    );
  }

  Widget _buildExpectItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _initializeVideo,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.large,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Iconsax.play_circle, size: 24),
              const SizedBox(width: 12),
              Text(
                'Start Workout',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
