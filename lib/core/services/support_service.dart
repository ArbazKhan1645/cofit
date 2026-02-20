import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../../features/support/support_controller.dart';
import 'supabase_service.dart';

/// Reusable support ticket service.
/// Call [showRaiseTicketSheet] from any screen to let the user raise a ticket.
class SupportService {
  SupportService._();

  /// Show a bottom sheet to raise a new support ticket.
  /// [screenReference] is an optional tag to track which screen the ticket came from.
  static const _topics = [
    'Subscription',
    'Workouts',
    'Meals & Recipes',
    'Challenges',
    'Account',
    'App Issues',
    'Other',
  ];

  static void showRaiseTicketSheet({String? screenReference}) {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    final isSubmitting = false.obs;
    final selectedTopic = RxnString();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.textDisabled,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),
              // Title
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: AppRadius.medium,
                    ),
                    child: const Icon(Iconsax.message_question,
                        color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Raise a Ticket',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Topic selection
              const Text(
                'Select Topic',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _topics
                        .map((topic) => GestureDetector(
                              onTap: () {
                                selectedTopic.value =
                                    selectedTopic.value == topic ? null : topic;
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selectedTopic.value == topic
                                      ? AppColors.primary
                                      : AppColors.bgCream,
                                  borderRadius: AppRadius.pill,
                                  border: Border.all(
                                    color: selectedTopic.value == topic
                                        ? AppColors.primary
                                        : AppColors.borderLight,
                                  ),
                                ),
                                child: Text(
                                  topic,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: selectedTopic.value == topic
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  )),
              const SizedBox(height: 14),
              // Subject
              TextField(
                controller: subjectController,
                decoration: InputDecoration(
                  labelText: 'Subject',
                  hintText: 'Brief summary of your issue',
                  filled: true,
                  fillColor: AppColors.bgCream,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.medium,
                    borderSide: BorderSide.none,
                  ),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 14),
              // Message
              TextField(
                controller: messageController,
                decoration: InputDecoration(
                  labelText: 'Describe your issue',
                  hintText: 'Tell us what happened...',
                  filled: true,
                  fillColor: AppColors.bgCream,
                  border: OutlineInputBorder(
                    borderRadius: AppRadius.medium,
                    borderSide: BorderSide.none,
                  ),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 20),
              // Submit
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSubmitting.value
                          ? null
                          : () => _submitTicket(
                                subjectController: subjectController,
                                messageController: messageController,
                                screenReference: screenReference,
                                isSubmitting: isSubmitting,
                                topic: selectedTopic.value,
                              ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.medium),
                      ),
                      child: isSubmitting.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Submit Ticket',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  static Future<void> _submitTicket({
    required TextEditingController subjectController,
    required TextEditingController messageController,
    String? screenReference,
    required RxBool isSubmitting,
    String? topic,
  }) async {
    final rawSubject = subjectController.text.trim();
    final message = messageController.text.trim();

    if (rawSubject.isEmpty) {
      Get.snackbar('Missing Subject', 'Please enter a subject',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (message.isEmpty) {
      Get.snackbar('Missing Message', 'Please describe your issue',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final subject =
        topic != null ? '[$topic] $rawSubject' : rawSubject;

    isSubmitting.value = true;
    try {
      await createTicket(
        subject: subject,
        message: message,
        screenReference: screenReference,
      );
      Get.back(); // close bottom sheet
      // Refresh ticket list if controller is active
      if (Get.isRegistered<SupportController>()) {
        Get.find<SupportController>().loadMyTickets();
      }
      Get.snackbar('Ticket Submitted', 'We\'ll get back to you soon!',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit ticket. Please try again.',
          snackPosition: SnackPosition.BOTTOM);
    }
    isSubmitting.value = false;
  }

  /// Create a ticket with an initial message directly via API.
  static Future<void> createTicket({
    required String subject,
    required String message,
    String priority = 'normal',
    String? screenReference,
  }) async {
    final supabase = SupabaseService.to;
    final userId = supabase.userId!;

    // Insert ticket
    final ticketResponse = await supabase.from('support_tickets').insert({
      'user_id': userId,
      'subject': subject,
      'priority': priority,
      if (screenReference != null) 'screen_reference': screenReference,
    }).select('id').single();

    final ticketId = ticketResponse['id'] as String;

    // Insert first message
    await supabase.from('ticket_messages').insert({
      'ticket_id': ticketId,
      'sender_id': userId,
      'message': message,
      'is_admin': false,
    });
  }
}
