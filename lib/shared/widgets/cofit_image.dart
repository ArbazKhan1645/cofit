import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';

/// Reusable image widget - drop-in replacement for CachedNetworkImage.
/// Handles null/empty URLs, shimmer loading, error fallback, and offline caching.
///
/// Usage:
///   CofitImage(imageUrl: post.imageUrls.first, height: 200)
///   CofitImage(imageUrl: url, width: 100, height: 100, borderRadius: BorderRadius.circular(12))
class CofitImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CofitImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Handle null or empty URL
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildError();
    }

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? _buildPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildError(),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.bgCream,
      highlightColor: AppColors.bgWhite,
      child: Container(
        width: width,
        height: height,
        color: AppColors.bgCream,
      ),
    );
  }

  Widget _buildError() {
    return Container(
      width: width,
      height: height,
      color: AppColors.bgCream,
      child: const Center(
        child: Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted),
      ),
    );
  }
}
