import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'crashlytics_controller.dart';

class CrashlyticsDetailScreen extends GetView<AdminCrashlyticsController> {
  const CrashlyticsDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final log = controller.selectedCrash.value;
      if (log == null) {
        return Scaffold(
          appBar: AppBar(title: const Text('Crash Detail')),
          body: const Center(child: Text('No crash selected')),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.bgCream,
        appBar: AppBar(
          title: const Text('Crash Detail'),
          actions: [
            IconButton(
              icon: const Icon(Iconsax.trash),
              onPressed: () {
                controller.showDeleteDialog(log.id);
              },
              tooltip: 'Delete',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: AppPadding.screenAll,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Severity + time header
              _buildHeaderCard(context, log),
              const SizedBox(height: 16),

              // Error info
              _buildSection(
                context,
                title: 'Error',
                children: [
                  _buildInfoRow(context, 'Type', log.errorType),
                  _buildInfoRow(context, 'Severity', log.severityLabel),
                  _buildInfoRow(context, 'Source', log.source),
                ],
              ),
              const SizedBox(height: 16),

              // Error message
              _buildSection(
                context,
                title: 'Message',
                children: [
                  _buildCopyableText(context, log.errorMessage),
                ],
              ),
              const SizedBox(height: 16),

              // Stack trace
              if (log.stackTrace != null && log.stackTrace!.isNotEmpty) ...[
                _buildSection(
                  context,
                  title: 'Stack Trace',
                  trailing: IconButton(
                    icon: const Icon(Iconsax.copy, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: log.stackTrace!));
                      Get.snackbar('Copied', 'Stack trace copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM);
                    },
                    tooltip: 'Copy',
                  ),
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: AppRadius.medium,
                      ),
                      child: SelectableText(
                        log.stackTrace!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Color(0xFFD4D4D4),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Device info
              _buildSection(
                context,
                title: 'Device Info',
                children: [
                  if (log.platform != null)
                    _buildInfoRow(context, 'Platform', log.platform!),
                  if (log.osVersion != null)
                    _buildInfoRow(context, 'OS Version', log.osVersion!),
                  if (log.deviceModel != null)
                    _buildInfoRow(context, 'Device', log.deviceModel!),
                  if (log.appVersion != null)
                    _buildInfoRow(context, 'App Version', log.appVersion!),
                ],
              ),
              const SizedBox(height: 16),

              // User info
              _buildSection(
                context,
                title: 'User',
                children: [
                  _buildInfoRow(context, 'Name', log.displayName),
                  if (log.userId != null)
                    _buildInfoRow(context, 'User ID', log.userId!),
                  if (log.userEmail != null)
                    _buildInfoRow(context, 'Email', log.userEmail!),
                ],
              ),
              const SizedBox(height: 16),

              // Context
              if (log.screenRoute != null || log.extraData.isNotEmpty)
                _buildSection(
                  context,
                  title: 'Context',
                  children: [
                    if (log.screenRoute != null)
                      _buildInfoRow(context, 'Screen/Route', log.screenRoute!),
                    if (log.extraData.isNotEmpty)
                      _buildInfoRow(
                          context, 'Extra Data', log.extraData.toString()),
                  ],
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    });
  }

  // ============================================
  // HEADER CARD
  // ============================================

  Widget _buildHeaderCard(BuildContext context, dynamic log) {
    return Container(
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
        border: log.fatal
            ? Border.all(color: AppColors.error.withValues(alpha: 0.3))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: log.fatal
                  ? AppColors.errorLight
                  : AppColors.warningLight,
              borderRadius: AppRadius.medium,
            ),
            child: Icon(
              log.fatal ? Iconsax.danger : Iconsax.warning_2,
              color: log.fatal ? AppColors.error : AppColors.warning,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.shortErrorType,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${log.severityLabel} \u2022 ${log.source} \u2022 ${log.timeAgo}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // SECTION
  // ============================================

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
    Widget? trailing,
  }) {
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
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700, color: AppColors.textSecondary),
              ),
              const Spacer(),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopyableText(BuildContext context, String text) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: text));
        Get.snackbar('Copied', 'Error message copied',
            snackPosition: SnackPosition.BOTTOM);
      },
      child: SelectableText(
        text,
        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(color: AppColors.textSecondary, height: 1.5),
      ),
    );
  }
}
