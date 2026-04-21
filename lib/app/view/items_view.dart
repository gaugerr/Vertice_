import 'package:flutter/material.dart';
import 'package:vertice/app/model/category_model.dart';
import 'package:vertice/app/view_model/shopping_list_viewmodel.dart';
import 'package:vertice/app/widgets/cards/item_card.dart';
import 'package:vertice/app/widgets/list_view_builder.dart';

class ItemsView extends StatefulWidget {
  final ShoppingListViewModel viewModel;
  final CategoryModel category;
  const ItemsView({
    super.key,
    required this.category,
    required this.viewModel,
  });

  @override
  State<ItemsView> createState() => _ItemsViewState();
}

class _ItemsViewState extends State<ItemsView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _itemNameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _itemNameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.category.title),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final total = widget.viewModel.calculateCategoryTotal(
            widget.category,
          );
          return FloatingActionButton.extended(
            onPressed: null,
            backgroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.green.shade300, width: 1),
            ),
            label: Text(
              'Total: R\$ ${total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          );
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _itemNameController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter an item';
                  } else if (value.length > 50) {
                    return 'Item name cannot exceed 50 characters';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Add item',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                focusNode: _focusNode,
                onFieldSubmitted: (value) {
                  if (_formKey.currentState!.validate()) {
                    widget.viewModel.addItem(
                      category: widget.category,
                      itemName: value.trim(),
                    );
                    _itemNameController.clear();
                    _formKey.currentState!.reset();
                    _focusNode.requestFocus();
                  }
                },
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, child) {
                  final items = widget.viewModel.getItemsByCategory(
                    widget.category.id!,
                  );
                  return MyListViewBuilder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ItemCard(
                        viewModel: widget.viewModel,
                        itemModel: item,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
