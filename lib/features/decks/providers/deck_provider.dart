import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcard_learning/data/database/app_database.dart';
import 'package:flashcard_learning/data/repositories/deck_repository.dart';

// Database provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});

// Repository provider
final deckRepositoryProvider = Provider<DeckRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DeckRepositoryImpl(database);
});

// Deck list stream provider
final deckListProvider = StreamProvider<List<DeckWithCardCount>>((ref) {
  final repository = ref.watch(deckRepositoryProvider);
  return repository.watchAllDecks();
});
