import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/crash_log_model.dart';
import 'crashlytics_controller.dart';

class CrashlyticsListScreen extends GetView<AdminCrashlyticsController> {
  const CrashlyticsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Crashlytics'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.trash),
            onPressed: () => controller.showClearAllDialog(),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats cards
          _buildStatsSection(context),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search errors, users, routes...',
                prefixIcon: const Icon(Iconsax.search_normal),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.medium,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Filter chips
          Padding(
            padding: AppPadding.horizontal,
            child: Obx(() => Row(
                  children: [
                    _buildFilterChip(context, 'All', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        context, 'Crashes (${controller.totalCrashes})', 'crash'),
                    const SizedBox(width: 8),
                    _buildFilterChip(context,
                        'Exceptions (${controller.totalExceptions})', 'exception'),
                  ],
                )),
          ),
          const SizedBox(height: 10),
          // Error type breakdown
          _buildErrorTypeBar(context),
          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.crashLogs.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = controller.filteredLogs;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.shield_tick,
                          size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text('No crash logs',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppColors.textMuted)),
                      const SizedBox(height: 8),
                      Text('Your app is running smoothly!',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refreshLogs,
                child: ListView.separated(
                  padding: AppPadding.screen.copyWith(top: 4, bottom: 20),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _buildCrashCard(context, list[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ============================================
  // STATS SECTION
  // ============================================

  Widget _buildStatsSection(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              _buildStatChip(context, '${controller.crashLogs.length}', 'Total',
                  AppColors.info),
              const SizedBox(width: 10),
              _buildStatChip(context, '${controller.totalCrashes}', 'Crashes',
                  AppColors.error),
              const SizedBox(width: 10),
              _buildStatChip(context, '${controller.totalToday}', 'Today',
                  AppColors.warning),
              const SizedBox(width: 10),
              _buildStatChip(context, '${controller.totalThisWeek}', 'This Week',
                  AppColors.success),
            ],
          ),
        ));
  }

  Widget _buildStatChip(
      BuildContext context, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.medium,
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          children: [
            Text(value,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // ============================================
  // ERROR TYPE BREAKDOWN BAR
  // ============================================

  Widget _buildErrorTypeBar(BuildContext context) {
    return Obx(() {
      final breakdown = controller.errorTypeBreakdown;
      if (breakdown.isEmpty) return const SizedBox.shrink();

      return Container(
        height: 36,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: breakdown.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final entry = breakdown.entries.elementAt(index);
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: AppRadius.pill,
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(entry.key,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary)),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: AppRadius.pill,
                    ),
                    child: Text('${entry.value}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                            fontSize: 10)),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  // ============================================
  // FILTER CHIP
  // ============================================

  Widget _buildFilterChip(BuildContext context, String label, String value) {
    final selected = controller.filterType.value == value;
    return GestureDetector(
      onTap: () => controller.filterType.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: AppRadius.pill,
          boxShadow: selected ? [] : AppShadows.subtle,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  // ============================================
  // CRASH CARD
  // ============================================

  Widget _buildCrashCard(BuildContext context, CrashLogModel log) {
    return GestureDetector(
      onTap: () {
        controller.selectedCrash.value = log;
        Get.toNamed(AppRoutes.adminCrashlyticsDetail);
      },
      child: Container(
        padding: AppPadding.card,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
          border: log.fatal
              ? Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: severity badge + time + delete
            Row(
              children: [
                _buildSeverityBadge(context, log),
                const SizedBox(width: 8),
                _buildSourceBadge(context, log),
                const Spacer(),
                Text(log.timeAgo,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.textMuted)),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => controller.showDeleteDialog(log.id),
                  child: const Icon(Iconsax.trash, size: 16, color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Error type
            Text(
              log.shortErrorType,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Error message preview
            Text(
              log.errorMessage,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            // Footer: user + platform + route
            Row(
              children: [
                if (log.userName != null) ...[
                  const Icon(Iconsax.user, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(log.displayName,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.textMuted)),
                  const SizedBox(width: 12),
                ],
                if (log.platform != null) ...[
                  Icon(
                    log.platform == 'ios' ? Iconsax.mobile : Iconsax.mobile,
                    size: 12,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(log.platform!,
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(color: AppColors.textMuted)),
                  const SizedBox(width: 12),
                ],
                if (log.screenRoute != null) ...[
                  const Icon(Iconsax.monitor, size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(log.screenRoute!,
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.textMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBadge(BuildContext context, CrashLogModel log) {
    final isFatal = log.fatal;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isFatal ? AppColors.errorLight : AppColors.warningLight,
        borderRadius: AppRadius.small,
      ),
      child: Text(
        log.severityLabel,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: isFatal ? AppColors.error : AppColors.warning,
            fontWeight: FontWeight.w700,
            fontSize: 10),
      ),
    );
  }

  Widget _buildSourceBadge(BuildContext context, CrashLogModel log) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.infoLight,
        borderRadius: AppRadius.small,
      ),
      child: Text(
        log.source,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.info, fontWeight: FontWeight.w600, fontSize: 10),
      ),
    );
  }
}
