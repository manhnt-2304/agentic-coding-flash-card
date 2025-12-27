// Entry point for drift's web worker
import 'package:drift/web/worker.dart';

void main() {
  driftWorkerMain(() async {
    // Return the sqlite3 module
    return WasmDatabaseSetup.loadFromNetwork(
      sqlite3WasmUri: Uri.parse('sqlite3.wasm'),
    );
  });
}
