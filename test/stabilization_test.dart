import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vertice/app/helpers/database_helper.dart';
import 'package:vertice/app/model/item_model.dart';
import 'package:vertice/app/model/shopping_list_model.dart';
import 'package:vertice/app/model/category_model.dart';
import 'package:vertice/app/view_model/shopping_list_viewmodel.dart';

class FailingDatabase implements DatabaseHelper {
  @override
  Future<int> updateItem(ItemModel item) async => throw StateError('Disk full');
  @override
  Future<int> deleteItem(int id) async => throw StateError('Disk full');
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  sqfliteFfiInit();
  test('all units use quantity and totals are scoped to the list', () {
    final vm = ShoppingListViewModel();
    final list = ShoppingListModel(id: 1, storeName: 'Store', date: DateTime(2026), description: '');
    final items = [
      ItemModel(id: 1, name: 'Rice', price: 20, quantity: 0.5, unit: 'kg', isPurchased: true, categoryId: 1, shoppingListId: 1),
      ItemModel(id: 2, name: 'Milk', price: 4, quantity: 2, unit: 'L', isPurchased: true, categoryId: 1, shoppingListId: 1),
      ItemModel(id: 3, name: 'Other list', price: 100, isPurchased: true, categoryId: 2, shoppingListId: 2),
      ItemModel(id: 4, name: 'Pending', price: 100, categoryId: 1, shoppingListId: 1),
    ];
    vm.updateItemsInMemory(items);
    expect(vm.calculateItemTotal(items.first), 10);
    expect(vm.calculateListTotal(list), 18);
    expect(vm.calculateCategoryTotal(CategoryModel(id: 1, title: 'Food', shoppingListId: 1)), 18);
    vm.dispose();
  });

  test('currency totals sum rounded line amounts', () {
    final vm = ShoppingListViewModel();
    expect(vm.calculateItemTotal(ItemModel(name: 'Fraction', price: 1.99, quantity: 0.333)), 0.66);
    vm.dispose();
  });

  test('failed update and delete preserve committed state', () async {
    final vm = ShoppingListViewModel(databaseHelper: FailingDatabase());
    final item = ItemModel(id: 1, name: 'Original', categoryId: 1, shoppingListId: 1);
    vm.updateItemsInMemory([item]);
    expect(await vm.updateItem(item.copyWith(name: 'Changed')), false);
    expect(vm.getItemsByCategory(1).single.name, 'Original');
    expect(vm.errorMessage, isNotNull);
    expect(await vm.deleteItem(item), false);
    expect(vm.getItemsByCategory(1), hasLength(1));
    expect(await vm.updateItem(item.copyWith(quantity: double.nan)), false);
    vm.dispose();
  });

  Future<Database> legacyDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('PRAGMA foreign_keys = ON');
    await db.execute('CREATE TABLE shoppingLists (id INTEGER PRIMARY KEY, mercado TEXT NOT NULL, data INTEGER NOT NULL, descricao TEXT)');
    await db.execute('CREATE TABLE categorias (id INTEGER PRIMARY KEY, tituloCategoria TEXT NOT NULL, shoppingListId INTEGER REFERENCES shoppingLists(id) ON DELETE CASCADE)');
    await db.execute('CREATE TABLE itens (id INTEGER PRIMARY KEY, nomeItem TEXT NOT NULL, preco REAL NOT NULL, quantidade REAL NOT NULL, unidade TEXT NOT NULL, isComprado INTEGER NOT NULL, categoriaId INTEGER REFERENCES categorias(id) ON DELETE CASCADE, shoppingListId INTEGER REFERENCES shoppingLists(id) ON DELETE CASCADE)');
    await db.insert('shoppingLists', {'id': 1, 'mercado': 'Market', 'data': 0, 'descricao': 'Keep'});
    await db.insert('categorias', {'id': 1, 'tituloCategoria': 'Food', 'shoppingListId': 1});
    await db.insert('itens', {'id': 1, 'nomeItem': 'Rice', 'preco': 20, 'quantidade': 0.5, 'unidade': 'kg', 'isComprado': 1, 'categoriaId': 1, 'shoppingListId': 1});
    return db;
  }

  test('legacy migration preserves IDs, values, relationships and cascade', () async {
    final db = await legacyDatabase();
    addTearDown(db.close);
    await DatabaseHelper.migrate(db, 1, 3);
    final helper = DatabaseHelper.forDatabase(db);
    expect((await helper.getAllShoppingLists()).single.storeName, 'Market');
    final item = (await helper.getItemsByShoppingList(1)).single;
    expect(item.id, 1);
    expect(item.quantity, 0.5);
    expect(item.price, 20);
    expect(item.isPurchased, true);
    expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    await helper.deleteShoppingList(1);
    expect(await db.query('items'), isEmpty);
    expect(await db.query('categories'), isEmpty);
  });

  test('version 2 upgrade leaves current data unchanged', () async {
    final db = await legacyDatabase();
    addTearDown(db.close);
    await DatabaseHelper.migrate(db, 1, 2);
    final before = await db.query('items');
    await DatabaseHelper.migrate(db, 2, 3);
    expect(await db.query('items'), before);
  });

  test('list creation rolls back if a category insertion fails', () async {
    final db = await legacyDatabase();
    addTearDown(db.close);
    await DatabaseHelper.migrate(db, 1, 3);
    await db.execute("CREATE TRIGGER fail_category BEFORE INSERT ON categories BEGIN SELECT RAISE(ABORT, 'test failure'); END");
    final helper = DatabaseHelper.forDatabase(db);
    await expectLater(helper.createShoppingListWithCategories(ShoppingListModel(storeName: 'New', date: DateTime(2026), description: '')), throwsA(anything));
    expect(await db.query('shoppingLists'), hasLength(1));
    expect(await db.query('categories'), hasLength(1));
  });

  test('rename is persisted and survives reload', () async {
    final db = await legacyDatabase();
    addTearDown(db.close);
    await DatabaseHelper.migrate(db, 1, 3);
    final helper = DatabaseHelper.forDatabase(db);
    final vm = ShoppingListViewModel(databaseHelper: helper);
    await vm.initializeShoppingLists();
    expect(await vm.updateShoppingList(vm.shoppingLists.single.copyWith(storeName: 'Renamed')), true);
    await vm.initializeShoppingLists();
    expect(vm.shoppingLists.single.storeName, 'Renamed');
    vm.dispose();
  });
}
