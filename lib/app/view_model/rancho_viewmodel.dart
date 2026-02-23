import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/model/categoria_model.dart';
import 'package:rancho_consciente/app/model/rancho_model.dart';

class RanchoViewModel extends ChangeNotifier {
  final List<RanchoModel> listasCompras = [];

  void adicionarRancho({
    required String nomeMercado,
    required DateTime data,
    required String descricao,
  }) {
    listasCompras.add(
      RanchoModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        mercado: nomeMercado,
        data: data,
        categorias: CategoriaModel.gerarCategoriasPadrao(),
        descricao: descricao,
      ),
    );
    notifyListeners();
  }

  //TODO
  void adicionarItem() {}
}
