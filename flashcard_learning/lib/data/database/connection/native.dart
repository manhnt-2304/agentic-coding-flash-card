// Native implementation (Android/iOS/Desktop using SQLite via FFI)
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

QueryExecutor connectImpl() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'flashcard_learning.sqlite'));
    return NativeDatabase(file);
  });
}

QueryExecutor connectInMemoryImpl() {
  return NativeDatabase.memory();
}
