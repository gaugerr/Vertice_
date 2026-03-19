import 'dart:convert';

import 'package:flutter/widgets.dart';

class ItemModel {
  int? id; //banco deve gerar automaticamente esse id
  String nomeItem;
  double preco;
  double quantidade;
  String unidade;
  bool isComprado;
  int? categoriaId; //futura chave pra ligar a categoria pertencente

  ItemModel({
    this.id,
    required this.nomeItem,
    this.preco = 0.0,
    this.quantidade = 1.0,
    this.unidade = 'un',
    this.isComprado = false,
    this.categoriaId,
  });

  ItemModel copyWith({
    int? id,
    String? nomeItem,
    double? preco,
    double? quantidade,
    String? unidade,
    bool? isComprado,
    ValueGetter<int?>? categoriaId,
  }) {
    return ItemModel(
      id: id ?? this.id,
      nomeItem: nomeItem ?? this.nomeItem,
      preco: preco ?? this.preco,
      quantidade: quantidade ?? this.quantidade,
      unidade: unidade ?? this.unidade,
      isComprado: isComprado ?? this.isComprado,
      categoriaId: categoriaId != null ? categoriaId() : this.categoriaId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nomeItem': nomeItem,
      'preco': preco,
      'quantidade': quantidade,
      'unidade': unidade,
      'isComprado': isComprado ? 1 : 0,
      'categoriaId': categoriaId,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id']?.toInt(),
      nomeItem: map['nomeItem'] ?? '',
      preco: map['preco']?.toDouble() ?? 0.0,
      quantidade: map['quantidade']?.toDouble() ?? 0.0,
      unidade: map['unidade'] ?? '',
      isComprado: map['isComprado'] == 1,
      categoriaId: map['categoriaId']?.toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory ItemModel.fromJson(String source) =>
      ItemModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ItemModel(id: $id, nomeItem: $nomeItem, preco: $preco, quantidade: $quantidade, unidade: $unidade, isComprado: $isComprado, categoriaId: $categoriaId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ItemModel &&
        other.id == id &&
        other.nomeItem == nomeItem &&
        other.preco == preco &&
        other.quantidade == quantidade &&
        other.unidade == unidade &&
        other.isComprado == isComprado &&
        other.categoriaId == categoriaId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nomeItem.hashCode ^
        preco.hashCode ^
        quantidade.hashCode ^
        unidade.hashCode ^
        isComprado.hashCode ^
        categoriaId.hashCode;
  }
}
