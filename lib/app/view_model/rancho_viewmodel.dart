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

  List<String> getListaItens(CategoriaModel categoria) {
    return categoria.itens.map((item) => item.nomeItem).toList();
  }

  bool isCategoriaCompleta(CategoriaModel categoria) {
    final itens = categoria.itens;
    if (itens.isEmpty) return false;
    return itens.every((item) => item.isComprado == true);
  }

  void toggleIsComprado(ItemModel item) {
    item.isComprado = !item.isComprado;
    notifyListeners();
  }

  double calcularTotalCategoria(CategoriaModel categoria) {
    double totalCategoria = categoria.itens
        .where((item) => item.isComprado)
        .fold(0.0, (soma, item) => soma + calcularTotalItem(item));

    return totalCategoria;
  }

  double calcularTotalRancho(RanchoModel rancho) {
    return rancho.categorias.fold(
      0.0,
      (totalAcumulado, categoria) =>
          totalAcumulado + calcularTotalCategoria(categoria),
    );
  }

  double calcularTotalItem(ItemModel item) {
    if (item.unidade == 'un') {
      return item.quantidade * item.preco;
    } else {
      return item.preco;
    }
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
