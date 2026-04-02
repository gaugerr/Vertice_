import 'dart:convert';

class CategoriaModel {
  int? id;
  int? shoppingListId; // O elo com a shoppingList
  String tituloCategoria;

  CategoriaModel({this.id, this.shoppingListId, required this.tituloCategoria});

  // Nota: Aqui as categorias nascem sem shoppingListId, você deve atribuir
  // o ID da shoppingList atual antes de salvar no banco.
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

  // Simplificado para aceitar int? direto, como fizemos na ItemModel
  CategoriaModel copyWith({
    int? id,
    int? shoppingListId,
    String? tituloCategoria,
  }) {
    return CategoriaModel(
      id: id ?? this.id,
      shoppingListId: shoppingListId ?? this.shoppingListId,
      tituloCategoria: tituloCategoria ?? this.tituloCategoria,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'shoppingListId': shoppingListId, // Injetado
      'tituloCategoria': tituloCategoria,
    };
  }

  factory CategoriaModel.fromMap(Map<String, dynamic> map) {
    return CategoriaModel(
      id: map['id']?.toInt(),
      shoppingListId: map['shoppingListId']?.toInt(), // Injetado
      tituloCategoria: map['tituloCategoria'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoriaModel.fromJson(String source) =>
      CategoriaModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'CategoriaModel(id: $id, shoppingListId: $shoppingListId, tituloCategoria: $tituloCategoria)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoriaModel &&
        other.id == id &&
        other.shoppingListId == shoppingListId && // Comparação injetada
        other.tituloCategoria == tituloCategoria;
  }

  @override
  int get hashCode =>
      id.hashCode ^ shoppingListId.hashCode ^ tituloCategoria.hashCode;
}
