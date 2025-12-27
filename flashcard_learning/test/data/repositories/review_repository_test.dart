import 'package:flutter_test/flutter_test.dart';
import 'package:flashcard_learning/data/database/app_database.dart';
import 'package:flashcard_learning/data/repositories/review_repository.dart';
import 'package:flashcard_learning/data/repositories/deck_repository.dart';
import 'package:flashcard_learning/data/repositories/card_repository.dart';
import 'package:flashcard_learning/services/sm2_algorithm.dart';

void main() {
  late AppDatabase database;
  late ReviewRepository reviewRepository;
  late DeckRepository deckRepository;
  late CardRepository cardRepository;
  late SM2Algorithm algorithm;
  late String testDeckId;
  late String testCardId;
  late String testSessionId;

  setUp(() async {
    database = AppDatabase.inMemory();
    algorithm = SM2AlgorithmImpl();
    reviewRepository = ReviewRepositoryImpl(database, algorithm);
    deckRepository = DeckRepositoryImpl(database);
    cardRepository = CardRepositoryImpl(database);

    // Create test deck
    await deckRepository.createDeck('Test Deck');
    final decks = await deckRepository.watchAllDecks().first;
    testDeckId = decks.first.id;

    // Create test card
    await cardRepository.createCard(
      deckId: testDeckId,
      frontText: 'Hello',
      backText: 'Xin chào',
    );
    final cards = await cardRepository.watchCardsByDeck(testDeckId).first;
    testCardId = cards.first.id;

    // Create test session
    testSessionId = 'test-session-1';
    await database.into(database.studySessions).insert(
      StudySessionsCompanion.insert(
        id: testSessionId,
        deckId: testDeckId,
        startTime: DateTime.now(),
        cardsReviewed: 0,
        cardsKnown: 0,
        cardsForgot: 0,
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  group('ReviewRepository', () {
    test('should record review and update card SRS fields', () async {
      // Initial card state
      final cardBefore = await cardRepository.getCardById(testCardId);
      expect(cardBefore!.reviewCount, 0);
      expect(cardBefore.easeFactor, 2.5);
      expect(cardBefore.nextReviewDate, isNull);

      // Record a "Normal" rating (3)
      await reviewRepository.recordReview(
        cardId: testCardId,
        sessionId: testSessionId,
        rating: 3,
      );

      // Check card was updated
      final cardAfter = await cardRepository.getCardById(testCardId);
      expect(cardAfter!.reviewCount, 1);
      expect(cardAfter.easeFactor, 2.5); // Unchanged for Normal
      expect(cardAfter.currentInterval, 3); // First review with Normal = 3 days
      expect(cardAfter.nextReviewDate, isNotNull);
      expect(cardAfter.lastReviewedAt, isNotNull);
    });

    test('should record "Easy" rating (5) and increase ease factor', () async {
      // Record an "Easy" rating
      await reviewRepository.recordReview(
        cardId: testCardId,
        sessionId: testSessionId,
        rating: 5,
      );

      final card = await cardRepository.getCardById(testCardId);
      expect(card!.reviewCount, 1);
      expect(card.easeFactor, 2.65); // 2.5 + 0.15
      expect(card.currentInterval, 7); // First review with Easy = 7 days
    });

    test('should record "Hard" rating (1) and decrease ease factor', () async {
      // Record a "Hard" rating
      await reviewRepository.recordReview(
        cardId: testCardId,
        sessionId: testSessionId,
        rating: 1,
      );

      final card = await cardRepository.getCardById(testCardId);
      expect(card!.reviewCount, 1);
      expect(card.easeFactor, 2.3); // 2.5 - 0.2
      expect(card.currentInterval, 1); // First review with Hard = 1 day
    });

    test('should create CardReview record', () async {
      await reviewRepository.recordReview(
        cardId: testCardId,
        sessionId: testSessionId,
        rating: 3,
      );

      // Query CardReviews table
      final reviews = await (database.select(database.cardReviews)
            ..where((r) => r.sessionId.equals(testSessionId)))
          .get();

      expect(reviews.length, 1);
      expect(reviews.first.cardId, testCardId);
      expect(reviews.first.rating, 3);
      expect(reviews.first.reviewTimestamp, isNotNull);
    });

    test('should handle multiple reviews with increasing intervals', () async {
      // First review: Normal (3)
      await reviewRepository.recordReview(
        cardId: testCardId,
        sessionId: testSessionId,
        rating: 3,
      );

      var card = await cardRepository.getCardById(testCardId);
      expect(card!.currentInterval, 3); // First: 3 days
      expect(card.reviewCount, 1);

      // Second review: Normal (3)
      await reviewRepository.recordReview(
        cardId: testCardId,
        sessionId: testSessionId,
        rating: 3,
      );

      card = await cardRepository.getCardById(testCardId);
      expect(card!.currentInterval, 8); // 3 * 2.5 = 7.5 → 8 days (rounded)
      expect(card.reviewCount, 2);

      // Third review: Easy (5)
      await reviewRepository.recordReview(
        cardId: testCardId,
        sessionId: testSessionId,
        rating: 5,
      );

      card = await cardRepository.getCardById(testCardId);
      expect(card!.easeFactor, 2.65); // 2.5 + 0.15
      expect(card.currentInterval, 21); // 8 * 2.65 = 21.2 → 21 days
      expect(card.reviewCount, 3);
    });

    test('should reset interval to 1 on Hard rating after progress', () async {
      // Build up some progress
      await reviewRepository.recordReview(
        cardId: testCardId,
        sessionId: testSessionId,
        rating: 3,
      );

      await reviewRepository.recordReview(
        cardId: testCardId,
        sessionId: testSessionId,
        rating: 5,
      );

      var card = await cardRepository.getCardById(testCardId);
      expect(card!.currentInterval, greaterThan(5));

      // Now rate as Hard (1)
      await reviewRepository.recordReview(
        cardId: testCardId,
        sessionId: testSessionId,
        rating: 1,
      );

      card = await cardRepository.getCardById(testCardId);
      expect(card!.currentInterval, 1); // Reset to 1 day
      expect(card.easeFactor, lessThan(2.5)); // Decreased
    });
  });
}
