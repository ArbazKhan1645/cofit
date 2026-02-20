import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../app/routes/app_routes.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import 'dashboard/admin_dashboard_controller.dart';
import 'dashboard/widgets/admin_drawer.dart';

class AdminHomeScreen extends GetView<AdminDashboardController> {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // Back from admin → clear admin stack, go fresh to main with data refresh
        Get.offAllNamed(AppRoutes.main);
      },
      child: Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Iconsax.menu_1),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: controller.refreshDashboard,
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.totalUsers.value == 0 &&
            controller.totalPosts.value == 0) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.refreshDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppPadding.screen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildWelcomeHeader(context),
                const SizedBox(height: 12),
                _buildStatsCards(context),
                const SizedBox(height: 12),
                _buildUserBreakdownChart(context),
                const SizedBox(height: 12),
                _buildPostStatusChart(context),
                const SizedBox(height: 12),
                _buildSubscriptionSection(context),
                const SizedBox(height: 12),
                _buildWorkoutStatsCards(context),
                const SizedBox(height: 12),
                _buildWorkoutDifficultyChart(context),
                const SizedBox(height: 12),
                _buildWorkoutCategoryChart(context),
                const SizedBox(height: 12),
                _buildChallengeStatsCards(context),
                const SizedBox(height: 12),
                _buildAchievementStatsCards(context),
                const SizedBox(height: 12),
                _buildQuickActions(context),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      }),
    ),
    );
  }

  // ============================================
  // WELCOME HEADER
  // ============================================

  Widget _buildWelcomeHeader(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : (hour < 17 ? 'Good afternoon' : 'Good evening');

    return Container(
      width: double.infinity,
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.primaryGlow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting,',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.adminName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Here's your app overview",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: AppRadius.medium,
            ),
            child: const Icon(Iconsax.status_up, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  // ============================================
  // STATS CARDS (2x2 grid)
  // ============================================

  Widget _buildStatsCards(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Row(
            children: [
              _buildStatCard(
                context,
                '${controller.totalUsers.value + controller.totalAdmins.value}',
                'Total Users',
                Iconsax.people,
                AppColors.peach,
              ),
              const SizedBox(width: 4),
              _buildStatCard(
                context,
                '${controller.activeSubscriptions.value}',
                'Active Subs',
                Iconsax.crown_1,
                AppColors.sunnyYellow,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildStatCard(
                context,
                '${controller.totalPosts.value}',
                'Total Posts',
                Iconsax.document_text,
                AppColors.lavender,
              ),
              const SizedBox(width: 4),
              _buildStatCard(
                context,
                '${controller.openTickets.value}',
                'Open Tickets',
                Iconsax.message_question,
                AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.small,
          boxShadow: AppShadows.subtle,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.medium,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // USER BREAKDOWN PIE CHART
  // ============================================

  Widget _buildUserBreakdownChart(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Breakdown',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final users = controller.totalUsers.value;
            final admins = controller.totalAdmins.value;
            final banned = controller.bannedUsers.value;
            final total = users + admins + banned;

            if (total == 0) {
              return SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    'No user data yet',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 40,
                        sections: [
                          if (users > 0)
                            PieChartSectionData(
                              value: users.toDouble(),
                              title: '$users',
                              color: AppColors.mintFresh,
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          if (admins > 0)
                            PieChartSectionData(
                              value: admins.toDouble(),
                              title: '$admins',
                              color: AppColors.lavender,
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          if (banned > 0)
                            PieChartSectionData(
                              value: banned.toDouble(),
                              title: '$banned',
                              color: AppColors.softRose,
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(
                          context,
                          'Users',
                          AppColors.mintFresh,
                          users,
                        ),
                        const SizedBox(height: 14),
                        _buildLegendItem(
                          context,
                          'Admins',
                          AppColors.lavender,
                          admins,
                        ),
                        const SizedBox(height: 14),
                        _buildLegendItem(
                          context,
                          'Banned',
                          AppColors.softRose,
                          banned,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    int count,
  ) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Text(
          '$count',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  // ============================================
  // POST STATUS BAR CHART
  // ============================================

  Widget _buildPostStatusChart(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Post Status',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final pending = controller.pendingPosts.value;
            final approved = controller.approvedPosts.value;
            final rejected = controller.rejectedPosts.value;
            final vals = [pending, approved, rejected];
            final maxVal = vals.reduce((a, b) => a > b ? a : b);

            return SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal > 0 ? maxVal * 1.3 : 10,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final labels = ['Pending', 'Approved', 'Rejected'];
                          if (value.toInt() >= 0 &&
                              value.toInt() < labels.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                labels[value.toInt()],
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(color: AppColors.textMuted),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _makeBarGroup(0, pending.toDouble(), AppColors.sunnyYellow),
                    _makeBarGroup(1, approved.toDouble(), AppColors.mintFresh),
                    _makeBarGroup(2, rejected.toDouble(), AppColors.softRose),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 32,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
      ],
    );
  }

  // ============================================
  // SUBSCRIPTIONS
  // ============================================

  Widget _buildSubscriptionSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subscriptions',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          Obx(() {
            final total =
                controller.totalUsers.value + controller.totalAdmins.value;
            final activePercent = total > 0
                ? controller.activeSubscriptions.value / total
                : 0.0;
            final freePercent = total > 0
                ? controller.freeUsers.value / total
                : 0.0;

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCircularIndicator(
                  context,
                  label: 'Active',
                  count: '${controller.activeSubscriptions.value}',
                  percent: activePercent,
                  color: AppColors.mintFresh,
                ),
                _buildCircularIndicator(
                  context,
                  label: 'Free',
                  count: '${controller.freeUsers.value}',
                  percent: freePercent,
                  color: AppColors.skyBlue,
                ),
                _buildCircularIndicator(
                  context,
                  label: 'Revenue',
                  count: '\$0',
                  percent: 0.0,
                  color: AppColors.sunnyYellow,
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCircularIndicator(
    BuildContext context, {
    required String label,
    required String count,
    required double percent,
    required Color color,
  }) {
    return Column(
      children: [
        CircularPercentIndicator(
          radius: 40.0,
          lineWidth: 8.0,
          percent: percent.clamp(0.0, 1.0),
          center: Text(
            count,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          progressColor: color,
          backgroundColor: color.withValues(alpha: 0.15),
          circularStrokeCap: CircularStrokeCap.round,
          animation: true,
          animationDuration: 800,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }

  // ============================================
  // WORKOUT STATS CARDS
  // ============================================

  Widget _buildWorkoutStatsCards(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Workout Overview',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Column(
            children: [
              Row(
                children: [
                  _buildStatCard(
                    context,
                    '${controller.totalWorkouts.value}',
                    'Total Workouts',
                    Iconsax.weight,
                    AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context,
                    '${controller.activeWorkouts.value}',
                    'Active',
                    Iconsax.tick_circle,
                    AppColors.mintFresh,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatCard(
                    context,
                    '${controller.premiumWorkouts.value}',
                    'Premium',
                    Iconsax.crown_1,
                    AppColors.sunnyYellow,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    context,
                    '${controller.totalCompletions.value}',
                    'Completions',
                    Iconsax.chart_2,
                    AppColors.lavender,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================
  // WORKOUT DIFFICULTY PIE CHART
  // ============================================

  Widget _buildWorkoutDifficultyChart(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Difficulty Breakdown',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final beginner = controller.beginnerWorkouts.value;
            final intermediate = controller.intermediateWorkouts.value;
            final advanced = controller.advancedWorkouts.value;
            final total = beginner + intermediate + advanced;

            if (total == 0) {
              return SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    'No workout data yet',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ),
              );
            }

            return SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 40,
                        sections: [
                          if (beginner > 0)
                            PieChartSectionData(
                              value: beginner.toDouble(),
                              title: '$beginner',
                              color: AppColors.mintFresh,
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          if (intermediate > 0)
                            PieChartSectionData(
                              value: intermediate.toDouble(),
                              title: '$intermediate',
                              color: AppColors.sunnyYellow,
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          if (advanced > 0)
                            PieChartSectionData(
                              value: advanced.toDouble(),
                              title: '$advanced',
                              color: AppColors.softRose,
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(
                          context,
                          'Beginner',
                          AppColors.mintFresh,
                          beginner,
                        ),
                        const SizedBox(height: 14),
                        _buildLegendItem(
                          context,
                          'Intermediate',
                          AppColors.sunnyYellow,
                          intermediate,
                        ),
                        const SizedBox(height: 14),
                        _buildLegendItem(
                          context,
                          'Advanced',
                          AppColors.softRose,
                          advanced,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================
  // WORKOUT CATEGORY BAR CHART
  // ============================================

  Widget _buildWorkoutCategoryChart(BuildContext context) {
    const categoryLabels = {
      'full_body': 'Full Body',
      'upper_body': 'Upper',
      'lower_body': 'Lower',
      'core': 'Core',
      'cardio': 'Cardio',
      'hiit': 'HIIT',
      'yoga': 'Yoga',
      'pilates': 'Pilates',
    };

    const categoryColors = [
      AppColors.primary,
      AppColors.peach,
      AppColors.mintFresh,
      AppColors.sunnyYellow,
      AppColors.lavender,
      AppColors.skyBlue,
      AppColors.softRose,
      AppColors.info,
    ];

    return Container(
      width: double.infinity,
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workouts by Category',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          Obx(() {
            final catMap = controller.categoryBreakdown;
            if (catMap.isEmpty) {
              return SizedBox(
                height: 160,
                child: Center(
                  child: Text(
                    'No workout data yet',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ),
              );
            }

            final entries = categoryLabels.entries.toList();
            final groups = <BarChartGroupData>[];
            double maxVal = 0;

            for (int i = 0; i < entries.length; i++) {
              final count = (catMap[entries[i].key] ?? 0).toDouble();
              if (count > maxVal) maxVal = count;
              groups.add(
                _makeBarGroup(
                  i,
                  count,
                  categoryColors[i % categoryColors.length],
                ),
              );
            }

            return SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxVal > 0 ? maxVal * 1.3 : 10,
                  barTouchData: BarTouchData(enabled: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx >= 0 && idx < entries.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                entries[idx].value,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: AppColors.textMuted,
                                      fontSize: 9,
                                    ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: groups,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================
  // QUICK ACTIONS
  // ============================================

  Widget _buildChallengeStatsCards(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challenge Stats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard(
                  context,
                  '${controller.totalChallenges.value}',
                  'Total Challenges',
                  Iconsax.cup,
                  AppColors.lavender,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  '${controller.activeChallengesCount.value}',
                  'Active',
                  Iconsax.flag,
                  AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard(
                  context,
                  '${controller.totalChallengeParticipants.value}',
                  'Participants',
                  Iconsax.people,
                  AppColors.skyBlue,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  '${controller.totalChallengeCompletions.value}',
                  'Completions',
                  Iconsax.tick_circle,
                  AppColors.mintFresh,
                ),
              ],
            ),
          ],
        ));
  }

  // ============================================
  // ACHIEVEMENT STATS
  // ============================================

  Widget _buildAchievementStatsCards(BuildContext context) {
    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Achievement Stats',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard(
                  context,
                  '${controller.totalAchievements.value}',
                  'Total',
                  Iconsax.medal_star,
                  AppColors.lavender,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  '${controller.activeAchievementsCount.value}',
                  'Active',
                  Iconsax.tick_circle,
                  AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard(
                  context,
                  '${controller.totalAchievementCompletions.value}',
                  'Completions',
                  Iconsax.star_1,
                  AppColors.skyBlue,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  context,
                  '${controller.totalUsersWithProgress.value}',
                  'Users Tracking',
                  Iconsax.people,
                  AppColors.mintFresh,
                ),
              ],
            ),
          ],
        ));
  }

  // ============================================

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Obx(
          () => Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  title: 'Pending Posts',
                  count: controller.pendingPosts.value,
                  icon: Iconsax.document_text,
                  color: AppColors.sunnyYellow,
                  onTap: () => Get.toNamed(AppRoutes.adminCommunity),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  title: 'Open Tickets',
                  count: controller.openTickets.value,
                  icon: Iconsax.message_question,
                  color: AppColors.primary,
                  onTap: () => Get.toNamed(AppRoutes.adminSupport),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: AppPadding.card,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
          border: count > 0
              ? Border.all(color: color.withValues(alpha: 0.3), width: 1.5)
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: AppRadius.medium,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: count > 0 ? color : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
