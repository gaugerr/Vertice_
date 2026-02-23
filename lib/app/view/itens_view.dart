import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/model/categoria_model.dart';
import 'package:rancho_consciente/app/widgets/grid_builder.dart';
import 'package:rancho_consciente/app/widgets/item_row.dart';

class ItensView extends StatelessWidget {
  final CategoriaModel categoriaModel;
  const ItensView({super.key, required this.categoriaModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(categoriaModel.tituloCategoria),
      ),
      body: MyGridBuilder(
        colunas: 1,
        itemCount: categoriaModel.itens.length,
        itemBuilder: (context, index) {
          final itemAtual = categoriaModel.itens[index];
          return ItemRow(itemModel: itemAtual);
        },
      ),
    );
  }
}
