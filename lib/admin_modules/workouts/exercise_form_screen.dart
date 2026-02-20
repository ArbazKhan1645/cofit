import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/media/media_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/workout_model.dart';
import 'workout_controller.dart';

class ExerciseFormScreen extends StatefulWidget {
  const ExerciseFormScreen({super.key});

  @override
  State<ExerciseFormScreen> createState() => _ExerciseFormScreenState();
}

class _ExerciseFormScreenState extends State<ExerciseFormScreen> {
  final _controller = Get.find<AdminWorkoutController>();
  final _uuid = const Uuid();

  // Arguments
  late final int? _editIndex;
  late final bool _isEdit;
  late final WorkoutExerciseModel? _existingEx;

  // Text controllers
  late final TextEditingController _nameC;
  late final TextEditingController _descC;
  late final TextEditingController _videoUrlC;
  late final TextEditingController _durationC;
  late final TextEditingController _repsC;
  late final TextEditingController _setsC;
  late final TextEditingController _restC;

  // Local state
  String _exerciseType = 'timed';
  String _videoSource = 'url';
  bool _isUploadingVideo = false;
  String _uploadedVideoUrl = '';

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _editIndex = args['editIndex'] as int?;
    _isEdit = _editIndex != null;
    _existingEx = _isEdit ? _controller.exercises[_editIndex!] : null;

    _nameC = TextEditingController(text: _existingEx?.name ?? '');
    _descC = TextEditingController(text: _existingEx?.description ?? '');
    _videoUrlC = TextEditingController(text: _existingEx?.videoUrl ?? '');
    _durationC = TextEditingController(
      text: _existingEx?.durationSeconds.toString() ?? '30',
    );
    _repsC = TextEditingController(text: _existingEx?.reps?.toString() ?? '');
    _setsC = TextEditingController(text: _existingEx?.sets?.toString() ?? '');
    _restC = TextEditingController(
      text: _existingEx?.restSeconds?.toString() ?? '',
    );
    _exerciseType = _existingEx?.exerciseType ?? 'timed';

