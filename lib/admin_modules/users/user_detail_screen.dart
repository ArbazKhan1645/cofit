import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/cofit_image.dart';
import 'users_controller.dart';

class UserDetailScreen extends GetView<AdminUsersController> {
  const UserDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = controller.selectedUser.value;
      if (user == null) {
        return Scaffold(
          appBar: AppBar(),
          body: const Center(child: Text('User not found')),
        );
      }

      return Scaffold(
        backgroundColor: AppColors.bgCream,
        appBar: AppBar(
          title: const Text('User Details'),
          actions: [
            // Ban/Unban
            IconButton(
              icon: Icon(
                user.isBanned ? Iconsax.shield_tick : Iconsax.slash,
                color: user.isBanned ? AppColors.success : AppColors.warning,
              ),
              onPressed: () => controller.toggleBan(user),
              tooltip: user.isBanned ? 'Unban' : 'Ban',
            ),
            // Delete
            IconButton(
              icon: const Icon(Iconsax.trash, color: AppColors.error),
              onPressed: () async {
                await controller.deleteUser(user);
                if (controller.users.every((u) => u.id != user.id)) {
                  Get.back();
                }
              },
              tooltip: 'Delete',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: AppPadding.screen,
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Profile header
              _buildProfileHeader(context, user),
              const SizedBox(height: 20),
              // Status & Type
              _buildStatusSection(context, user),
              const SizedBox(height: 16),
              // Account info
              _buildInfoSection(context, 'Account Info', [
                _infoRow(context, 'Email', user.email, Iconsax.sms),
                if (user.username != null && user.username!.isNotEmpty)
                  _infoRow(context, 'Username', '@${user.username}',
                      Iconsax.user_tag),
                _infoRow(
                    context,
                    'Joined',
                    DateFormat('d MMM yyyy').format(user.createdAt),
                    Iconsax.calendar_1),
                _infoRow(
                    context,
                    'Last Updated',
                    DateFormat('d MMM yyyy').format(user.updatedAt),
                    Iconsax.clock),
              ]),
              const SizedBox(height: 16),
              // Body & Fitness
              _buildInfoSection(context, 'Fitness Profile', [
                if (user.gender != null)
                  _infoRow(context, 'Gender', user.gender!, Iconsax.user),
                if (user.dateOfBirth != null)
                  _infoRow(
                      context,
                      'Date of Birth',
                      DateFormat('d MMM yyyy').format(user.dateOfBirth!),
                      Iconsax.cake),
                if (user.heightCm != null)
                  _infoRow(context, 'Height', '${user.heightCm} cm',
                      Iconsax.ruler),
                if (user.weightKg != null)
                  _infoRow(context, 'Weight', '${user.weightKg} kg',
                      Iconsax.weight_1),
                if (user.fitnessLevel != null)
                  _infoRow(context, 'Level', user.fitnessLevel!,
                      Iconsax.chart_2),
                _infoRow(context, 'Workout Days/Week',
                    '${user.workoutDaysPerWeek}', Iconsax.calendar_tick),
                if (user.preferredWorkoutTime != null)
                  _infoRow(context, 'Preferred Time',
                      user.preferredWorkoutTime!, Iconsax.timer_1),
                if (user.preferredSessionDuration != null)
                  _infoRow(context, 'Session Duration',
                      '${user.preferredSessionDuration} min', Iconsax.clock),
              ]),
              // Goals
              if (user.fitnessGoals.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildTagsSection(context, 'Fitness Goals', user.fitnessGoals,
                    AppColors.primary),
              ],
              // Preferred workout types
              if (user.preferredWorkoutTypes.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildTagsSection(context, 'Preferred Workouts',
                    user.preferredWorkoutTypes, AppColors.lavender),
              ],
              // Physical limitations
              if (user.physicalLimitations.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildTagsSection(context, 'Physical Limitations',
                    user.physicalLimitations, AppColors.warning),
              ],
              // Medical conditions
              if (user.medicalConditions.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildTagsSection(context, 'Medical Conditions',
                    user.medicalConditions, AppColors.error),
              ],
              // Equipment
              if (user.availableEquipment.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildTagsSection(context, 'Available Equipment',
                    user.availableEquipment, AppColors.mintFresh),
              ],
              const SizedBox(height: 16),
              // Stats
              _buildInfoSection(context, 'Activity Stats', [
                _infoRow(context, 'Workouts Completed',
                    '${user.totalWorkoutsCompleted}', Iconsax.medal_star),
                _infoRow(context, 'Total Minutes',
                    '${user.totalMinutesWorkedOut}', Iconsax.timer_1),
                _infoRow(context, 'Calories Burned',
                    '${user.totalCaloriesBurned}', Iconsax.flash_1),
                _infoRow(context, 'Current Streak', '${user.currentStreak} days',
                    Iconsax.chart_success),
                _infoRow(context, 'Longest Streak', '${user.longestStreak} days',
                    Iconsax.crown_1),
                if (user.lastWorkoutDate != null)
                  _infoRow(
                      context,
                      'Last Workout',
                      DateFormat('d MMM yyyy').format(user.lastWorkoutDate!),
                      Iconsax.calendar_tick),
              ]),
              const SizedBox(height: 16),
              // Subscription
              _buildInfoSection(context, 'Subscription', [
                _infoRow(
                    context,
                    'Status',
                    user.subscriptionStatus ?? 'free',
                    Iconsax.card),
                if (user.subscriptionPlan != null)
                  _infoRow(context, 'Plan', user.subscriptionPlan!,
                      Iconsax.receipt_2),
                if (user.subscriptionStartDate != null)
                  _infoRow(
                      context,
                      'Started',
                      DateFormat('d MMM yyyy')
                          .format(user.subscriptionStartDate!),
                      Iconsax.calendar_1),
                if (user.subscriptionEndDate != null)
                  _infoRow(
                      context,
                      'Expires',
                      DateFormat('d MMM yyyy')
                          .format(user.subscriptionEndDate!),
                      Iconsax.calendar_remove),
              ]),
              // Journal prompts
              if (user.biggestChallenge != null ||
                  user.currentFeeling != null ||
                  user.timeline != null ||
                  user.motivation != null) ...[
                const SizedBox(height: 16),
                _buildInfoSection(context, 'Journal Prompts', [
                  if (user.biggestChallenge != null)
                    _infoRow(context, 'Biggest Challenge',
                        user.biggestChallenge!, Iconsax.flag),
                  if (user.currentFeeling != null)
                    _infoRow(context, 'Current Feeling',
                        user.currentFeeling!, Iconsax.emoji_happy),
                  if (user.timeline != null)
                    _infoRow(
                        context, 'Timeline', user.timeline!, Iconsax.timer_1),
                  if (user.motivation != null)
                    _infoRow(context, 'Motivation', user.motivation!,
                        Iconsax.heart),
                ]),
              ],
              const SizedBox(height: 40),
              // Ban button at bottom
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => controller.toggleBan(user),
                  icon: Icon(
                    user.isBanned ? Iconsax.shield_tick : Iconsax.slash,
                    size: 20,
                  ),
                  label: Text(user.isBanned ? 'Unban User' : 'Ban User'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor:
                        user.isBanned ? AppColors.success : AppColors.error,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: user.isBanned ? AppColors.success : AppColors.error,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.large),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Delete button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await controller.deleteUser(user);
                    if (controller.users.every((u) => u.id != user.id)) {
                      Get.back();
                    }
                  },
                  icon: const Icon(Iconsax.trash, size: 20),
                  label: const Text('Delete Account'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.large),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    });
  }

