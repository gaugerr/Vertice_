import '../model/category_model.dart';
import '../model/item_model.dart';
import '../model/shopping_list_model.dart';
import 'shopping_backup.dart';

abstract interface class ShoppingRepository {
  Future<int> createShoppingListWithCategories(ShoppingListModel list);
  Future<List<ShoppingListModel>> getAllShoppingLists();
  Future<List<CategoryModel>> getCategoriesByShoppingList(int listId);
  Future<List<ItemModel>> getItemsByShoppingList(int listId);
  Future<int> insertItem(ItemModel item, int categoryId);
  Future<int> updateItem(ItemModel item);
  Future<int> updateShoppingList(ShoppingListModel list);
  Future<int> deleteItem(int id);
  Future<int> deleteShoppingList(int id);
  Future<ShoppingBackup> exportBackup();
  Future<void> restoreBackup(ShoppingBackup backup);
}
