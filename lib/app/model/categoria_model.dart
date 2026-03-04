import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'item_model.dart';

class CategoriaModel {
  int? id;
  String tituloCategoria;
  List<ItemModel> itens;

  CategoriaModel({
    this.id,
    required this.tituloCategoria,
    this.itens = const [],
  });

  double get totalCategoria {
    return itens.fold(0.0, (soma, item) => soma + item.preco);
  }

  int get totalComprados {
    return itens.where((item) => item.isComprado).length;
  }

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

  CategoriaModel copyWith({
    ValueGetter<int?>? id,
    String? tituloCategoria,
    List<ItemModel>? itens,
  }) {
    return CategoriaModel(
      id: id != null ? id() : this.id,
      tituloCategoria: tituloCategoria ?? this.tituloCategoria,
      itens: itens ?? this.itens,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tituloCategoria': tituloCategoria,
      // lista de itens não vai pra tabela, cada item terá o id identificando a qual categoria pertence
    };
  }

  factory CategoriaModel.fromMap(Map<String, dynamic> map) {
    return CategoriaModel(
      id: map['id']?.toInt(),
      tituloCategoria: map['tituloCategoria'] ?? '',
      itens:
          [], // Começa vazio; o carregamento será feito por uma query separada
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoriaModel.fromJson(String source) =>
      CategoriaModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'CategoriaModel(id: $id, tituloCategoria: $tituloCategoria, itens: $itens)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoriaModel &&
        other.id == id &&
        other.tituloCategoria == tituloCategoria &&
        listEquals(other.itens, itens);
  }

  @override
  int get hashCode => id.hashCode ^ tituloCategoria.hashCode ^ itens.hashCode;
}
