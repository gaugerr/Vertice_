import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/helpers/database_helper.dart';
import 'package:rancho_consciente/app/model/categoria_model.dart';
import 'package:rancho_consciente/app/model/item_model.dart';
import 'package:rancho_consciente/app/model/rancho_model.dart';

class RanchoViewModel extends ChangeNotifier {
  final Map<int, List<ItemModel>> _itensAgrupados = {};

  Future<void> adicionarRancho({
    required String nomeMercado,
    required DateTime data,
    required String descricao,
  }) async {
    await DatabaseHelper.instance.criarNovoRanchoComCategorias(
      RanchoModel(
        id: null, //gerado automaticamente pelo autoincrement do sql
        mercado: nomeMercado,
        data: data,
        categorias:
            [], //gerado automaticamente, databaseHelper relaciona cada cat. com o id do rancho
        descricao: descricao,
      ),
    );

    notifyListeners();
  }

  Future<void> adicionarItem({
    required categoria,
    required nomeDigitado,
  }) async {
    final itemByName = ItemModel(
      nomeItem: nomeDigitado,
      categoriaId: categoria.id!,
      ranchoId: categoria.ranchoId,
    );

    final idGerado = await DatabaseHelper.instance.insertItem(
      itemByName,
      categoria.id,
    );

    final itemComId = itemByName.copyWith(id: idGerado);

    if (!_itensAgrupados.containsKey(itemComId.categoriaId)) {
      _itensAgrupados[itemComId.categoriaId!] = [];
    }

    _itensAgrupados[itemComId.categoriaId]!.add(itemComId);
    notifyListeners();
  }

  Future<void> inicializarItensDoRancho(int ranchoId) async {
    final List<ItemModel> listaDoBanco = await DatabaseHelper.instance
        .getItensPorRancho(ranchoId);

    _itensAgrupados.clear();

    for (var item in listaDoBanco) {
      final idCat = item.categoriaId;

      if (!_itensAgrupados.containsKey(idCat)) {
        _itensAgrupados[idCat!] = [];
      }

      _itensAgrupados[idCat]!.add(item);
    }

    notifyListeners();
  }

  List<ItemModel> getItensDaCategoria(int categoriaId) {
    return _itensAgrupados[categoriaId] ?? [];
  }

  void atualizarItensNaMemoria(List<ItemModel> todosOsItens) {
    _itensAgrupados.clear();
    for (var item in todosOsItens) {
      _itensAgrupados.putIfAbsent(item.categoriaId!, () => []).add(item);
    }
    notifyListeners();
  }

  List<String> getListaItens(CategoriaModel categoria) {
    final itens = getItensDaCategoria(categoria.id!);

    return itens.map((item) => item.nomeItem).toList();
  }

  bool isCategoriaCompleta(CategoriaModel categoria) {
    final itens = getItensDaCategoria(categoria.id!);
    if (itens.isEmpty) return false;
    return itens.every((item) => item.isComprado == true);
  }

  void toggleIsComprado(ItemModel item) {
    item.isComprado = !item.isComprado;
    notifyListeners();
  }

  double calcularTotalCategoria(CategoriaModel categoria) {
    final itens = getItensDaCategoria(categoria.id!);
    double totalCategoria = itens
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
