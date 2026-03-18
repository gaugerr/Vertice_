import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'categoria_model.dart';

class RanchoModel {
  int? id;
  String mercado;
  DateTime data;
  String descricao;
  List<CategoriaModel> categorias;

  RanchoModel({
    this.id,
    required this.mercado,
    required this.data,
    required this.descricao,
    this.categorias = const [],
  });

  RanchoModel copyWith({
    ValueGetter<int?>? id,
    String? mercado,
    DateTime? data,
    String? descricao,
    List<CategoriaModel>? categorias,
  }) {
    return RanchoModel(
      id: id != null ? id() : this.id,
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

  factory RanchoModel.fromMap(Map<String, dynamic> map) {
    return RanchoModel(
      id: map['id']?.toInt(),
      mercado: map['mercado'] ?? '',
      data: DateTime.fromMillisecondsSinceEpoch(map['data']),
      descricao: map['descricao'] ?? '',
      categorias: [],
    );
  }

  String toJson() => json.encode(toMap());

  factory RanchoModel.fromJson(String source) =>
      RanchoModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'RanchoModel(id: $id, mercado: $mercado, data: $data, descricao: $descricao, categorias: $categorias)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RanchoModel &&
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
