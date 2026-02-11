import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/media/media_service.dart';
import '../../../data/models/user_model.dart';

class EditProfileController extends GetxController {
  final AuthService _authService = AuthService.to;

  // Text controllers
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final bioController = TextEditingController();
  final heightController = TextEditingController();
  final weightController = TextEditingController();
  final dobController = TextEditingController();

  // Rx fields
  final Rx<DateTime?> dateOfBirth = Rx<DateTime?>(null);
  final RxString gender = ''.obs;
  final RxString fitnessLevel = ''.obs;
  final RxInt workoutDaysPerWeek = 3.obs;
  final RxString preferredWorkoutTime = ''.obs;

  // State
  final RxBool isUploadingImage = false.obs;
  final RxBool isSaving = false.obs;
  final formKey = GlobalKey<FormState>();

  // Original values for change detection
  UserModel? _originalUser;

  @override
  void onInit() {
    super.onInit();
    _populateFromUser();
  }

  void _populateFromUser() {
    final user = _authService.currentUser;
    if (user == null) return;
    _originalUser = user;

    fullNameController.text = user.fullName ?? '';
    usernameController.text = user.username ?? '';
    bioController.text = user.bio ?? '';
    heightController.text =
        user.heightCm != null ? user.heightCm!.toStringAsFixed(0) : '';
    weightController.text =
        user.weightKg != null ? user.weightKg!.toStringAsFixed(0) : '';

    dateOfBirth.value = user.dateOfBirth;
    if (user.dateOfBirth != null) {
      dobController.text = DateFormat('MMM d, yyyy').format(user.dateOfBirth!);
    }

    gender.value = user.gender ?? '';
    fitnessLevel.value = user.fitnessLevel ?? '';
    workoutDaysPerWeek.value = user.workoutDaysPerWeek;
    preferredWorkoutTime.value = user.preferredWorkoutTime ?? '';
  }

  bool get hasChanges {
    if (_originalUser == null) return false;
    return fullNameController.text != (_originalUser!.fullName ?? '') ||
        usernameController.text != (_originalUser!.username ?? '') ||
        bioController.text != (_originalUser!.bio ?? '') ||
        heightController.text !=
            (_originalUser!.heightCm?.toStringAsFixed(0) ?? '') ||
        weightController.text !=
            (_originalUser!.weightKg?.toStringAsFixed(0) ?? '') ||
        dateOfBirth.value != _originalUser!.dateOfBirth ||
        gender.value != (_originalUser!.gender ?? '') ||
        fitnessLevel.value != (_originalUser!.fitnessLevel ?? '') ||
        workoutDaysPerWeek.value != _originalUser!.workoutDaysPerWeek ||
        preferredWorkoutTime.value !=
            (_originalUser!.preferredWorkoutTime ?? '');
  }

  Future<void> pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: dateOfBirth.value ?? DateTime(now.year - 25),
      firstDate: DateTime(1940),
      lastDate: now,
    );
    if (picked != null) {
      dateOfBirth.value = picked;
      dobController.text = DateFormat('MMM d, yyyy').format(picked);
    }
  }

  Future<void> uploadProfileImage() async {
    final bytes = await MediaService.to.pickImageFromGallery();
    if (bytes == null) return;

    isUploadingImage.value = true;
    try {
      final url = await MediaService.to.uploadProfileImage(bytes);
      await _authService.updateProfile(avatarUrl: url);
    } catch (_) {
      // Upload failed — user can retry
    }
    isUploadingImage.value = false;
  }

  Future<void> saveProfile() async {
    if (!formKey.currentState!.validate()) return;

    isSaving.value = true;
    final success = await _authService.updateProfile(
      fullName: fullNameController.text.trim(),
      username: usernameController.text.trim().isNotEmpty
          ? usernameController.text.trim()
          : null,
      bio: bioController.text.trim(),
      dateOfBirth: dateOfBirth.value,
      gender: gender.value.isNotEmpty ? gender.value : null,
      heightCm: double.tryParse(heightController.text),
      weightKg: double.tryParse(weightController.text),
      fitnessLevel: fitnessLevel.value.isNotEmpty ? fitnessLevel.value : null,
      workoutDaysPerWeek: workoutDaysPerWeek.value,
      preferredWorkoutTime:
          preferredWorkoutTime.value.isNotEmpty ? preferredWorkoutTime.value : null,
    );

    isSaving.value = false;

    if (success) {
      Get.back();
      Get.snackbar('Success', 'Profile updated',
          snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('Error', 'Failed to update profile',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    heightController.dispose();
    weightController.dispose();
    dobController.dispose();
    super.onClose();
  }
}
