import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/model/categoria_model.dart';
import 'package:rancho_consciente/app/view_model/rancho_viewmodel.dart';
import 'package:rancho_consciente/app/widgets/cards/itens.card.dart';
import 'package:rancho_consciente/app/widgets/list_view_builder.dart';

class ItensView extends StatefulWidget {
  final RanchoViewModel ranchoViewModel;
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
        title: Text(widget.categoriaModel.tituloCategoria),
        actions: [
          ListenableBuilder(
            listenable: widget.ranchoViewModel,
            builder: (context, _) {
              final total = widget.ranchoViewModel.calcularTotalCategoria(
                widget.categoriaModel,
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
      body: Column(
        children: [
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
              decoration: InputDecoration(hintText: 'Adicionar item'),
              focusNode: _focusNode,

              onFieldSubmitted: (value) {
                if (_formKey.currentState!.validate()) {
                  widget.ranchoViewModel.adicionarItem(
                    categoria: widget.categoriaModel,
                    nomeDigitado: value.trim(),
                  );
                  _nameItemController.clear(); //limpa o campo ao dar enter
                  _formKey.currentState!
                      .reset(); //reseta a mensagem de erro do campo
                  _focusNode.requestFocus(); //mantém o teclado na tela
                } else {
                  // mostra erros se a validação falhar
                }
              },
            ),
          ),

          Expanded(
            child: ListenableBuilder(
              listenable: widget.ranchoViewModel,
              builder: (context, child) => MyListViewBuilder(
                itemCount: widget.categoriaModel.itens.length,
                itemBuilder: (context, index) {
                  final itemAtual = widget.categoriaModel.itens[index];
                  return ItemCard(
                    ranchoViewModel: widget.ranchoViewModel,
                    itemModel: itemAtual,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
