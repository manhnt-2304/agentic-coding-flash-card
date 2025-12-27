import 'package:flashcard_learning/data/database/app_database.dart';
import 'package:flashcard_learning/services/sm2_algorithm.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

/// Repository for recording card reviews and updating SRS schedule
abstract class ReviewRepository {
  /// Record a card review and update the card's SRS fields
  Future<void> recordReview({
    required String cardId,
    required String sessionId,
    required int rating, // 1=Hard/Forgot, 3=Normal, 5=Easy/Know
  });
}

class ReviewRepositoryImpl implements ReviewRepository {
  final AppDatabase _db;
  final SM2Algorithm _algorithm;

  ReviewRepositoryImpl(this._db, this._algorithm);

  @override
  Future<void> recordReview({
    required String cardId,
    required String sessionId,
    required int rating,
  }) async {
    await _db.transaction(() async {
      // Get current card state
      final card = await (_db.select(_db.cards)
            ..where((c) => c.id.equals(cardId)))
          .getSingle();

      // Calculate new SRS values using SM-2 algorithm
      final sm2Result = _algorithm.calculate(
        rating: rating,
        previousEaseFactor: card.easeFactor,
        previousInterval: card.currentInterval,
        reviewCount: card.reviewCount,
      );

      // Update card with new SRS values
      await (_db.update(_db.cards)..where((c) => c.id.equals(cardId))).write(
        CardsCompanion(
          lastReviewedAt: Value(DateTime.now()),
          nextReviewDate: Value(sm2Result.nextReviewDate),
          easeFactor: Value(sm2Result.easeFactor),
          currentInterval: Value(sm2Result.currentInterval),
          reviewCount: Value(card.reviewCount + 1),
        ),
      );

      // Record review in CardReviews table
      await _db.into(_db.cardReviews).insert(
        CardReviewsCompanion.insert(
          id: const Uuid().v4(),
          sessionId: sessionId,
          cardId: cardId,
          reviewTimestamp: DateTime.now(),
          rating: rating,
          timeSpent: 0, // Will be calculated in future tasks
        ),
      );
    });
  }
}
