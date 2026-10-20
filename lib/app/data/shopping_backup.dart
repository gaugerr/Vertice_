import 'dart:convert';

/// Validated, versioned transfer format, independent of either local database.
class ShoppingBackup {
  final List<Map<String, Object?>> lists;
  final List<Map<String, Object?>> categories;
  final List<Map<String, Object?>> items;

  ShoppingBackup._(this.lists, this.categories, this.items);

  factory ShoppingBackup.fromRows({
    required List<Map<String, Object?>> lists,
    required List<Map<String, Object?>> categories,
    required List<Map<String, Object?>> items,
  }) => ShoppingBackup.parse(jsonEncode({
    'format': 'vertice-backup', 'version': 1,
    'lists': lists, 'categories': categories, 'items': items,
  }));

  factory ShoppingBackup.parse(String source) {
    if (source.length > 10000000) throw const FormatException('Backup maior que 10 MB.');
    final root = jsonDecode(source);
    if (root is! Map || root['format'] != 'vertice-backup' || root['version'] != 1) {
      throw const FormatException('Arquivo de backup incompatível.');
    }
    List<Map<String, Object?>> rows(String key, Set<String> fields) {
      final raw = root[key];
      if (raw is! List || raw.length > 50000) throw const FormatException('Quantidade de registros inválida.');
      final ids = <int>{};
      return raw.map((row) {
        if (row is! Map || row.keys.toSet().difference(fields).isNotEmpty ||
            fields.difference(row.keys.toSet()).isNotEmpty ||
            row['id'] is! int || row['id'] <= 0 || !ids.add(row['id'] as int)) {
          throw const FormatException('Registro inválido ou duplicado.');
        }
        return Map<String, Object?>.unmodifiable(Map<String, Object?>.from(row));
      }).toList(growable: false);
    }
    void name(Object? value) {
      if (value is! String || value.trim().isEmpty || value.length > 50) {
        throw const FormatException('Nome inválido no backup.');
      }
    }
    final lists = rows('lists', {'id', 'storeName', 'date', 'description'});
    final categories = rows('categories', {'id', 'title', 'shoppingListId'});
    final items = rows('items', {'id', 'name', 'price', 'quantity', 'unit', 'isPurchased', 'categoryId', 'shoppingListId'});
    final listIds = lists.map((row) => row['id']).toSet();
    final categoryLists = {for (final row in categories) row['id']: row['shoppingListId']};
    for (final row in lists) {
      name(row['storeName']);
      if (row['date'] is! int || (row['date'] as int).abs() > 8640000000000000 ||
          row['description'] is! String || (row['description'] as String).length > 10000) {
        throw const FormatException('Lista inválida.');
      }
    }
    for (final row in categories) {
      name(row['title']);
      if (!listIds.contains(row['shoppingListId'])) throw const FormatException('Categoria sem lista.');
    }
    for (final row in items) {
      name(row['name']);
      final price = row['price'];
      final quantity = row['quantity'];
      if (price is! num || !price.isFinite || price < 0 ||
          quantity is! num || !quantity.isFinite || quantity <= 0 ||
          !['un', 'kg', 'L'].contains(row['unit']) ||
          ![0, 1].contains(row['isPurchased']) ||
          !listIds.contains(row['shoppingListId']) ||
          !categoryLists.containsKey(row['categoryId']) ||
          categoryLists[row['categoryId']] != row['shoppingListId']) {
        throw const FormatException('Item ou relacionamento inválido.');
      }
    }
    return ShoppingBackup._(List.unmodifiable(lists), List.unmodifiable(categories), List.unmodifiable(items));
  }

  String encode() => const JsonEncoder.withIndent('  ').convert({
    'format': 'vertice-backup', 'version': 1,
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'lists': lists, 'categories': categories, 'items': items,
  });
}
