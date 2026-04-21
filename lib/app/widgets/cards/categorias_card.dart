import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vertice/app/model/categoria_model.dart';
import 'package:vertice/app/view/itens_view.dart';
import 'package:vertice/app/view_model/shopping_list_viewmodel.dart';

class CategoriasCard extends StatelessWidget {
  final ShoppingListViewModel ranchoViewModel;
  final CategoriaModel categorias;
  const CategoriasCard({
    super.key,
    required this.categorias,
    required this.ranchoViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ranchoViewModel,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              categorias.tituloCategoria,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ListenableBuilder(
              listenable: ranchoViewModel,
              builder: (context, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white60, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...ranchoViewModel
                          .getListaItens(categorias)
                          .take(4)
                          .map(
                            (nome) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                "• $nome", // Um bullet point ajuda na leitura
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                      if (ranchoViewModel.getListaItens(categorias).length > 4)
                        Text(
                          "+ ${ranchoViewModel.getListaItens(categorias).length - 4} itens...",
                          style: TextStyle(
                            color: Colors.deepPurpleAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 4),
            // Text(
            //   'Itens: ${categorias.itens}',
            //   style: const TextStyle(color: Colors.white, fontSize: 10),
            //   textAlign: TextAlign.center,
            // ),
          ],
        ),
      ),
      builder: (context, staticChild) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: ranchoViewModel.isCategoriaCompleta(categorias)
                  ? Colors.green
                  : Colors.transparent,
            ),
          ),
          color: Theme.of(
            context,
          ).colorScheme.surface, // Usa o cinza escuro do seu tema
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ItensView(
                    ranchoViewModel: ranchoViewModel,
                    categoriaModel: categorias,
                  ),
                ),
              );
            },
            child: staticChild,
          ),
        );
      },
    );
  }
}
