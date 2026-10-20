import 'package:flutter/material.dart';
import 'package:vertice/app/model/item_model.dart';
import 'package:vertice/app/view_model/shopping_list_viewmodel.dart';
import 'package:vertice/app/widgets/confirm_action_dialog.dart';
import 'package:vertice/app/widgets/popup_menu_button.dart';
import 'package:vertice/app/widgets/rename_action_dialog.dart';

class ItemCard extends StatefulWidget {
  final ShoppingListViewModel viewModel;
  final ItemModel itemModel;
  const ItemCard({super.key, required this.itemModel, required this.viewModel});
  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  final _quantity = TextEditingController();
  final _price = TextEditingController();
  final _name = TextEditingController();
  bool _saving = false;

  void _restore() {
    _quantity.text = widget.itemModel.quantity.toString();
    _price.text = widget.itemModel.price.toStringAsFixed(2);
    _name.text = widget.itemModel.name;
  }

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _save(ItemModel item) async {
    if (_saving) return;
    setState(() => _saving = true);
    final saved = await widget.viewModel.updateItem(item);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (!saved) _restore();
    });
  }

  Future<void> _saveNumbers() async {
    if (_saving) return;
    final quantity = double.tryParse(_quantity.text.replaceAll(',', '.'));
    final price = double.tryParse(_price.text.replaceAll(',', '.'));
    if (quantity == null || !quantity.isFinite || quantity <= 0 ||
        price == null || !price.isFinite || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Informe quantidade maior que zero e preço não negativo.'),
      ));
      _restore();
      return;
    }
    if (quantity == widget.itemModel.quantity && price == widget.itemModel.price) return;
    await _save(widget.itemModel.copyWith(quantity: quantity, price: price));
  }

  @override
  void dispose() {
    _quantity.dispose();
    _price.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.itemModel;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Checkbox(
                value: item.isPurchased,
                onChanged: _saving ? null : (value) => _save(item.copyWith(isPurchased: value)),
              ),
              Expanded(child: Text(item.name, style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold,
                decoration: item.isPurchased ? TextDecoration.lineThrough : null,
              ))),
              if (item.isPurchased)
                Text('Total: R\$ ${widget.viewModel.calculateItemTotal(item).toStringAsFixed(2)}'),
              IgnorePointer(
                ignoring: _saving,
                child: CustomPopupMenuButton(
                  excludeLabel: 'Delete', renameLabel: 'Rename',
                  onExcludePressed: () => showDialog(
                    context: context,
                    builder: (_) => ConfirmActionDialog(
                      title: 'Delete item?', description: "Remove '${item.name}'?",
                      cancelActionLabel: 'CANCEL', confirmActionLabel: 'DELETE',
                      confirmColor: Colors.red,
                      onConfirm: () { widget.viewModel.deleteItem(item); },
                    ),
                  ),
                  onRenamePressed: () {
                    _name.text = item.name;
                    showDialog(context: context, builder: (_) => RenameActionDialog(
                      renamedController: _name, title: 'Rename Item',
                      validatorErrorEmpty: 'Please enter a name',
                      validatorErrorMaximumLength: 'Maximum 50 characters',
                      cancelActionLabel: 'CANCEL', confirmActionLabel: 'SAVE',
                      onConfirm: (name) { _save(item.copyWith(name: name.trim())); },
                    ));
                  },
                ),
              ),
            ]),
            if (item.isPurchased) Row(children: [
              Expanded(child: DropdownButtonFormField<String>(
                value: item.unit,
                decoration: const InputDecoration(labelText: 'Unit'),
                items: ['un', 'kg', 'L'].map((unit) =>
                  DropdownMenuItem(value: unit, child: Text(unit))).toList(),
                onChanged: _saving ? null : (unit) {
                  if (unit != null) _save(item.copyWith(unit: unit));
                },
              )),
              Expanded(child: TextField(
                controller: _quantity, enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Quantity'),
                onSubmitted: (_) => _saveNumbers(),
                onTapOutside: (_) { _saveNumbers(); FocusScope.of(context).unfocus(); },
              )),
              Expanded(child: TextField(
                controller: _price, enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Price / ${item.unit}'),
                onSubmitted: (_) => _saveNumbers(),
                onTapOutside: (_) { _saveNumbers(); FocusScope.of(context).unfocus(); },
              )),
            ]),
          ],
        ),
      ),
    );
  }
}
