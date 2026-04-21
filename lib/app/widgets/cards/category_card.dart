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
    return ListenableBuilder(
      listenable: viewModel,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              category.title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ListenableBuilder(
              listenable: viewModel,
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
                      ...viewModel
                          .getItemNames(category)
                          .take(4)
                          .map(
                            (name) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                '• $name',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),

                      if (viewModel.getItemNames(category).length > 4)
                        Text(
                          '+ ${viewModel.getItemNames(category).length - 4} items...',
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
          ],
        ),
      ),
      builder: (context, staticChild) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: viewModel.isCategoryComplete(category)
                  ? Colors.green
                  : Colors.transparent,
            ),
          ),
          color: Theme.of(context).colorScheme.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => ItemsView(
                    viewModel: viewModel,
                    category: category,
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
