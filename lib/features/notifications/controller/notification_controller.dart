import 'dart:async';
import 'package:cofit_collective/data/models/notification_model.dart';
import 'package:cofit_collective/features/community/controllers/community_controller.dart';
import 'package:cofit_collective/features/community/views/community_screen.dart';
import 'package:cofit_collective/features/notifications/controller/logger.dart';
import 'package:cofit_collective/features/notifications/controller/repo.dart';
import 'package:get/get.dart';

enum NotificationStatus { initial, loading, loaded, loadingMore, error }

class NotificationController extends GetxController {
  final INotificationRepository _repository;

  NotificationController({INotificationRepository? repository})
    : _repository = repository ?? NotificationRepository();

  // ─── OBSERVABLE STATE ─────────────────────────────────────────────────────

  final notifications = <NotificationModel>[].obs;
  final status = NotificationStatus.initial.obs;
  final errorMessage = RxnString();
  final unreadCount = 0.obs;
  final hasMore = true.obs;

  // ─── PRIVATE STATE ────────────────────────────────────────────────────────

  StreamSubscription<NotificationModel>? _newNotifSub;
  StreamSubscription<int>? _unreadCountSub;

  String? _currentUserId;
  static const int _pageSize = 30;
  static const String _tag = 'NotificationController';

  // ─── COMPUTED ─────────────────────────────────────────────────────────────

  bool get isLoading => status.value == NotificationStatus.loading;
  bool get isLoadingMore => status.value == NotificationStatus.loadingMore;
  bool get hasError => errorMessage.value != null;
  bool get hasUnread => unreadCount.value > 0;

  /// Returns notifications grouped by date bucket for the UI.
  /// Buckets: Today → Yesterday → Earlier This Week → Month Name → Older
  Map<String, List<NotificationModel>> get groupedNotifications {
    if (notifications.isEmpty) return {};

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final thisWeekStart = today.subtract(Duration(days: today.weekday - 1));

    final Map<String, List<NotificationModel>> groups = {};

    // LinkedHashMap-style insertion preserves display order
    for (final n in notifications) {
      final date = DateTime(
        n.createdAt.year,
        n.createdAt.month,
        n.createdAt.day,
      );

      final String key;
      if (date == today) {
        key = 'Today';
      } else if (date == yesterday) {
        key = 'Yesterday';
      } else if (!date.isBefore(thisWeekStart)) {
        key = 'Earlier This Week';
      } else if (date.year == now.year) {
        key = _monthName(date.month);
      } else {
        key = '${_monthName(date.month)} ${date.year}';
      }

      groups.putIfAbsent(key, () => []).add(n);
    }

    return groups;
  }

