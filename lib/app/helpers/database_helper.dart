import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vertice/app/model/category_model.dart';
import 'package:vertice/app/model/item_model.dart';
import 'package:vertice/app/model/shopping_list_model.dart';

class DatabaseHelper {
  // Singleton: ensures only ONE instance of this class exists throughout the app.
  static final DatabaseHelper instance = DatabaseHelper._init();

  // Holds the actual database connection.
  Database? _database;
  final DatabaseFactory _factory;
  final String? _databasePath;

  // Private constructor: prevents instantiation via DatabaseHelper() elsewhere.
  DatabaseHelper._init() : _factory = databaseFactory, _databasePath = null;

  @visibleForTesting
  DatabaseHelper.forTesting({
    required DatabaseFactory factory,
    required String databasePath,
  }) : _factory = factory,
       _databasePath = databasePath;

  // Getter: returns the open database, or initialises it if needed.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vertice_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final path =
        _databasePath ?? join(await _factory.getDatabasesPath(), filePath);

    return await _factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
      ),
    );
  }

  // Version 2 is the baseline. Keep it for existing development installations.
  // Older schemas were experimental and are not supported. Future schema
  // changes must add explicit migrations that preserve existing records.
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    throw StateError(
      'Banco de desenvolvimento incompatível (versão $oldVersion). '
      'Limpe os dados do aplicativo ou reinstale-o para usar a versão $newVersion. '
      'O banco existente não foi apagado.',
    );
  }

  Future _createDB(Database db, int version) async {
    // 1. Shopping Lists table (root)
    await db.execute('''
      CREATE TABLE shoppingLists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        storeName TEXT NOT NULL,
        date INTEGER NOT NULL,
        description TEXT
      )
    ''');

    // 2. Categories table (linked to shoppingLists)
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        shoppingListId INTEGER,
        FOREIGN KEY (shoppingListId) REFERENCES shoppingLists (id) ON DELETE CASCADE
      )
    ''');

    // 3. Items table (linked to categories)
    await db.execute('''
      CREATE TABLE items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity REAL NOT NULL,
        unit TEXT NOT NULL,
        isPurchased INTEGER NOT NULL,
        categoryId INTEGER,
        shoppingListId INTEGER,
        FOREIGN KEY (shoppingListId) REFERENCES shoppingLists (id) ON DELETE CASCADE,
        FOREIGN KEY (categoryId) REFERENCES categories (id) ON DELETE CASCADE
      )
    ''');
  }

  // INSERT SHOPPING LIST — inserts and returns the generated ID
  Future<int> insertShoppingList(ShoppingListModel shoppingList) async {
    final db = await database;
    return await db.insert('shoppingLists', shoppingList.toMap());
  }

  // INSERT CATEGORY — inserts a category linked to a shopping list
  Future<int> insertCategory(CategoryModel category, int shoppingListId) async {
    final db = await database;
    final map = category.toMap();
    map['shoppingListId'] = shoppingListId;
    return await db.insert('categories', map);
  }

  // CREATE SHOPPING LIST WITH DEFAULT CATEGORIES
  Future<int> createShoppingListWithCategories(
    ShoppingListModel newShoppingList,
  ) async {
    final shoppingListId = await insertShoppingList(newShoppingList);
    final defaultCategories = CategoryModel.generateDefaults();
    for (var category in defaultCategories) {
      await insertCategory(category, shoppingListId);
    }
    return shoppingListId;
  }

  // GET ALL SHOPPING LISTS
  Future<List<ShoppingListModel>> getAllShoppingLists() async {
    final db = await database;
    final result = await db.query('shoppingLists');
    return result.map((json) => ShoppingListModel.fromMap(json)).toList();
  }

  // GET SHOPPING LIST BY ID
  Future<ShoppingListModel?> getShoppingListById(int id) async {
    final db = await database;
    final maps = await db.query(
      'shoppingLists',
      columns: ['id', 'storeName', 'date', 'description'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ShoppingListModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // GET CATEGORIES FOR A SHOPPING LIST
  Future<List<CategoryModel>> getCategoriesByShoppingList(
    int shoppingListId,
  ) async {
    final db = await database;
    final result = await db.query(
      'categories',
      where: 'shoppingListId = ?',
      whereArgs: [shoppingListId],
    );
    return result.map((json) => CategoryModel.fromMap(json)).toList();
  }

  // GET ITEMS FOR A CATEGORY
  Future<List<ItemModel>> getItemsByCategory(int categoryId) async {
    final db = await database;
    final result = await db.query(
      'items',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'isPurchased ASC, id ASC',
    );
    return result.map((json) => ItemModel.fromMap(json)).toList();
  }

  // GET ALL ITEMS FOR A SHOPPING LIST
  Future<List<ItemModel>> getItemsByShoppingList(int shoppingListId) async {
    final db = await database;
    final result = await db.query(
      'items',
      where: 'shoppingListId = ?',
      whereArgs: [shoppingListId],
    );
    return result.map((json) => ItemModel.fromMap(json)).toList();
  }

  // UPDATE ITEM
  Future<int> updateItem(ItemModel item) async {
    final db = await database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // DELETE ITEM
  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  // DELETE SHOPPING LIST
  Future<int> deleteShoppingList(int id) async {
    final db = await database;
    return await db.delete('shoppingLists', where: 'id = ?', whereArgs: [id]);
  }

  // INSERT ITEM
  Future<int> insertItem(ItemModel item, int categoryId) async {
    final db = await database;
    final map = item.toMap();
    map['categoryId'] = categoryId;
    final id = await db.insert('items', map);
    return id;
  }
}
