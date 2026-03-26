import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/helpers/database_helper.dart';
import 'package:rancho_consciente/app/model/rancho_model.dart';
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
  final ranchoViewModel = RanchoViewModel();

  Future<List<RanchoModel>>? _ranchosFuture;

  //atualiza os dados do banco, ao adicionar um novo rancho
  void _atualizarLista() {
    setState(() {
      _ranchosFuture = DatabaseHelper.instance.getAllRanchos();
    });
  }

  //pega os dados do banco apenas quando a tela é chamada (abrir app/voltar pra tela de ranchos)
  @override
  void initState() {
    super.initState();
    _ranchosFuture = DatabaseHelper.instance.getAllRanchos();
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
              AddRanchoForms(
                viewModel: ranchoViewModel,
                onSave: _atualizarLista,
              ),
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
          /*TO DO implementar um future builder, que vai receber a função 
          gettAllRanchos da database */

          return FutureBuilder<List<RanchoModel>>(
            future: _ranchosFuture,
            builder: (context, asyncSnapshot) {
              if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (asyncSnapshot.hasError) {
                return Center(
                  child: Text('Erro de conexão com o banco de dados'),
                );
              } else {
                if (asyncSnapshot.data!.isEmpty) {
                  return Center(
                    child: Text('Nenhuma lista de compras criada!'),
                  );
                }
                return MyGridBuilder(
                  colunas: 1,
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
