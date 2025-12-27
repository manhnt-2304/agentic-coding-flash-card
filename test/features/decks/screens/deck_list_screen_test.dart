import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flashcard_learning/data/repositories/deck_repository.dart';
import 'package:flashcard_learning/data/database/app_database.dart';
import 'package:flashcard_learning/features/decks/providers/deck_provider.dart';
import 'package:flashcard_learning/features/decks/screens/deck_list_screen.dart';

@GenerateMocks([DeckRepository])
import 'deck_list_screen_test.mocks.dart';

void main() {
  late MockDeckRepository mockRepository;

  setUp(() {
    mockRepository = MockDeckRepository();
  });

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        deckRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('DeckListScreen Widget Tests', () {
    testWidgets('shows empty state when no decks exist', (tester) async {
      // Arrange
      when(mockRepository.watchAllDecks()).thenAnswer(
        (_) => Stream.value([]),
      );

      // Act
      await tester.pumpWidget(createTestWidget(const DeckListScreen()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No decks yet'), findsOneWidget);
      expect(find.text('Tap + to create your first deck'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows list of decks with card counts', (tester) async {
      // Arrange
      final now = DateTime.now();
      final testDecks = [
        DeckWithCardCount(
          Deck(
            id: '1',
            name: 'Test Deck 1',
            createdAt: now,
            lastStudiedAt: now,
          ),
          5,
        ),
        DeckWithCardCount(
          Deck(
            id: '2',
            name: 'Test Deck 2',
            createdAt: now,
            lastStudiedAt: null,
          ),
          0,
        ),
      ];

      when(mockRepository.watchAllDecks()).thenAnswer(
        (_) => Stream.value(testDecks),
      );

      // Act
      await tester.pumpWidget(createTestWidget(const DeckListScreen()));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test Deck 1'), findsOneWidget);
      expect(find.text('Test Deck 2'), findsOneWidget);
      expect(find.text('5 cards'), findsOneWidget);
      expect(find.text('0 cards'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('opens create deck dialog when FAB is pressed', (tester) async {
      // Arrange
      when(mockRepository.watchAllDecks()).thenAnswer(
        (_) => Stream.value([]),
      );

      // Act
      await tester.pumpWidget(createTestWidget(const DeckListScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Create Deck'), findsOneWidget);
      expect(find.byType(TextField), findsAtLeastNWidgets(1)); // Name field and optional description
    });

    testWidgets('creates deck when dialog is submitted', (tester) async {
      // Arrange
      when(mockRepository.watchAllDecks()).thenAnswer(
        (_) => Stream.value([]),
      );
      when(mockRepository.createDeck(any)).thenAnswer(
        (_) async => {},
      );

      // Act
      await tester.pumpWidget(createTestWidget(const DeckListScreen()));
      await tester.pumpAndSettle();

      // Open dialog
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fill form
      await tester.enterText(
        find.byType(TextField).first,
        'New Deck',
      );

      // Submit
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Assert
      verify(mockRepository.createDeck('New Deck')).called(1);
    });

    testWidgets('shows action menu on long press', (tester) async {
      // Arrange
      final now = DateTime.now();
      final testDeck = DeckWithCardCount(
        Deck(
          id: '1',
          name: 'Test Deck',
          createdAt: now,
          lastStudiedAt: now,
        ),
        5,
      );

      when(mockRepository.watchAllDecks()).thenAnswer(
        (_) => Stream.value([testDeck]),
      );

      // Act
      await tester.pumpWidget(createTestWidget(const DeckListScreen()));
      await tester.pumpAndSettle();

      // Long press on deck
      await tester.longPress(find.text('Test Deck'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('deletes deck when delete is confirmed', (tester) async {
      // Arrange
      final now = DateTime.now();
      final testDeck = DeckWithCardCount(
        Deck(
          id: '1',
          name: 'Test Deck',
          createdAt: now,
          lastStudiedAt: now,
        ),
        5,
      );

      when(mockRepository.watchAllDecks()).thenAnswer(
        (_) => Stream.value([testDeck]),
      );
      when(mockRepository.deleteDeck('1')).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createTestWidget(const DeckListScreen()));
      await tester.pumpAndSettle();

      // Long press to open menu
      await tester.longPress(find.text('Test Deck'));
      await tester.pumpAndSettle();

      // Tap delete
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Confirm deletion
      await tester.tap(find.text('Delete').last);
      await tester.pumpAndSettle();

      // Assert
      verify(mockRepository.deleteDeck('1')).called(1);
    });
  });
}
