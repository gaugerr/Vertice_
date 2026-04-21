import 'package:flutter/material.dart';
import 'package:vertice/app/utils/utils.dart';
import 'package:vertice/app/view_model/shopping_list_viewmodel.dart';

class AddShoppingListForm extends StatefulWidget {
  final ShoppingListViewModel viewModel;

  const AddShoppingListForm({super.key, required this.viewModel});

  @override
  State<AddShoppingListForm> createState() => _AddShoppingListFormState();
}

class _AddShoppingListFormState extends State<AddShoppingListForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(30),
          height: 430,
          child: Column(
            spacing: 20,
            children: [
              Text('Create shopping list'),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter a title for the shopping list';
                  } else if (value.length > 30) {
                    return 'Title cannot exceed 30 characters';
                  }
                  return null;
                },
                controller: _nameController,
                decoration: InputDecoration(
                  hint: Text(
                    'List title',
                    style: TextStyle(color: Colors.white24),
                  ),
                ),
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a date';
                  }
                  return null;
                },
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  hint: Text('Date', style: TextStyle(color: Colors.white24)),
                ),
                onTap: () async {
                  DateTime? date = await AppUtils.datePicker(context);
                  if (date != null) {
                    setState(() {
                      _dateController.text =
                          "${date.day}/${date.month.toString().padLeft(2, '0')}/${date.year}";
                    });
                  }
                },
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  } else if (value.length > 50) {
                    return 'Description cannot exceed 50 characters';
                  }
                  return null;
                },
                controller: _descriptionController,
                decoration: InputDecoration(
                  hint: Text(
                    'Description',
                    style: TextStyle(color: Colors.white24),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.deepPurpleAccent,
                  elevation: 6,
                  backgroundColor: Colors.deepPurpleAccent,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.viewModel.addShoppingList(
                      storeName: _nameController.text.trim(),
                      date: AppUtils.parseDate(_dateController.text),
                      description: _descriptionController.text.trim(),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Create', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
