import 'package:cofit_collective/core/services/support_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/cofit_avatar.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/profile_controller.dart';
import '../../community/controllers/community_controller.dart';
import '../../community/views/my_posts_screen.dart';
import '../../community/views/saved_posts_screen.dart';
import 'help_support_screen.dart';
import 'about_screen.dart';

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
            onPressed: () {
              SupportService.showRaiseTicketSheet(screenReference: 'AnyScreen');
              // Get.toNamed(AppRoutes.settings);
            },
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
            // Admin section — only visible for admin users
            Obx(
              () => controller.isAdmin.value
                  ? Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: _buildAdminSection(context),
                    )
                  : const SizedBox.shrink(),
            ),
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
          // Avatar with upload
          Obx(
            () => Stack(
              alignment: Alignment.center,
              children: [
                CofitAvatar(
                  imageUrl: controller.userAvatar.value,
                  userId: controller.userId.value,
                  userName: controller.userName.value,
                  radius: 50,
                  showEditIcon: true,
                  onTap: () => controller.uploadProfileImage(),
                ),
                if (controller.isUploadingImage.value)
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Name
          Obx(
            () => Text(
              controller.userName.value,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 4),
          Obx(
            () => Text(
              controller.userEmail.value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => controller.memberSince.value.isNotEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
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
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Obx(
      () => Row(
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
              value: '${controller.totalMinutes.value}',
              label: 'Minutes',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
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
            icon: Iconsax.edit_2,
            title: 'Edit Profile',
            onTap: () => Get.toNamed(AppRoutes.editProfile),
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Iconsax.document,
            title: 'My Posts',
            onTap: () {
              Get.find<CommunityController>().loadMyPosts();
              Get.to(() => const MyPostsScreen());
            },
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Iconsax.bookmark,
            title: 'Saved Posts',
            onTap: () {
              Get.find<CommunityController>().loadSavedPosts();
              Get.to(() => const SavedPostsScreen());
            },
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
            onTap: () => Get.toNamed(AppRoutes.settings),
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Iconsax.card,
            title: 'Subscription',
            trailing: Obx(
              () => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: controller.hasActiveSub.value
                      ? AppColors.successLight
                      : AppColors.bgBlush,
                  borderRadius: AppRadius.small,
                ),
                child: Text(
                  controller.hasActiveSub.value ? 'Active' : 'Free',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: controller.hasActiveSub.value
                        ? AppColors.success
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ),
            onTap: () => Get.toNamed(AppRoutes.subscription),
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Iconsax.message_question,
            title: 'Help & Support',
            onTap: () => Get.to(() => const HelpSupportScreen()),
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            icon: Iconsax.info_circle,
            title: 'About',
            onTap: () => Get.to(() => const AboutScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: _buildMenuItem(
        context,
        icon: Iconsax.shield_tick,
        title: 'Enter Admin Mode',
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: AppRadius.small,
          ),
          child: Text(
            'Admin',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () => Get.toNamed(AppRoutes.adminHome),
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
      title: Text(title, style: Theme.of(context).textTheme.titleSmall),
      trailing:
          trailing ??
          const Icon(
            Iconsax.arrow_right_3,
            size: 20,
            color: AppColors.textMuted,
          ),
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