  static String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month];
  }

  // ─── LIFECYCLE ────────────────────────────────────────────────────────────

  /// Call once after user auth is confirmed.
  /// Safe to call multiple times — skips if same user already loaded.
  Future<void> initialize(String userId) async {
    if (_currentUserId == userId) return;
    _currentUserId = userId;

    _cancelSubscriptions();
    await _loadInitial(userId);
    _startRealtimeSubscriptions(userId);
  }

  void _startRealtimeSubscriptions(String userId) {
    // New INSERT → prepend to list + bump unread count
    _newNotifSub = _repository.newNotificationStream(userId).listen((
      notification,
    ) {
      AppLogger.d(_tag, 'Realtime INSERT: ${notification.id}');
      notifications.insert(0, notification);
      unreadCount.value += 1;
    }, onError: (e) => AppLogger.e(_tag, 'newNotificationStream error', e));

    // Unread count stream keeps badge consistent with DB truth
    _unreadCountSub = _repository.unreadCountStream(userId).listen((count) {
      AppLogger.d(_tag, 'Realtime unread count: $count');
      unreadCount.value = count;
    }, onError: (e) => AppLogger.e(_tag, 'unreadCountStream error', e));
  }

  void _cancelSubscriptions() {
    _newNotifSub?.cancel();
    _unreadCountSub?.cancel();
    _newNotifSub = null;
    _unreadCountSub = null;
  }

  @override
  void onClose() {
    _cancelSubscriptions();
    _repository.dispose();
    super.onClose();
  }

  // ─── DATA LOADING ─────────────────────────────────────────────────────────

  Future<void> _loadInitial(String userId) async {
    status.value = NotificationStatus.loading;
    errorMessage.value = null;

    try {
      // Parallel fetch — faster initial load
      final results = await Future.wait([
        _repository.fetchNotifications(userId: userId, limit: _pageSize),
        _repository.fetchUnreadCount(userId),
      ]);

      notifications.assignAll(results[0] as List<NotificationModel>);
      unreadCount.value = results[1] as int;
      hasMore.value = (results[0] as List).length == _pageSize;
      status.value = NotificationStatus.loaded;
    } on NotificationException catch (e) {
      AppLogger.e(_tag, 'Initial load failed', e);
      status.value = NotificationStatus.error;
      errorMessage.value = e.message;
    }
  }

  /// Pull-to-refresh — resets to page 0
  Future<void> refresh() async {
    if (_currentUserId == null) return;
    await _loadInitial(_currentUserId!);
  }

  /// Load next page (infinite scroll)
  Future<void> loadMore() async {
    if (_currentUserId == null) return;
    if (!hasMore.value) return;
    if (isLoadingMore) return;

    status.value = NotificationStatus.loadingMore;

    try {
      final more = await _repository.fetchNotifications(
        userId: _currentUserId!,
        limit: _pageSize,
        offset: notifications.length,
      );

      notifications.addAll(more);
      hasMore.value = more.length == _pageSize;
      status.value = NotificationStatus.loaded;
    } on NotificationException catch (e) {
      AppLogger.e(_tag, 'loadMore failed', e);
      // Don't show error state — keep existing list visible
      status.value = NotificationStatus.loaded;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  // ─── ACTIONS ──────────────────────────────────────────────────────────────

  /// Optimistic mark-as-read: updates UI instantly, syncs to DB async.
  Future<void> markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;
    if (notifications[index].isRead) return; // Already read — skip

    // Optimistic update
    final original = notifications[index];
    notifications[index] = original.copyWith(
      isRead: true,
      readAt: DateTime.now(),
    );
    if (unreadCount.value > 0) unreadCount.value -= 1;

    try {
      await _repository.markAsRead(notificationId);
    } on NotificationException catch (e) {
      AppLogger.e(_tag, 'markAsRead failed, reverting', e);
      // Revert on failure
      notifications[index] = original;
      unreadCount.value += 1;
      Get.snackbar(
        'Error',
        'Could not mark as read. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Optimistic mark-all-read: clears all unread dots in UI instantly.
  Future<void> markAllAsRead() async {
    if (_currentUserId == null) return;
    if (unreadCount.value == 0) return;

    // Snapshot for rollback
    final snapshot = notifications.toList();
    final prevCount = unreadCount.value;

    // Optimistic update
    final now = DateTime.now();
    notifications.assignAll(
      notifications
          .map((n) => n.isRead ? n : n.copyWith(isRead: true, readAt: now))
          .toList(),
    );
    unreadCount.value = 0;

    try {
      await _repository.markAllAsRead(_currentUserId!);
    } on NotificationException catch (e) {
      AppLogger.e(_tag, 'markAllAsRead failed, reverting', e);
      notifications.assignAll(snapshot);
      unreadCount.value = prevCount;
      Get.snackbar(
        'Error',
        'Could not mark all as read. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Optimistic delete: removes from UI instantly, syncs to DB async.
  Future<void> deleteNotification(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index == -1) return;

    final removed = notifications[index];
    notifications.removeAt(index);

    // If was unread — decrement badge
    if (!removed.isRead && unreadCount.value > 0) {
      unreadCount.value -= 1;
    }

    try {
      await _repository.deleteNotification(notificationId);
    } on NotificationException catch (e) {
      AppLogger.e(_tag, 'deleteNotification failed, restoring', e);
      notifications.insert(index, removed);
      if (!removed.isRead) unreadCount.value += 1;
      Get.snackbar(
        'Error',
        'Could not delete notification. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ─── NAVIGATION HANDLER ───────────────────────────────────────────────────

  /// Call on notification tap: marks as read + navigates to target screen.
  void onNotificationTap(NotificationModel notification) async {
    // Fire-and-forget read mark
    markAsRead(notification.id);

    if (notification.hasNavigation && notification.screenReference != null) {
      final ref = notification.screenReference!;
      handleScreenRoutes(ref.route, ref.resourceId ?? '');

      // Get.toNamed(ref.route, arguments: ref.navigationArguments);
    } else if (notification.hasExternalUrl) {
      // Handle via url_launcher in the screen layer if needed
      AppLogger.d(_tag, 'External URL: ${notification.externalUrl}');
    }
  }

  void handleScreenRoutes(String route, String refrenceId) async {
    if (route == '/post-detail') {
      await Get.find<CommunityController>().initializeFeed(refrenceId);
    }
  }
}
