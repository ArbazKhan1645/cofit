import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/services/media/media_service.dart';
import '../../core/theme/app_colors.dart';

/// Profile avatar widget with permanent offline caching.
///
/// Priority:
/// 1. Permanent profile cache (offline-first, never expires)
/// 2. CachedNetworkImage (network with disk cache)
/// 3. Initials or default icon fallback
///
/// Usage:
///   CofitAvatar(imageUrl: user.avatarUrl, userId: user.id, radius: 20)
///   CofitAvatar(imageUrl: user.avatarUrl, userName: user.fullName, radius: 24, onTap: () {})
class CofitAvatar extends StatefulWidget {
  final String? imageUrl;
  final String? userId;
  final String? userName;
  final double radius;
  final VoidCallback? onTap;
  final VoidCallback? onEditTap;
  final bool showEditIcon;
  final Color? backgroundColor;

  const CofitAvatar({
    super.key,
    this.imageUrl,
    this.userId,
    this.userName,
    this.radius = 20,
    this.onTap,
    this.onEditTap,
    this.showEditIcon = false,
    this.backgroundColor,
  });

  @override
  State<CofitAvatar> createState() => _CofitAvatarState();
}

class _CofitAvatarState extends State<CofitAvatar> {
  @override
  void initState() {
    super.initState();
    // Trigger background caching of the profile image
    _cacheProfileImage();
  }

  @override
  void didUpdateWidget(covariant CofitAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-cache if the URL changed
    if (oldWidget.imageUrl != widget.imageUrl) {
      _cacheProfileImage();
    }
  }

  void _cacheProfileImage() {
    if (widget.userId != null &&
        widget.imageUrl != null &&
        widget.imageUrl!.isNotEmpty) {
      // Fire and forget - cache in background
      MediaService.to.cacheProfileImage(widget.userId!, widget.imageUrl!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar = _buildAvatar();

    if (widget.showEditIcon) {
      final editIcon = Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Iconsax.camera,
          size: widget.radius * 0.5,
          color: Colors.white,
        ),
      );

      avatar = Stack(
        children: [
          avatar,
          Positioned(
            bottom: 0,
            right: 0,
            child: widget.onEditTap != null
                ? GestureDetector(onTap: widget.onEditTap, child: editIcon)
                : editIcon,
          ),
        ],
      );
    }

    if (widget.onTap != null) {
      return GestureDetector(onTap: widget.onTap, child: avatar);
    }

    return avatar;
  }

  Widget _buildAvatar() {
    final bgColor = widget.backgroundColor ?? AppColors.bgBlush;

    // Try permanent profile cache first (offline-first)
    if (widget.userId != null) {
      final cachedPath = MediaService.to.getCachedProfileImagePath(widget.userId!);
      if (cachedPath != null) {
        return CircleAvatar(
          radius: widget.radius,
          backgroundColor: bgColor,
          backgroundImage: FileImage(File(cachedPath)),
          onBackgroundImageError: (_, _) {},
        );
      }
    }

    // Try network image with CachedNetworkImage
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: bgColor,
        backgroundImage: CachedNetworkImageProvider(widget.imageUrl!),
        onBackgroundImageError: (_, _) {},
        child: null,
      );
    }

    // Fallback: initials or default icon
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: bgColor,
      child: _buildFallback(),
    );
  }

  Widget _buildFallback() {
    // Show initials if we have a name
    if (widget.userName != null && widget.userName!.isNotEmpty) {
      final initials = _getInitials(widget.userName!);
      return Text(
        initials,
        style: TextStyle(
          color: AppColors.primary,
          fontSize: widget.radius * 0.7,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    // Default icon
    return Icon(
      Iconsax.user,
      size: widget.radius * 0.8,
      color: AppColors.primary,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}
