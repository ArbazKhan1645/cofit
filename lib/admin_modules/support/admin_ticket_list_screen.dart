import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/community_model.dart';
import '../../data/models/support_ticket_model.dart';
import '../../shared/widgets/cofit_image.dart';
import 'admin_support_controller.dart';

class AdminTicketListScreen extends GetView<AdminSupportController> {
  const AdminTicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: const Text('Support Center')),
      body: Column(
        children: [
          // Stats bar
          _buildStatsBar(context),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search tickets or users...',
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
            child: Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(context, 'All', 'all'),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                          context, 'Open (${controller.totalOpen})', 'open'),
                      const SizedBox(width: 8),
                      _buildFilterChip(context,
                          'In Progress (${controller.totalInProgress})', 'in_progress'),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, 'Resolved', 'resolved'),
                      const SizedBox(width: 8),
                      _buildFilterChip(context, 'Closed', 'closed'),
                    ],
                  ),
                )),
          ),
          const SizedBox(height: 10),
          // Ticket list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.tickets.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = controller.filteredTickets;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.message_question,
                          size: 64, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text('No tickets found',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.refreshTickets,
                child: ListView.separated(
                  padding: AppPadding.screen.copyWith(top: 4, bottom: 20),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _buildTicketCard(context, list[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ============================================
  // STATS BAR
  // ============================================

  Widget _buildStatsBar(BuildContext context) {
    return Obx(() => Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: [
              _buildStatChip(context, '${controller.totalOpen}', 'Open',
                  AppColors.info),
              const SizedBox(width: 10),
              _buildStatChip(context, '${controller.totalInProgress}',
                  'In Progress', AppColors.warning),
              const SizedBox(width: 10),
              _buildStatChip(context, '${controller.totalResolved}',
                  'Resolved', AppColors.success),
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
                    ?.copyWith(color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  // ============================================
  // FILTER CHIP
  // ============================================

  Widget _buildFilterChip(BuildContext context, String label, String value) {
    final selected = controller.filterStatus.value == value;
    return GestureDetector(
      onTap: () => controller.filterStatus.value = value,
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
  // TICKET CARD
  // ============================================

  Widget _buildTicketCard(BuildContext context, SupportTicketModel ticket) {
    return GestureDetector(
      onTap: () {
        controller.selectedTicket.value = ticket;
        controller.loadMessages(ticket.id);
        Get.toNamed(AppRoutes.adminTicketChat);
      },
      child: Container(
        padding: AppPadding.card,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User row + status
            Row(
              children: [
                _buildAvatar(ticket.user),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ticket.user?.displayName ?? 'Unknown',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                      Text(ticket.timeAgo,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
                ),
                _buildStatusBadge(context, ticket),
              ],
            ),
            const SizedBox(height: 10),
            // Subject
            Text(ticket.subject,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            // Last message preview
            if (ticket.lastMessage != null) ...[
              const SizedBox(height: 6),
              Text(
                ticket.lastMessage!.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 8),
            // Priority + screen ref
            Row(
              children: [
                if (ticket.priority != 'normal') ...[
                  _buildPriorityBadge(context, ticket),
                  const SizedBox(width: 8),
                ],
                if (ticket.screenReference != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Iconsax.mobile,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(ticket.screenReference!,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.textMuted)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(UserSummary? user) {
    if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CofitImage(imageUrl: user.avatarUrl!, width: 40, height: 40),
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.bgBlush,
      child: Text(
        user?.displayName.isNotEmpty == true
            ? user!.displayName[0].toUpperCase()
            : 'U',
        style: const TextStyle(
            color: AppColors.primary, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, SupportTicketModel ticket) {
    Color color;
    Color bgColor;

    if (ticket.isOpen) {
      color = AppColors.info;
      bgColor = AppColors.infoLight;
    } else if (ticket.isInProgress) {
      color = AppColors.warning;
      bgColor = AppColors.warningLight;
    } else if (ticket.isResolved) {
      color = AppColors.success;
      bgColor = AppColors.successLight;
    } else {
      color = AppColors.textMuted;
      bgColor = AppColors.bgCream;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.small,
      ),
      child: Text(ticket.statusLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color, fontWeight: FontWeight.w600, fontSize: 10)),
    );
  }

  Widget _buildPriorityBadge(BuildContext context, SupportTicketModel ticket) {
    Color color;
    if (ticket.priority == 'urgent') {
      color = AppColors.error;
    } else if (ticket.priority == 'high') {
      color = AppColors.warning;
    } else {
      color = AppColors.textMuted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.small,
      ),
      child: Text(ticket.priorityLabel,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color, fontWeight: FontWeight.w600, fontSize: 9)),
    );
  }
}
