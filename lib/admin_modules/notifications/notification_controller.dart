import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/media/media_service.dart';
import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/user_model.dart';
import '../../notifications/firebase_sender.dart';
import '../../shared/controllers/base_controller.dart';
import '../../shared/mixins/connectivity_mixin.dart';

class AdminNotificationController extends BaseController with ConnectivityMixin {
  final SupabaseService _supabase = SupabaseService.to;
  final FcmNotificationSender _fcmSender = FcmNotificationSender();

  // ============================================
  // FORM STATE
  // ============================================

  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  // Image
  final Rx<Uint8List?> selectedImageBytes = Rx<Uint8List?>(null);
  final RxBool isUploadingImage = false.obs;

  // Target mode: 'all' or 'specific'
  final RxString targetMode = 'all'.obs;

  // User selection (for specific mode)
  final RxList<UserModel> allUsers = <UserModel>[].obs;
  final RxList<UserModel> selectedUsers = <UserModel>[].obs;
  final RxString userSearchQuery = ''.obs;

  // Sending state
  final RxBool isSending = false.obs;

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
  }

  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    super.onClose();
  }

  // ============================================
  // USER LOADING
  // ============================================

  Future<void> _loadUsers() async {
    if (!await ensureConnectivity()) return;
    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('full_name');

      allUsers.value = (response as List)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (_) {}
  }

  List<UserModel> get filteredUsers {
    if (userSearchQuery.value.isEmpty) return allUsers;
    final q = userSearchQuery.value.toLowerCase();
    return allUsers
        .where((u) =>
            u.displayName.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q))
        .toList();
  }

  void toggleUserSelection(UserModel user) {
    final exists = selectedUsers.any((u) => u.id == user.id);
    if (exists) {
      selectedUsers.removeWhere((u) => u.id == user.id);
    } else {
      selectedUsers.add(user);
    }
  }

  bool isUserSelected(String userId) =>
      selectedUsers.any((u) => u.id == userId);

  void clearSelection() => selectedUsers.clear();

  // ============================================
  // IMAGE
  // ============================================

  Future<void> pickImage() async {
    final bytes = await MediaService.to.pickImageFromGallery();
    if (bytes != null) selectedImageBytes.value = bytes;
  }

  void removeImage() => selectedImageBytes.value = null;

  // ============================================
  // SEND
  // ============================================

  Future<void> sendNotification() async {
    final title = titleController.text.trim();
    final body = bodyController.text.trim();

    if (title.isEmpty) {
      Get.snackbar('Error', 'Title is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (body.isEmpty) {
      Get.snackbar('Error', 'Description is required',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (targetMode.value == 'specific' && selectedUsers.isEmpty) {
      Get.snackbar('Error', 'Please select at least one user',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (!await ensureConnectivity()) return;
    isSending.value = true;

    try {
      // Upload image if selected
      String? imageUrl;
      if (selectedImageBytes.value != null) {
        imageUrl =
            await MediaService.to.uploadPostImage(selectedImageBytes.value!);
      }

      // Build target user IDs (null = all users)
      final List<String>? targetUserIds = targetMode.value == 'specific'
          ? selectedUsers.map((u) => u.id).toList()
          : null;

      // Send via FCM
      final sentCount = await _fcmSender.sendAdminBroadcast(
        title: title,
        body: body,
        imageUrl: imageUrl,
        targetUserIds: targetUserIds,
      );

      // Reset form
      titleController.clear();
      bodyController.clear();
      selectedImageBytes.value = null;
      selectedUsers.clear();

      Get.snackbar(
        'Sent!',
        'Notification sent to $sentCount devices',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withValues(alpha: 0.1),
        colorText: AppColors.success,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to send notification: $e',
          snackPosition: SnackPosition.BOTTOM);
    }

    isSending.value = false;
  }

  // ============================================
  // CONFIRM DIALOG
  // ============================================

  void confirmSend() {
    final targetLabel = targetMode.value == 'all'
        ? 'ALL users'
        : '${selectedUsers.length} selected user${selectedUsers.length > 1 ? 's' : ''}';

    Get.dialog(
      AlertDialog(
        title: const Text('Send Notification'),
        content: Text(
          'Send this notification to $targetLabel?\n\n'
          'Title: ${titleController.text.trim()}\n'
          'Body: ${bodyController.text.trim()}',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              sendNotification();
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
