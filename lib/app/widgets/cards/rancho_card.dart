import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rancho_consciente/app/model/rancho_model.dart';
import 'package:rancho_consciente/app/view/categorias_view.dart';
import 'package:rancho_consciente/app/view_model/rancho_viewmodel.dart';

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text('id = ${rancho.id}'),
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
                style: const TextStyle(color: Colors.white60, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                //  rancho.data.toString(),
                "${rancho.data.day.toString().padLeft(2, '0')}/${rancho.data.month.toString().padLeft(2, '0')}/${rancho.data.year}",
                style: const TextStyle(color: Colors.white24, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
