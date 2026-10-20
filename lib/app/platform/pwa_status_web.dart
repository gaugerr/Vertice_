import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

@JS('verticeOfflineReady')
external JSBoolean? get _offlineReady;
@JS('verticeUpdateReady')
external JSBoolean? get _updateReady;
@JS('verticeInstallReady')
external JSBoolean? get _installReady;
@JS('verticeApplyUpdate')
external void _applyUpdate();
@JS('verticeInstall')
external void _install();

class PwaStatus extends StatefulWidget {
  const PwaStatus({super.key});
  @override
  State<PwaStatus> createState() => _PwaStatusState();
}

class _PwaStatusState extends State<PwaStatus> {
  late final JSFunction _listener;
  static const _events = ['online', 'offline', 'vertice-pwa-changed'];
  @override
  void initState() {
    super.initState();
    _listener = ((web.Event _) { if (mounted) setState(() {}); }).toJS;
    for (final event in _events) { web.window.addEventListener(event, _listener); }
  }
  @override
  void dispose() {
    for (final event in _events) { web.window.removeEventListener(event, _listener); }
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final online = web.window.navigator.onLine;
    final ready = _offlineReady?.toDart ?? false;
    final update = _updateReady?.toDart ?? false;
    final install = _installReady?.toDart ?? false;
    return Material(
      color: const Color(0xFF191325),
      child: SafeArea(bottom: false, child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Row(children: [
          Icon(online ? Icons.check_circle_outline : Icons.wifi_off, size: 16, color: online ? Colors.greenAccent : Colors.amber),
          const SizedBox(width: 8),
          Expanded(child: Text(
            !online ? 'Offline · dados salvos neste aparelho' : ready
              ? 'Pronto para usar offline · dados neste aparelho'
              : 'Preparando uso offline… mantenha aberto',
            style: const TextStyle(fontSize: 12),
          )),
          if (update) TextButton(onPressed: () {
            if (web.window.confirm('Conclua a edição dos campos antes de atualizar. Os dados já salvos serão mantidos. Atualizar agora?')) _applyUpdate();
          }, child: const Text('Atualizar')),
          if (install && !update) TextButton(onPressed: _install, child: const Text('Instalar')),
        ]),
      )),
    );
  }
}
