import 'package:flutter/material.dart';
import 'package:vertice/app/utils/utils.dart';
import 'package:vertice/app/view_model/rancho_viewmodel.dart';

class AddRanchoForms extends StatefulWidget {
  final ShoppingListViewModel viewModel;

  const AddRanchoForms({super.key, required this.viewModel});

  @override
  State<AddRanchoForms> createState() => _AddRanchoFormsState();
}

class _AddRanchoFormsState extends State<AddRanchoForms> {
  // Chave global para o formulário, essencial para acionar a validação
  final _formKey = GlobalKey<FormState>();

  // Controlador para o TextFormField, para acessar o texto digitado
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Variável para controlar o estado de carregamento/processamento do botão
  //final bool _isProcessing = false;

  @override
  void dispose() {
    // É importante descartar o controlador quando o widget não for mais necessário
    _nameController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(
          context,
        ).viewInsets.bottom, // Empurra o modal para cima do teclado
      ),
      child: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(30),

          // color: Colors.deepPurpleAccent,
          height: 430,
          child: Column(
            spacing: 20,
            children: [
              Text('Criar lista de compras'),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Digite um título para a lista de compras';
                  } else if (value.length > 30) {
                    return 'O título não pode exceder 30 caracteres';
                  }
                  return null;
                },
                controller: _nameController,
                //style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hint: Text(
                    'Título da lista',
                    style: TextStyle(color: Colors.white24),
                  ),
                ),
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione uma data';
                  }
                  return null;
                },
                controller: _dateController,
                readOnly: true,

                decoration: InputDecoration(
                  hint: Text('Data', style: TextStyle(color: Colors.white24)),
                ),
                onTap: () async {
                  DateTime? data = await AppUtils.datePicker(context);
                  if (data != null) {
                    setState(() {
                      _dateController.text =
                          "${data.day}/${data.month.toString().padLeft(2, '0')}/${data.year}";
                    });
                  }
                },
              ),
              TextFormField(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor, digite uma descrição';
                  } else if (value.length > 50) {
                    return 'A descrição pode exceder 50 caracteres';
                  }
                  return null;
                },
                controller: _descriptionController,
                decoration: InputDecoration(
                  hint: Text(
                    'Descrição',
                    style: TextStyle(color: Colors.white24),
                  ),
                ),
              ),
              //   SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.deepPurpleAccent,
                  elevation: 6,

                  backgroundColor: Colors.deepPurpleAccent,
                ),
                onPressed: () {
                  // O validate() dispara todos os validadores de uma vez
                  if (_formKey.currentState!.validate()) {
                    // Se caiu aqui, todos os campos estão OK!
                    widget.viewModel.adicionarRancho(
                      nomeMercado: _nameController.text.trim(),
                      data: AppUtils.converterData(_dateController.text),
                      descricao: _descriptionController.text.trim(),
                    );

                    Navigator.pop(context);
                  } else {
                    // Se caiu aqui, o Flutter automaticamente mostra os erros em vermelho
                  }
                },
                child: Text('Criar', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
