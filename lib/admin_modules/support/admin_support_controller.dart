import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/support_ticket_model.dart';
import '../../shared/controllers/base_controller.dart';

class AdminSupportController extends BaseController {
  final SupabaseService _supabase = SupabaseService.to;

  // ============================================
  // STATE
  // ============================================

  final RxList<SupportTicketModel> tickets = <SupportTicketModel>[].obs;
  final RxString filterStatus = 'all'.obs;
  final RxString searchQuery = ''.obs;

  // Chat
  final Rx<SupportTicketModel?> selectedTicket = Rx<SupportTicketModel?>(null);
  final RxList<TicketMessageModel> messages = <TicketMessageModel>[].obs;
  final messageController = TextEditingController();
  final RxBool isSending = false.obs;
  final scrollController = ScrollController();

  // ============================================
  // LIFECYCLE
  // ============================================

  @override
  void onInit() {
    super.onInit();
    loadAllTickets();
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  // ============================================
  // COMPUTED
  // ============================================

  int get totalOpen => tickets.where((t) => t.isOpen).length;
  int get totalInProgress => tickets.where((t) => t.isInProgress).length;
  int get totalResolved => tickets.where((t) => t.isResolved).length;

  List<SupportTicketModel> get filteredTickets {
    var list = tickets.toList();

    // Filter by status
    if (filterStatus.value != 'all') {
      list = list.where((t) => t.status == filterStatus.value).toList();
    }

    // Search
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list
          .where((t) =>
              t.subject.toLowerCase().contains(q) ||
              (t.user?.displayName.toLowerCase().contains(q) ?? false))
          .toList();
    }

    return list;
  }

  // ============================================
  // LOAD DATA
  // ============================================

  Future<void> loadAllTickets() async {
    setLoading(true);
    try {
      final response = await _supabase
          .from('support_tickets')
          .select(
              '*, users(id, full_name, username, avatar_url), ticket_messages(id, ticket_id, sender_id, message, is_admin, created_at)')
          .order('updated_at', ascending: false);

      tickets.value = (response as List)
          .map((json) =>
              SupportTicketModel.fromJson(json as Map<String, dynamic>))
          .toList();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  }

  Future<void> refreshTickets() async => loadAllTickets();

  // ============================================
  // MESSAGES
  // ============================================

  Future<void> loadMessages(String ticketId) async {
    try {
      final response = await _supabase
          .from('ticket_messages')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      messages.value = (response as List)
          .map((json) =>
              TicketMessageModel.fromJson(json as Map<String, dynamic>))
          .toList();

      _scrollToBottom();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load messages',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> sendReply(String ticketId) async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    isSending.value = true;
    try {
      final adminId = _supabase.userId!;
      await _supabase.from('ticket_messages').insert({
        'ticket_id': ticketId,
        'sender_id': adminId,
        'message': text,
        'is_admin': true,
      });

      // Update ticket status to in_progress if it was open, and update timestamp
      final ticket = selectedTicket.value;
      final newStatus =
          (ticket != null && ticket.isOpen) ? 'in_progress' : ticket?.status;

      await _supabase.from('support_tickets').update({
        'updated_at': DateTime.now().toIso8601String(),
        if (ticket != null && ticket.isOpen) 'status': 'in_progress',
      }).eq('id', ticketId);

      messageController.clear();
      await loadMessages(ticketId);

      // Update local ticket
      if (ticket != null && newStatus != null) {
        selectedTicket.value = ticket.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        _updateTicketLocally(ticketId, selectedTicket.value!);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to send reply',
          snackPosition: SnackPosition.BOTTOM);
    }
    isSending.value = false;
  }

  // ============================================
  // STATUS MANAGEMENT
  // ============================================

  Future<void> updateStatus(String ticketId, String newStatus) async {
    try {
      await _supabase.from('support_tickets').update({
        'status': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', ticketId);

      if (selectedTicket.value?.id == ticketId) {
        selectedTicket.value = selectedTicket.value!.copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
      }
      _updateTicketLocally(
        ticketId,
        tickets
            .firstWhere((t) => t.id == ticketId)
            .copyWith(status: newStatus, updatedAt: DateTime.now()),
      );

      Get.snackbar('Updated', 'Ticket status changed to ${_statusLabel(newStatus)}',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void showStatusDialog(String ticketId, String currentStatus) {
    final statuses = ['open', 'in_progress', 'resolved', 'closed'];
    Get.dialog(
      AlertDialog(
        title: const Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) {
            final isSelected = status == currentStatus;
            return ListTile(
              leading: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              title: Text(_statusLabel(status)),
              onTap: isSelected
                  ? null
                  : () {
                      Get.back();
                      updateStatus(ticketId, status);
                    },
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================
  // HELPERS
  // ============================================

  void _updateTicketLocally(String ticketId, SupportTicketModel updated) {
    final index = tickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      tickets[index] = updated;
      tickets.refresh();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'open':
        return 'Open';
      case 'in_progress':
        return 'In Progress';
      case 'resolved':
        return 'Resolved';
      case 'closed':
        return 'Closed';
      default:
        return status;
    }
  }
}
