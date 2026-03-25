import 'package:flutter/material.dart';

class RenameActionDialog extends StatelessWidget {
  final TextEditingController renamedController;
  final String title;
  final String validatorErrorEmpty;
  final String validatorErrorMaximumLength;
  final String cancelActionLabel;
  final String confirmActionLabel;
  final Function(String) onConfirm;

  const RenameActionDialog({
    super.key,
    required this.renamedController,
    required this.title,
    required this.validatorErrorEmpty,
    required this.validatorErrorMaximumLength,
    required this.cancelActionLabel,
    required this.confirmActionLabel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    return AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: Form(
        key: formKey,
        child: TextFormField(
          autofocus: true,

          autovalidateMode: AutovalidateMode.onUserInteraction,

          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return validatorErrorEmpty;
            } else if (value.length > 50) {
              return validatorErrorMaximumLength;
            }
            return null;
          },
          controller: renamedController,
          decoration: InputDecoration(
            hint: Text(
              renamedController.text,
              style: TextStyle(color: Colors.white38),
            ),
          ),
          onTap: () {
            renamedController.selection = TextSelection(
              baseOffset: 0,
              extentOffset: renamedController.text.length,
            );
          },
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(cancelActionLabel),
        ),
        TextButton(
          onPressed: () async {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context);
              onConfirm(renamedController.text);
            }
          },
          child: Text(
            confirmActionLabel,
            style: TextStyle(color: Colors.green),
          ),
        ),
      ],
    );
  }
}
