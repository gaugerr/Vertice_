import 'dart:convert';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vertice/app/data/drift_repository.dart';
import 'package:vertice/app/data/shopping_backup.dart';
import 'package:vertice/app/model/item_model.dart';
import 'package:vertice/app/model/shopping_list_model.dart';

void main() {
  test('Drift CRUD, cascade, backup and restore preserve values', () async {
    final repo = DriftShoppingRepository(NativeDatabase.memory());
    addTearDown(repo.close);
    final id = await repo.createShoppingListWithCategories(ShoppingListModel(storeName: 'Mercado', date: DateTime(2026), description: 'Mensal'));
    final categories = await repo.getCategoriesByShoppingList(id);
    expect(categories, hasLength(6));
    final itemId = await repo.insertItem(ItemModel(name: 'Arroz', price: 20, quantity: 0.5, unit: 'kg', isPurchased: true, categoryId: categories.first.id, shoppingListId: id), categories.first.id!);
    final item = (await repo.getItemsByShoppingList(id)).single;
    expect(item.id, itemId);
    expect(item.quantity, 0.5);
    await repo.updateItem(item.copyWith(quantity: 2));
    final backup = await repo.exportBackup();
    await repo.deleteShoppingList(id);
    expect(await repo.getItemsByShoppingList(id), isEmpty);
    expect(await repo.getCategoriesByShoppingList(id), isEmpty);
    await repo.restoreBackup(ShoppingBackup.parse(backup.encode()));
    expect((await repo.getItemsByShoppingList(id)).single.quantity, 2);
    expect((await repo.getAllShoppingLists()).single.storeName, 'Mercado');
  });

  test('Drift restores atomically and keeps old data on SQL failure', () async {
    final repo = DriftShoppingRepository(NativeDatabase.memory());
    addTearDown(repo.close);
    await repo.createShoppingListWithCategories(ShoppingListModel(storeName: 'Original', date: DateTime(2026), description: ''));
    final backup = await repo.exportBackup();
    await repo.database.customStatement("CREATE TRIGGER stop_restore BEFORE INSERT ON categories BEGIN SELECT RAISE(ABORT, 'test'); END");
    await expectLater(repo.restoreBackup(backup), throwsA(anything));
    expect((await repo.getAllShoppingLists()).single.storeName, 'Original');
    expect(await repo.getCategoriesByShoppingList(1), hasLength(6));
  });

  test('backup rejects wrong owner relationships, duplicate IDs and versions', () {
    final data = {
      'format': 'vertice-backup', 'version': 1,
      'lists': [{'id': 1, 'storeName': 'A', 'date': 0, 'description': ''}],
      'categories': [{'id': 1, 'title': 'A', 'shoppingListId': 2}],
      'items': [],
    };
    expect(() => ShoppingBackup.parse(jsonEncode(data)), throwsFormatException);
    data['categories'] = [];
    data['version'] = 99;
    expect(() => ShoppingBackup.parse(jsonEncode(data)), throwsFormatException);
    data['version'] = 1;
    data['lists'] = [
      {'id': 1, 'storeName': 'A', 'date': 0, 'description': ''},
      {'id': 1, 'storeName': 'B', 'date': 0, 'description': ''},
    ];
    expect(() => ShoppingBackup.parse(jsonEncode(data)), throwsFormatException);
  });

  test('empty backup is valid and roundtrips', () {
    final backup = ShoppingBackup.fromRows(lists: [], categories: [], items: []);
    expect(ShoppingBackup.parse(backup.encode()).lists, isEmpty);
  });
}
