import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/model/categoria_model.dart';
import 'package:rancho_consciente/app/model/item_model.dart';
import 'package:rancho_consciente/app/model/rancho_model.dart';

class RanchoViewModel extends ChangeNotifier {
  final List<RanchoModel> listasCompras = [
    RanchoModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mercado: 'Marel',
      data: DateTime.now(),
      categorias: CategoriaModel.gerarCategoriasPadrao(),
      descricao: 'teste',
    ),
  ];

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

  void adicionarItem({required categoria, required nomeDigitado}) {
    final novoItem = ItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nomeItem: nomeDigitado,
    );

    categoria.itens.add(novoItem);

    notifyListeners();
  }

  void toggleIsComprado(ItemModel item) {
    item.isComprado = !item.isComprado;
    notifyListeners();
  }

  double calcularTotalCategoria(CategoriaModel categoria) {
    double totalCategoria = categoria.itens
        .where((item) => item.isComprado)
        .fold(0.0, (soma, item) => soma + (item.preco * item.quantidade));
    notifyListeners();
    return totalCategoria;
  }

  double calcularTotalItem(ItemModel item) {
    return item.quantidade * item.preco;
  }

  void atualizarPrecoItem(ItemModel item, double novoPreco) {
    item.preco = novoPreco;
    notifyListeners();
  }

  void atualizarQtdItem(ItemModel item, double novaQtd) {
    item.quantidade = novaQtd;
    notifyListeners();
  }

  void atualizarUnidadeItem(ItemModel item, String novaUnidade) {
    item.unidade = novaUnidade;
    notifyListeners();
  }
}
