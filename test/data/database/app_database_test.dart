import 'package:flutter_test/flutter_test.dart';
import 'package:flashcard_learning/data/database/app_database.dart';
import 'package:drift/drift.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = AppDatabase.inMemory();
  });

  tearDown(() async {
    await database.close();
  });

  group('Database Schema', () {
    test('should create all tables on initialization', () async {
      final deckCount = await database.select(database.decks).get();
      expect(deckCount, isEmpty);
      
      final cardCount = await database.select(database.cards).get();
      expect(cardCount, isEmpty);
      
      final sessionCount = await database.select(database.studySessions).get();
      expect(sessionCount, isEmpty);
      
      final reviewCount = await database.select(database.cardReviews).get();
      expect(reviewCount, isEmpty);
      
      final prefsCount = await database.select(database.userPreferences).get();
      expect(prefsCount, isEmpty);
    });

    test('should enforce foreign key constraint for cards', () async {
      expect(
        () => database.into(database.cards).insert(
          CardsCompanion.insert(
            id: 'card-1',
            deckId: 'non-existent-deck',
            frontText: 'test',
            backText: 'test',
            createdAt: DateTime.now(),
            easeFactor: 2.5,
            reviewCount: 0,
            currentInterval: 0,
          ),
        ),
        throwsA(isA<DriftWrappedException>()),
      );
    });
    
    test('should cascade delete cards when deck deleted', () async {
      // Create deck
      await database.into(database.decks).insert(
        DecksCompanion.insert(
          id: 'deck-1',
          name: 'Test Deck',
          createdAt: DateTime.now(),
        ),
      );
      
      // Create card
      await database.into(database.cards).insert(
        CardsCompanion.insert(
          id: 'card-1',
          deckId: 'deck-1',
          frontText: 'front',
          backText: 'back',
          createdAt: DateTime.now(),
          easeFactor: 2.5,
          reviewCount: 0,
          currentInterval: 0,
        ),
      );
      
      // Verify card exists
      var cards = await database.select(database.cards).get();
      expect(cards.length, 1);
      
      // Delete deck
      await (database.delete(database.decks)
        ..where((d) => d.id.equals('deck-1'))).go();
      
      // Verify card was cascade deleted
      cards = await database.select(database.cards).get();
      expect(cards, isEmpty);
    });
  });
}
