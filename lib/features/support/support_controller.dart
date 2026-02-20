import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/services/supabase_service.dart';
import '../../data/models/support_ticket_model.dart';
import '../../shared/controllers/base_controller.dart';

class SupportController extends BaseController {
  final SupabaseService _supabase = SupabaseService.to;

  // State
  final RxList<SupportTicketModel> tickets = <SupportTicketModel>[].obs;
  final Rx<SupportTicketModel?> selectedTicket = Rx<SupportTicketModel?>(null);
  final RxList<TicketMessageModel> messages = <TicketMessageModel>[].obs;
  final messageController = TextEditingController();
  final RxBool isSending = false.obs;
  final scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    loadMyTickets();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // ============================================
  // LOAD TICKETS
  // ============================================

  Future<void> loadMyTickets() async {
    setLoading(true);
    try {
      final userId = _supabase.userId!;
      final response = await _supabase
          .from('support_tickets')
          .select(
            '*, ticket_messages(id, ticket_id, sender_id, message, is_admin, created_at)',
          )
          .eq('user_id', userId)
          .order('updated_at', ascending: false);

      tickets.value = (response as List)
          .map(
            (json) => SupportTicketModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
      setSuccess();
    } catch (e) {
      setError(e.toString());
    }
    setLoading(false);
  }

  Future<void> refreshTickets() async => loadMyTickets();

  // ============================================
  // LOAD MESSAGES
  // ============================================

  Future<void> loadMessages(String ticketId) async {
    try {
      final response = await _supabase
          .from('ticket_messages')
          .select('*, users(id, full_name, username, avatar_url)')
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      messages.value = (response as List)
          .map(
            (json) => TicketMessageModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      _scrollToBottom();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load messages',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ============================================
  // SEND MESSAGE
  // ============================================

  Future<void> sendMessage(String ticketId) async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    isSending.value = true;
    try {
      final userId = _supabase.userId!;
      await _supabase.from('ticket_messages').insert({
        'ticket_id': ticketId,
        'sender_id': userId,
        'message': text,
        'is_admin': false,
      });

      // Update ticket updated_at
      await _supabase
          .from('support_tickets')
          .update({'updated_at': DateTime.now().toIso8601String()})
          .eq('id', ticketId);

      messageController.clear();
      await loadMessages(ticketId);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to send message',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    isSending.value = false;
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
}