    // If editing and has a video URL, check if it's an uploaded URL
    final existingVideo = _existingEx?.videoUrl;
    if (existingVideo != null && existingVideo.contains('supabase')) {
      _videoSource = 'upload';
      _uploadedVideoUrl = existingVideo;
    }
  }

  @override
  void dispose() {
    // _nameC.dispose();
    // _descC.dispose();
    // _videoUrlC.dispose();
    // _durationC.dispose();
    // _repsC.dispose();
    // _setsC.dispose();
    // _restC.dispose();
    super.dispose();
  }

  void _save() {
    if (_nameC.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Exercise name is required',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Resolve video URL
    String? videoUrl;
    if (_videoSource == 'upload' && _uploadedVideoUrl.isNotEmpty) {
      videoUrl = _uploadedVideoUrl;
    } else if (_videoSource == 'url' && _videoUrlC.text.trim().isNotEmpty) {
      final err = AdminWorkoutController.validateVideoUrl(_videoUrlC.text);
      if (err != null) {
        Get.snackbar('Error', err, snackPosition: SnackPosition.BOTTOM);
        return;
      }
      videoUrl = _videoUrlC.text.trim();
    }

    final newEx = WorkoutExerciseModel(
      id: _existingEx?.id ?? 'temp_${_uuid.v4()}',
      workoutId: _controller.editingWorkout.value?.id ?? '',
      name: _nameC.text.trim(),
      description: _descC.text.trim().isNotEmpty ? _descC.text.trim() : null,
      videoUrl: videoUrl,
      orderIndex: _isEdit
          ? _existingEx!.orderIndex
          : _controller.currentVariantExercises.length,
      durationSeconds: int.tryParse(_durationC.text) ?? 30,
      reps: _repsC.text.isNotEmpty ? int.tryParse(_repsC.text) : null,
      sets: _setsC.text.isNotEmpty ? int.tryParse(_setsC.text) : null,
      restSeconds: _restC.text.isNotEmpty ? int.tryParse(_restC.text) : null,
      exerciseType: _exerciseType,
      variantId: _isEdit
          ? _existingEx!.variantId
          : _controller.selectedVariant.value?.id,
      alternatives: _existingEx?.alternatives ?? {},
      createdAt: _existingEx?.createdAt ?? DateTime.now(),
    );

    if (_isEdit) {
      _controller.exercises[_editIndex!] = newEx;
    } else {
      _controller.exercises.add(newEx);
    }
    Get.back();
  }

  Future<void> _pickAndUploadVideo() async {
    final bytes = await MediaService.to.pickVideoFromGallery();
    if (bytes == null) return;

    setState(() => _isUploadingVideo = true);
    try {
      final url = await MediaService.to.uploadWorkoutVideo(bytes);
      setState(() {
        _uploadedVideoUrl = url;
        _isUploadingVideo = false;
      });
    } catch (e) {
      setState(() => _isUploadingVideo = false);
      Get.snackbar(
        'Error',
        'Failed to upload video',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Exercise' : 'Add Exercise'),
        actions: [
          TextButton(
            onPressed: _isUploadingVideo ? null : _save,
            child: _isUploadingVideo
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screen,
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildBasicInfoCard(context),
            const SizedBox(height: 24),
            _buildVideoCard(context),
            const SizedBox(height: 24),
            _buildTypeSettingsCard(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ============================================
  // BASIC INFO CARD
  // ============================================
  Widget _buildBasicInfoCard(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Info',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _nameC,
            decoration: const InputDecoration(
              labelText: 'Exercise Name *',
              prefixIcon: Icon(Iconsax.text),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descC,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Iconsax.document_text),
              alignLabelWithHint: true,
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // ============================================
  // VIDEO CARD
  // ============================================
  Widget _buildVideoCard(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + toggle
          Row(
            children: [
              const Icon(Iconsax.video, size: 20, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                'Video',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'url', label: Text('URL')),
                  ButtonSegment(value: 'upload', label: Text('Upload')),
                ],
                selected: {_videoSource},
                onSelectionChanged: (s) =>
                    setState(() => _videoSource = s.first),
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStatePropertyAll(
                    Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // URL mode
          if (_videoSource == 'url')
            TextFormField(
              controller: _videoUrlC,
              decoration: const InputDecoration(
                labelText: 'Video URL (optional)',
                prefixIcon: Icon(Iconsax.link),
                hintText: 'YouTube, Vimeo, etc.',
              ),
              keyboardType: TextInputType.url,
            ),

          // Upload mode
          if (_videoSource == 'upload') ...[
            if (_isUploadingVideo)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.bgBlush,
                  borderRadius: AppRadius.medium,
                ),
                child: const Column(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    SizedBox(height: 8),
                    Text('Uploading video...'),
                  ],
                ),
              )
            else if (_uploadedVideoUrl.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: AppRadius.medium,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Iconsax.tick_circle,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Video uploaded',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _uploadedVideoUrl = ''),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: _pickAndUploadVideo,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: AppColors.bgBlush,
                    borderRadius: AppRadius.medium,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Iconsax.video_add,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pick Video',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  // ============================================
  // TYPE & SETTINGS CARD
  // ============================================
  Widget _buildTypeSettingsCard(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Type & Settings',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // Exercise type toggle
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'timed', label: Text('Timed')),
                ButtonSegment(value: 'reps', label: Text('Reps')),
                ButtonSegment(value: 'rest', label: Text('Rest')),
              ],
              selected: {_exerciseType},
              onSelectionChanged: (s) =>
                  setState(() => _exerciseType = s.first),
            ),
          ),
          const SizedBox(height: 16),

          // Conditional fields based on type
          if (_exerciseType == 'reps') ...[
            TextFormField(
              controller: _setsC,
              decoration: const InputDecoration(
                labelText: 'Sets',
                prefixIcon: Icon(Iconsax.repeat),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _repsC,
              decoration: const InputDecoration(
                labelText: 'Reps',
                prefixIcon: Icon(Iconsax.weight),
              ),
              keyboardType: TextInputType.number,
            ),
          ] else ...[
            TextFormField(
              controller: _durationC,
              decoration: const InputDecoration(
                labelText: 'Duration (seconds)',
                prefixIcon: Icon(Iconsax.timer_1),
              ),
              keyboardType: TextInputType.number,
            ),
          ],

          const SizedBox(height: 16),
          // Rest is always shown
          TextFormField(
            controller: _restC,
            decoration: const InputDecoration(
              labelText: 'Rest (seconds)',
              prefixIcon: Icon(Iconsax.pause),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
