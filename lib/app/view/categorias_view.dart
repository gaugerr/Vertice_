import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/model/rancho_model.dart';
import 'package:rancho_consciente/app/view_model/rancho_viewmodel.dart';
import 'package:rancho_consciente/app/widgets/cards/categorias_card.dart';
import 'package:rancho_consciente/app/widgets/grid_builder.dart';

class CategoriasView extends StatelessWidget {
  final RanchoViewModel ranchoViewModel;
  final RanchoModel ranchoModel;
  const CategoriasView({
    super.key,
    required this.ranchoModel,
    required this.ranchoViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //centerTitle: true,
        title: Text(ranchoModel.mercado),
        actions: [
          ListenableBuilder(
            listenable: ranchoViewModel,
            builder: (context, _) {
              final total = ranchoViewModel.calcularTotalRancho(ranchoModel);

              return Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.green.shade300,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Total: R\$ ${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: MyGridBuilder(
        colunas: 2,
        itemCount: ranchoModel.categorias.length,
        itemBuilder: (context, index) {
          final categorias = ranchoModel.categorias[index];
          return CategoriasCard(
            ranchoViewModel: ranchoViewModel,
            categorias: categorias,
          );
        },
      ),
    );
  }
}
