import 'dart:convert';

class CategoryModel {
  int? id;
  int? shoppingListId;
  String title;

  CategoryModel({this.id, this.shoppingListId, required this.title});

  // Note: Categories are created without a shoppingListId; assign
  // the current shoppingList ID before saving to the database.
  static List<CategoryModel> generateDefaults() {
    return [
      CategoryModel(title: 'Essenciais'),
      CategoryModel(title: 'Hortifruti'),
      CategoryModel(title: 'Higiene e Limpeza'),
      CategoryModel(title: 'Padaria e Laticínios'),
      CategoryModel(title: 'Carnes e Bebidas'),
      CategoryModel(title: 'Outros'),
    ];
  }

  CategoryModel copyWith({
    int? id,
    int? shoppingListId,
    String? title,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      title: title ?? this.title,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shoppingListId': shoppingListId,
      'title': title,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id']?.toInt(),
      shoppingListId: map['shoppingListId']?.toInt(),
      title: map['title'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoryModel.fromJson(String source) =>
      CategoryModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'CategoryModel(id: $id, shoppingListId: $shoppingListId, title: $title)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoryModel &&
        other.id == id &&
        other.shoppingListId == shoppingListId &&
        other.title == title;
  }

  @override
  int get hashCode => id.hashCode ^ shoppingListId.hashCode ^ title.hashCode;
}
