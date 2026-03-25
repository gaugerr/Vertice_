import 'package:flutter/material.dart';

class CustomPopupMenuButton extends StatelessWidget {
  final VoidCallback onExcludePressed;
  final VoidCallback onRenamePressed;
  final String excludeLabel;
  final String renameLabel;

  const CustomPopupMenuButton({
    super.key,
    required this.onExcludePressed,
    required this.onRenamePressed,
    required this.excludeLabel,
    required this.renameLabel,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 1) {
          onRenamePressed();
        } else if (value == 2) {
          onExcludePressed();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 1, child: Text(renameLabel)),
        PopupMenuItem(
          value: 2,
          child: Text(excludeLabel, style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }
}
