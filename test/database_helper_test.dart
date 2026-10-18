import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vertice/app/helpers/database_helper.dart';
import 'package:vertice/app/model/item_model.dart';
import 'package:vertice/app/model/shopping_list_model.dart';

void main() {
  late Directory directory;
  late String databasePath;
  final factory = databaseFactoryFfi;

  setUpAll(sqfliteFfiInit);
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('vertice_database_test_');
    databasePath = p.join(directory.path, 'test.db');
  });
  tearDown(() async {
    await factory.deleteDatabase(databasePath);
    await directory.delete();
  });

  DatabaseHelper helper() =>
      DatabaseHelper.forTesting(factory: factory, databasePath: databasePath);

  test(
    'fresh database supports lists, categories, items and cascading deletion',
    () async {
      final databaseHelper = helper();
      final db = await databaseHelper.database;
      addTearDown(db.close);
      expect(await db.getVersion(), 2);

      final listId = await databaseHelper.createShoppingListWithCategories(
        ShoppingListModel(
          storeName: 'Mercado',
          date: DateTime(2026, 10, 18),
          description: 'Compras da semana',
        ),
      );
      final categories = await databaseHelper.getCategoriesByShoppingList(
        listId,
      );
      expect(categories, hasLength(6));
      final itemId = await databaseHelper.insertItem(
        ItemModel(
          name: 'Banana',
          price: 12.5,
          quantity: 2,
          unit: 'kg',
          isPurchased: true,
          categoryId: categories.first.id,
          shoppingListId: listId,
        ),
        categories.first.id!,
      );
      final items = await databaseHelper.getItemsByShoppingList(listId);
      expect(items.single.id, itemId);
      expect(items.single.price, 12.5);
      expect(items.single.quantity, 2);
      expect(items.single.isPurchased, isTrue);

      await databaseHelper.deleteShoppingList(listId);
      expect(await databaseHelper.getAllShoppingLists(), isEmpty);
      expect(await db.query('categories'), isEmpty);
      expect(await db.query('items'), isEmpty);
    },
  );

  test(
    'reopening version 2 preserves saved records and relationships',
    () async {
      final original = helper();
      final db = await original.database;
      final listId = await original.createShoppingListWithCategories(
        ShoppingListModel(
          storeName: 'Mercado',
          date: DateTime(2026, 10, 18),
          description: 'Não apagar',
        ),
      );
      final category = (await original.getCategoriesByShoppingList(
        listId,
      )).first;
      await original.insertItem(
        ItemModel(
          name: 'Arroz',
          categoryId: category.id,
          shoppingListId: listId,
        ),
        category.id!,
      );
      await db.close();

      final reopened = helper();
      final reopenedDb = await reopened.database;
      addTearDown(reopenedDb.close);
      expect(
        (await reopened.getAllShoppingLists()).single.description,
        'Não apagar',
      );
      expect(await reopened.getCategoriesByShoppingList(listId), hasLength(6));
      final item = (await reopened.getItemsByShoppingList(listId)).single;
      expect(item.name, 'Arroz');
      expect(item.categoryId, category.id);
      expect(await reopenedDb.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    },
  );

  test(
    'unsupported development database is rejected without erasing its data',
    () async {
      final legacy = await factory.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, _) async {
            await db.execute(
              'CREATE TABLE categorias (id INTEGER PRIMARY KEY, tituloCategoria TEXT)',
            );
            await db.insert('categorias', {
              'id': 7,
              'tituloCategoria': 'Preservar',
            });
          },
        ),
      );
      await legacy.close();

      await expectLater(
        helper().database,
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('Limpe os dados do aplicativo'),
          ),
        ),
      );

      final untouched = await factory.openDatabase(databasePath);
      addTearDown(untouched.close);
      expect(await untouched.getVersion(), 1);
      expect((await untouched.query('categorias')).single, {
        'id': 7,
        'tituloCategoria': 'Preservar',
      });
    },
  );
}
