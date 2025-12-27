import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcard_learning/features/decks/screens/deck_detail_screen.dart';
import 'package:flashcard_learning/data/repositories/deck_repository.dart';
import 'package:flashcard_learning/data/repositories/card_repository.dart';
import 'package:flashcard_learning/data/database/app_database.dart' as db;
import 'package:flashcard_learning/features/decks/providers/deck_provider.dart';
import 'package:flashcard_learning/features/study/screens/study_session_screen.dart' hide databaseProvider;

void main() {
  group('DeckDetailScreen Widget Tests', () {
    late db.AppDatabase database;
    late DeckRepository deckRepository;
    late CardRepository cardRepository;
    late String testDeckId;

    setUp(() async {
      database = db.AppDatabase.inMemory();
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

    testWidgets('displays deck name and card count', (tester) async {
      // Add 3 cards to deck
      await cardRepository.createCard(
        deckId: testDeckId,
        frontText: 'Card 1',
        backText: 'Answer 1',
      );
      await cardRepository.createCard(
        deckId: testDeckId,
        frontText: 'Card 2',
        backText: 'Answer 2',
      );
      await cardRepository.createCard(
        deckId: testDeckId,
        frontText: 'Card 3',
        backText: 'Answer 3',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: DeckDetailScreen(deckId: testDeckId),
          ),
        ),
      );

      // Wait for initial frame
      await tester.pump();
      
      // Wait for async operations with timeout
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify deck name in AppBar
      expect(find.text('Test Deck'), findsOneWidget);

      // Verify card count in info card
      expect(find.text('3 cards'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('displays card list with front and back text', (tester) async {
      // Add cards with distinct text
      await cardRepository.createCard(
        deckId: testDeckId,
        frontText: 'Hello',
        backText: 'こんにちは',
      );
      await cardRepository.createCard(
        deckId: testDeckId,
        frontText: 'Goodbye',
        backText: 'さようなら',
      );
      await cardRepository.createCard(
        deckId: testDeckId,
        frontText: 'Thank you',
        backText: 'ありがとう',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: DeckDetailScreen(deckId: testDeckId),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify all front texts are displayed
      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('Goodbye'), findsOneWidget);
      expect(find.text('Thank you'), findsOneWidget);

      // Verify all back texts are displayed
      expect(find.text('こんにちは'), findsOneWidget);
      expect(find.text('さようなら'), findsOneWidget);
      expect(find.text('ありがとう'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('Study FAB navigates to StudySessionScreen', (tester) async {
      // Add at least one card so FAB appears
      await cardRepository.createCard(
        deckId: testDeckId,
        frontText: 'Test Card',
        backText: 'Test Answer',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: DeckDetailScreen(deckId: testDeckId),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify Study FAB exists
      final studyFab = find.widgetWithText(FloatingActionButton, 'Study');
      expect(studyFab, findsOneWidget);

      // Tap the FAB
      await tester.tap(studyFab);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify navigation to StudySessionScreen
      expect(find.byType(StudySessionScreen), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('shows empty state when deck has no cards', (tester) async {
      // Don't add any cards - deck should be empty

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: DeckDetailScreen(deckId: testDeckId),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify empty state messages
      expect(find.text('No cards yet'), findsOneWidget);
      expect(find.text('Add cards to start studying'), findsOneWidget);

      // Verify "Add First Card" button exists
      expect(find.text('Add First Card'), findsOneWidget);

      // Verify Study FAB does NOT appear when empty
      final studyFab = find.widgetWithText(FloatingActionButton, 'Study');
      expect(studyFab, findsNothing);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('Add Card button shows snackbar', (tester) async {
      // Add one card to show the info card with "Add Card" button
      await cardRepository.createCard(
        deckId: testDeckId,
        frontText: 'Test',
        backText: 'Test',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: DeckDetailScreen(deckId: testDeckId),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Find and tap "Add Card" button in the info card
      final addCardButton = find.widgetWithText(ElevatedButton, 'Add Card');
      expect(addCardButton, findsOneWidget);

      await tester.tap(addCardButton);
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 750)); // Wait for snackbar

      // Verify snackbar message
      expect(find.text('Coming in Task 2.2'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('truncates long card text to 50 characters', (tester) async {
      // Add card with very long text
      const longFrontText = 'This is a very long front text that should definitely be truncated because it exceeds fifty characters by a lot';
      const longBackText = 'This is a very long back text that should definitely be truncated because it exceeds fifty characters by a lot';

      await cardRepository.createCard(
        deckId: testDeckId,
        frontText: longFrontText,
        backText: longBackText,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: DeckDetailScreen(deckId: testDeckId),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify text is truncated to 50 chars + "..."
      expect(find.textContaining('This is a very long front text that should defin...'), findsOneWidget);
      expect(find.textContaining('This is a very long back text that should defini...'), findsOneWidget);

      // Verify full text is NOT displayed
      expect(find.text(longFrontText), findsNothing);
      expect(find.text(longBackText), findsNothing);
    }, timeout: const Timeout(Duration(seconds: 10)));

    testWidgets('displays last studied date when available', (tester) async {
      // Add a card
      await cardRepository.createCard(
        deckId: testDeckId,
        frontText: 'Test',
        backText: 'Test',
      );

      // Update deck with lastStudiedAt
      final decks = await deckRepository.watchAllDecks().first;
      final deck = decks.first;
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      await deckRepository.updateDeck(deck.copyWith(lastStudiedAt: yesterday));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
          ],
          child: MaterialApp(
            home: DeckDetailScreen(deckId: testDeckId),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify "Last studied" text appears
      expect(find.textContaining('Last studied:'), findsOneWidget);
      expect(find.textContaining('Yesterday'), findsOneWidget);
    }, timeout: const Timeout(Duration(seconds: 10)));
  });
}
