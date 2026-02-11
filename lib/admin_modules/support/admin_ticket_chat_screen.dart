import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/support_ticket_model.dart';
import 'admin_support_controller.dart';

class AdminTicketChatScreen extends GetView<AdminSupportController> {
  const AdminTicketChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ticket = controller.selectedTicket.value;
      if (ticket == null) {
        return const Scaffold(
          body: Center(child: Text('No ticket selected')),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.bgCream,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(ticket.subject,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              Text(
                '${ticket.user?.displayName ?? 'Unknown'} • ${ticket.statusLabel}',
                style: TextStyle(
                  fontSize: 12,
                  color: _statusColor(ticket),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (val) =>
                  controller.updateStatus(ticket.id, val),
              itemBuilder: (_) => [
                if (!ticket.isInProgress)
                  const PopupMenuItem(
                    value: 'in_progress',
                    child: Row(children: [
                      Icon(Iconsax.timer_1, size: 18, color: AppColors.warning),
                      SizedBox(width: 8),
                      Text('Mark In Progress'),
                    ]),
                  ),
                if (!ticket.isResolved)
                  const PopupMenuItem(
                    value: 'resolved',
                    child: Row(children: [
                      Icon(Iconsax.tick_circle,
                          size: 18, color: AppColors.success),
                      SizedBox(width: 8),
                      Text('Mark Resolved'),
                    ]),
                  ),
                if (!ticket.isClosed)
                  const PopupMenuItem(
                    value: 'closed',
                    child: Row(children: [
                      Icon(Iconsax.lock_1, size: 18, color: AppColors.textMuted),
                      SizedBox(width: 8),
                      Text('Close Ticket'),
                    ]),
                  ),
                if (!ticket.isOpen)
                  const PopupMenuItem(
                    value: 'open',
                    child: Row(children: [
                      Icon(Iconsax.refresh, size: 18, color: AppColors.info),
                      SizedBox(width: 8),
                      Text('Reopen'),
                    ]),
                  ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            // Ticket info bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              color: Colors.white,
              child: Row(
                children: [
                  _buildInfoChip(context, ticket.priorityLabel,
                      _priorityColor(ticket.priority)),
                  if (ticket.screenReference != null) ...[
                    const SizedBox(width: 8),
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
                  const Spacer(),
                  Text(
                    DateFormat('d MMM yyyy').format(ticket.createdAt),
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
            // Messages
            Expanded(
              child: Obx(() {
                if (controller.messages.isEmpty) {
                  return const Center(
                    child: Text('No messages yet',
                        style: TextStyle(color: AppColors.textMuted)),
                  );
                }
                return ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) =>
                      _buildMessageBubble(context, controller.messages[index]),
                );
              }),
            ),
            // Input bar
            _buildInputBar(context, ticket.id),
          ],
        ),
      );
    });
  }

  Widget _buildMessageBubble(BuildContext context, TicketMessageModel msg) {
    final isAdmin = msg.isAdmin;

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isAdmin ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isAdmin
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isAdmin
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment:
              isAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isAdmin)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  msg.sender?.displayName ?? 'User',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            Text(
              msg.message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isAdmin ? Colors.white : AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('d MMM, HH:mm').format(msg.createdAt),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isAdmin
                        ? Colors.white.withValues(alpha: 0.7)
                        : AppColors.textMuted,
                    fontSize: 10,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(BuildContext context, String ticketId) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).padding.bottom + 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.messageController,
              decoration: InputDecoration(
                hintText: 'Type a reply...',
                filled: true,
                fillColor: AppColors.bgCream,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.pill,
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => controller.sendReply(ticketId),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => IconButton(
                onPressed: controller.isSending.value
                    ? null
                    : () => controller.sendReply(ticketId),
                icon: controller.isSending.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Iconsax.send_15),
                color: AppColors.primary,
              )),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.small,
      ),
      child: Text(label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color, fontWeight: FontWeight.w600, fontSize: 10)),
    );
  }

  Color _statusColor(SupportTicketModel ticket) {
    if (ticket.isOpen) return AppColors.info;
    if (ticket.isInProgress) return AppColors.warning;
    if (ticket.isResolved) return AppColors.success;
    return AppColors.textMuted;
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'urgent':
        return AppColors.error;
      case 'high':
        return AppColors.warning;
      case 'low':
        return AppColors.textMuted;
      default:
        return AppColors.info;
    }
  }
}
