import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../data/models/user_model.dart';
import '../../shared/controllers/base_controller.dart';

class AdminUsersController extends BaseController {
  final SupabaseService _supabase = SupabaseService.to;

  // ============================================
  // STATE
  // ============================================

  final RxList<UserModel> users = <UserModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString filterType = 'all'.obs; // all, user, admin, banned

  // Detail view
  final Rx<UserModel?> selectedUser = Rx<UserModel?>(null);

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  // ============================================
  // COMPUTED
  // ============================================

  List<UserModel> get filteredUsers {
    var list = users.toList();

    // Filter by type
    switch (filterType.value) {
      case 'user':
        list = list.where((u) => u.userType == 'user' && !u.isBanned).toList();
        break;
      case 'admin':
        list = list.where((u) => u.userType == 'admin').toList();
        break;
      case 'banned':
        list = list.where((u) => u.isBanned).toList();
        break;
    }

    // Search
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where((u) =>
              u.displayName.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q) ||
              (u.username?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return list;
  }

  int get totalUsers => users.where((u) => u.userType == 'user').length;
  int get totalAdmins => users.where((u) => u.userType == 'admin').length;
  int get totalBanned => users.where((u) => u.isBanned).length;

  // ============================================
  // LOAD DATA
  // ============================================

  Future<void> loadUsers() async {
    setLoading(true);
    try {
      final response = await _supabase
          .from('users')
          .select()
          .order('created_at', ascending: false);
      users.value = (response as List)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  }

  Future<void> refreshUsers() async => loadUsers();

  // ============================================
  // BAN / UNBAN
  // ============================================

  Future<void> toggleBan(UserModel user) async {
    final newBanned = !user.isBanned;
    final action = newBanned ? 'Ban' : 'Unban';

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('$action ${user.displayName}?'),
        content: Text(
          newBanned
              ? 'This user will be banned and unable to access the app.'
              : 'This user will be unbanned and can access the app again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: newBanned
                ? ElevatedButton.styleFrom(backgroundColor: Colors.red)
                : null,
            child: Text(action),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _supabase
          .from('users')
          .update({
            'is_banned': newBanned,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', user.id);

      // Update local state
      final index = users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        users[index] = users[index].copyWith(isBanned: newBanned);
        users.refresh();
      }
      if (selectedUser.value?.id == user.id) {
        selectedUser.value = selectedUser.value!.copyWith(isBanned: newBanned);
      }

      Get.snackbar(
        'Success',
        '${user.displayName} has been ${newBanned ? 'banned' : 'unbanned'}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to $action user',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ============================================
  // DELETE USER
  // ============================================

  Future<void> deleteUser(UserModel user) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete User Account?'),
        content: Text(
          'This will permanently delete ${user.displayName}\'s account and all their data. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await _supabase.from('users').delete().eq('id', user.id);
      users.removeWhere((u) => u.id == user.id);

      Get.snackbar(
        'Success',
        '${user.displayName}\'s account has been deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete user',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
