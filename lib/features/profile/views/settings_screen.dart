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
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        // Load cache size on first build
        controller.loadCacheSize();
        return SingleChildScrollView(
          padding: AppPadding.screen,
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildPushNotificationsSection(context),
              const SizedBox(height: 24),
              _buildEmailSection(context),
              const SizedBox(height: 24),
              _buildQuietHoursSection(context),
              const SizedBox(height: 24),
              _buildDataSection(context),
              const SizedBox(height: 24),
              _buildAppSection(context),
              const SizedBox(height: 24),
              _buildDangerZoneSection(context),
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  // ============================================
  // PUSH NOTIFICATIONS
  // ============================================

  Widget _buildPushNotificationsSection(BuildContext context) {
    return _buildCard(
      context,
      title: 'Push Notifications',
      children: [
        _buildSwitchTile(
          context,
          icon: Iconsax.notification,
          title: 'Push Notifications',
          subtitle: 'Enable all push notifications',
          value: controller.pushEnabled,
          onChanged: controller.togglePushEnabled,
        ),
        const Divider(height: 1, indent: 56),
        Obx(() => AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: controller.pushEnabled.value
                  ? Column(
                      children: [
                        _buildSwitchTile(
                          context,
                          icon: Iconsax.weight,
                          title: 'Workout Reminders',
                          subtitle: 'Workout time & streak warnings',
                          value: controller.workoutReminders,
                          onChanged: controller.toggleWorkoutReminders,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSwitchTile(
                          context,
                          icon: Iconsax.cup,
                          title: 'Challenge Updates',
                          subtitle: 'Challenge progress & leaderboard',
                          value: controller.challengeUpdates,
                          onChanged: controller.toggleChallengeUpdates,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSwitchTile(
                          context,
                          icon: Iconsax.medal_star,
                          title: 'Achievement Alerts',
                          subtitle: 'Badges & streak milestones',
                          value: controller.achievementAlerts,
                          onChanged: controller.toggleAchievementAlerts,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSwitchTile(
                          context,
                          icon: Iconsax.people,
                          title: 'Social Notifications',
                          subtitle: 'Likes, comments & follows',
                          value: controller.socialNotifications,
                          onChanged: controller.toggleSocialNotifications,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSwitchTile(
                          context,
                          icon: Iconsax.card,
                          title: 'Subscription Alerts',
                          subtitle: 'Renewal & payment updates',
                          value: controller.subscriptionAlerts,
                          onChanged: controller.toggleSubscriptionAlerts,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSwitchTile(
                          context,
                          icon: Iconsax.tag,
                          title: 'Marketing',
                          subtitle: 'Promotions & offers',
                          value: controller.marketingNotifications,
                          onChanged: controller.toggleMarketingNotifications,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            )),
      ],
    );
  }

  // ============================================
  // EMAIL
  // ============================================

  Widget _buildEmailSection(BuildContext context) {
    return _buildCard(
      context,
      title: 'Email Notifications',
      children: [
        _buildSwitchTile(
          context,
          icon: Iconsax.sms,
          title: 'Email Notifications',
          subtitle: 'Enable all email notifications',
          value: controller.emailEnabled,
          onChanged: controller.toggleEmailEnabled,
        ),
        const Divider(height: 1, indent: 56),
        Obx(() => AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: controller.emailEnabled.value
                  ? Column(
                      children: [
                        _buildSwitchTile(
                          context,
                          icon: Iconsax.chart,
                          title: 'Weekly Summary',
                          subtitle: 'Weekly progress report email',
                          value: controller.emailWeeklySummary,
                          onChanged: controller.toggleEmailWeeklySummary,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSwitchTile(
                          context,
                          icon: Iconsax.flag,
                          title: 'Challenge Updates',
                          subtitle: 'Challenge activity via email',
                          value: controller.emailChallengeUpdates,
                          onChanged: controller.toggleEmailChallengeUpdates,
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildSwitchTile(
                          context,
                          icon: Iconsax.discount_shape,
                          title: 'Promotions',
                          subtitle: 'Offers & promotional emails',
                          value: controller.emailPromotions,
                          onChanged: controller.toggleEmailPromotions,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            )),
      ],
    );
  }

  // ============================================
  // QUIET HOURS
  // ============================================

  Widget _buildQuietHoursSection(BuildContext context) {
    return _buildCard(
      context,
      title: 'Quiet Hours',
      children: [
        _buildSwitchTile(
          context,
          icon: Iconsax.moon,
          title: 'Quiet Hours',
          subtitle: 'Mute notifications during set time',
          value: controller.quietHoursEnabled,
          onChanged: controller.toggleQuietHours,
        ),
        Obx(() => AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: controller.quietHoursEnabled.value
                  ? Column(
                      children: [
                        const Divider(height: 1, indent: 56),
                        _buildTimeTile(
                          context,
                          icon: Iconsax.clock,
                          title: 'Start Time',
                          value: controller.quietHoursStart,
                          onTap: () => _pickTime(
                            context,
                            controller.quietHoursStart.value,
                            controller.setQuietHoursStart,
                          ),
                        ),
                        const Divider(height: 1, indent: 56),
                        _buildTimeTile(
                          context,
                          icon: Iconsax.clock,
                          title: 'End Time',
                          value: controller.quietHoursEnd,
                          onTap: () => _pickTime(
                            context,
                            controller.quietHoursEnd.value,
                            controller.setQuietHoursEnd,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            )),
      ],
    );
  }

  // ============================================
  // DATA
  // ============================================

  Widget _buildDataSection(BuildContext context) {
    return _buildCard(
      context,
      title: 'Data',
      children: [
        ListTile(
          leading: _buildIcon(Iconsax.trash),
          title: const Text('Clear Cache'),
          trailing: Obx(() => Text(
                controller.cacheSize.value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
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
    );
  }

  // ============================================
  // APP INFO
  // ============================================

  Widget _buildAppSection(BuildContext context) {
    return _buildCard(
      context,
      title: 'App',
      children: [
        ListTile(
          leading: _buildIcon(Iconsax.info_circle),
          title: const Text('App Version'),
          trailing: Obx(() => Text(
                controller.appVersion.value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
              )),
        ),
      ],
    );
  }

  // ============================================
  // DANGER ZONE
  // ============================================

  Widget _buildDangerZoneSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Text(
              'Danger Zone',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600, color: Colors.red),
            ),
          ),
          Obx(() => ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: AppRadius.small,
                  ),
                  child: controller.isDeleting.value
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.red),
                        )
                      : const Icon(Iconsax.trash, color: Colors.red, size: 20),
                ),
                title: const Text('Delete Account',
                    style: TextStyle(color: Colors.red)),
                subtitle: Text('Permanently delete your account & all data',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.textMuted)),
                enabled: !controller.isDeleting.value,
                onTap: controller.showDeleteAccountDialog,
              )),
        ],
      ),
    );
  }

  // ============================================
  // SHARED WIDGETS
  // ============================================

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
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
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.bgBlush,
        borderRadius: AppRadius.small,
      ),
      child: Icon(icon, color: AppColors.primary, size: 20),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required RxBool value,
    required void Function(bool) onChanged,
  }) {
    return Obx(() => SwitchListTile(
          secondary: _buildIcon(icon),
          title: Text(title),
          subtitle: subtitle != null
              ? Text(subtitle,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.textMuted))
              : null,
          value: value.value,
          onChanged: onChanged,
        ));
  }

  Widget _buildTimeTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required RxString value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: _buildIcon(icon),
      title: Text(title),
      trailing: Obx(() => Text(
            value.value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.textMuted),
          )),
      onTap: onTap,
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    String currentValue,
    void Function(String) onPicked,
  ) async {
    final parts = currentValue.split(':');
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
      onPicked(formatted);
    }
  }
}
