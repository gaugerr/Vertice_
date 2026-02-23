import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/model/categoria_model.dart';
import 'package:rancho_consciente/app/view/itens_view.dart';

class CategoriasCard extends StatelessWidget {
  final CategoriaModel categorias;
  const CategoriasCard({super.key, required this.categorias});

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
              builder: (_) => ItensView(categoriaModel: categorias),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
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

              const SizedBox(height: 4),
              Text(
                'Itens: ${categorias.itens}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
