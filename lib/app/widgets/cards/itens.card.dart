import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/model/item_model.dart';
import 'package:rancho_consciente/app/view_model/rancho_viewmodel.dart';

class ItemCard extends StatelessWidget {
  final RanchoViewModel ranchoViewModel;
  final ItemModel itemModel;
  const ItemCard({
    super.key,
    required this.itemModel,
    required this.ranchoViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              // mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Checkbox(
                  value: itemModel.isComprado,
                  onChanged: (bool? value) => {
                    ranchoViewModel.toggleIsComprado(itemModel),
                  },
                ),

                Text(
                  itemModel.nomeItem,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: itemModel.isComprado
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (itemModel.isComprado) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: itemModel.unidade, // "un", "kg", ou "l"
                      decoration: const InputDecoration(
                        labelText: 'Unidade',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      items: ['un', 'kg', 'L'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (novoValor) {
                        // Aqui você chama sua ViewModel para atualizar o modelo
                        //ranchoViewModel.atualizarUnidade(itemModel, novoValor!);
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: itemModel.quantidade.toString(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        label: Text('Quantidade'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      initialValue: itemModel.preco.toString(),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        label: Text('Preço'),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
