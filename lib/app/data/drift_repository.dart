import 'package:drift/drift.dart';
import '../model/category_model.dart';
import '../model/item_model.dart';
import '../model/shopping_list_model.dart';
import 'shopping_backup.dart';
import 'shopping_repository.dart';

class VerticeDatabase extends GeneratedDatabase {
  VerticeDatabase(QueryExecutor executor) : super(executor);

  @override
  int get schemaVersion => 1;
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (_) async {
      await customStatement('CREATE TABLE shoppingLists (id INTEGER PRIMARY KEY AUTOINCREMENT, storeName TEXT NOT NULL, date INTEGER NOT NULL, description TEXT)');
      await customStatement('CREATE TABLE categories (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, shoppingListId INTEGER NOT NULL REFERENCES shoppingLists(id) ON DELETE CASCADE)');
      await customStatement('CREATE TABLE items (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, price REAL NOT NULL CHECK(price >= 0), quantity REAL NOT NULL CHECK(quantity > 0), unit TEXT NOT NULL, isPurchased INTEGER NOT NULL, categoryId INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE, shoppingListId INTEGER NOT NULL REFERENCES shoppingLists(id) ON DELETE CASCADE)');
    },
    beforeOpen: (_) async => customStatement('PRAGMA foreign_keys = ON'),
    onUpgrade: (_, from, to) async => throw StateError('Migração de banco não implementada: $from → $to'),
  );
}

class DriftShoppingRepository implements ShoppingRepository {
  final VerticeDatabase database;
  DriftShoppingRepository(QueryExecutor executor) : database = VerticeDatabase(executor);

  List<Variable> _variables(Iterable<Object?> values) => values.map((value) {
    if (value == null) return const Variable<String>(null);
    if (value is int) return Variable<int>(value);
    if (value is num) return Variable<double>(value.toDouble());
    if (value is String) return Variable<String>(value);
    throw ArgumentError('Unsupported SQL value');
  }).toList();

  Future<List<Map<String, Object?>>> _query(String sql, [List<Object?> args = const []]) async =>
    (await database.customSelect(sql, variables: _variables(args)).get()).map((row) => row.data).toList();

  Future<int> _insert(String table, Map<String, Object?> data) {
    final values = Map<String, Object?>.from(data)..removeWhere((key, value) => key == 'id' && value == null);
    return database.customInsert('INSERT INTO $table (${values.keys.join(',')}) VALUES (${List.filled(values.length, '?').join(',')})', variables: _variables(values.values));
  }

  Future<int> _update(String table, Map<String, Object?> data) => database.customUpdate(
    'UPDATE $table SET ${data.keys.where((key) => key != 'id').map((key) => '$key = ?').join(',')} WHERE id = ?',
    variables: _variables([...data.entries.where((entry) => entry.key != 'id').map((entry) => entry.value), data['id']]),
  );

  @override
  Future<int> createShoppingListWithCategories(ShoppingListModel list) => database.transaction(() async {
    final id = await _insert('shoppingLists', list.toMap());
    for (final category in CategoryModel.generateDefaults()) {
      await _insert('categories', category.copyWith(shoppingListId: id).toMap());
    }
    return id;
  });

  @override
  Future<List<ShoppingListModel>> getAllShoppingLists() async =>
    (await _query('SELECT * FROM shoppingLists ORDER BY id DESC')).map(ShoppingListModel.fromMap).toList();
  @override
  Future<List<CategoryModel>> getCategoriesByShoppingList(int listId) async =>
    (await _query('SELECT * FROM categories WHERE shoppingListId = ? ORDER BY id', [listId])).map(CategoryModel.fromMap).toList();
  @override
  Future<List<ItemModel>> getItemsByShoppingList(int listId) async =>
    (await _query('SELECT * FROM items WHERE shoppingListId = ? ORDER BY id', [listId])).map(ItemModel.fromMap).toList();
  @override
  Future<int> insertItem(ItemModel item, int categoryId) => _insert('items', {...item.toMap(), 'categoryId': categoryId});
  @override
  Future<int> updateItem(ItemModel item) => _update('items', item.toMap());
  @override
  Future<int> updateShoppingList(ShoppingListModel list) => _update('shoppingLists', list.toMap());
  @override
  Future<int> deleteItem(int id) => database.customUpdate('DELETE FROM items WHERE id = ?', variables: [Variable<int>(id)]);
  @override
  Future<int> deleteShoppingList(int id) => database.customUpdate('DELETE FROM shoppingLists WHERE id = ?', variables: [Variable<int>(id)]);
  @override
  Future<ShoppingBackup> exportBackup() => database.transaction(() async => ShoppingBackup.fromRows(
    lists: await _query('SELECT * FROM shoppingLists'),
    categories: await _query('SELECT * FROM categories'),
    items: await _query('SELECT * FROM items'),
  ));
  @override
  Future<void> restoreBackup(ShoppingBackup backup) => database.transaction(() async {
    await database.customStatement('DELETE FROM items');
    await database.customStatement('DELETE FROM categories');
    await database.customStatement('DELETE FROM shoppingLists');
    for (final row in backup.lists) { await _insert('shoppingLists', row); }
    for (final row in backup.categories) { await _insert('categories', row); }
    for (final row in backup.items) { await _insert('items', row); }
  });

  Future<void> close() => database.close();
}
