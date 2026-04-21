import 'package:flutter/material.dart';
import 'package:vertice/app/model/categoria_model.dart';
import 'package:vertice/app/view_model/shopping_list_viewmodel.dart';
import 'package:vertice/app/widgets/cards/itens.card.dart';
import 'package:vertice/app/widgets/list_view_builder.dart';

class ItensView extends StatefulWidget {
  final ShoppingListViewModel ranchoViewModel;
  final CategoriaModel categoriaModel;
  const ItensView({
    super.key,
    required this.categoriaModel,
    required this.ranchoViewModel,
  });

  @override
  State<ItensView> createState() => _ItensViewState();
}

class _ItensViewState extends State<ItensView> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameItemController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _nameItemController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Centraliza para dar um ar mais limpo
        title: Text(widget.categoriaModel.tituloCategoria),
        // Removido o chip das actions para não cortar o título
      ),
      // Adicionado o FAB centralizado com o total
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ListenableBuilder(
        listenable: widget.ranchoViewModel,
        builder: (context, _) {
          final total = widget.ranchoViewModel.calcularTotalCategoria(
            widget.categoriaModel,
          );
          return FloatingActionButton.extended(
            onPressed: null,
            // Mantendo o fundo escuro que combina com seu app
            backgroundColor: Colors.black,
            // AJUSTE AQUI: Mudando de bola para o seu estilo levemente arredondado
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                10,
              ), // Mesmo raio do seu código original
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
                controller: _nameItemController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Digite um item';
                  } else if (value.length > 50) {
                    return 'O item não pode exceder 50 caracteres';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'Adicionar item',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                focusNode: _focusNode,
                onFieldSubmitted: (value) {
                  if (_formKey.currentState!.validate()) {
                    widget.ranchoViewModel.adicionarItem(
                      categoria: widget.categoriaModel,
                      nomeDigitado: value.trim(),
                    );
                    _nameItemController.clear();
                    _formKey.currentState!.reset();
                    _focusNode.requestFocus();
                  }
                },
              ),
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: widget.ranchoViewModel,
                builder: (context, child) {
                  final listaItens = widget.ranchoViewModel.getItensDaCategoria(
                    widget.categoriaModel.id!,
                  );
                  return MyListViewBuilder(
                    itemCount: listaItens.length,
                    itemBuilder: (context, index) {
                      final itemAtual = listaItens[index];
                      return ItemCard(
                        ranchoViewModel: widget.ranchoViewModel,
                        itemModel: itemAtual,
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
