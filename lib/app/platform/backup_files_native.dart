import 'package:flutter/services.dart';

Future<void> saveBackupFile(String text) => Clipboard.setData(ClipboardData(text: text));
Future<String?> pickBackupFile() async => (await Clipboard.getData(Clipboard.kTextPlain))?.text;
const backupSaveLabel = 'Copiar backup';
const backupOpenLabel = 'Colar backup';
