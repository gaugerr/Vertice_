import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/helpers/database_helper.dart';
import 'package:rancho_consciente/app/model/categoria_model.dart';
import 'package:rancho_consciente/app/model/item_model.dart';
import 'package:rancho_consciente/app/model/rancho_model.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final Map<int, List<ItemModel>> _itensAgrupados = {};
  final List<ShoppingListModel> _shoppingLists = [];
  List<ShoppingListModel> get shoppingLists => _shoppingLists;

  Future<void> adicionarRancho({
    required String nomeMercado,
    required DateTime data,
    required String descricao,
  }) async {
    final rancho = ShoppingListModel(
      id: null, //gerado automaticamente pelo autoincrement do sql
      mercado: nomeMercado,
      data: data,
      categorias:
          [], //gerado automaticamente, databaseHelper relaciona cada cat. com o id do rancho
      descricao: descricao,
    );

    final idGerado = await DatabaseHelper.instance.criarNovoRanchoComCategorias(
      rancho,
    );

    final ranchoComId = rancho.copyWith(id: idGerado);

    bool jaExiste = _shoppingLists.any((item) => item.id == idGerado);

    if (!jaExiste) {
      _shoppingLists.insert(0, ranchoComId);

      notifyListeners();
    }
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

  Future<void> initializeShoppingLists() async {
    final List<ShoppingListModel> shoppingListsGetter = await DatabaseHelper
        .instance
        .getAllRanchos();

    _shoppingLists.clear();
    _shoppingLists.addAll(shoppingListsGetter);
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

  double calcularTotalCategoria(CategoriaModel categoria) {
    final itens = getItensDaCategoria(categoria.id!);
    double totalCategoria = itens
        .where((item) => item.isComprado)
        .fold(0.0, (soma, item) => soma + calcularTotalItem(item));

    return totalCategoria;
  }

  double calcularTotalRancho(ShoppingListModel rancho) {
    double total = 0.0;
    // Percorre cada "balde" (lista de itens) dentro do Mapa
    for (var listaDeItens in _itensAgrupados.values) {
      for (var item in listaDeItens) {
        if (item.isComprado) {
          // Soma: Preço * Quantidade
          total += (item.preco * item.quantidade);
        }
      }
    }

    return total;
  }

  double calcularTotalItem(ItemModel item) {
    if (item.unidade == 'un') {
      return item.quantidade * item.preco;
    } else {
      return item.preco;
    }
  }

  //função de updateItem completa, atualiza na memória (usuário vê a mudança instantâneamente) e depois atualiza no banco de dados em segundo plano
  Future<void> updateItem(ItemModel itemNovo) async {
    //atualiza na memória
    final lista = _itensAgrupados[itemNovo.categoriaId];
    if (lista != null) {
      final index = lista.indexWhere((i) => i.id == itemNovo.id);
      if (index != -1) {
        lista[index] = itemNovo;
      }
    }

    notifyListeners();
    try {
      await DatabaseHelper.instance.updateItem(itemNovo);
    } catch (e) {
      //todo implementar snack bar de erro e reverter ao item original
    }
  }

  Future<void> updateBuyList(ShoppingListModel rancho) async {}

  Future<void> deleteItem(ItemModel item) async {
    //posição original do item
    final lista = _itensAgrupados[item.categoriaId];
    if (lista == null) return;

    final indexOriginal = lista.indexWhere((i) => i.id == item.id);

    //remove da tela NA HORA
    lista.removeAt(indexOriginal);
    notifyListeners();

    try {
      await DatabaseHelper.instance.deleteItem(item.id!);
    } catch (e) {
      //
    }
  }

  Future<void> deleteBuyList(ShoppingListModel rancho) async {
    // 1. Localiza o índice real comparando os IDs

    final index = _shoppingLists.indexWhere((i) => i.id == rancho.id);

    if (index != -1) {
      // 2. Remove da lista e guarda o backup (caso o banco falhe)
      final backup = _shoppingLists.removeAt(index);

      // 3. O SEGREDO: notifyListeners() IMEDIATAMENTE após o removeAt
      notifyListeners();

      try {
        await DatabaseHelper.instance.deleteRancho(rancho.id!);
      } catch (e) {
        // 4. Se o banco der erro, devolvemos o item para a lista
        _shoppingLists.insert(index, backup);
        notifyListeners();
      }
    }
  }
}
