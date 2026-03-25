import 'package:flutter/material.dart';

class ConfirmActionDialog extends StatelessWidget {
  final String title;
  final String description;
  final String cancelActionLabel;
  final String confirmActionLabel;
  final VoidCallback onConfirm;
  final Color confirmColor;

  const ConfirmActionDialog({
    super.key,
    required this.title,
    required this.description,
    required this.cancelActionLabel,
    required this.confirmActionLabel,
    required this.onConfirm,
    required this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: Text(description),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelActionLabel),
        ),
        TextButton(
          onPressed: () async {
            Navigator.pop(context);
            //callback pra executar algo ao confirmar
            onConfirm();
          },
          child: Text(
            confirmActionLabel,
            style: TextStyle(color: confirmColor),
          ),
        ),
      ],
    );
  }
}
