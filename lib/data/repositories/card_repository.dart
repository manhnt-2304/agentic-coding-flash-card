import 'package:flashcard_learning/data/database/app_database.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

abstract class CardRepository {
  Stream<List<Card>> watchCardsByDeck(String deckId);
  Future<Card?> getCardById(String cardId);
  Future<List<Card>> getDueCards(String deckId);
  Future<void> createCard({
    required String deckId,
    required String frontText,
    String? frontImagePath,
    required String backText,
    String? backImagePath,
  });
  Future<void> updateCard(Card card);
  Future<void> deleteCard(String cardId);
  Future<void> resetProgress(String cardId);
}

class CardRepositoryImpl implements CardRepository {
  final AppDatabase _db;

  CardRepositoryImpl(this._db);

  @override
  Stream<List<Card>> watchCardsByDeck(String deckId) {
    return (_db.select(_db.cards)
          ..where((c) => c.deckId.equals(deckId))
          ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
        .watch();
  }

  @override
  Future<Card?> getCardById(String cardId) async {
    return await (_db.select(_db.cards)
          ..where((c) => c.id.equals(cardId)))
        .getSingleOrNull();
  }

  @override
  Future<List<Card>> getDueCards(String deckId) async {
    final now = DateTime.now();
    return await (_db.select(_db.cards)
          ..where((c) => 
              c.deckId.equals(deckId) &
              (c.nextReviewDate.isNull() | c.nextReviewDate.isSmallerThanValue(now)))
          ..orderBy([(c) => OrderingTerm.asc(c.nextReviewDate)]))
        .get();
  }

  @override
  Future<void> createCard({
    required String deckId,
    required String frontText,
    String? frontImagePath,
    required String backText,
    String? backImagePath,
  }) async {
    await _db.into(_db.cards).insert(
      CardsCompanion.insert(
        id: const Uuid().v4(),
        deckId: deckId,
        frontText: frontText,
        backText: backText,
        frontImagePath: Value(frontImagePath),
        backImagePath: Value(backImagePath),
        createdAt: DateTime.now(),
        easeFactor: 2.5,
        reviewCount: 0,
        currentInterval: 0,
      ),
    );
  }

  @override
  Future<void> updateCard(Card card) async {
    await (_db.update(_db.cards)..where((c) => c.id.equals(card.id)))
        .write(card);
  }

  @override
  Future<void> deleteCard(String cardId) async {
    await (_db.delete(_db.cards)..where((c) => c.id.equals(cardId))).go();
  }

  @override
  Future<void> resetProgress(String cardId) async {
    await (_db.update(_db.cards)..where((c) => c.id.equals(cardId)))
        .write(
      CardsCompanion(
        easeFactor: const Value(2.5),
        reviewCount: const Value(0),
        currentInterval: const Value(0),
        nextReviewDate: const Value(null),
        lastReviewedAt: const Value(null),
      ),
    );
  }
}
