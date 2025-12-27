import 'package:flutter_test/flutter_test.dart';
import 'package:flashcard_learning/data/database/app_database.dart';
import 'package:flashcard_learning/data/repositories/deck_repository.dart';
import 'package:flashcard_learning/data/repositories/card_repository.dart';
import 'package:flashcard_learning/data/repositories/session_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

void main() {
  late AppDatabase database;
  late SessionRepository sessionRepository;
  late DeckRepository deckRepository;
  late CardRepository cardRepository;

  setUp(() async {
    database = AppDatabase.inMemory();
    sessionRepository = SessionRepositoryImpl(database);
    deckRepository = DeckRepositoryImpl(database);
    cardRepository = CardRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('SessionRepository', () {
    test('should get session summary with correct data', () async {
      // Create deck
      await deckRepository.createDeck('Test Deck');
      final decks = await deckRepository.watchAllDecks().first;
      final deckId = decks.first.id;

      // Create session
      final sessionId = const Uuid().v4();
      final startTime = DateTime.now().subtract(const Duration(minutes: 5));
      
      await database.into(database.studySessions).insert(
        StudySessionsCompanion.insert(
          id: sessionId,
          deckId: deckId,
          startTime: startTime,
          endTime: Value(DateTime.now()),
          cardsReviewed: 10,
          cardsKnown: 7,
          cardsForgot: 3,
        ),
      );

      // Get summary
      final summary = await sessionRepository.getSessionSummary(sessionId);

      expect(summary.cardsReviewed, 10);
      expect(summary.cardsKnown, 7);
      expect(summary.cardsForgot, 3);
      expect(summary.accuracyRate, closeTo(70.0, 0.1)); // 7/10 * 100
      expect(summary.duration, greaterThanOrEqualTo(300)); // ~5 minutes
    });

    test('should calculate accuracy rate correctly', () async {
      // Create deck
      await deckRepository.createDeck('Test Deck');
      final decks = await deckRepository.watchAllDecks().first;
      final deckId = decks.first.id;

      // Perfect session
      final sessionId = const Uuid().v4();
      await database.into(database.studySessions).insert(
        StudySessionsCompanion.insert(
          id: sessionId,
          deckId: deckId,
          startTime: DateTime.now(),
          cardsReviewed: 5,
          cardsKnown: 5,
          cardsForgot: 0,
        ),
      );

      final summary = await sessionRepository.getSessionSummary(sessionId);
      expect(summary.accuracyRate, 100.0);
    });

    test('should handle zero cards reviewed', () async {
      // Create deck
      await deckRepository.createDeck('Test Deck');
      final decks = await deckRepository.watchAllDecks().first;
      final deckId = decks.first.id;

      // Empty session
      final sessionId = const Uuid().v4();
      await database.into(database.studySessions).insert(
        StudySessionsCompanion.insert(
          id: sessionId,
          deckId: deckId,
          startTime: DateTime.now(),
          cardsReviewed: 0,
          cardsKnown: 0,
          cardsForgot: 0,
        ),
      );

      final summary = await sessionRepository.getSessionSummary(sessionId);
      expect(summary.accuracyRate, 0.0);
    });

    test('should get forgotten card IDs', () async {
      // Create deck and cards
      await deckRepository.createDeck('Test Deck');
      final decks = await deckRepository.watchAllDecks().first;
      final deckId = decks.first.id;

      await cardRepository.createCard(
        deckId: deckId,
        frontText: 'Card 1',
        backText: 'Answer 1',
      );
      await cardRepository.createCard(
        deckId: deckId,
        frontText: 'Card 2',
        backText: 'Answer 2',
      );

      final cards = await cardRepository.watchCardsByDeck(deckId).first;

      // Create session
      final sessionId = const Uuid().v4();
      await database.into(database.studySessions).insert(
        StudySessionsCompanion.insert(
          id: sessionId,
          deckId: deckId,
          startTime: DateTime.now(),
          cardsReviewed: 2,
          cardsKnown: 1,
          cardsForgot: 1,
        ),
      );

      // Create card reviews (1 = Forgot)
      await database.into(database.cardReviews).insert(
        CardReviewsCompanion.insert(
          id: const Uuid().v4(),
          sessionId: sessionId,
          cardId: cards[0].id,
          reviewTimestamp: DateTime.now(),
          rating: 1, // Forgot
          timeSpent: 10,
        ),
      );

      await database.into(database.cardReviews).insert(
        CardReviewsCompanion.insert(
          id: const Uuid().v4(),
          sessionId: sessionId,
          cardId: cards[1].id,
          reviewTimestamp: DateTime.now(),
          rating: 5, // Know
          timeSpent: 5,
        ),
      );

      // Get forgotten cards
      final forgottenIds = await sessionRepository.getForgottenCardIds(sessionId);

      expect(forgottenIds.length, 1);
      expect(forgottenIds.first, cards[0].id);
    });

    test('should throw exception for non-existent session', () async {
      expect(
        () => sessionRepository.getSessionSummary('non-existent-id'),
        throwsException,
      );
    });
  });
}
