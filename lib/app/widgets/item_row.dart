import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/model/item_model.dart';

class ItemRow extends StatelessWidget {
  final ItemModel itemModel;
  const ItemRow({super.key, required this.itemModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Row(
        children: [Text(itemModel.nomeItem), Text('${itemModel.preco}')],
      ),
    );
  }
}
