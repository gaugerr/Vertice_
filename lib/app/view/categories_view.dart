import 'package:flutter/material.dart';
import 'package:vertice/app/helpers/database_helper.dart';
import 'package:vertice/app/model/category_model.dart';
import 'package:vertice/app/model/shopping_list_model.dart';
import 'package:vertice/app/view_model/shopping_list_viewmodel.dart';
import 'package:vertice/app/widgets/cards/category_card.dart';
import 'package:vertice/app/widgets/grid_builder.dart';

class CategoriesView extends StatefulWidget {
  final ShoppingListViewModel viewModel;
  final ShoppingListModel shoppingList;
  const CategoriesView({
    super.key,
    required this.shoppingList,
    required this.viewModel,
  });

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  Future<List<CategoryModel>>? _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = DatabaseHelper.instance.getCategoriesByShoppingList(
      widget.shoppingList.id!,
    );
    widget.viewModel.loadItemsForList(widget.shoppingList.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.shoppingList.storeName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final total = widget.viewModel.calculateListTotal(
            widget.shoppingList,
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
        padding: const EdgeInsets.only(top: 16.0),
        child: FutureBuilder<List<CategoryModel>>(
          future: _categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Database connection error'),
              );
            } else {
              if (snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No categories found'),
                );
              }
              return MyGridBuilder(
                columns: 2,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final category = snapshot.data![index];
                  return CategoryCard(
                    viewModel: widget.viewModel,
                    category: category,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
