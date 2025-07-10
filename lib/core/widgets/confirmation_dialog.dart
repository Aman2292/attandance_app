import 'package:flutter/material.dart';
import '../constants.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: AppTextStyles.heading3),
      content: Text(content, style: AppTextStyles.bodyMedium),
      actions: [
        TextButton(
          style: AppButtonStyles.textButton,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: AppButtonStyles.primaryButton,
          onPressed: () {
            onConfirm();
            Navigator.pop(context);
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}