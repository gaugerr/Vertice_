import 'package:flutter/material.dart';
import 'package:vertice/app/helpers/database_helper.dart';
import 'package:vertice/app/model/category_model.dart';
import 'package:vertice/app/model/item_model.dart';
import 'package:vertice/app/model/shopping_list_model.dart';

class ShoppingListViewModel extends ChangeNotifier {
  final Map<int, List<ItemModel>> _groupedItems = {};
  final List<ShoppingListModel> _shoppingLists = [];
  List<ShoppingListModel> get shoppingLists => _shoppingLists;

  Future<void> addShoppingList({
    required String storeName,
    required DateTime date,
    required String description,
  }) async {
    final shoppingList = ShoppingListModel(
      id: null,
      storeName: storeName,
      date: date,
      categories: [],
      description: description,
    );

    final generatedId =
        await DatabaseHelper.instance.createShoppingListWithCategories(
      shoppingList,
    );

    final shoppingListWithId = shoppingList.copyWith(id: generatedId);

    final alreadyExists = _shoppingLists.any((item) => item.id == generatedId);

    if (!alreadyExists) {
      _shoppingLists.insert(0, shoppingListWithId);
      notifyListeners();
    }
  }

  Future<void> addItem({
    required category,
    required itemName,
  }) async {
    final item = ItemModel(
      name: itemName,
      categoryId: category.id!,
      shoppingListId: category.shoppingListId,
    );

    final generatedId = await DatabaseHelper.instance.insertItem(
      item,
      category.id,
    );

    final itemWithId = item.copyWith(id: generatedId);

    if (!_groupedItems.containsKey(itemWithId.categoryId)) {
      _groupedItems[itemWithId.categoryId!] = [];
    }

    _groupedItems[itemWithId.categoryId]!.add(itemWithId);
    notifyListeners();
  }

  Future<void> initializeShoppingLists() async {
    final List<ShoppingListModel> fetchedLists =
        await DatabaseHelper.instance.getAllShoppingLists();

    _shoppingLists.clear();
    _shoppingLists.addAll(fetchedLists);
    notifyListeners();
  }

  Future<void> loadItemsForList(int shoppingListId) async {
    final List<ItemModel> dbItems =
        await DatabaseHelper.instance.getItemsByShoppingList(shoppingListId);

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

  double calculateCategoryTotal(CategoryModel category) {
    final items = getItemsByCategory(category.id!);
    double total = items
        .where((item) => item.isPurchased)
        .fold(0.0, (sum, item) => sum + calculateItemTotal(item));
    return total;
  }

  double calculateListTotal(ShoppingListModel shoppingList) {
    double total = 0.0;
    for (var itemsList in _groupedItems.values) {
      for (var item in itemsList) {
        if (item.isPurchased) {
          total += (item.price * item.quantity);
        }
      }
    }
    return total;
  }

  double calculateItemTotal(ItemModel item) {
    if (item.unit == 'un') {
      return item.quantity * item.price;
    } else {
      return item.price;
    }
  }

  Future<void> updateItem(ItemModel updatedItem) async {
    final list = _groupedItems[updatedItem.categoryId];
    if (list != null) {
      final index = list.indexWhere((i) => i.id == updatedItem.id);
      if (index != -1) {
        list[index] = updatedItem;
      }
    }

    notifyListeners();
    try {
      await DatabaseHelper.instance.updateItem(updatedItem);
    } catch (e) {
      // TODO: show error snackbar and revert to original item
    }
  }

  Future<void> updateShoppingList(ShoppingListModel shoppingList) async {}

  Future<void> deleteItem(ItemModel item) async {
    final list = _groupedItems[item.categoryId];
    if (list == null) return;

    final originalIndex = list.indexWhere((i) => i.id == item.id);

    list.removeAt(originalIndex);
    notifyListeners();

    try {
      await DatabaseHelper.instance.deleteItem(item.id!);
    } catch (e) {
      //
    }
  }

  Future<void> deleteShoppingList(ShoppingListModel shoppingList) async {
    final index = _shoppingLists.indexWhere((i) => i.id == shoppingList.id);

    if (index != -1) {
      final backup = _shoppingLists.removeAt(index);
      notifyListeners();

      try {
        await DatabaseHelper.instance.deleteShoppingList(shoppingList.id!);
      } catch (e) {
        _shoppingLists.insert(index, backup);
        notifyListeners();
      }
    }
  }
}
