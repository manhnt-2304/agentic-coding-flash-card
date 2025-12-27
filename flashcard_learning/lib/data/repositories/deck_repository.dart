import 'package:flashcard_learning/data/database/app_database.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart';

abstract class DeckRepository {
  Stream<List<DeckWithCardCount>> watchAllDecks();
  Future<DeckWithCardCount?> getDeckById(String deckId);
  Future<void> createDeck(String name);
  Future<void> updateDeck(DeckWithCardCount deck);
  Future<void> deleteDeck(String deckId);
}

class DeckWithCardCount {
  final Deck deck;
  final int cardCount;

  DeckWithCardCount(this.deck, this.cardCount);

  String get id => deck.id;
  String get name => deck.name;
  DateTime get createdAt => deck.createdAt;
  DateTime? get lastStudiedAt => deck.lastStudiedAt;

  DeckWithCardCount copyWith({String? name, DateTime? lastStudiedAt}) {
    return DeckWithCardCount(
      Deck(
        id: deck.id,
        name: name ?? deck.name,
        createdAt: deck.createdAt,
        lastStudiedAt: lastStudiedAt ?? deck.lastStudiedAt,
      ),
      cardCount,
    );
  }
}

class DeckRepositoryImpl implements DeckRepository {
  final AppDatabase _db;

  DeckRepositoryImpl(this._db);

  @override
  Stream<List<DeckWithCardCount>> watchAllDecks() {
    return _db.select(_db.decks).watch().asyncMap((decks) async {
      final List<DeckWithCardCount> result = [];
      for (final deck in decks) {
        final count = await _getCardCount(deck.id);
        result.add(DeckWithCardCount(deck, count));
      }
      // Sort by lastStudiedAt desc (most recently studied first)
      result.sort((a, b) {
        if (a.lastStudiedAt == null) return 1;
        if (b.lastStudiedAt == null) return -1;
        return b.lastStudiedAt!.compareTo(a.lastStudiedAt!);
      });
      return result;
    });
  }

  @override
  Future<DeckWithCardCount?> getDeckById(String deckId) async {
    final deck = await (_db.select(_db.decks)
          ..where((d) => d.id.equals(deckId)))
        .getSingleOrNull();
    
    if (deck == null) return null;
    
    final count = await _getCardCount(deckId);
    return DeckWithCardCount(deck, count);
  }

  @override
  Future<void> createDeck(String name) async {
    await _db.into(_db.decks).insert(
      DecksCompanion.insert(
        id: const Uuid().v4(),
        name: name,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> updateDeck(DeckWithCardCount deck) async {
    await (_db.update(_db.decks)
          ..where((d) => d.id.equals(deck.id)))
        .write(
      DecksCompanion(
        name: Value(deck.name),
        lastStudiedAt: Value(deck.lastStudiedAt),
      ),
    );
  }

  @override
  Future<void> deleteDeck(String deckId) async {
    await (_db.delete(_db.decks)..where((d) => d.id.equals(deckId))).go();
  }

  Future<int> _getCardCount(String deckId) async {
    final query = _db.selectOnly(_db.cards)
      ..addColumns([_db.cards.id.count()])
      ..where(_db.cards.deckId.equals(deckId));
    
    final result = await query.getSingle();
    return result.read(_db.cards.id.count()) ?? 0;
  }
}
