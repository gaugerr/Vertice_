import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vertice/app/model/shopping_list_model.dart';
import 'package:vertice/app/view/categories_view.dart';
import 'package:vertice/app/view_model/shopping_list_viewmodel.dart';
import 'package:vertice/app/widgets/confirm_action_dialog.dart';
import 'package:vertice/app/widgets/popup_menu_button.dart';
import 'package:vertice/app/widgets/rename_action_dialog.dart';

class ShoppingListCard extends StatelessWidget {
  final ShoppingListViewModel viewModel;
  final ShoppingListModel shoppingList;
  const ShoppingListCard({
    super.key,
    required this.shoppingList,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => CategoriesView(
                viewModel: viewModel,
                shoppingList: shoppingList,
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
                      shoppingList.storeName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      shoppingList.description,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "${shoppingList.date.day.toString().padLeft(2, '0')}/${shoppingList.date.month.toString().padLeft(2, '0')}/${shoppingList.date.year}",
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
                    title: 'Delete list?',
                    description: "Remove '${shoppingList.storeName}'?",
                    cancelActionLabel: 'CANCEL',
                    confirmActionLabel: 'DELETE',
                    onConfirm: () async =>
                        await viewModel.deleteShoppingList(shoppingList),
                    confirmColor: Colors.red,
                  ),
                ),
                onRenamePressed: () => showDialog(
                  context: context,
                  builder: (context) => RenameActionDialog(
                    renamedController: TextEditingController(
                      text: shoppingList.storeName,
                    ),
                    title: 'Rename list',
                    validatorErrorEmpty: 'Enter the store name',
                    validatorErrorMaximumLength: 'Maximum 50 characters',
                    cancelActionLabel: 'CANCEL',
                    confirmActionLabel: 'SAVE',
                    onConfirm: (newName) async {
                      final updated = shoppingList.copyWith(storeName: newName);
                      await viewModel.updateShoppingList(updated);
                    },
                  ),
                ),
                excludeLabel: 'Delete',
                renameLabel: 'Rename',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
