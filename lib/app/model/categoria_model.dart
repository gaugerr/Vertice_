import 'dart:convert';

import 'package:flutter/foundation.dart';

class CategoriaModel {
  int? id;
  String tituloCategoria;

  CategoriaModel({this.id, required this.tituloCategoria});

  static List<CategoriaModel> gerarCategoriasPadrao() {
    return [
      CategoriaModel(tituloCategoria: 'Essenciais'),
      CategoriaModel(tituloCategoria: 'Hortifruti'),
      CategoriaModel(tituloCategoria: 'Higiene e Limpeza'),
      CategoriaModel(tituloCategoria: 'Padaria e Laticínios'),
      CategoriaModel(tituloCategoria: 'Carnes e Bebidas'),
      CategoriaModel(tituloCategoria: 'Outros'),
    ];
  }

  CategoriaModel copyWith({ValueGetter<int?>? id, String? tituloCategoria}) {
    return CategoriaModel(
      id: id != null ? id() : this.id,
      tituloCategoria: tituloCategoria ?? this.tituloCategoria,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'tituloCategoria': tituloCategoria};
  }

  factory CategoriaModel.fromMap(Map<String, dynamic> map) {
    return CategoriaModel(
      id: map['id']?.toInt(),
      tituloCategoria: map['tituloCategoria'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoriaModel.fromJson(String source) =>
      CategoriaModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'CategoriaModel(id: $id, tituloCategoria: $tituloCategoria)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoriaModel &&
        other.id == id &&
        other.tituloCategoria == tituloCategoria;
  }

  @override
  int get hashCode => id.hashCode ^ tituloCategoria.hashCode;
}
