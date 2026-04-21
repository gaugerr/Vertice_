import 'package:flutter/material.dart';
import 'package:vertice/app/view/add_shopping_list_form.dart';
import 'package:vertice/app/view_model/shopping_list_viewmodel.dart';
import 'package:vertice/app/widgets/bottom_sheet.dart';
import 'package:vertice/app/widgets/cards/shopping_list_card.dart';
import 'package:vertice/app/widgets/grid_builder.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final viewModel = ShoppingListViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.initializeShoppingLists();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Text('VÉRTICE', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(
              'O ponto de encontro entre necessidade e gasto',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.infinity,
        height: 60,
        margin: EdgeInsets.symmetric(horizontal: 22),
        child: FloatingActionButton.extended(
          onPressed: () {
            ShowBottomSheet.bottomSheet(
              context,
              AddShoppingListForm(viewModel: viewModel),
            );
          },
          label: Center(
            child: Text(
              'Criar nova lista de compras',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          icon: Icon(Icons.add_shopping_cart_outlined),
        ),
      ),

      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, child) {
          final lists = viewModel.shoppingLists;

          if (lists.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma lista de compras criada!',
                style: TextStyle(color: Colors.white60),
              ),
            );
          }

          return MyGridBuilder(
            columns: 1,
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final shoppingList = lists[index];
              return ShoppingListCard(
                viewModel: viewModel,
                shoppingList: shoppingList,
              );
            },
          );
        },
      ),
    );
  }
}
