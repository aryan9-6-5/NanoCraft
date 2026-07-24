import 'package:flutter/material.dart';

/// Themed dialog wrapper that uses the app's dialog theme automatically.
/// Provides a consistent dialog API with title, content, and actions.
class NanoDialog extends StatelessWidget {
  final String title;
  final String content;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const NanoDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmLabel,
    this.cancelLabel,
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  /// Convenience method to show the dialog and return the result.
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => NanoDialog(
        title: title,
        content: content,
        confirmLabel: confirmLabel ?? 'Confirm',
        cancelLabel: cancelLabel ?? 'Cancel',
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
        isDestructive: isDestructive,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        if (cancelLabel != null)
          TextButton(
            onPressed: onCancel ?? () => Navigator.pop(context, false),
            child: Text(cancelLabel!),
          ),
        if (confirmLabel != null)
          TextButton(
            onPressed: onConfirm ?? () => Navigator.pop(context, true),
            style: isDestructive
                ? TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error)
                : null,
            child: Text(confirmLabel!),
          ),
      ],
    );
  }
}
