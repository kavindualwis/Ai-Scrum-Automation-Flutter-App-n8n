import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PlatformDialogs {
  /// Shows a platform-specific dialog
  /// iOS: CupertinoAlertDialog
  /// Android: AlertDialog
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
    Color? confirmColor,
  }) async {
    if (Platform.isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(message),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, true),
                isDestructiveAction: confirmColor != null,
                child: Text(confirmText),
              ),
            ],
          );
        },
      );
    } else {
      return showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  confirmText,
                  style: TextStyle(color: confirmColor ?? Colors.blue),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  /// Shows a platform-specific info dialog
  static Future<void> showInfoDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
  }) async {
    final button = buttonText ?? 'OK';

    if (Platform.isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(message),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: Text(button),
              ),
            ],
          );
        },
      );
    } else {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(button),
              ),
            ],
          );
        },
      );
    }
  }

  /// Shows a platform-specific error dialog
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    String? buttonText,
  }) async {
    final button = buttonText ?? 'OK';

    if (Platform.isIOS) {
      await showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(message),
            ),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.pop(context),
                child: Text(button),
              ),
            ],
          );
        },
      );
    } else {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(button, style: const TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );
    }
  }
}
