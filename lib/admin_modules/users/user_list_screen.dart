import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../app/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../data/models/user_model.dart';
import '../../shared/widgets/cofit_image.dart';
import 'users_controller.dart';

class UserListScreen extends GetView<AdminUsersController> {
  const UserListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(title: const Text('Users')),
      body: Column(
        children: [
          // Summary stats
          _buildStatsBar(context),
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Iconsax.search_normal),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.medium,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          // Filter tabs
          Padding(
            padding: AppPadding.horizontal,
            child: Obx(() => Row(
                  children: [
                    _buildFilterChip(context, 'All', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Users', 'user'),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Admins', 'admin'),
                    const SizedBox(width: 8),
                    _buildFilterChip(context, 'Banned', 'banned'),
                  ],
                )),
          ),
          const SizedBox(height: 12),
          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.users.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = controller.filteredUsers;
              if (items.isEmpty) {
                return _buildEmptyState(context);
              }
              return RefreshIndicator(
                onRefresh: controller.refreshUsers,
                child: ListView.separated(
                  padding: AppPadding.screen,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _buildUserCard(context, items[index]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ============================================
  // STATS BAR
  // ============================================
  Widget _buildStatsBar(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              _buildStatChip(
                  context, '${controller.users.length}', 'Total', Iconsax.people),
              const SizedBox(width: 8),
              _buildStatChip(context, '${controller.totalUsers}', 'Users',
                  Iconsax.profile_2user),
              const SizedBox(width: 8),
              _buildStatChip(context, '${controller.totalAdmins}', 'Admins',
                  Iconsax.shield_tick),
              const SizedBox(width: 8),
              _buildStatChip(context, '${controller.totalBanned}', 'Banned',
                  Iconsax.slash),
            ],
          ),
        ));
  }

  Widget _buildStatChip(
      BuildContext context, String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.medium,
          boxShadow: AppShadows.subtle,
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700)),
            Text(label,
                style: Theme.of(context)
                    .textTheme
                    .labelSmall
                    ?.copyWith(color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // ============================================
  // FILTER CHIPS
  // ============================================
  Widget _buildFilterChip(BuildContext context, String label, String value) {
    final selected = controller.filterType.value == value;
    return GestureDetector(
      onTap: () => controller.filterType.value = value,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: AppRadius.pill,
          boxShadow: selected ? [] : AppShadows.subtle,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }

  // ============================================
  // USER CARD
  // ============================================
  Widget _buildUserCard(BuildContext context, UserModel user) {
    return GestureDetector(
      onTap: () {
        controller.selectedUser.value = user;
        Get.toNamed(AppRoutes.adminUserDetail);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.subtle,
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: _buildAvatar(user),
          title: Row(
            children: [
              Flexible(
                child: Text(user.displayName,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              if (user.isAdmin) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.lavenderLight,
                    borderRadius: AppRadius.small,
                  ),
                  child: Text('Admin',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.lavender,
                          fontWeight: FontWeight.w600,
                          fontSize: 10)),
                ),
              ],
            ],
          ),
          subtitle: Text(user.email,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppColors.textMuted),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Status badge
              _buildStatusBadge(context, user),
              // Menu
              PopupMenuButton<String>(
                onSelected: (val) => _handleMenuAction(val, user),
                itemBuilder: (_) => [
                  const PopupMenuItem(
                    value: 'view',
                    child: Row(children: [
                      Icon(Iconsax.eye, size: 18),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ]),
                  ),
                  // Role toggle — hide for self
                  if (user.id != controller.currentUserId)
                    PopupMenuItem(
                      value: 'role',
                      child: Row(children: [
                        Icon(
                          user.isAdmin ? Iconsax.user : Iconsax.shield_tick,
                          size: 18,
                          color: AppColors.lavender,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          user.isAdmin ? 'Remove Admin' : 'Make Admin',
                          style: const TextStyle(color: AppColors.lavender),
                        ),
                      ]),
                    ),
                  // Ban — hide for self
                  if (user.id != controller.currentUserId)
                    PopupMenuItem(
                      value: 'ban',
                      child: Row(children: [
                        Icon(
                          user.isBanned ? Iconsax.shield_tick : Iconsax.slash,
                          size: 18,
                          color:
                              user.isBanned ? AppColors.success : AppColors.warning,
                        ),
                        const SizedBox(width: 8),
                        Text(user.isBanned ? 'Unban' : 'Ban',
                            style: TextStyle(
                                color: user.isBanned
                                    ? AppColors.success
                                    : AppColors.warning)),
                      ]),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(children: [
                      Icon(Iconsax.trash, size: 18, color: AppColors.error),
                      SizedBox(width: 8),
                      Text('Delete',
                          style: TextStyle(color: AppColors.error)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(UserModel user) {
    if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CofitImage(
          imageUrl: user.avatarUrl!,
          width: 48,
          height: 48,
        ),
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.bgBlush,
      child: Text(
        user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
        style: const TextStyle(
            color: AppColors.primary, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, UserModel user) {
    if (user.isBanned) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: AppRadius.small,
        ),
        child: Text('Banned',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.error, fontWeight: FontWeight.w600)),
      );
    }

    final isActive = user.hasActiveSubscription;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successLight : AppColors.warningLight,
        borderRadius: AppRadius.small,
      ),
      child: Text(
        isActive ? 'Active' : 'Free',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: isActive ? AppColors.success : AppColors.warning,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  void _handleMenuAction(String action, UserModel user) {
    switch (action) {
      case 'view':
        controller.selectedUser.value = user;
        Get.toNamed(AppRoutes.adminUserDetail);
        break;
      case 'role':
        controller.toggleRole(user);
        break;
      case 'ban':
        controller.toggleBan(user);
        break;
      case 'delete':
        controller.deleteUser(user);
        break;
    }
  }

  // ============================================
  // EMPTY STATE
  // ============================================
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Iconsax.people, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('No users found',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.textMuted)),
        ],
      ),
    );
  }
}
