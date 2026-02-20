import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_colors.dart';

/// Full-screen image viewer with pinch-to-zoom.
///
/// Usage:
///   FullScreenImageViewer.open(context, imageUrl);
///   FullScreenImageViewer.open(context, imageUrl, heroTag: 'post_img_123');
class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;
  final String? heroTag;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    this.heroTag,
  });

  /// Opens the image viewer with a fade transition.
  static void open(BuildContext context, String imageUrl, {String? heroTag}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (_, _, _) => FullScreenImageViewer(
          imageUrl: imageUrl,
          heroTag: heroTag,
        ),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.contain,
      placeholder: (_, _) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      errorWidget: (_, _, _) => const Center(
        child: Icon(Iconsax.gallery_slash, color: Colors.white54, size: 48),
      ),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Stack(
          children: [
            // Zoomable image
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: heroTag != null
                    ? Hero(tag: heroTag!, child: imageWidget)
                    : imageWidget,
              ),
            ),

            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
