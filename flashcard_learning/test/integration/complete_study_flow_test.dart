import 'package:flashcard_learning/data/database/app_database.dart';
import 'package:flashcard_learning/data/repositories/card_repository.dart';
import 'package:flashcard_learning/data/repositories/deck_repository.dart';
import 'package:flashcard_learning/data/repositories/review_repository.dart';
import 'package:flashcard_learning/data/repositories/session_repository.dart';
import 'package:flashcard_learning/services/sm2_algorithm.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;

/// Integration Test for Task 1.8: Complete Study Flow
///
/// Tests the end-to-end study flow at repository level:
/// 1. Create deck and cards
/// 2. Simulate study session (record reviews)
/// 3. Verify session statistics
/// 4. Verify card SRS updates
/// 5. Verify session summary data
void main() {
  group('Task 1.8 - Complete Study Flow Integration Test', () {
    late AppDatabase database;
    late DeckRepository deckRepository;
    late CardRepository cardRepository;
    late ReviewRepository reviewRepository;
    late SessionRepository sessionRepository;

    setUp(() async {
      // Create in-memory database
      database = AppDatabase.inMemory();

      // Initialize repositories
      final algorithm = SM2AlgorithmImpl();
      deckRepository = DeckRepositoryImpl(database);
      cardRepository = CardRepositoryImpl(database);
      reviewRepository = ReviewRepositoryImpl(database, algorithm);
      sessionRepository = SessionRepositoryImpl(database);
    });

    tearDown(() async {
      await database.close();
    });

    test(
      'Complete study flow: Create deck → Study cards → Verify data',
      () async {
        // ==========================================
        // STEP 1: Create deck and 5 cards
        // ==========================================
        await deckRepository.createDeck('Test Study Deck');
        final decks = await deckRepository.watchAllDecks().first;
        final deckId = decks.first.id;

        final cardData = [
          {'front': 'What is Flutter?', 'back': 'UI framework'},
          {'front': 'What is Dart?', 'back': 'Programming language'},
          {'front': 'What is Widget?', 'back': 'UI building block'},
          {'front': 'What is State?', 'back': 'Data that changes'},
          {'front': 'What is Provider?', 'back': 'State management'},
        ];

        for (final data in cardData) {
          await cardRepository.createCard(
            deckId: deckId,
            frontText: data['front']!,
            backText: data['back']!,
          );
        }

        final cards = await cardRepository.watchCardsByDeck(deckId).first;
        expect(cards.length, 5, reason: 'Should have 5 cards');

        // ==========================================
        // STEP 2: Create session and simulate study
        // ==========================================
        final sessionId = 'test-session-001';
        final startTime = DateTime.now().subtract(const Duration(minutes: 5));

        // Create session record
        await database.into(database.studySessions).insert(
          StudySessionsCompanion.insert(
            id: sessionId,
            deckId: deckId,
            startTime: startTime,
            cardsReviewed: 0,
            cardsKnown: 0,
            cardsForgot: 0,
          ),
        );

        // Simulate studying cards with ratings
        // Ratings: [1, 5, 5, 1, 5] = 3 known, 2 forgot, 60% accuracy
        final ratings = [1, 5, 5, 1, 5];
        int knownCount = 0;
        int forgotCount = 0;

        for (int i = 0; i < cards.length; i++) {
          final rating = ratings[i];
          
          // Record review (this also updates card SRS)
          await reviewRepository.recordReview(
            cardId: cards[i].id,
            sessionId: sessionId,
            rating: rating,
          );

          // Update statistics
          if (rating == 5) {
            knownCount++;
          } else if (rating == 1) {
            forgotCount++;
          }
        }

        // End session with final statistics
        final endTime = DateTime.now();
        await (database.update(database.studySessions)
              ..where((s) => s.id.equals(sessionId)))
            .write(
          StudySessionsCompanion(
            endTime: drift.Value(endTime),
            cardsReviewed: drift.Value(5),
            cardsKnown: drift.Value(knownCount),
            cardsForgot: drift.Value(forgotCount),
          ),
        );

        // ==========================================
        // STEP 3: Verify session in database
        // ==========================================
        final sessions = await database.select(database.studySessions).get();
        expect(sessions.length, 1, reason: 'Should have 1 session');

        final session = sessions.first;
        expect(session.deckId, deckId);
        expect(session.cardsReviewed, 5);
        expect(session.cardsKnown, 3);
        expect(session.cardsForgot, 2);
        expect(session.endTime, isNotNull);
        expect(session.endTime!.isAfter(session.startTime), true);

        // ==========================================
        // STEP 4: Verify card reviews
        // ==========================================
        final reviews = await database.select(database.cardReviews).get();
        expect(reviews.length, 5, reason: 'Should have 5 reviews');

        final reviewRatings = reviews.map((r) => r.rating).toList()..sort();
        expect(reviewRatings, [1, 1, 5, 5, 5],
            reason: 'Ratings should match');

        for (final review in reviews) {
          expect(review.sessionId, sessionId);
        }

        // ==========================================
        // STEP 5: Verify SRS updates on cards
        // ==========================================
        final updatedCards =
            await cardRepository.watchCardsByDeck(deckId).first;

        for (final card in updatedCards) {
          expect(card.lastReviewedAt, isNotNull);
          expect(card.nextReviewDate, isNotNull);
          expect(card.reviewCount, 1);
          expect(card.easeFactor, isNot(2.5));
          expect(card.currentInterval, greaterThan(0));
        }

        // ==========================================
        // STEP 6: Verify session summary
        // ==========================================
        final summary = await sessionRepository.getSessionSummary(sessionId);

        expect(summary.cardsReviewed, 5);
        expect(summary.cardsKnown, 3);
        expect(summary.cardsForgot, 2);
        expect(summary.accuracyRate, closeTo(60.0, 0.1));
        expect(summary.duration, greaterThan(0));

        // ==========================================
        // STEP 7: Verify forgotten cards
        // ==========================================
        final forgottenIds =
            await sessionRepository.getForgottenCardIds(sessionId);

        expect(forgottenIds.length, 2);

        for (final cardId in forgottenIds) {
          final review = reviews.firstWhere((r) => r.cardId == cardId);
          expect(review.rating, 1);
        }
      },
    );

    test('Session statistics with manual data', () async {
      // Create deck and 10 cards
      await deckRepository.createDeck('Stats Deck');
      final decks = await deckRepository.watchAllDecks().first;
      final deckId = decks.first.id;

      for (int i = 1; i <= 10; i++) {
        await cardRepository.createCard(
          deckId: deckId,
          frontText: 'Q$i',
          backText: 'A$i',
        );
      }

      final cards = await cardRepository.watchCardsByDeck(deckId).first;

      // Create session manually
      final sessionId = 'test-session-123';
      final startTime = DateTime.now().subtract(const Duration(minutes: 10));
      final endTime = DateTime.now();

      await database.into(database.studySessions).insert(
        StudySessionsCompanion.insert(
          id: sessionId,
          deckId: deckId,
          startTime: startTime,
          endTime: drift.Value(endTime),
          cardsReviewed: 10,
          cardsKnown: 7,
          cardsForgot: 3,
        ),
      );

      // Create reviews: 7 known, 3 forgot
      for (int i = 0; i < 10; i++) {
        final rating = i < 7 ? 5 : 1;
        await reviewRepository.recordReview(
          cardId: cards[i].id,
          sessionId: sessionId,
          rating: rating,
        );
      }

      // Verify summary
      final summary = await sessionRepository.getSessionSummary(sessionId);

      expect(summary.cardsReviewed, 10);
      expect(summary.cardsKnown, 7);
      expect(summary.cardsForgot, 3);
      expect(summary.accuracyRate, closeTo(70.0, 0.1));
      expect(summary.duration, greaterThanOrEqualTo(600));

      // Verify forgotten cards
      final forgottenIds =
          await sessionRepository.getForgottenCardIds(sessionId);
      expect(forgottenIds.length, 3);

      // Verify SRS updates
      final updatedCards = await cardRepository.watchCardsByDeck(deckId).first;
      for (final card in updatedCards) {
        expect(card.lastReviewedAt, isNotNull);
        expect(card.nextReviewDate, isNotNull);
        expect(card.reviewCount, 1);
      }
    });

    test('Perfect session: All cards known', () async {
      await deckRepository.createDeck('Perfect Deck');
      final decks = await deckRepository.watchAllDecks().first;
      final deckId = decks.first.id;

      // Create 3 cards
      for (int i = 1; i <= 3; i++) {
        await cardRepository.createCard(
          deckId: deckId,
          frontText: 'Q$i',
          backText: 'A$i',
        );
      }

      final cards = await cardRepository.watchCardsByDeck(deckId).first;

      // Create perfect session
      final sessionId = 'perfect-session';
      await database.into(database.studySessions).insert(
        StudySessionsCompanion.insert(
          id: sessionId,
          deckId: deckId,
          startTime: DateTime.now().subtract(const Duration(minutes: 2)),
          endTime: drift.Value(DateTime.now()),
          cardsReviewed: 3,
          cardsKnown: 3,
          cardsForgot: 0,
        ),
      );

      // All reviews with rating 5
      for (final card in cards) {
        await reviewRepository.recordReview(
          cardId: card.id,
          sessionId: sessionId,
          rating: 5,
        );
      }

      // Verify 100% accuracy
      final summary = await sessionRepository.getSessionSummary(sessionId);
      expect(summary.cardsReviewed, 3);
      expect(summary.cardsKnown, 3);
      expect(summary.cardsForgot, 0);
      expect(summary.accuracyRate, 100.0);

      // No forgotten cards
      final forgottenIds =
          await sessionRepository.getForgottenCardIds(sessionId);
      expect(forgottenIds, isEmpty);
    });

    test('All cards forgotten', () async {
      await deckRepository.createDeck('Hard Deck');
      final decks = await deckRepository.watchAllDecks().first;
      final deckId = decks.first.id;

      // Create 3 cards
      for (int i = 1; i <= 3; i++) {
        await cardRepository.createCard(
          deckId: deckId,
          frontText: 'Hard Q$i',
          backText: 'Hard A$i',
        );
      }

      final cards = await cardRepository.watchCardsByDeck(deckId).first;

      // Create difficult session
      final sessionId = 'hard-session';
      await database.into(database.studySessions).insert(
        StudySessionsCompanion.insert(
          id: sessionId,
          deckId: deckId,
          startTime: DateTime.now().subtract(const Duration(minutes: 2)),
          endTime: drift.Value(DateTime.now()),
          cardsReviewed: 3,
          cardsKnown: 0,
          cardsForgot: 3,
        ),
      );

      // All reviews with rating 1
      for (final card in cards) {
        await reviewRepository.recordReview(
          cardId: card.id,
          sessionId: sessionId,
          rating: 1,
        );
      }

      // Verify 0% accuracy
      final summary = await sessionRepository.getSessionSummary(sessionId);
      expect(summary.cardsReviewed, 3);
      expect(summary.cardsKnown, 0);
      expect(summary.cardsForgot, 3);
      expect(summary.accuracyRate, 0.0);

      // All cards forgotten
      final forgottenIds =
          await sessionRepository.getForgottenCardIds(sessionId);
      expect(forgottenIds.length, 3);
    });
  });
}
