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
    return LayoutBuilder(builder: (context, constraints) {
      final count = columns == 1
          ? (constraints.maxWidth >= 700 ? 2 : 1)
          : (constraints.maxWidth >= 700 ? 3 : 2);
      return GridView.builder(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
        itemCount: itemCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisSpacing: 10, mainAxisSpacing: 10,
          crossAxisCount: count,
          mainAxisExtent: columns == 1 ? 155 : 285,
        ),
        itemBuilder: itemBuilder,
      );
    });
  }
}
