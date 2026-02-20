import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'notification_controller.dart';

class NotificationSendScreen extends GetView<AdminNotificationController> {
  const NotificationSendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Send Notification'),
        actions: [
          Obx(() => TextButton.icon(
                onPressed:
                    controller.isSending.value ? null : controller.confirmSend,
                icon: controller.isSending.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Iconsax.send_1, size: 18),
                label: Text(controller.isSending.value ? 'Sending...' : 'Send'),
              )),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screen,
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildTargetCard(context),
            const SizedBox(height: 24),
            _buildContentCard(context),
            const SizedBox(height: 24),
            _buildImageCard(context),
            const SizedBox(height: 24),
            _buildPreviewCard(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ============================================
  // TARGET SELECTION
  // ============================================

  Widget _buildTargetCard(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Target Audience',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Obx(() => SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'all',
                      label: Text('All Users'),
                      icon: Icon(Iconsax.people, size: 18),
                    ),
                    ButtonSegment(
                      value: 'specific',
                      label: Text('Specific Users'),
                      icon: Icon(Iconsax.user_tick, size: 18),
                    ),
                  ],
                  selected: {controller.targetMode.value},
                  onSelectionChanged: (s) =>
                      controller.targetMode.value = s.first,
                ),
              )),
          const SizedBox(height: 12),
          // Specific user selection
          Obx(() {
            if (controller.targetMode.value != 'specific') {
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Iconsax.info_circle,
                        size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Notification will be sent to all registered users',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ],
                ),
              );
            }
            return _buildUserSelector(context);
          }),
        ],
      ),
    );
  }

  Widget _buildUserSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selected chips
        Obx(() {
          if (controller.selectedUsers.isEmpty) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.selectedUsers.map((user) {
                return Chip(
                  avatar: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  label: Text(user.displayName),
                  onDeleted: () => controller.toggleUserSelection(user),
                  backgroundColor: AppColors.bgBlush,
                );
              }).toList(),
            ),
          );
        }),
        // Search
        TextField(
          onChanged: (v) => controller.userSearchQuery.value = v,
          decoration: InputDecoration(
            hintText: 'Search users...',
            prefixIcon: const Icon(Iconsax.search_normal, size: 20),
            isDense: true,
            filled: true,
            fillColor: AppColors.bgCream,
            border: OutlineInputBorder(
              borderRadius: AppRadius.medium,
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // User list
        Obx(() {
          final users = controller.filteredUsers;
          if (users.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('No users found',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textMuted)),
              ),
            );
          }
          return ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 250),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Obx(() {
                  final isSelected = controller.isUserSelected(user.id);
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.1),
                      backgroundImage:
                          (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                              ? NetworkImage(user.avatarUrl!)
                              : null,
                      child: (user.avatarUrl == null || user.avatarUrl!.isEmpty)
                          ? Text(
                              user.displayName.isNotEmpty
                                  ? user.displayName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600),
                            )
                          : null,
                    ),
                    title: Text(user.displayName,
                        style: const TextStyle(fontSize: 14)),
                    subtitle: Text(user.email,
                        style: TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                    trailing: Icon(
                      isSelected
                          ? Iconsax.tick_circle5
                          : Iconsax.tick_circle,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textDisabled,
                      size: 22,
                    ),
                    onTap: () => controller.toggleUserSelection(user),
                  );
                });
              },
            ),
          );
        }),
      ],
    );
  }

  // ============================================
  // CONTENT
  // ============================================

  Widget _buildContentCard(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notification Content',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.titleController,
            decoration: const InputDecoration(
              labelText: 'Title *',
              prefixIcon: Icon(Iconsax.text),
              hintText: 'e.g. New Workout Available!',
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: controller.bodyController,
            decoration: const InputDecoration(
              labelText: 'Description *',
              prefixIcon: Icon(Iconsax.document_text),
              alignLabelWithHint: true,
              hintText: 'e.g. Check out our latest HIIT workout...',
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  // ============================================
  // IMAGE (OPTIONAL)
  // ============================================

  Widget _buildImageCard(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Image',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text('(optional)',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final bytes = controller.selectedImageBytes.value;
            if (bytes != null) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.medium,
                    child: Image.memory(bytes,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: controller.removeImage,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              );
            }
            return GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.bgBlush,
                  borderRadius: AppRadius.medium,
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Iconsax.gallery_add,
                        color: AppColors.primary, size: 32),
                    const SizedBox(height: 8),
                    Text('Add Image',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================
  // PREVIEW
  // ============================================

  Widget _buildPreviewCard(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preview',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCream,
              borderRadius: AppRadius.medium,
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App icon + title row
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Iconsax.weight,
                          color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    Text('CoFit',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.textMuted)),
                    const Spacer(),
                    Text('now',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 8),
                // Title
                Builder(builder: (context) {
                  return ValueListenableBuilder(
                    valueListenable: controller.titleController,
                    builder: (_, value, _) => Text(
                      value.text.isNotEmpty ? value.text : 'Notification Title',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: value.text.isNotEmpty
                                ? AppColors.textPrimary
                                : AppColors.textDisabled,
                          ),
                    ),
                  );
                }),
                const SizedBox(height: 4),
                // Body
                Builder(builder: (context) {
                  return ValueListenableBuilder(
                    valueListenable: controller.bodyController,
                    builder: (_, value, _) => Text(
                      value.text.isNotEmpty
                          ? value.text
                          : 'Notification description will appear here...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: value.text.isNotEmpty
                                ? AppColors.textSecondary
                                : AppColors.textDisabled,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
                // Image preview
                Obx(() {
                  final bytes = controller.selectedImageBytes.value;
                  if (bytes == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ClipRRect(
                      borderRadius: AppRadius.small,
                      child: Image.memory(bytes,
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
