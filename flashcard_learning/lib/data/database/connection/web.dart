// Web implementation using sql.js (IndexedDB storage)
import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor connectImpl() {
  return WebDatabase('flashcard_learning', logStatements: true);
}

QueryExecutor connectInMemoryImpl() {
  // For testing, use volatile (in-memory) storage
  return WebDatabase.withStorage(
    DriftWebStorage.volatile(),
    logStatements: true,
  );
}

