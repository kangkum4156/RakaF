import 'package:flutter/material.dart';

void showDuplicateDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("확인"),
        ),
      ],
    ),
  );
}