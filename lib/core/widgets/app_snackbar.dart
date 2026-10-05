import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Global key to manage ScaffoldMessenger from anywhere in the application
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Enum representing the types of notification snackbars
enum SnackBarType { success, error, info, warning }

/// Core global SnackBar utility component
abstract class AppSnackBar {
  /// Global key to assign to MaterialApp.router (scaffoldMessengerKey)
  static GlobalKey<ScaffoldMessengerState> get messengerKey =>
      rootScaffoldMessengerKey;

  /// Shows a custom styled global SnackBar
  static void show({
    required String message,
    BuildContext? context,
    SnackBarType type = SnackBarType.info,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
    VoidCallback? onVisible,
  }) {
    final messengerState = context != null
        ? ScaffoldMessenger.of(context)
        : rootScaffoldMessengerKey.currentState;

    if (messengerState == null) {
      debugPrint('AppSnackBar: ScaffoldMessengerState is not available.');
      return;
    }

    final config = _getSnackBarConfig(type, customIcon: icon);

    messengerState.hideCurrentSnackBar();
    messengerState.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              config.icon,
              color: config.iconColor,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        action: action,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        elevation: 6,
        onVisible: onVisible,
      ),
    );
  }

  /// Helper to show a success SnackBar
  static void showSuccess(
    String message, {
    BuildContext? context,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      message: message,
      context: context,
      type: SnackBarType.success,
      duration: duration,
      action: action,
    );
  }

  /// Helper to show an error SnackBar
  static void showError(
    String message, {
    BuildContext? context,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    show(
      message: message,
      context: context,
      type: SnackBarType.error,
      duration: duration,
      action: action,
    );
  }

  /// Helper to show an info SnackBar
  static void showInfo(
    String message, {
    BuildContext? context,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    show(
      message: message,
      context: context,
      type: SnackBarType.info,
      duration: duration,
      action: action,
    );
  }

  /// Helper to show a warning SnackBar
  static void showWarning(
    String message, {
    BuildContext? context,
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    show(
      message: message,
      context: context,
      type: SnackBarType.warning,
      duration: duration,
      action: action,
    );
  }

  /// Hides the currently visible SnackBar
  static void hide({BuildContext? context}) {
    final messengerState = context != null
        ? ScaffoldMessenger.of(context)
        : rootScaffoldMessengerKey.currentState;

    messengerState?.hideCurrentSnackBar();
  }

  static _SnackBarConfig _getSnackBarConfig(
    SnackBarType type, {
    IconData? customIcon,
  }) {
    switch (type) {
      case SnackBarType.success:
        return _SnackBarConfig(
          icon: customIcon ?? Icons.check_circle_outline_rounded,
          iconColor: Colors.white,
          backgroundColor: AppColors.primaryContainer,
        );
      case SnackBarType.error:
        return _SnackBarConfig(
          icon: customIcon ?? Icons.error_outline_rounded,
          iconColor: Colors.white,
          backgroundColor: AppColors.errorContainer,
        );
      case SnackBarType.warning:
        return _SnackBarConfig(
          icon: customIcon ?? Icons.warning_amber_rounded,
          iconColor: AppColors.tertiary,
          backgroundColor: AppColors.surfaceContainerHighest,
        );
      case SnackBarType.info:
        return _SnackBarConfig(
          icon: customIcon ?? Icons.info_outline_rounded,
          iconColor: AppColors.secondary,
          backgroundColor: AppColors.surfaceContainerHigh,
        );
    }
  }
}

class _SnackBarConfig {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _SnackBarConfig({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}
