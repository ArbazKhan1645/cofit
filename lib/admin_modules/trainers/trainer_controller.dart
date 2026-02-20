import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/media/media_service.dart';
import '../../core/services/supabase_service.dart';
import '../../data/models/workout_model.dart';
import '../../notifications/firebase_sender.dart';
import '../../shared/controllers/base_controller.dart';
import '../../shared/mixins/connectivity_mixin.dart';

class TrainerController extends BaseController with ConnectivityMixin {
  final SupabaseService _supabase = SupabaseService.to;

  // List state
  final RxList<TrainerModel> trainers = <TrainerModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString filterStatus = 'all'.obs;

  // Form state
  final formKey = GlobalKey<FormState>();
  final RxBool isSaving = false.obs;
  final RxBool isUploadingImage = false.obs;
  final Rx<TrainerModel?> editingTrainer = Rx<TrainerModel?>(null);
  final Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);

  // Text controllers
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();
  final yearsExperienceController = TextEditingController();
  final instagramController = TextEditingController();
  final websiteController = TextEditingController();

  // List fields
  final RxList<String> specialties = <String>[].obs;
  final RxList<String> certifications = <String>[].obs;
  final RxBool isActive = true.obs;
  final RxString avatarUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadTrainers();
  }

  List<TrainerModel> get filteredTrainers {
    var list = trainers.toList();
    if (filterStatus.value == 'active') {
      list = list.where((t) => t.isActive).toList();
    } else if (filterStatus.value == 'inactive') {
      list = list.where((t) => !t.isActive).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where(
            (t) =>
                t.fullName.toLowerCase().contains(q) ||
                (t.email?.toLowerCase().contains(q) ?? false) ||
                t.specialties.any((s) => s.toLowerCase().contains(q)),
          )
          .toList();
    }
    return list;
  }

  Future<void> loadTrainers() async {
    if (!await ensureConnectivity()) return;
    setLoading(true);
    try {
      final response = await _supabase
          .from('trainers')
          .select()
          .order('created_at', ascending: false);
      trainers.value = (response as List)
          .map((json) => TrainerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  }

  Future<void> refreshTrainers() async => loadTrainers();

  // ============================================
  // FORM
  // ============================================

  void initFormForCreate() {
    editingTrainer.value = null;
    selectedImageBytes.value = null;
    avatarUrl.value = '';
    fullNameController.clear();
    emailController.clear();
    bioController.clear();
    yearsExperienceController.clear();
    instagramController.clear();
    websiteController.clear();
    specialties.clear();
    certifications.clear();
    isActive.value = true;
  }

  void initFormForEdit(TrainerModel trainer) {
    editingTrainer.value = trainer;
    selectedImageBytes.value = null;
    avatarUrl.value = trainer.avatarUrl ?? '';
    fullNameController.text = trainer.fullName;
    emailController.text = trainer.email ?? '';
    bioController.text = trainer.bio ?? '';
    yearsExperienceController.text = trainer.yearsExperience > 0
        ? trainer.yearsExperience.toString()
        : '';
    instagramController.text = trainer.instagramHandle ?? '';
    websiteController.text = trainer.websiteUrl ?? '';
    specialties.value = List<String>.from(trainer.specialties);
    certifications.value = List<String>.from(trainer.certifications);
    isActive.value = trainer.isActive;
  }

  Future<void> pickImage() async {
    final bytes = await MediaService.to.pickImageFromGallery();
    if (bytes != null) selectedImageBytes.value = bytes;
  }

  void removeImage() {
    selectedImageBytes.value = null;
    avatarUrl.value = '';
  }

  void addSpecialty(String val) {
    if (val.trim().isNotEmpty && !specialties.contains(val.trim())) {
      specialties.add(val.trim());
    }
  }

  void removeSpecialty(String val) => specialties.remove(val);

  void addCertification(String val) {
    if (val.trim().isNotEmpty && !certifications.contains(val.trim())) {
      certifications.add(val.trim());
    }
  }

  void removeCertification(String val) => certifications.remove(val);

  Future<void> saveTrainer() async {
    if (!formKey.currentState!.validate()) return;
    if (!await ensureConnectivity()) return;

    isSaving.value = true;
    try {
      String? imageUrl;
      if (selectedImageBytes.value != null) {
        imageUrl = await MediaService.to.uploadTrainerImage(
          selectedImageBytes.value!,
        );
      }

      final data = <String, dynamic>{
        'full_name': fullNameController.text.trim(),
        'email': emailController.text.trim().isNotEmpty
            ? emailController.text.trim()
            : null,
        'avatar_url':
            imageUrl ?? (avatarUrl.value.isNotEmpty ? avatarUrl.value : null),
        'bio': bioController.text.trim().isNotEmpty
            ? bioController.text.trim()
            : null,
        'specialties': specialties.toList(),
        'certifications': certifications.toList(),
        'years_experience': int.tryParse(yearsExperienceController.text) ?? 0,
        'instagram_handle': instagramController.text.trim().isNotEmpty
            ? instagramController.text.trim()
            : null,
        'website_url': websiteController.text.trim().isNotEmpty
            ? websiteController.text.trim()
            : null,
        'is_active': isActive.value,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final isNewTrainer = editingTrainer.value == null;

      if (!isNewTrainer) {
        await _supabase
            .from('trainers')
            .update(data)
            .eq('id', editingTrainer.value!.id);
      } else {
        data['created_at'] = DateTime.now().toIso8601String();
        await _supabase.from('trainers').insert(data);
      }

      // Send push notification to all users on new trainer (unawaited)
      if (isNewTrainer) {
        final name = fullNameController.text.trim();
        final specs = specialties.isNotEmpty
            ? specialties.take(2).join(', ')
            : 'Fitness';
        final years = int.tryParse(yearsExperienceController.text) ?? 0;
        final imgUrl = data['avatar_url'] as String?;

        FcmNotificationSender().sendAdminBroadcast(
          title: 'New Trainer Joined!',
          body: '$name — $specs specialist.'
              '${years > 0 ? ' $years+ years experience.' : ''}'
              ' Check out their profile!',
          imageUrl: imgUrl,
        );
      }

      await loadTrainers();
      Get.back();
      Get.snackbar(
        'Success',
        isNewTrainer ? 'Trainer added' : 'Trainer updated',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('Save trainer error: $e');
      Get.snackbar(
        'Error',
        'Failed to save trainer',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    isSaving.value = false;
  }

  Future<void> deleteTrainer(String id) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Trainer'),
        content: const Text('Are you sure you want to delete this trainer?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!await ensureConnectivity()) return;

    try {
      await _supabase.from('trainers').delete().eq('id', id);
      trainers.removeWhere((t) => t.id == id);
      Get.snackbar(
        'Success',
        'Trainer deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete trainer',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    bioController.dispose();
    yearsExperienceController.dispose();
    instagramController.dispose();
    websiteController.dispose();
    super.onClose();
  }
}
