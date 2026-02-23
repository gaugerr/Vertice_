import 'package:flutter/material.dart';

class MyGridBuilder extends StatelessWidget {
  final int itemCount;
  final int colunas;
  final Widget Function(BuildContext context, int index) itemBuilder;

  const MyGridBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.colunas,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(18),

      itemCount: itemCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        crossAxisCount: colunas,
        childAspectRatio: colunas == 1 ? 5.0 : 0.8,
      ),
      itemBuilder: itemBuilder,
    );
  }
}
