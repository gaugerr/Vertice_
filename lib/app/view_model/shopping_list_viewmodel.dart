import 'package:flutter/material.dart';
import '../data/shopping_repository.dart';
import '../data/shopping_backup.dart';
import '../data/repository_factory.dart';
import 'package:vertice/app/model/category_model.dart';
import 'package:vertice/app/model/item_model.dart';
import 'package:vertice/app/model/shopping_list_model.dart';

class ShoppingListViewModel extends ChangeNotifier {
  ShoppingListViewModel({ShoppingRepository? repository, ShoppingRepository? databaseHelper})
      : _db = repository ?? databaseHelper ?? createRepository();
  final ShoppingRepository _db;
  bool isLoading = true;
  String? loadError;
  String? errorMessage;
  Future<void> _pending = Future<void>.value();

  // Serialize writes and never publish an uncommitted change.
  Future<bool> _write(Future<void> Function() action) {
    final result = _pending.then((_) async {
      try {
        await action();
        errorMessage = null;
        notifyListeners();
        return true;
      } catch (error) {
        errorMessage = error is ArgumentError
            ? 'Confira o nome, preço e quantidade informados.'
            : 'Não foi possível salvar. A alteração não foi aplicada. Tente novamente.';
        notifyListeners();
        return false;
      }
    });
    _pending = result.then<void>((_) {});
    return result;
  }

  void _validateName(String name) {
    if (name.trim().isEmpty || name.trim().length > 50) {
      throw ArgumentError('Invalid name');
    }
  }

  final Map<int, List<ItemModel>> _groupedItems = {};
  final List<ShoppingListModel> _shoppingLists = [];
  List<ShoppingListModel> get shoppingLists => _shoppingLists;

  Future<bool> addShoppingList({
    required String storeName,
    required DateTime date,
    required String description,
  }) => _write(() async {
    _validateName(storeName);
    final shoppingList = ShoppingListModel(
      id: null,
      storeName: storeName.trim(),
      date: date,
      categories: [],
      description: description,
    );

    final generatedId =
        await _db.createShoppingListWithCategories(
      shoppingList,
    );

    final shoppingListWithId = shoppingList.copyWith(id: generatedId);

    final alreadyExists = _shoppingLists.any((item) => item.id == generatedId);

    if (!alreadyExists) {
      _shoppingLists.insert(0, shoppingListWithId);
      notifyListeners();
    }
  });

  Future<bool> addItem({
    required CategoryModel category,
    required String itemName,
  }) => _write(() async {
    _validateName(itemName);
    final item = ItemModel(
      name: itemName.trim(),
      categoryId: category.id!,
      shoppingListId: category.shoppingListId,
    );

    final generatedId = await _db.insertItem(
      item,
      category.id!,
    );

    final itemWithId = item.copyWith(id: generatedId);

    if (!_groupedItems.containsKey(itemWithId.categoryId)) {
      _groupedItems[itemWithId.categoryId!] = [];
    }

    _groupedItems[itemWithId.categoryId]!.add(itemWithId);
    notifyListeners();
  });

  Future<void> initializeShoppingLists() async {
    isLoading = true;
    loadError = null;
    notifyListeners();
    try {
      final lists = await _db.getAllShoppingLists();
      _shoppingLists..clear()..addAll(lists);
    } catch (_) {
      loadError = 'Não foi possível abrir os dados locais. Confira se o navegador está atualizado e permite armazenamento, fora do modo privado.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<List<CategoryModel>> getCategoriesForList(int id) => _db.getCategoriesByShoppingList(id);

  Future<String> exportBackup() async {
    await _pending;
    return (await _db.exportBackup()).encode();
  }

  Future<bool> restoreBackup(String source) => _write(() async {
    final backup = ShoppingBackup.parse(source);
    await _db.restoreBackup(backup);
    _groupedItems.clear();
    _shoppingLists..clear()..addAll(await _db.getAllShoppingLists());
  });

  Future<void> loadItemsForList(int shoppingListId) async {
    final List<ItemModel> dbItems =
        await _db.getItemsByShoppingList(shoppingListId);

    _groupedItems.clear();

    for (var item in dbItems) {
      final catId = item.categoryId;

      if (!_groupedItems.containsKey(catId)) {
        _groupedItems[catId!] = [];
      }

      _groupedItems[catId]!.add(item);
    }

    notifyListeners();
  }

  List<ItemModel> getItemsByCategory(int categoryId) {
    return _groupedItems[categoryId] ?? [];
  }

  void updateItemsInMemory(List<ItemModel> allItems) {
    _groupedItems.clear();
    for (var item in allItems) {
      _groupedItems.putIfAbsent(item.categoryId!, () => []).add(item);
    }
    notifyListeners();
  }

  List<String> getItemNames(CategoryModel category) {
    final items = getItemsByCategory(category.id!);
    return items.map((item) => item.name).toList();
  }

  bool isCategoryComplete(CategoryModel category) {
    final items = getItemsByCategory(category.id!);
    if (items.isEmpty) return false;
    return items.every((item) => item.isPurchased == true);
  }

  int _itemCents(ItemModel item) => (item.price * item.quantity * 100).round();

  double calculateCategoryTotal(CategoryModel category) =>
      getItemsByCategory(category.id!).where((item) => item.isPurchased)
          .fold<int>(0, (sum, item) => sum + _itemCents(item)) / 100;

  double calculateListTotal(ShoppingListModel shoppingList) =>
      _groupedItems.values.expand((items) => items)
          .where((item) => item.isPurchased && item.shoppingListId == shoppingList.id)
          .fold<int>(0, (sum, item) => sum + _itemCents(item)) / 100;

  double calculateItemTotal(ItemModel item) => _itemCents(item) / 100;

  Future<bool> updateItem(ItemModel updatedItem) => _write(() async {
    _validateName(updatedItem.name);
    if (!updatedItem.price.isFinite || updatedItem.price < 0 ||
        !updatedItem.quantity.isFinite || updatedItem.quantity <= 0 ||
        !['un', 'kg', 'L'].contains(updatedItem.unit)) {
      throw ArgumentError('Invalid price or quantity');
    }
    final saved = updatedItem.copyWith(name: updatedItem.name.trim());
    if (await _db.updateItem(saved) != 1) throw StateError('Item not found');
    final list = _groupedItems[saved.categoryId];
    final index = list?.indexWhere((item) => item.id == saved.id) ?? -1;
    if (index >= 0) list![index] = saved;
  });

  Future<bool> updateShoppingList(ShoppingListModel shoppingList) => _write(() async {
    _validateName(shoppingList.storeName);
    final saved = shoppingList.copyWith(storeName: shoppingList.storeName.trim());
    if (await _db.updateShoppingList(saved) != 1) throw StateError('List not found');
    final index = _shoppingLists.indexWhere((list) => list.id == saved.id);
    if (index >= 0) _shoppingLists[index] = saved;
  });

  Future<bool> deleteItem(ItemModel item) => _write(() async {
    if (await _db.deleteItem(item.id!) != 1) throw StateError('Item not found');
    _groupedItems[item.categoryId]?.removeWhere((entry) => entry.id == item.id);
  });

  Future<bool> deleteShoppingList(ShoppingListModel shoppingList) => _write(() async {
    if (await _db.deleteShoppingList(shoppingList.id!) != 1) throw StateError('List not found');
    _shoppingLists.removeWhere((list) => list.id == shoppingList.id);
    for (final items in _groupedItems.values) {
      items.removeWhere((item) => item.shoppingListId == shoppingList.id);
    }
  });
}

