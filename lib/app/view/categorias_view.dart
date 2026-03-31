import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/helpers/database_helper.dart';
import 'package:rancho_consciente/app/model/categoria_model.dart';
import 'package:rancho_consciente/app/model/rancho_model.dart';
import 'package:rancho_consciente/app/view_model/rancho_viewmodel.dart';
import 'package:rancho_consciente/app/widgets/cards/categorias_card.dart';
import 'package:rancho_consciente/app/widgets/grid_builder.dart';

class CategoriasView extends StatefulWidget {
  final ShoppingListViewModel ranchoViewModel;
  final ShoppingListModel ranchoModel;
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
        centerTitle: true,
        title: Text(
          widget.ranchoModel.mercado,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      // Definindo o local do FAB para o centro inferior
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ListenableBuilder(
        listenable: widget.ranchoViewModel,
        builder: (context, _) {
          final total = widget.ranchoViewModel.calcularTotalRancho(
            widget.ranchoModel,
          );

          return FloatingActionButton.extended(
            onPressed: null, // Apenas para exibição do valor
            backgroundColor: Colors.black,
            // Estilo idêntico ao da tela de itens (levemente arredondado)
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
        child: FutureBuilder<List<CategoriaModel>>(
          future: _categoriasFuture,
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (asyncSnapshot.hasError) {
              return const Center(
                child: Text('Erro de conexão com o banco de dados'),
              );
            } else {
              if (asyncSnapshot.data!.isEmpty) {
                return const Center(
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
      ),
    );
  }
}
