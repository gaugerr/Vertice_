import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'categoria_model.dart';

class ShoppingListModel {
  int? id;
  String mercado;
  DateTime data;
  String descricao;
  List<CategoriaModel> categorias;

  ShoppingListModel({
    this.id,
    required this.mercado,
    required this.data,
    required this.descricao,
    this.categorias = const [],
  });

  ShoppingListModel copyWith({
    int? id,
    String? mercado,
    DateTime? data,
    String? descricao,
    List<CategoriaModel>? categorias,
  }) {
    return ShoppingListModel(
      id: id ?? this.id,
      mercado: mercado ?? this.mercado,
      data: data ?? this.data,
      descricao: descricao ?? this.descricao,
      categorias: categorias ?? this.categorias,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mercado': mercado,

      'data': data.millisecondsSinceEpoch,
      'descricao': descricao,
    };
  }

  factory ShoppingListModel.fromMap(Map<String, dynamic> map) {
    return ShoppingListModel(
      id: map['id']?.toInt(),
      mercado: map['mercado'] ?? '',
      data: DateTime.fromMillisecondsSinceEpoch(map['data']),
      descricao: map['descricao'] ?? '',
      categorias: [],
    );
  }

  String toJson() => json.encode(toMap());

  factory ShoppingListModel.fromJson(String source) =>
      ShoppingListModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ShoppingListModel(id: $id, mercado: $mercado, data: $data, descricao: $descricao, categorias: $categorias)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShoppingListModel &&
        other.id == id &&
        other.mercado == mercado &&
        other.data == data &&
        other.descricao == descricao &&
        listEquals(other.categorias, categorias);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        mercado.hashCode ^
        data.hashCode ^
        descricao.hashCode ^
        categorias.hashCode;
  }
}
