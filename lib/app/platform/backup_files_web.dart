import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

Future<void> saveBackupFile(String text) async {
  final blob = web.Blob([text.toJS].toJS, web.BlobPropertyBag(type: 'application/json'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()..href = url..download = 'vertice-backup-${DateTime.now().millisecondsSinceEpoch}.json';
  web.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  Timer(const Duration(seconds: 2), () => web.URL.revokeObjectURL(url));
}

Future<String?> pickBackupFile() {
  final result = Completer<String?>();
  final input = web.HTMLInputElement()..type = 'file'..accept = '.json,application/json';
  input.addEventListener('change', ((web.Event _) async {
    try {
      final files = input.files;
      if (files == null || files.length == 0) { result.complete(null); return; }
      final file = files.item(0)!;
      if (file.size > 10000000) throw const FormatException('Backup maior que 10 MB.');
      result.complete((await file.text().toDart).toDart);
    } catch (error, stack) { result.completeError(error, stack); }
  }).toJS);
  input.addEventListener('cancel', ((web.Event _) { if (!result.isCompleted) result.complete(null); }).toJS);
  input.click();
  return result.future;
}
const backupSaveLabel = 'Baixar backup';
const backupOpenLabel = 'Abrir arquivo';
