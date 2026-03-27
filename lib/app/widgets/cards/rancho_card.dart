import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/model/rancho_model.dart';
import 'package:rancho_consciente/app/view/categorias_view.dart';
import 'package:rancho_consciente/app/view_model/rancho_viewmodel.dart';
import 'package:rancho_consciente/app/widgets/confirm_action_dialog.dart';
import 'package:rancho_consciente/app/widgets/popup_menu_button.dart';
import 'package:rancho_consciente/app/widgets/rename_action_dialog.dart';

class RanchoCard extends StatelessWidget {
  final RanchoViewModel ranchoViewModel;
  final RanchoModel rancho;
  const RanchoCard({
    super.key,
    required this.rancho,
    required this.ranchoViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(
        context,
      ).colorScheme.surface, // Usa o cinza escuro do seu tema
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => CategoriasView(
                ranchoViewModel: ranchoViewModel,
                ranchoModel: rancho,
              ),
            ),
          );
        },
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      rancho.mercado,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      rancho.descricao,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${rancho.data.day.toString().padLeft(2, '0')}/${rancho.data.month.toString().padLeft(2, '0')}/${rancho.data.year}",
                      style: const TextStyle(
                        color: Colors.white24,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              top: 8,
              right: 8,
              child: CustomPopupMenuButton(
                onExcludePressed: () => showDialog(
                  context: context,
                  builder: (context) => ConfirmActionDialog(
                    title: 'Excluir Lista?',
                    description: "Deseja remover '${rancho.mercado}'?",
                    cancelActionLabel: 'CANCELAR',
                    confirmActionLabel: 'EXCLUIR',
                    onConfirm: () async =>
                        await ranchoViewModel.deleteBuyList(rancho),
                    confirmColor: Colors.red,
                  ),
                ),
                onRenamePressed: () => showDialog(
                  context: context,
                  builder: (context) => RenameActionDialog(
                    renamedController: TextEditingController(
                      text: rancho.mercado,
                    ),
                    title: 'Renomear Lista',
                    validatorErrorEmpty: 'Digite o nome do Mercado',
                    validatorErrorMaximumLength: 'Máximo 50 caracteres',
                    cancelActionLabel: 'CANCELAR',
                    confirmActionLabel: 'SALVAR',
                    onConfirm: (novoNome) async {
                      final itemNovo = rancho.copyWith(mercado: novoNome);

                      await ranchoViewModel.updateBuyList(itemNovo);
                    },
                  ),
                ),
                excludeLabel: 'Excluir',
                renameLabel: 'Renomear',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
