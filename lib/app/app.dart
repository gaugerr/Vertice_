import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/view/add_rancho_forms.dart';
import 'package:rancho_consciente/app/view_model/rancho_viewmodel.dart';
import 'package:rancho_consciente/app/widgets/bottom_sheet.dart';
import 'package:rancho_consciente/app/widgets/cards/rancho_card.dart';
import 'package:rancho_consciente/app/widgets/grid_builder.dart';

class App extends StatelessWidget {
  final ranchoViewModel = RanchoViewModel();

  App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text('Rancho Consciente')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ShowBottomSheet.bottomSheet(
            context,
            AddRanchoForms(viewModel: ranchoViewModel),
          );
        },
        label: Text('Criar nova lista de compras'),
        icon: Icon(Icons.add_shopping_cart_outlined),
      ),
      body: ListenableBuilder(
        listenable: ranchoViewModel,
        builder: (context, child) {
          return MyGridBuilder(
            colunas: 2,
            itemCount: ranchoViewModel.listasCompras.length,
            itemBuilder: (context, index) {
              final rancho = ranchoViewModel.listasCompras[index];
              return RanchoCard(rancho: rancho);
            },
          );
        },
      ),
    );
  }
}
