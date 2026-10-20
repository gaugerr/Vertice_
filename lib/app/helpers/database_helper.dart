import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vertice/app/model/category_model.dart';
import 'package:vertice/app/model/item_model.dart';
import 'package:vertice/app/model/shopping_list_model.dart';

class DatabaseHelper {
  // Singleton: ensures only ONE instance of this class exists throughout the app.
  static final DatabaseHelper instance = DatabaseHelper._init();

  // Holds the actual database connection.
  static Database? _database;

  // Private constructor: prevents instantiation via DatabaseHelper() elsewhere.
  DatabaseHelper._init() : _providedDatabase = null;

  DatabaseHelper.forDatabase(Database db) : _providedDatabase = db;
  final Database? _providedDatabase;

  // Getter: returns the open database, or initialises it if needed.
  Future<Database> get database async {
    if (_providedDatabase != null) return _providedDatabase!;
    if (_database != null) return _database!;
    _database = await _initDB('vertice_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: migrate,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // openDatabase runs upgrades in a transaction. Unknown schemas fail closed.
  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    Future<void> renameTable(String oldName, String newName) async {
      final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type = 'table'");
      final names = tables.map((row) => row['name']).toSet();
      if (names.contains(oldName)) {
        if (names.contains(newName)) {
          throw StateError('Ambiguous database schema: $oldName and $newName');
        }
        await db.execute('ALTER TABLE "$oldName" RENAME TO "$newName"');
      }
    }
    await renameTable('ranchos', 'shoppingLists');
    await renameTable('categorias', 'categories');
    await renameTable('itens', 'items');
    const mappings = {
      'shoppingLists': {'mercado': 'storeName', 'data': 'date', 'descricao': 'description'},
      'categories': {'tituloCategoria': 'title', 'ranchoId': 'shoppingListId'},
      'items': {'nomeItem': 'name', 'preco': 'price', 'quantidade': 'quantity',
        'unidade': 'unit', 'isComprado': 'isPurchased',
        'categoriaId': 'categoryId', 'ranchoId': 'shoppingListId'},
    };
    for (final table in mappings.entries) {
      final info = await db.rawQuery('PRAGMA table_info("${table.key}")');
      final columns = info.map((row) => row['name']).toSet();
      if (columns.isEmpty) throw StateError('Missing table: ${table.key}');
      for (final column in table.value.entries) {
        if (columns.contains(column.key)) {
          if (columns.contains(column.value)) throw StateError('Ambiguous column');
          await db.execute('ALTER TABLE "${table.key}" RENAME COLUMN "${column.key}" TO "${column.value}"');
        }
      }
    }
    final violations = await db.rawQuery('PRAGMA foreign_key_check');
    if (violations.isNotEmpty) throw StateError('Database has orphan records');
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
    final db = await instance.database;
    return await db.insert('shoppingLists', shoppingList.toMap());
  }

  // INSERT CATEGORY — inserts a category linked to a shopping list
  Future<int> insertCategory(CategoryModel category, int shoppingListId) async {
    final db = await instance.database;
    final map = category.toMap();
    map['shoppingListId'] = shoppingListId;
    return await db.insert('categories', map);
  }

  // CREATE SHOPPING LIST WITH DEFAULT CATEGORIES
  Future<int> createShoppingListWithCategories(
    ShoppingListModel newShoppingList,
  ) async {
    final db = await database;
    return db.transaction((txn) async {
      final id = await txn.insert('shoppingLists', newShoppingList.toMap());
      for (final category in CategoryModel.generateDefaults()) {
        final map = category.toMap();
        map['shoppingListId'] = id;
        await txn.insert('categories', map);
      }
      return id;
    });
  }

  // GET ALL SHOPPING LISTS
  Future<List<ShoppingListModel>> getAllShoppingLists() async {
    final db = await instance.database;
    final result = await db.query('shoppingLists');
    return result.map((json) => ShoppingListModel.fromMap(json)).toList();
  }

  // GET SHOPPING LIST BY ID
  Future<ShoppingListModel?> getShoppingListById(int id) async {
    final db = await instance.database;
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
    final db = await instance.database;
    final result = await db.query(
      'categories',
      where: 'shoppingListId = ?',
      whereArgs: [shoppingListId],
    );
    return result.map((json) => CategoryModel.fromMap(json)).toList();
  }

  // GET ITEMS FOR A CATEGORY
  Future<List<ItemModel>> getItemsByCategory(int categoryId) async {
    final db = await instance.database;
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
    final db = await instance.database;
    final result = await db.query(
      'items',
      where: 'shoppingListId = ?',
      whereArgs: [shoppingListId],
    );
    return result.map((json) => ItemModel.fromMap(json)).toList();
  }

  // UPDATE ITEM
  Future<int> updateItem(ItemModel item) async {
    final db = await instance.database;
    return await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> updateShoppingList(ShoppingListModel list) async {
    final db = await database;
    return db.update('shoppingLists', list.toMap(), where: 'id = ?', whereArgs: [list.id]);
  }

  // DELETE ITEM
  Future<int> deleteItem(int id) async {
    final db = await instance.database;
    return await db.delete('items', where: 'id = ?', whereArgs: [id]);
  }

  // DELETE SHOPPING LIST
  Future<int> deleteShoppingList(int id) async {
    final db = await instance.database;
    return await db.delete('shoppingLists', where: 'id = ?', whereArgs: [id]);
  }

  // INSERT ITEM
  Future<int> insertItem(ItemModel item, int categoryId) async {
    final db = await instance.database;
    final map = item.toMap();
    map['categoryId'] = categoryId;
    final id = await db.insert('items', map);
    return id;
  }
}
