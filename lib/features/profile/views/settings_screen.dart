import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        padding: AppPadding.screen,
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildNotificationsSection(context),
            const SizedBox(height: 24),
            _buildDataSection(context),
            const SizedBox(height: 24),
            _buildAppSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text('Notifications',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Obx(() => SwitchListTile(
                secondary: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.bgBlush,
                    borderRadius: AppRadius.small,
                  ),
                  child: const Icon(Iconsax.notification,
                      color: AppColors.primary, size: 20),
                ),
                title: const Text('Push Notifications'),
                value: controller.notificationsEnabled.value,
                onChanged: controller.toggleNotifications,
              )),
          const Divider(height: 1, indent: 56),
          Obx(() => SwitchListTile(
                secondary: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.bgBlush,
                    borderRadius: AppRadius.small,
                  ),
                  child: const Icon(Iconsax.timer_1,
                      color: AppColors.primary, size: 20),
                ),
                title: const Text('Workout Reminders'),
                value: controller.workoutReminders.value,
                onChanged: controller.toggleWorkoutReminders,
              )),
          const Divider(height: 1, indent: 56),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgBlush,
                borderRadius: AppRadius.small,
              ),
              child: const Icon(Iconsax.clock,
                  color: AppColors.primary, size: 20),
            ),
            title: const Text('Reminder Time'),
            trailing: Obx(() => Text(
                  controller.reminderTime.value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                )),
            onTap: () async {
              final parts = controller.reminderTime.value.split(':');
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: int.parse(parts[0]),
                  minute: int.parse(parts[1]),
                ),
              );
              if (picked != null) {
                final formatted =
                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                controller.setReminderTime(formatted);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text('Data',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgBlush,
                borderRadius: AppRadius.small,
              ),
              child: const Icon(Iconsax.trash,
                  color: AppColors.primary, size: 20),
            ),
            title: const Text('Clear Cache'),
            trailing: Obx(() => Text(
                  controller.cacheSize.value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                )),
            onTap: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Clear Cache'),
                  content: const Text(
                      'This will clear cached data. Are you sure?'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.clearCache();
                      },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text('App',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.bgBlush,
                borderRadius: AppRadius.small,
              ),
              child: const Icon(Iconsax.info_circle,
                  color: AppColors.primary, size: 20),
            ),
            title: const Text('App Version'),
            trailing: Text(
              controller.appVersion,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
