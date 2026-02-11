import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/profile_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_2),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPadding.screen,
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildProfileHeader(context),
            const SizedBox(height: 24),
            _buildStatsRow(context),
            const SizedBox(height: 24),
            _buildMenuSection(context),
            const SizedBox(height: 24),
            _buildSettingsSection(context),
            const SizedBox(height: 24),
            _buildSignOutButton(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.extraLarge,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                ),
                child: Center(
                  child: Obx(() => Text(
                        controller.userName.value.isNotEmpty
                            ? controller.userName.value[0].toUpperCase()
                            : 'U',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      )),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppShadows.subtle,
                  ),
                  child: IconButton(
                    icon: const Icon(Iconsax.edit, size: 16),
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Name
          Obx(() => Text(
                controller.userName.value,
                style: Theme.of(context).textTheme.titleLarge,
              )),
          const SizedBox(height: 4),
          Obx(() => Text(
                controller.userEmail.value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
              )),
          const SizedBox(height: 8),
          Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.bgBlush,
                  borderRadius: AppRadius.pill,
                ),
                child: Text(
                  'Member since ${controller.memberSince.value}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            context,
            value: '${controller.totalWorkouts.value}',
            label: 'Workouts',
          ),
        ),
        Container(width: 1, height: 40, color: AppColors.borderLight),
        Expanded(
          child: _buildStatItem(
            context,
            value: '${controller.currentStreak.value}',
            label: 'Day Streak',
          ),
        ),
        Container(width: 1, height: 40, color: AppColors.borderLight),
        Expanded(
          child: _buildStatItem(
            context,
            value: '${controller.badgesEarned.value}',
            label: 'Badges',
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, {required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Iconsax.book_1,
            title: 'Journal Entries',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Iconsax.heart,
            title: 'Saved Workouts',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Iconsax.bookmark,
            title: 'Saved Recipes',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Iconsax.document,
            title: 'My Posts',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          _buildMenuItem(
            context,
            icon: Iconsax.setting_2,
            title: 'Settings',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Iconsax.card,
            title: 'Subscription',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: AppRadius.small,
              ),
              child: Text(
                'Active',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                    ),
              ),
            ),
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Iconsax.message_question,
            title: 'Help & Support',
            onTap: () {},
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Iconsax.info_circle,
            title: 'About',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.bgBlush,
          borderRadius: AppRadius.small,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
      trailing: trailing ??
          const Icon(Iconsax.arrow_right_3, size: 20, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56);
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          Get.dialog(
            AlertDialog(
              title: const Text('Sign Out'),
              content: const Text('Are you sure you want to sign out?'),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    controller.signOut();
                  },
                  child: const Text('Sign Out'),
                ),
              ],
            ),
          );
        },
        icon: const Icon(Iconsax.logout),
        label: const Text('Sign Out'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.error,
          side: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }
}
