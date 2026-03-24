import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/model/item_model.dart';
import 'package:rancho_consciente/app/view_model/rancho_viewmodel.dart';

class ItemCard extends StatefulWidget {
  final RanchoViewModel ranchoViewModel;
  final ItemModel itemModel;
  const ItemCard({
    super.key,
    required this.itemModel,
    required this.ranchoViewModel,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _qtdController = TextEditingController();
  final TextEditingController _precoController = TextEditingController();

  // Variável para controlar o estado de carregamento/processamento do botão
  //final bool _isProcessing = false;
  final FocusNode _precoFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();

    _precoFocusNode.addListener(() {
      if (_precoFocusNode.hasFocus) {
        _precoController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _precoController.text.length,
        );
      }
    });

    _qtdController.text = widget.itemModel.quantidade.toString();
    _precoController.text = widget.itemModel.preco.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _qtdController.dispose();
    _precoController.dispose();
    _precoFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Checkbox(
                  visualDensity: VisualDensity.compact,
                  value: widget.itemModel.isComprado,
                  onChanged: (bool? value) {
                    final novoItem = widget.itemModel.copyWith(
                      isComprado: !widget.itemModel.isComprado,
                    );
                    widget.ranchoViewModel.updateItem(novoItem);
                  },
                ),
                SizedBox(width: 10),
                Text(
                  widget.itemModel.nomeItem,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: widget.itemModel.isComprado
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                Spacer(),

                // Spacer(),
                if (widget.itemModel.isComprado) ...[
                  Text(
                    'Total: R\$ ${widget.ranchoViewModel.calcularTotalItem(widget.itemModel).toStringAsFixed(2)}',
                  ),
                  SizedBox(width: 10),
                ],
                PopupMenuButton<int>(
                  icon: const Icon(Icons.more_vert),

                  onSelected: (value) async {
                    if (value == 1) {
                      // Mostra o alerta de confirmação
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(
                              "Excluir Item?",
                              textAlign: TextAlign.center,
                            ),
                            content: Text(
                              "Deseja realmente remover '${widget.itemModel.nomeItem}' da lista?",
                            ),
                            actionsAlignment: MainAxisAlignment.spaceEvenly,
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(
                                  context,
                                ), // Fecha sem fazer nada
                                child: const Text("CANCELAR"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // 1. Fecha o Dialog primeiro
                                  Navigator.pop(context);

                                  // 2. Deleta da memória(instantânea) e depois do banco
                                  await widget.ranchoViewModel.deleteItem(
                                    widget.itemModel,
                                  );
                                },
                                child: const Text(
                                  "EXCLUIR",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    } else if (value == 2) {
                      //logica se for 2 // renomear
                    }
                  },

                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 2, child: Text('Renomear')),
                    const PopupMenuItem(
                      value: 1,
                      child: Text(
                        'Excluir',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Form(
              key: _formKey,
              child: Row(
                children: [
                  if (widget.itemModel.isComprado) ...[
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: widget.itemModel.unidade, // "un", "kg", ou "l"
                        decoration: const InputDecoration(
                          labelText: 'Unidade',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        items: ['un', 'kg', 'L'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null && value.isNotEmpty) {
                            final novoItem = widget.itemModel.copyWith(
                              unidade: value,
                            );

                            widget.ranchoViewModel.updateItem(novoItem);
                          }
                        },
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        controller: _qtdController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          label: Text('Quantidade'),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),

                        onTap: () {
                          _qtdController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _qtdController.text.length,
                          );
                        },
                        onChanged: (value) {
                          final novaQtd =
                              double.tryParse(value.replaceAll(',', '.')) ??
                              0.0;

                          final novoItem = widget.itemModel.copyWith(
                            quantidade: novaQtd,
                          );

                          widget.ranchoViewModel.updateItem(novoItem);
                        },
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        controller: _precoController,
                        focusNode: _precoFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),

                        decoration: InputDecoration(
                          border: InputBorder.none,
                          label: Text('Preço'),

                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          alignLabelWithHint: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        onTap: () {
                          _precoController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _precoController.text.length,
                          );
                        },

                        onFieldSubmitted: (value) {
                          final novoPreco =
                              double.tryParse(value.replaceAll(',', '.')) ??
                              0.0;

                          final novoItem = widget.itemModel.copyWith(
                            preco: novoPreco,
                          );
                          widget.ranchoViewModel.updateItem(novoItem);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
