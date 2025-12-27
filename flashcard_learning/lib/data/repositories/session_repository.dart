import 'package:flashcard_learning/data/database/app_database.dart';
import 'package:drift/drift.dart';

/// Session summary data
class SessionSummaryData {
  final int cardsReviewed;
  final int cardsKnown;
  final int cardsForgot;
  final double accuracyRate; // Percentage
  final int duration; // Seconds
  final int nextReviewCount; // Cards due tomorrow

  SessionSummaryData({
    required this.cardsReviewed,
    required this.cardsKnown,
    required this.cardsForgot,
    required this.accuracyRate,
    required this.duration,
    required this.nextReviewCount,
  });
}

/// Repository for study session operations
abstract class SessionRepository {
  Future<SessionSummaryData> getSessionSummary(String sessionId);
  Future<List<String>> getForgottenCardIds(String sessionId);
}

class SessionRepositoryImpl implements SessionRepository {
  final AppDatabase _db;

  SessionRepositoryImpl(this._db);

  @override
  Future<SessionSummaryData> getSessionSummary(String sessionId) async {
    // Get session data
    final session = await (_db.select(_db.studySessions)
          ..where((s) => s.id.equals(sessionId)))
        .getSingleOrNull();

    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }

    // Calculate duration
    final endTime = session.endTime ?? DateTime.now();
    final duration = endTime.difference(session.startTime).inSeconds;

    // Calculate accuracy rate
    final total = session.cardsReviewed;
    final accuracyRate = total > 0 
        ? (session.cardsKnown / total * 100) 
        : 0.0;

    // Get next review count (cards due tomorrow)
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final tomorrowEnd = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 23, 59, 59);
    
    final nextReviewQuery = _db.selectOnly(_db.cards)
      ..addColumns([_db.cards.id.count()])
      ..where(_db.cards.nextReviewDate.isSmallerOrEqualValue(tomorrowEnd));
    
    final result = await nextReviewQuery.getSingle();
    final nextReviewCount = result.read(_db.cards.id.count()) ?? 0;

    return SessionSummaryData(
      cardsReviewed: session.cardsReviewed,
      cardsKnown: session.cardsKnown,
      cardsForgot: session.cardsForgot,
      accuracyRate: accuracyRate,
      duration: duration,
      nextReviewCount: nextReviewCount,
    );
  }

  @override
  Future<List<String>> getForgottenCardIds(String sessionId) async {
    // Get all card reviews with rating 1 (Forgot/Hard) from this session
    final reviews = await (_db.select(_db.cardReviews)
          ..where((r) => r.sessionId.equals(sessionId) & r.rating.equals(1)))
        .get();

    return reviews.map((r) => r.cardId).toList();
  }
}
