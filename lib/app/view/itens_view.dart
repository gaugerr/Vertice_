import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/model/categoria_model.dart';

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
      body: Placeholder(),
    );
  }
}
