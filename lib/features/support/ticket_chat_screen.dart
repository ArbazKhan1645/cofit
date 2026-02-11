import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/support_ticket_model.dart';
import 'support_controller.dart';

class TicketChatScreen extends GetView<SupportController> {
  const TicketChatScreen({super.key});

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
              Text(ticket.statusLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: _statusColor(ticket),
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ),
        body: Column(
          children: [
            // Resolved/Closed banner
            if (!ticket.isActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                color: ticket.isResolved
                    ? AppColors.successLight
                    : AppColors.bgCream,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      ticket.isResolved
                          ? Iconsax.tick_circle
                          : Iconsax.lock_1,
                      size: 16,
                      color: ticket.isResolved
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ticket.isResolved
                          ? 'This ticket has been resolved'
                          : 'This ticket is closed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ticket.isResolved
                                ? AppColors.success
                                : AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            // Messages list
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
            // Input bar (only if ticket is active)
            if (ticket.isActive) _buildInputBar(context, ticket.id),
          ],
        ),
      );
    });
  }

  Widget _buildMessageBubble(BuildContext context, TicketMessageModel msg) {
    final currentUserId = SupabaseService.to.userId;
    final isMe = msg.senderId == currentUserId;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe
                ? const Radius.circular(16)
                : const Radius.circular(4),
            bottomRight: isMe
                ? const Radius.circular(4)
                : const Radius.circular(16),
          ),
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (msg.isAdmin && !isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.shield_tick,
                        size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Support',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            Text(
              msg.message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isMe ? Colors.white : AppColors.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('d MMM, HH:mm').format(msg.createdAt),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isMe
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
                hintText: 'Type a message...',
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
              onSubmitted: (_) => controller.sendMessage(ticketId),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => IconButton(
                onPressed: controller.isSending.value
                    ? null
                    : () => controller.sendMessage(ticketId),
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

  Color _statusColor(SupportTicketModel ticket) {
    if (ticket.isOpen) return AppColors.info;
    if (ticket.isInProgress) return AppColors.warning;
    if (ticket.isResolved) return AppColors.success;
    return AppColors.textMuted;
  }
}
