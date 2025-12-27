import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcard_learning/features/cards/screens/card_editor_screen.dart';
import 'package:flashcard_learning/data/database/app_database.dart' hide Card;
import 'package:flashcard_learning/data/repositories/deck_repository.dart';
import 'package:flashcard_learning/data/repositories/card_repository.dart';
import 'package:flashcard_learning/features/decks/providers/deck_provider.dart'
    show databaseProvider;

void main() {
  late AppDatabase database;
  late DeckRepository deckRepository;
  late CardRepository cardRepository;
  late String testDeckId;

  setUp(() async {
    database = AppDatabase.inMemory();
    deckRepository = DeckRepositoryImpl(database);
    cardRepository = CardRepositoryImpl(database);

    // Create test deck
    await deckRepository.createDeck('Test Deck');
    final decks = await deckRepository.watchAllDecks().first;
    testDeckId = decks.first.id;
  });

  tearDown(() async {
    await database.close();
  });

  group('CardEditorScreen - Create Mode', () {
    testWidgets('displays empty form for new card', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: CardEditorScreen(deckId: testDeckId),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Add Card'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Front and back
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('validates front text is not empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: CardEditorScreen(deckId: testDeckId),
          ),
        ),
      );

      await tester.pump();

      // Tap save without entering text
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Please enter front text'), findsOneWidget);
    });

    testWidgets('validates back text is not empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: CardEditorScreen(deckId: testDeckId),
          ),
        ),
      );

      await tester.pump();

      // Enter front text only
      await tester.enterText(
        find.byType(TextFormField).first,
        'Hello',
      );

      // Tap save without entering back text
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Please enter back text'), findsOneWidget);
    });

    testWidgets('creates new card when form is valid', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: CardEditorScreen(deckId: testDeckId),
          ),
        ),
      );

      await tester.pump();

      // Enter front text
      await tester.enterText(
        find.byType(TextFormField).first,
        'Hello',
      );

      // Enter back text
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Xin chào',
      );

      // Tap save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify card was created
      final cards = await cardRepository.watchCardsByDeck(testDeckId).first;
      expect(cards.length, 1);
      expect(cards.first.frontText, 'Hello');
      expect(cards.first.backText, 'Xin chào');
    });

    testWidgets('pops screen after successful save', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CardEditorScreen(deckId: testDeckId),
                      ),
                    );
                  },
                  child: const Text('Open Editor'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open editor
      await tester.tap(find.text('Open Editor'));
      await tester.pumpAndSettle();

      expect(find.text('Add Card'), findsOneWidget);

      // Fill and save
      await tester.enterText(find.byType(TextFormField).first, 'Test');
      await tester.enterText(find.byType(TextFormField).at(1), 'Test');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Should navigate back
      expect(find.text('Add Card'), findsNothing);
      expect(find.text('Open Editor'), findsOneWidget);
    });
  });

  group('CardEditorScreen - Edit Mode', () {
    testWidgets('displays existing card data', (tester) async {
      // Create a card first
      await cardRepository.createCard(
        deckId: testDeckId,
        frontText: 'Hello',
        backText: 'Xin chào',
      );

      final cards = await cardRepository.watchCardsByDeck(testDeckId).first;
      final cardId = cards.first.id;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: CardEditorScreen(
              deckId: testDeckId,
              cardId: cardId,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Edit Card'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Xin chào'), findsOneWidget);
    });

    testWidgets('updates existing card', (tester) async {
      // Create a card first
      await cardRepository.createCard(
        deckId: testDeckId,
        frontText: 'Hello',
        backText: 'Xin chào',
      );

      final cards = await cardRepository.watchCardsByDeck(testDeckId).first;
      final cardId = cards.first.id;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: CardEditorScreen(
              deckId: testDeckId,
              cardId: cardId,
            ),
          ),
        ),
      );

      await tester.pump();

      // Clear and update front text
      await tester.enterText(
        find.byType(TextFormField).first,
        'Goodbye',
      );

      // Clear and update back text
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'Tạm biệt',
      );

      // Tap save
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      // Verify card was updated
      final updatedCards = await cardRepository.watchCardsByDeck(testDeckId).first;
      expect(updatedCards.length, 1);
      expect(updatedCards.first.frontText, 'Goodbye');
      expect(updatedCards.first.backText, 'Tạm biệt');
    });

    testWidgets('shows delete button in edit mode', (tester) async {
      // Create a card first
      await cardRepository.createCard(
        deckId: testDeckId,
        frontText: 'Hello',
        backText: 'Xin chào',
      );

      final cards = await cardRepository.watchCardsByDeck(testDeckId).first;
      final cardId = cards.first.id;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: CardEditorScreen(
              deckId: testDeckId,
              cardId: cardId,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('deletes card after confirmation', (tester) async {
      // Create a card first
      await cardRepository.createCard(
        deckId: testDeckId,
        frontText: 'Hello',
        backText: 'Xin chào',
      );

      final cards = await cardRepository.watchCardsByDeck(testDeckId).first;
      final cardId = cards.first.id;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: CardEditorScreen(
              deckId: testDeckId,
              cardId: cardId,
            ),
          ),
        ),
      );

      await tester.pump();

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Confirm delete dialog should appear
      expect(find.text('Delete Card'), findsOneWidget);
      expect(find.text('Are you sure you want to delete this card?'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify card was deleted
      final remainingCards = await cardRepository.watchCardsByDeck(testDeckId).first;
      expect(remainingCards.length, 0);
    });
  });

  group('CardEditorScreen - Cancel Button', () {
    testWidgets('closes screen without saving', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CardEditorScreen(deckId: testDeckId),
                      ),
                    );
                  },
                  child: const Text('Open Editor'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open editor
      await tester.tap(find.text('Open Editor'));
      await tester.pumpAndSettle();

      // Enter some text
      await tester.enterText(find.byType(TextFormField).first, 'Test');

      // Tap cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Should navigate back without saving
      expect(find.text('Add Card'), findsNothing);
      expect(find.text('Open Editor'), findsOneWidget);

      // Verify no card was created
      final cards = await cardRepository.watchCardsByDeck(testDeckId).first;
      expect(cards.length, 0);
    });
  });
}
