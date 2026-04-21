import 'package:flutter/material.dart';
import 'package:vertice/app/model/item_model.dart';
import 'package:vertice/app/view_model/rancho_viewmodel.dart';
import 'package:vertice/app/widgets/confirm_action_dialog.dart';
import 'package:vertice/app/widgets/popup_menu_button.dart';
import 'package:vertice/app/widgets/rename_action_dialog.dart';

class ItemCard extends StatefulWidget {
  final ShoppingListViewModel ranchoViewModel;
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
  final TextEditingController _renamedItem = TextEditingController();

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
    _renamedItem.text = widget.itemModel.nomeItem.toString();
  }

  @override
  void dispose() {
    _qtdController.dispose();
    _precoController.dispose();
    _precoFocusNode.dispose();
    _renamedItem.dispose();
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

                CustomPopupMenuButton(
                  onExcludePressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmActionDialog(
                        title: 'Excluir Item?',
                        description:
                            "Deseja realmente remover '${widget.itemModel.nomeItem}' da lista?",
                        cancelActionLabel: 'CANCELAR',
                        confirmActionLabel: 'EXCLUIR',
                        onConfirm: () async {
                          await widget.ranchoViewModel.deleteItem(
                            widget.itemModel,
                          );
                        },
                        confirmColor: Colors.red,
                      );
                    },
                  ),
                  onRenamePressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return RenameActionDialog(
                        renamedController: _renamedItem,
                        title: 'Renomear Item',
                        validatorErrorEmpty: 'Por favor, digite o nome do item',
                        validatorErrorMaximumLength:
                            'O nome não pode exceder 50 caracteres',
                        cancelActionLabel: 'CANCELAR',
                        confirmActionLabel: 'SALVAR',

                        onConfirm: (novoNome) async {
                          final itemNovo = widget.itemModel.copyWith(
                            nomeItem: novoNome,
                          );
                          await widget.ranchoViewModel.updateItem(itemNovo);
                        },
                      );
                    },
                  ),
                  excludeLabel: 'Excluir',
                  renameLabel: 'Renomear',
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
