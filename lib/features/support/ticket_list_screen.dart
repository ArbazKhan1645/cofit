import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../app/routes/app_routes.dart';
import '../../core/services/support_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/support_ticket_model.dart';
import 'support_controller.dart';

class TicketListScreen extends GetView<SupportController> {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: const Text('Help Center')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => SupportService.showRaiseTicketSheet(),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Iconsax.add),
        label: const Text('New Ticket',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.tickets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.tickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.message_question,
                    size: 64, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text('No tickets yet',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: AppColors.textMuted)),
                const SizedBox(height: 8),
                Text('Tap + to raise a new ticket',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textDisabled)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.refreshTickets,
          child: ListView.separated(
            padding: AppPadding.screen.copyWith(top: 16, bottom: 80),
            itemCount: controller.tickets.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _buildTicketCard(context, controller.tickets[index]),
          ),
        );
      }),
    );
  }

  Widget _buildTicketCard(BuildContext context, SupportTicketModel ticket) {
    return GestureDetector(
      onTap: () {
        controller.selectedTicket.value = ticket;
        controller.loadMessages(ticket.id);
        Get.toNamed(AppRoutes.supportChat);
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
            // Subject + status
            Row(
              children: [
                Expanded(
                  child: Text(ticket.subject,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ),
                _buildStatusBadge(context, ticket),
              ],
            ),
            const SizedBox(height: 8),
            // Last message preview
            if (ticket.lastMessage != null)
              Text(
                ticket.lastMessage!.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            const SizedBox(height: 8),
            // Time + priority
            Row(
              children: [
                Icon(Iconsax.clock, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(ticket.timeAgo,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.textMuted)),
                const Spacer(),
                if (ticket.priority != 'normal') _buildPriorityBadge(context, ticket),
              ],
            ),
          ],
        ),
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
