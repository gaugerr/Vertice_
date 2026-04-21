import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'category_model.dart';

class ShoppingListModel {
  int? id;
  String storeName;
  DateTime date;
  String description;
  List<CategoryModel> categories;

  ShoppingListModel({
    this.id,
    required this.storeName,
    required this.date,
    required this.description,
    this.categories = const [],
  });

  ShoppingListModel copyWith({
    int? id,
    String? storeName,
    DateTime? date,
    String? description,
    List<CategoryModel>? categories,
  }) {
    return ShoppingListModel(
      id: id ?? this.id,
      storeName: storeName ?? this.storeName,
      date: date ?? this.date,
      description: description ?? this.description,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'storeName': storeName,
      'date': date.millisecondsSinceEpoch,
      'description': description,
    };
  }

  factory ShoppingListModel.fromMap(Map<String, dynamic> map) {
    return ShoppingListModel(
      id: map['id']?.toInt(),
      storeName: map['storeName'] ?? '',
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      description: map['description'] ?? '',
      categories: [],
    );
  }

  String toJson() => json.encode(toMap());

  factory ShoppingListModel.fromJson(String source) =>
      ShoppingListModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ShoppingListModel(id: $id, storeName: $storeName, date: $date, description: $description, categories: $categories)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShoppingListModel &&
        other.id == id &&
        other.storeName == storeName &&
        other.date == date &&
        other.description == description &&
        listEquals(other.categories, categories);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        storeName.hashCode ^
        date.hashCode ^
        description.hashCode ^
        categories.hashCode;
  }
}
