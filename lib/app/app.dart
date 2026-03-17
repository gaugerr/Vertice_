import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/helpers/database_helper.dart';
import 'package:rancho_consciente/app/model/rancho_model.dart';
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
          /*TO DO implementar um future builder, que vai receber a função 
          gettAllRanchos da database */

          return FutureBuilder<List<RanchoModel>>(
            future: DatabaseHelper.instance.getAllRanchos(),
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (asyncSnapshot.hasError) {
                return Center(
                  child: Text('Erro de conexão com o banco de dados'),
                );
              } else {
                (asyncSnapshot.hasData);
                if (asyncSnapshot.data!.isEmpty) {
                  return Center(child: Text('Nenhum rancho criado ainda!'));
                }
                return MyGridBuilder(
                  colunas: 2,
                  itemCount: asyncSnapshot.data!.length,
                  itemBuilder: (context, index) {
                    final rancho = asyncSnapshot.data![index];
                    return RanchoCard(
                      ranchoViewModel: ranchoViewModel,
                      rancho: rancho,
                    );
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
