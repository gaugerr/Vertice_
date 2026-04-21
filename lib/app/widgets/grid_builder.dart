import 'package:flutter/material.dart';

class MyGridBuilder extends StatelessWidget {
  final int itemCount;
  final int columns;
  final Widget Function(BuildContext context, int index) itemBuilder;

  const MyGridBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(18),

      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: columns,
        childAspectRatio: columns == 1 ? 2.5 : 0.8,
      ),
      itemBuilder: itemBuilder,
    );
  }
}
