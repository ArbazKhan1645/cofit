import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static void show({
    required BuildContext context,
    required String message,
    SnackbarType type = SnackbarType.info,
    String? title,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onAction,
    String? actionLabel,
  }) {
    // Remove any existing snackbar
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final config = _getSnackbarConfig(type);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _SnackbarContent(
          message: message,
          title: title ?? config.defaultTitle,
          icon: config.icon,
          iconColor: config.iconColor,
          backgroundColor: config.backgroundColor,
          borderColor: config.borderColor,
          onAction: onAction,
          actionLabel: actionLabel,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  static void success(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.success,
      title: title,
      duration: duration,
    );
  }

  static void error(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.error,
      title: title,
      duration: duration,
    );
  }

  static void warning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.warning,
      title: title,
      duration: duration,
    );
  }

  static void info(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.info,
      title: title,
      duration: duration,
    );
  }

  static _SnackbarConfig _getSnackbarConfig(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarConfig(
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
          backgroundColor: AppColors.successLight,
          borderColor: AppColors.success.withValues(alpha: 0.3),
          defaultTitle: 'Success',
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          icon: Icons.error_rounded,
          iconColor: AppColors.error,
          backgroundColor: AppColors.errorLight,
          borderColor: AppColors.error.withValues(alpha: 0.3),
          defaultTitle: 'Error',
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          icon: Icons.warning_rounded,
          iconColor: AppColors.warning,
          backgroundColor: AppColors.warningLight,
          borderColor: AppColors.warning.withValues(alpha: 0.3),
          defaultTitle: 'Warning',
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          icon: Icons.info_rounded,
          iconColor: AppColors.info,
          backgroundColor: AppColors.infoLight,
          borderColor: AppColors.info.withValues(alpha: 0.3),
          defaultTitle: 'Info',
        );
    }
  }
}

class _SnackbarConfig {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final String defaultTitle;

  const _SnackbarConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.defaultTitle,
  });
}

class _SnackbarContent extends StatelessWidget {
  final String message;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback? onAction;
  final String? actionLabel;

  const _SnackbarContent({
    required this.message,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        // border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            // Colored accent bar
            Container(
              width: 6,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [iconColor, iconColor.withValues(alpha: 0.7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    // Icon with gradient background
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 14),
                    // Text content
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Action button or close
                    if (onAction != null && actionLabel != null) ...[
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          onAction!();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: iconColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          actionLabel!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ] else ...[
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
