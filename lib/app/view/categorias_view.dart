import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/model/rancho_model.dart';
import 'package:rancho_consciente/app/widgets/cards/categorias_card.dart';
import 'package:rancho_consciente/app/widgets/grid_builder.dart';

class CategoriasView extends StatelessWidget {
  final RanchoModel ranchoModel;
  const CategoriasView({super.key, required this.ranchoModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(ranchoModel.mercado)),

      body: MyGridBuilder(
        colunas: 2,
        itemCount: ranchoModel.categorias.length,
        itemBuilder: (context, index) {
          final categorias = ranchoModel.categorias[index];
          return CategoriasCard(categorias: categorias);
        },
      ),
    );
  }
}
