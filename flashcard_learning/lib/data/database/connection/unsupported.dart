// Unsupported platform fallback
import 'package:drift/drift.dart';

QueryExecutor connectImpl() {
  throw UnsupportedError(
    'No suitable database implementation was found on this platform.',
  );
}

QueryExecutor connectInMemoryImpl() {
  throw UnsupportedError(
    'No suitable database implementation was found on this platform.',
  );
}
