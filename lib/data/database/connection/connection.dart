// Conditional imports for platform-specific database implementation
import 'package:drift/drift.dart';

// Import platform-specific implementations
import 'unsupported.dart'
    if (dart.library.ffi) 'native.dart'
    if (dart.library.html) 'web.dart';

QueryExecutor connect() {
  return connectImpl();
}

QueryExecutor connectInMemory() {
  return connectInMemoryImpl();
}
