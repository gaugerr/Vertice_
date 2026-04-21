import 'dart:convert';

import 'package:flutter/widgets.dart';

class ItemModel {
  int? id;
  String name;
  double price;
  double quantity;
  String unit;
  bool isPurchased;
  int? categoryId;
  int? shoppingListId;

  ItemModel({
    this.id,
    required this.name,
    this.price = 0.0,
    this.quantity = 1.0,
    this.unit = 'un',
    this.isPurchased = false,
    this.categoryId,
    this.shoppingListId,
  });

  ItemModel copyWith({
    int? id,
    String? name,
    double? price,
    double? quantity,
    String? unit,
    bool? isPurchased,
    ValueGetter<int?>? categoryId,
    ValueGetter<int?>? shoppingListId,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      isPurchased: isPurchased ?? this.isPurchased,
      categoryId: categoryId != null ? categoryId() : this.categoryId,
      shoppingListId:
          shoppingListId != null ? shoppingListId() : this.shoppingListId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'isPurchased': isPurchased ? 1 : 0,
      'categoryId': categoryId,
      'shoppingListId': shoppingListId,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id']?.toInt(),
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      quantity: map['quantity']?.toDouble() ?? 0.0,
      unit: map['unit'] ?? '',
      isPurchased: map['isPurchased'] == 1,
      categoryId: map['categoryId']?.toInt(),
      shoppingListId: map['shoppingListId']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemModel.fromJson(String source) =>
      ItemModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ItemModel(id: $id, name: $name, price: $price, quantity: $quantity, unit: $unit, isPurchased: $isPurchased, categoryId: $categoryId, shoppingListId: $shoppingListId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemModel &&
        other.id == id &&
        other.name == name &&
        other.price == price &&
        other.quantity == quantity &&
        other.unit == unit &&
        other.isPurchased == isPurchased &&
        other.categoryId == categoryId &&
        other.shoppingListId == shoppingListId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        price.hashCode ^
        quantity.hashCode ^
        unit.hashCode ^
        isPurchased.hashCode ^
        categoryId.hashCode ^
        shoppingListId.hashCode;
  }
}
