import 'package:flutter/material.dart';
import 'package:vertice/app/model/item_model.dart';
import 'package:vertice/app/view_model/shopping_list_viewmodel.dart';
import 'package:vertice/app/widgets/confirm_action_dialog.dart';
import 'package:vertice/app/widgets/popup_menu_button.dart';
import 'package:vertice/app/widgets/rename_action_dialog.dart';

class ItemCard extends StatefulWidget {
  final ShoppingListViewModel viewModel;
  final ItemModel itemModel;
  const ItemCard({
    super.key,
    required this.itemModel,
    required this.viewModel,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _renamedItem = TextEditingController();

  final FocusNode _priceFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _priceFocusNode.addListener(() {
      if (_priceFocusNode.hasFocus) {
        _priceController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _priceController.text.length,
        );
      }
    });

    _quantityController.text = widget.itemModel.quantity.toString();
    _priceController.text = widget.itemModel.price.toStringAsFixed(2);
    _renamedItem.text = widget.itemModel.name.toString();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _priceController.dispose();
    _priceFocusNode.dispose();
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
                  value: widget.itemModel.isPurchased,
                  onChanged: (bool? value) {
                    final updatedItem = widget.itemModel.copyWith(
                      isPurchased: !widget.itemModel.isPurchased,
                    );
                    widget.viewModel.updateItem(updatedItem);
                  },
                ),
                SizedBox(width: 10),
                Text(
                  widget.itemModel.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: widget.itemModel.isPurchased
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                Spacer(),

                if (widget.itemModel.isPurchased) ...[
                  Text(
                    'Total: R\$ ${widget.viewModel.calculateItemTotal(widget.itemModel).toStringAsFixed(2)}',
                  ),
                  SizedBox(width: 10),
                ],

                CustomPopupMenuButton(
                  onExcludePressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmActionDialog(
                        title: 'Delete item?',
                        description:
                            "Remove '${widget.itemModel.name}' from the list?",
                        cancelActionLabel: 'CANCEL',
                        confirmActionLabel: 'DELETE',
                        onConfirm: () async {
                          await widget.viewModel.deleteItem(
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
                        title: 'Rename Item',
                        validatorErrorEmpty: 'Please enter a name',
                        validatorErrorMaximumLength:
                            'Name cannot exceed 50 characters',
                        cancelActionLabel: 'CANCEL',
                        confirmActionLabel: 'SAVE',
                        onConfirm: (newName) async {
                          final updatedItem = widget.itemModel.copyWith(
                            name: newName,
                          );
                          await widget.viewModel.updateItem(updatedItem);
                        },
                      );
                    },
                  ),
                  excludeLabel: 'Delete',
                  renameLabel: 'Rename',
                ),
              ],
            ),

            Form(
              key: _formKey,
              child: Row(
                children: [
                  if (widget.itemModel.isPurchased) ...[
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        value: widget.itemModel.unit,
                        decoration: const InputDecoration(
                          labelText: 'Unit',
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
                            final updatedItem = widget.itemModel.copyWith(
                              unit: value,
                            );
                            widget.viewModel.updateItem(updatedItem);
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
                        controller: _quantityController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          label: Text('Quantity'),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        onTap: () {
                          _quantityController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _quantityController.text.length,
                          );
                        },
                        onChanged: (value) {
                          final newQuantity =
                              double.tryParse(value.replaceAll(',', '.')) ??
                              0.0;

                          final updatedItem = widget.itemModel.copyWith(
                            quantity: newQuantity,
                          );
                          widget.viewModel.updateItem(updatedItem);
                        },
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        controller: _priceController,
                        focusNode: _priceFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          label: Text('Price'),
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          alignLabelWithHint: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        onTap: () {
                          _priceController.selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _priceController.text.length,
                          );
                        },
                        onFieldSubmitted: (value) {
                          final newPrice =
                              double.tryParse(value.replaceAll(',', '.')) ??
                              0.0;

                          final updatedItem = widget.itemModel.copyWith(
                            price: newPrice,
                          );
                          widget.viewModel.updateItem(updatedItem);
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
