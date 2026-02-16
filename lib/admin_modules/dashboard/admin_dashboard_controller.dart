import 'package:get/get.dart';

import '../../core/services/auth_service.dart';
import '../../core/services/supabase_service.dart';
import '../../shared/controllers/base_controller.dart';

class AdminDashboardController extends BaseController {
  final SupabaseService _supabase = SupabaseService.to;

  // ============================================
  // USER STATS
  // ============================================
  final RxInt totalUsers = 0.obs;
  final RxInt totalAdmins = 0.obs;
  final RxInt bannedUsers = 0.obs;
  final RxInt activeSubscriptions = 0.obs;
  final RxInt freeUsers = 0.obs;

  // ============================================
  // POST STATS
  // ============================================
  final RxInt totalPosts = 0.obs;
  final RxInt pendingPosts = 0.obs;
  final RxInt approvedPosts = 0.obs;
  final RxInt rejectedPosts = 0.obs;

  // ============================================
  // SUPPORT STATS
  // ============================================
  final RxInt openTickets = 0.obs;
  final RxInt inProgressTickets = 0.obs;
  final RxInt resolvedTickets = 0.obs;

  // ============================================
  // CONTENT STATS
  // ============================================
  final RxInt activeTrainers = 0.obs;
  final RxInt activeWorkouts = 0.obs;

  // ============================================
  // WORKOUT STATS
  // ============================================
  final RxInt totalWorkouts = 0.obs;
  final RxInt premiumWorkouts = 0.obs;
  final RxInt freeWorkouts = 0.obs;
  final RxInt totalCompletions = 0.obs;
  final RxDouble avgRating = 0.0.obs;

  // Difficulty breakdown
  final RxInt beginnerWorkouts = 0.obs;
  final RxInt intermediateWorkouts = 0.obs;
  final RxInt advancedWorkouts = 0.obs;

  // Category breakdown
  final RxMap<String, int> categoryBreakdown = <String, int>{}.obs;

  // ============================================
  // CHALLENGE STATS
  // ============================================
  final RxInt totalChallenges = 0.obs;
  final RxInt activeChallengesCount = 0.obs;
  final RxInt totalChallengeParticipants = 0.obs;
  final RxInt totalChallengeCompletions = 0.obs;

  // ============================================
  // ADMIN INFO
  // ============================================
  String get adminName =>
      AuthService.to.currentUser?.fullName ?? 'Admin';

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // ============================================
  // LOAD DATA
  // ============================================

  Future<void> loadDashboardData() async {
    setLoading(true);
    try {
      await Future.wait([
        _loadUserStats(),
        _loadPostStats(),
        _loadSupportStats(),
        _loadContentStats(),
        _loadChallengeStats(),
      ]);
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  }

  Future<void> _loadUserStats() async {
    final response = await _supabase
        .from('users')
        .select('id, user_type, is_banned, subscription_status');

    final users = response as List;
    totalUsers.value = users.where((u) => u['user_type'] == 'user').length;
    totalAdmins.value = users.where((u) => u['user_type'] == 'admin').length;
    bannedUsers.value = users.where((u) => u['is_banned'] == true).length;
    activeSubscriptions.value =
        users.where((u) => u['subscription_status'] == 'active').length;
    freeUsers.value = users
        .where((u) =>
            u['subscription_status'] == null ||
            u['subscription_status'] == 'free')
        .length;
  }

  Future<void> _loadPostStats() async {
    final response = await _supabase
        .from('posts')
        .select('id, approval_status');

    final posts = response as List;
    totalPosts.value = posts.length;
    pendingPosts.value =
        posts.where((p) => p['approval_status'] == 'pending').length;
    approvedPosts.value =
        posts.where((p) => p['approval_status'] == 'approved').length;
    rejectedPosts.value =
        posts.where((p) => p['approval_status'] == 'rejected').length;
  }

  Future<void> _loadSupportStats() async {
    final response = await _supabase
        .from('support_tickets')
        .select('id, status');

    final tickets = response as List;
    openTickets.value =
        tickets.where((t) => t['status'] == 'open').length;
    inProgressTickets.value =
        tickets.where((t) => t['status'] == 'in_progress').length;
    resolvedTickets.value =
        tickets.where((t) => t['status'] == 'resolved').length;
  }

  Future<void> _loadContentStats() async {
    final trainersRes = await _supabase
        .from('trainers')
        .select('id')
        .eq('is_active', true);
    activeTrainers.value = (trainersRes as List).length;

    final workoutsRes = await _supabase.from('workouts').select(
        'id, difficulty, category, is_premium, is_active, total_completions, average_rating');

    final workouts = workoutsRes as List;
    totalWorkouts.value = workouts.length;
    activeWorkouts.value =
        workouts.where((w) => w['is_active'] == true).length;
    premiumWorkouts.value =
        workouts.where((w) => w['is_premium'] == true).length;
    freeWorkouts.value =
        workouts.where((w) => w['is_premium'] != true).length;

    // Completions & rating
    int completionsSum = 0;
    double ratingSum = 0;
    int ratedCount = 0;
    for (final w in workouts) {
      completionsSum += (w['total_completions'] as int?) ?? 0;
      final r = (w['average_rating'] as num?)?.toDouble() ?? 0.0;
      if (r > 0) {
        ratingSum += r;
        ratedCount++;
      }
    }
    totalCompletions.value = completionsSum;
    avgRating.value = ratedCount > 0 ? ratingSum / ratedCount : 0.0;

    // Difficulty breakdown
    beginnerWorkouts.value =
        workouts.where((w) => w['difficulty'] == 'beginner').length;
    intermediateWorkouts.value =
        workouts.where((w) => w['difficulty'] == 'intermediate').length;
    advancedWorkouts.value =
        workouts.where((w) => w['difficulty'] == 'advanced').length;

    // Category breakdown
    final catMap = <String, int>{};
    for (final w in workouts) {
      final cat = (w['category'] as String?) ?? 'other';
      catMap[cat] = (catMap[cat] ?? 0) + 1;
    }
    categoryBreakdown.value = catMap;
  }

  Future<void> _loadChallengeStats() async {
    final challengesRes =
        await _supabase.from('challenges').select('id, status');
    final challenges = challengesRes as List;
    totalChallenges.value = challenges.length;
    activeChallengesCount.value =
        challenges.where((c) => c['status'] == 'active').length;

    final participantsRes = await _supabase
        .from('user_challenges')
        .select('id, is_completed');
    final participants = participantsRes as List;
    totalChallengeParticipants.value = participants.length;
    totalChallengeCompletions.value =
        participants.where((p) => p['is_completed'] == true).length;
  }

  Future<void> refreshDashboard() async => loadDashboardData();
}
