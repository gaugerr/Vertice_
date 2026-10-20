import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

QueryExecutor openWebDatabase() => LazyDatabase(() async {
  final result = await WasmDatabase.open(
    databaseName: 'vertice_local_v1',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );
  if (result.chosenImplementation == WasmStorageImplementation.inMemory ||
      result.chosenImplementation == WasmStorageImplementation.unsafeIndexedDb) {
    await result.resolvedExecutor.executor.close();
    throw StateError('Este navegador não oferece armazenamento local seguro. Use uma versão atualizada, fora do modo privado.');
  }
  return result.resolvedExecutor.executor;
});
