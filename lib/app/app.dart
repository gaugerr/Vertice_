import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/view/add_rancho_forms.dart';
import 'package:rancho_consciente/app/view_model/rancho_viewmodel.dart';
import 'package:rancho_consciente/app/widgets/bottom_sheet.dart';
import 'package:rancho_consciente/app/widgets/cards/rancho_card.dart';
import 'package:rancho_consciente/app/widgets/grid_builder.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final ranchoViewModel = ShoppingListViewModel();

  @override
  void initState() {
    super.initState();

    ranchoViewModel.initializeShoppingLists();
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
              AddRanchoForms(viewModel: ranchoViewModel),
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
        listenable: ranchoViewModel,
        builder: (context, child) {
          final listas = ranchoViewModel.shoppingLists;

          if (listas.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma lista de compras criada!',
                style: TextStyle(color: Colors.white60),
              ),
            );
          }

          return MyGridBuilder(
            colunas: 1,
            itemCount: listas.length,
            itemBuilder: (context, index) {
              final rancho = listas[index];
              return RanchoCard(
                ranchoViewModel: ranchoViewModel,
                rancho: rancho,
              );
            },
          );
        },
      ),
    );
  }
}
