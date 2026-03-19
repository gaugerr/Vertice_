import 'dart:convert';

class CategoriaModel {
  int? id;
  int? ranchoId; // O elo com o Rancho
  String tituloCategoria;

  CategoriaModel({this.id, this.ranchoId, required this.tituloCategoria});

  // Nota: Aqui as categorias nascem sem ranchoId, você deve atribuir
  // o ID do rancho atual antes de salvar no banco.
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
  CategoriaModel copyWith({int? id, int? ranchoId, String? tituloCategoria}) {
    return CategoriaModel(
      id: id ?? this.id,
      ranchoId: ranchoId ?? this.ranchoId,
      tituloCategoria: tituloCategoria ?? this.tituloCategoria,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ranchoId': ranchoId, // Injetado
      'tituloCategoria': tituloCategoria,
    };
  }

  factory CategoriaModel.fromMap(Map<String, dynamic> map) {
    return CategoriaModel(
      id: map['id']?.toInt(),
      ranchoId: map['ranchoId']?.toInt(), // Injetado
      tituloCategoria: map['tituloCategoria'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory CategoriaModel.fromJson(String source) =>
      CategoriaModel.fromMap(json.decode(source));

  @override
  String toString() =>
      'CategoriaModel(id: $id, ranchoId: $ranchoId, tituloCategoria: $tituloCategoria)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategoriaModel &&
        other.id == id &&
        other.ranchoId == ranchoId && // Comparação injetada
        other.tituloCategoria == tituloCategoria;
  }

  @override
  int get hashCode =>
      id.hashCode ^ ranchoId.hashCode ^ tituloCategoria.hashCode;
}
