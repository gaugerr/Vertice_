class ItemModel {
  final String id;
  final String nomeItem;
  final double preco;
  final double quantidade;
  final String unidade;
  bool isComprado;

  ItemModel({
    required this.id,
    required this.nomeItem,
    this.preco = 0.0,
    this.quantidade = 1.0,
    this.unidade = 'un',
    this.isComprado = false,
  });
}
