import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/crash_log_model.dart';
import '../../shared/controllers/base_controller.dart';
import '../../shared/mixins/connectivity_mixin.dart';

class AdminCrashlyticsController extends BaseController with ConnectivityMixin {
  final SupabaseService _supabase = SupabaseService.to;

  // ============================================
  // STATE
  // ============================================

  final RxList<CrashLogModel> crashLogs = <CrashLogModel>[].obs;
  final RxString filterType = 'all'.obs; // all, crash, exception
  final RxString searchQuery = ''.obs;
  final Rx<CrashLogModel?> selectedCrash = Rx<CrashLogModel?>(null);

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void onInit() {
    super.onInit();
    loadCrashLogs();
  }

  // ============================================
  // COMPUTED — STATISTICS
  // ============================================

  int get totalCrashes => crashLogs.where((c) => c.fatal).length;
  int get totalExceptions => crashLogs.where((c) => !c.fatal).length;
  int get totalToday {
    final now = DateTime.now();
    return crashLogs
        .where(
          (c) =>
              c.createdAt.year == now.year &&
              c.createdAt.month == now.month &&
              c.createdAt.day == now.day,
        )
        .length;
  }

  int get totalThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return crashLogs.where((c) => c.createdAt.isAfter(weekStart)).length;
  }

  /// Top error types grouped by frequency
  Map<String, int> get errorTypeBreakdown {
    final map = <String, int>{};
    for (final log in crashLogs) {
      map[log.shortErrorType] = (map[log.shortErrorType] ?? 0) + 1;
    }
    // Sort by frequency descending
    final sorted = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sorted.take(10));
  }

  /// Platform breakdown
  Map<String, int> get platformBreakdown {
    final map = <String, int>{};
    for (final log in crashLogs) {
      final p = log.platform ?? 'unknown';
      map[p] = (map[p] ?? 0) + 1;
    }
    return map;
  }

  List<CrashLogModel> get filteredLogs {
    var list = crashLogs.toList();

    // Filter by type
    if (filterType.value == 'crash') {
      list = list.where((c) => c.fatal).toList();
    } else if (filterType.value == 'exception') {
      list = list.where((c) => !c.fatal).toList();
    }

    // Search
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where(
            (c) =>
                c.errorType.toLowerCase().contains(q) ||
                c.errorMessage.toLowerCase().contains(q) ||
                (c.userName?.toLowerCase().contains(q) ?? false) ||
                (c.screenRoute?.toLowerCase().contains(q) ?? false),
          )
          .toList();
    }

    return list;
  }

  // ============================================
  // LOAD DATA
  // ============================================

  Future<void> loadCrashLogs() async {
    if (!await ensureConnectivity()) return;
    setLoading(true);
    try {
      // Try with user join first (needs FK to public.users)
      final response = await _supabase.client
          .from('crash_logs')
          .select('*, users(id, full_name, email, avatar_url)')
          .order('created_at', ascending: false)
          .limit(500);

      crashLogs.value = (response as List)
          .map((json) => CrashLogModel.fromJson(json as Map<String, dynamic>))
          .toList();
      setSuccess();
    } catch (e) {
      debugPrint('Crashlytics join query failed: $e');
      // Fallback: load without user join (FK might reference auth.users instead of public.users)
      try {
        final response = await _supabase.client
            .from('crash_logs')
            .select('*')
            .order('created_at', ascending: false)
            .limit(500);

        crashLogs.value = (response as List)
            .map((json) => CrashLogModel.fromJson(json as Map<String, dynamic>))
            .toList();
        setSuccess();
      } catch (e2) {
        debugPrint('Crashlytics load failed: $e2');
        setError(e2.toString());
      }
    }
    setLoading(false);
  }

  Future<void> refreshLogs() async => loadCrashLogs();

  // ============================================
  // DELETE
  // ============================================

  Future<void> deleteCrashLog(String id) async {
    if (!await ensureConnectivity()) return;
    try {
      await _supabase.client.from('crash_logs').delete().eq('id', id);
      crashLogs.removeWhere((c) => c.id == id);
      Get.back();
      Get.snackbar(
        'Deleted',
        'Crash log removed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete log',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> clearAllLogs() async {
    if (!await ensureConnectivity()) return;
    try {
      await _supabase.client
          .from('crash_logs')
          .delete()
          .neq('id', '00000000-0000-0000-0000-000000000000');
      crashLogs.clear();
      Get.snackbar(
        'Cleared',
        'All crash logs deleted',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print(e);
      Get.snackbar(
        'Error',
        'Failed to clear logs',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void showClearAllDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All Logs'),
        content: const Text(
          'Are you sure you want to delete all crash logs? This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              clearAllLogs();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void showDeleteDialog(String id) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Log'),
        content: const Text('Delete this crash log entry?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              deleteCrashLog(id);
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
