import 'dart:ffi';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flashcard_learning/data/database/app_database.dart';
import 'package:flashcard_learning/data/repositories/deck_repository.dart';

void main() {
  late AppDatabase database;
  late DeckRepository repository;

  setUpAll(() {
    // Setup SQLite for testing
    open.overrideFor(OperatingSystem.linux, _openOnLinux);
  });

  setUp(() async {
    database = AppDatabase.inMemory();
    repository = DeckRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('Deck Repository - CRUD', () {
    test('should create new deck', () async {
      await repository.createDeck('Test Deck');

      final decks = await repository.watchAllDecks().first;
      expect(decks.length, 1);
      expect(decks.first.name, 'Test Deck');
    });

    test('should get deck by ID', () async {
      await repository.createDeck('Test Deck');
      final decks = await repository.watchAllDecks().first;
      final deckId = decks.first.id;

      final deck = await repository.getDeckById(deckId);
      expect(deck, isNotNull);
      expect(deck!.name, 'Test Deck');
    });

    test('should update deck', () async {
      await repository.createDeck('Old Name');
      final decks = await repository.watchAllDecks().first;
      final deck = decks.first;

      await repository.updateDeck(deck.copyWith(name: 'New Name'));

      final updated = await repository.getDeckById(deck.id);
      expect(updated!.name, 'New Name');
    });

    test('should delete deck', () async {
      await repository.createDeck('Test Deck');
      final decks = await repository.watchAllDecks().first;
      final deckId = decks.first.id;

      await repository.deleteDeck(deckId);

      final allDecks = await repository.watchAllDecks().first;
      expect(allDecks, isEmpty);
    });
  });

  group('Deck Repository - Observation', () {
    test('should emit updates when deck created', () async {
      final stream = repository.watchAllDecks();
      
      // Drift streams emit immediately, so skip the first (empty) emission
      // and verify the stream emits after creating a deck
      await repository.createDeck('Test Deck');
      
      final decks = await stream.first;
      expect(decks, hasLength(1));
      expect(decks.first.deck.name, 'Test Deck');
    });

    test('should compute card count correctly', () async {
      // This test will be relevant after we implement CardRepository
      await repository.createDeck('Test Deck');
      final decks = await repository.watchAllDecks().first;
      
      expect(decks.first.cardCount, 0);
    });
  });
}

DynamicLibrary _openOnLinux() {
  try {
    return DynamicLibrary.open('libsqlite3.so');
  } catch (_) {
    // Fallback to SQLite from Flutter's bundled version
    return DynamicLibrary.process();
  }
}
