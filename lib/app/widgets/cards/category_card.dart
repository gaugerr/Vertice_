import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vertice/app/model/category_model.dart';
import 'package:vertice/app/view/items_view.dart';
import 'package:vertice/app/view_model/shopping_list_viewmodel.dart';

class CategoryCard extends StatelessWidget {
  final ShoppingListViewModel viewModel;
  final CategoryModel category;
  const CategoryCard({
    super.key,
    required this.category,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'category-${category.id}',
      container: true,
      child: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final items = viewModel.getItemsByCategory(category.id!);
          final complete = items.isNotEmpty && items.every((item) => item.isPurchased);
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: complete ? Colors.green : Colors.transparent),
            ),
            color: Theme.of(context).colorScheme.surface,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(context, CupertinoPageRoute(
                builder: (_) => ItemsView(viewModel: viewModel, category: category),
              )),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(category.title, style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    )),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white60),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (final item in items.take(4))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text('• ${item.name}',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (items.length > 4)
                            Text('+ ${items.length - 4} items...', style: const TextStyle(
                              color: Colors.deepPurpleAccent, fontSize: 11,
                              fontWeight: FontWeight.bold,
                            )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
