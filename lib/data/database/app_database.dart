import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'app_database.g.dart';

// Table definitions
class Decks extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastStudiedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get deckId => text().references(Decks, #id, onDelete: KeyAction.cascade)();
  TextColumn get frontText => text().withLength(min: 1, max: 500)();
  TextColumn get backText => text().withLength(min: 1, max: 500)();
  TextColumn get frontImagePath => text().nullable()();
  TextColumn get backImagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  DateTimeColumn get nextReviewDate => dateTime().nullable()();
  RealColumn get easeFactor => real()();
  IntColumn get reviewCount => integer()();
  IntColumn get currentInterval => integer()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class StudySessions extends Table {
  TextColumn get id => text()();
  TextColumn get deckId => text().references(Decks, #id)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get cardsReviewed => integer()();
  IntColumn get cardsKnown => integer()();
  IntColumn get cardsForgot => integer()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class CardReviews extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(StudySessions, #id)();
  TextColumn get cardId => text().references(Cards, #id)();
  DateTimeColumn get reviewTimestamp => dateTime()();
  IntColumn get rating => integer()();
  IntColumn get timeSpent => integer()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class UserPreferences extends Table {
  TextColumn get id => text()();
  TextColumn get ttsVoice => text()();
  BoolColumn get autoPlayEnabled => boolean()();
  BoolColumn get notificationEnabled => boolean()();
  TextColumn get notificationTime => text()();
  TextColumn get theme => text()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Decks, Cards, StudySessions, CardReviews, UserPreferences])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  // For testing
  AppDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      
      // Create indexes for performance
      await customStatement('''
        CREATE INDEX idx_cards_deck_id ON cards(deck_id);
        CREATE INDEX idx_cards_next_review ON cards(next_review_date);
        CREATE INDEX idx_card_reviews_session ON card_reviews(session_id);
        CREATE INDEX idx_study_sessions_deck ON study_sessions(deck_id);
      ''');
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'flashcard_learning.sqlite'));
    return NativeDatabase(file);
  });
}
