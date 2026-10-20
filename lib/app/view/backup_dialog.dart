import 'package:flutter/material.dart';
import '../platform/backup_files.dart';
import '../data/shopping_backup.dart';
import '../view_model/shopping_list_viewmodel.dart';

class BackupDialog extends StatefulWidget {
  final ShoppingListViewModel viewModel;
  const BackupDialog({super.key, required this.viewModel});
  @override
  State<BackupDialog> createState() => _BackupDialogState();
}

class _BackupDialogState extends State<BackupDialog> {
  final _text = TextEditingController();
  bool _busy = false;
  String? _message;

  Future<void> _run(Future<void> Function() action) async {
    setState(() { _busy = true; _message = null; });
    try { await action(); }
    catch (_) { if (mounted) setState(() => _message = 'Não foi possível concluir. Confira o arquivo e tente novamente.'); }
    finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  void dispose() { _text.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Backup e restauração'),
    content: SizedBox(width: 480, child: SingleChildScrollView(child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Os dados ficam neste aparelho e navegador. Guarde um backup antes de limpar os dados do site ou trocar de aparelho.'),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _busy ? null : () => _run(() async {
          final source = await widget.viewModel.exportBackup();
          await saveBackupFile(source);
          if (mounted) setState(() => _message = 'Backup gerado. Guarde o arquivo em um lugar seguro.');
        }), icon: const Icon(Icons.download), label: const Text(backupSaveLabel)),
        const Divider(height: 32),
        OutlinedButton(onPressed: _busy ? null : () => _run(() async {
          final source = await pickBackupFile();
          if (source != null && mounted) _text.text = source;
        }), child: const Text(backupOpenLabel)),
        const SizedBox(height: 8),
        TextField(controller: _text, enabled: !_busy, maxLines: 3,
          decoration: const InputDecoration(labelText: 'Conteúdo do backup', hintText: 'Abra um arquivo ou cole o JSON', border: OutlineInputBorder())),
        if (_message != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_message!)),
        if (_busy) const Padding(padding: EdgeInsets.only(top: 12), child: LinearProgressIndicator()),
      ],
    ))),
    actions: [
      TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Fechar')),
      FilledButton(onPressed: _busy ? null : () => _run(() async {
        final backup = ShoppingBackup.parse(_text.text);
        final accepted = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
          title: const Text('Substituir os dados atuais?'),
          content: Text('Este backup contém ${backup.lists.length} listas e ${backup.items.length} itens. A restauração substitui todos os dados atuais. Exporte um backup antes de continuar.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Substituir'))],
        ));
        if (accepted != true) return;
        final saved = await widget.viewModel.restoreBackup(_text.text);
        if (mounted) setState(() => _message = saved ? 'Backup restaurado.' : 'Não foi possível restaurar. Os dados anteriores foram mantidos.');
      }), child: const Text('Restaurar')),
    ],
  );
}
