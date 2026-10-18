import 'package:flutter_test/flutter_test.dart';
import 'package:vertice/app/model/category_model.dart';
import 'package:vertice/app/model/item_model.dart';
import 'package:vertice/app/model/shopping_list_model.dart';
import 'package:vertice/app/view_model/shopping_list_viewmodel.dart';

void main() {
  late ShoppingListViewModel viewModel;
  late ShoppingListModel shoppingList;
  final category = CategoryModel(
    id: 10,
    shoppingListId: 1,
    title: 'Essenciais',
  );

  setUp(() {
    viewModel = ShoppingListViewModel();
    shoppingList = ShoppingListModel(
      id: 1,
      storeName: 'Mercado',
      date: DateTime(2026, 10, 18),
      description: '',
    );
  });
  tearDown(() => viewModel.dispose());

  for (final unit in ['un', 'kg', 'L']) {
    test('item, category and list agree for $unit', () {
      final item = ItemModel(
        name: 'Produto',
        price: 10,
        quantity: 2,
        unit: unit,
        isPurchased: true,
        categoryId: category.id,
        shoppingListId: shoppingList.id,
      );
      viewModel.updateItemsInMemory([item]);
      final expected = unit == 'un' ? 20.0 : 10.0;
      expect(viewModel.calculateItemTotal(item), expected);
      expect(viewModel.calculateCategoryTotal(category), expected);
      expect(viewModel.calculateListTotal(shoppingList), expected);
    });
  }

  test('mixed units use final portion prices and ignore unpurchased items', () {
    viewModel.updateItemsInMemory([
      ItemModel(
        name: 'Arroz',
        price: 5,
        quantity: 3,
        isPurchased: true,
        categoryId: 10,
        shoppingListId: 1,
      ),
      ItemModel(
        name: 'Banana',
        price: 8.5,
        quantity: 0.75,
        unit: 'kg',
        isPurchased: true,
        categoryId: 11,
        shoppingListId: 1,
      ),
      ItemModel(
        name: 'Bebida',
        price: 7,
        quantity: 2,
        unit: 'L',
        isPurchased: true,
        categoryId: 12,
        shoppingListId: 1,
      ),
      ItemModel(
        name: 'Pendente',
        price: 100,
        quantity: 4,
        categoryId: 10,
        shoppingListId: 1,
      ),
      ItemModel(
        name: 'Outra lista',
        price: 200,
        isPurchased: true,
        categoryId: 20,
        shoppingListId: 2,
      ),
    ]);
    expect(viewModel.calculateCategoryTotal(category), 15);
    expect(viewModel.calculateListTotal(shoppingList), 30.5);
  });

  test('empty list has zero total', () {
    expect(viewModel.calculateListTotal(shoppingList), 0);
    expect(viewModel.calculateCategoryTotal(category), 0);
  });
}