  // ============================================
  // PROFILE HEADER
  // ============================================
  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    return Container(
      width: double.infinity,
      padding: AppPadding.cardLarge,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.subtle,
      ),
      child: Column(
        children: [
          // Avatar
          if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: CofitImage(
                imageUrl: user.avatarUrl!,
                width: 80,
                height: 80,
              ),
            )
          else
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.bgBlush,
              child: Text(
                user.displayName.isNotEmpty
                    ? user.displayName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                    fontSize: 28,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
            ),
          const SizedBox(height: 12),
          Text(user.displayName,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(user.email,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.textMuted)),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(user.bio!,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: AppColors.textSecondary)),
          ],
        ],
      ),
    );
  }

  // ============================================
  // STATUS SECTION
  // ============================================
  Widget _buildStatusSection(BuildContext context, dynamic user) {
    return Row(
      children: [
        // User type
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: user.isAdmin ? AppColors.lavenderLight : AppColors.infoLight,
              borderRadius: AppRadius.medium,
            ),
            child: Column(
              children: [
                Icon(user.isAdmin ? Iconsax.shield_tick : Iconsax.user,
                    size: 20,
                    color: user.isAdmin ? AppColors.lavender : AppColors.info),
                const SizedBox(height: 4),
                Text(user.userType.toString().toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: user.isAdmin
                            ? AppColors.lavender
                            : AppColors.info)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Ban status
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color:
                  user.isBanned ? AppColors.errorLight : AppColors.successLight,
              borderRadius: AppRadius.medium,
            ),
            child: Column(
              children: [
                Icon(user.isBanned ? Iconsax.slash : Iconsax.tick_circle,
                    size: 20,
                    color: user.isBanned ? AppColors.error : AppColors.success),
                const SizedBox(height: 4),
                Text(user.isBanned ? 'BANNED' : 'ACTIVE',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: user.isBanned
                            ? AppColors.error
                            : AppColors.success)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Subscription
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: user.hasActiveSubscription
                  ? AppColors.bgMint
                  : AppColors.warningLight,
              borderRadius: AppRadius.medium,
            ),
            child: Column(
              children: [
                Icon(Iconsax.card,
                    size: 20,
                    color: user.hasActiveSubscription
                        ? AppColors.mintFresh
                        : AppColors.warning),
                const SizedBox(height: 4),
                Text(
                    user.hasActiveSubscription
                        ? (user.subscriptionPlan ?? 'ACTIVE').toUpperCase()
                        : 'FREE',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: user.hasActiveSubscription
                            ? AppColors.mintFresh
                            : AppColors.warning)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================
  // INFO SECTION
  // ============================================
  Widget _buildInfoSection(
      BuildContext context, String title, List<Widget> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();
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
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _infoRow(
      BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 12),
          Text(label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.end,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  // ============================================
  // TAGS SECTION
  // ============================================
  Widget _buildTagsSection(
      BuildContext context, String title, List<String> tags, Color color) {
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
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags
                .map((tag) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: AppRadius.pill,
                      ),
                      child: Text(tag,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(
                                  color: color, fontWeight: FontWeight.w600)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
