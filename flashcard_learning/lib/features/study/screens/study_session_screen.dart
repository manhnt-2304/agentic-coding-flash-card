import 'package:flashcard_learning/core/navigation/routes.dart';
import 'package:flashcard_learning/data/database/app_database.dart';
import 'package:flashcard_learning/data/repositories/card_repository.dart';
import 'package:flashcard_learning/data/repositories/review_repository.dart';
import 'package:flashcard_learning/features/cards/widgets/flash_card.dart';
import 'package:flashcard_learning/features/cards/widgets/rating_buttons.dart';
import 'package:flashcard_learning/features/study/providers/study_session_provider.dart';
import 'package:flashcard_learning/services/sm2_algorithm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for study session
final studySessionProvider = StateNotifierProvider.autoDispose
    .family<StudySessionNotifier, StudySessionState, StudySessionArgs>(
  (ref, args) {
    final database = ref.watch(databaseProvider);
    final cardRepository = ref.watch(cardRepositoryProvider);
    final reviewRepository = ref.watch(reviewRepositoryProvider);
    
    return StudySessionNotifier(
      args: args,
      database: database,
      cardRepository: cardRepository,
      reviewRepository: reviewRepository,
    );
  },
);

/// Provider for card repository
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return CardRepositoryImpl(database);
});

/// Provider for review repository
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final algorithm = ref.watch(sm2AlgorithmProvider);
  return ReviewRepositoryImpl(database, algorithm);
});

/// Provider for SM-2 algorithm
final sm2AlgorithmProvider = Provider<SM2Algorithm>((ref) {
  return SM2AlgorithmImpl();
});

/// Provider for database
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});

/// Study Session Screen
/// 
/// Integrates FlashCard and RatingButtons widgets to create
/// a complete study experience with SRS integration.
class StudySessionScreen extends ConsumerWidget {
  final StudySessionArgs args;

  const StudySessionScreen({
    Key? key,
    required this.args,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(studySessionProvider(args));

    // Show loading while cards are being loaded
    if (sessionState.cards.isEmpty && !sessionState.isComplete) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Study Session'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show completion screen when all cards reviewed
    if (sessionState.isComplete) {
      // Navigate to SessionSummaryScreen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(
          '/session-summary',
          arguments: sessionState.sessionId,
        );
      });
      
      // Show loading while navigating
      return Scaffold(
        appBar: AppBar(
          title: const Text('Loading Summary...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show study interface
    return Scaffold(
      appBar: AppBar(
        title: Text(args.mode == StudyMode.basic ? 'Basic Study' : 'Smart Study'),
        actions: [
          // Progress indicator
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${sessionState.currentIndex + 1}/${sessionState.cards.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: sessionState.cards.isNotEmpty
                ? (sessionState.currentIndex + 1) / sessionState.cards.length
                : 0,
          ),

          // FlashCard
          Expanded(
            flex: 3,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: sessionState.currentCard != null
                    ? FlashCard(
                        frontText: sessionState.currentCard!.frontText,
                        backText: sessionState.currentCard!.backText,
                        frontImagePath: sessionState.currentCard!.frontImagePath,
                        backImagePath: sessionState.currentCard!.backImagePath,
                        isFlipped: sessionState.isFlipped,
                        onFlip: () {
                          ref.read(studySessionProvider(args).notifier).flip();
                        },
                        autoPlayTTS: false, // Will be implemented in Task 7.3
                        ttsVoice: 'en-US',
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),

          // Instructions
          if (!sessionState.isFlipped)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Tap the card to see the answer',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

          // RatingButtons (shown only after flip)
          if (sessionState.isFlipped)
            Expanded(
              flex: 1,
              child: RatingButtons(
                mode: args.mode,
                onRate: (rating) async {
                  await ref
                      .read(studySessionProvider(args).notifier)
                      .rate(rating);
                },
                disabled: false,
              ),
            )
          else
            const Expanded(
              flex: 1,
              child: SizedBox.shrink(),
            ),
        ],
      ),
    );
  }
}
