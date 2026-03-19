import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/helpers/database_helper.dart';
import 'package:rancho_consciente/app/model/categoria_model.dart';
import 'package:rancho_consciente/app/model/rancho_model.dart';
import 'package:rancho_consciente/app/view_model/rancho_viewmodel.dart';
import 'package:rancho_consciente/app/widgets/cards/categorias_card.dart';
import 'package:rancho_consciente/app/widgets/grid_builder.dart';

class CategoriasView extends StatefulWidget {
  final RanchoViewModel ranchoViewModel;
  final RanchoModel ranchoModel;
  const CategoriasView({
    super.key,
    required this.ranchoModel,
    required this.ranchoViewModel,
  });

  @override
  State<CategoriasView> createState() => _CategoriasViewState();
}

class _CategoriasViewState extends State<CategoriasView> {
  Future<List<CategoriaModel>>? _categoriasFuture;

  @override
  void initState() {
    super.initState();
    _categoriasFuture = DatabaseHelper.instance.getCategoriasPorRancho(
      widget.ranchoModel.id!,
    );
    widget.ranchoViewModel.inicializarItensDoRancho(widget.ranchoModel.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //centerTitle: true,
        title: Text(widget.ranchoModel.mercado),
        actions: [
          ListenableBuilder(
            listenable: widget.ranchoViewModel,
            builder: (context, _) {
              final total = widget.ranchoViewModel.calcularTotalRancho(
                widget.ranchoModel,
              );

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

      body: FutureBuilder<List<CategoriaModel>>(
        future: _categoriasFuture,

        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (asyncSnapshot.hasError) {
            return Center(child: Text('Erro de conexão com o banco de dados'));
          } else {
            if (asyncSnapshot.data!.isEmpty) {
              return Center(
                child: Text('Nenhuma categoria de compras encontrada'),
              );
            }
            return MyGridBuilder(
              colunas: 2,
              itemCount: asyncSnapshot.data!.length,
              itemBuilder: (context, index) {
                final categorias = asyncSnapshot.data![index];
                return CategoriasCard(
                  ranchoViewModel: widget.ranchoViewModel,
                  categorias: categorias,
                );
              },
            );
          }
        },
      ),
    );
  }
}
