import 'package:flashcard_learning/core/navigation/routes.dart';
import 'package:flashcard_learning/data/repositories/deck_repository.dart';
import 'package:flashcard_learning/data/repositories/card_repository.dart';
import 'package:flashcard_learning/features/study/screens/study_session_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Demo screen to showcase Study Session (Task 1.6)
/// 
/// Creates a sample deck with 5 cards and starts a study session
class StudySessionDemoScreen extends ConsumerStatefulWidget {
  const StudySessionDemoScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<StudySessionDemoScreen> createState() =>
      _StudySessionDemoScreenState();
}

class _StudySessionDemoScreenState
    extends ConsumerState<StudySessionDemoScreen> {
  String? _deckId;
  bool _isLoading = true;
  StudyMode _selectedMode = StudyMode.basic;

  @override
  void initState() {
    super.initState();
    _setupDemoData();
  }

  Future<void> _setupDemoData() async {
    final database = ref.read(databaseProvider);
    final deckRepository = DeckRepositoryImpl(database);
    final cardRepository = CardRepositoryImpl(database);

    // Create demo deck
    await deckRepository.createDeck('Demo Study Deck');
    final decks = await deckRepository.watchAllDecks().first;
    final deckId = decks.first.id;

    // Create 5 sample cards
    final sampleCards = [
      {
        'front': 'What is Flutter?',
        'back':
            'Flutter is an open-source UI software development kit created by Google.'
      },
      {'front': 'What is Dart?', 'back': 'Dart is a programming language designed for client development.'},
      {
        'front': 'What is a Widget?',
        'back': 'A Widget is a basic building block of Flutter UI.'
      },
      {
        'front': 'What is State Management?',
        'back': 'State Management is a way to manage and share application state across widgets.'
      },
      {
        'front': 'What is Riverpod?',
        'back': 'Riverpod is a reactive caching and data-binding framework for Flutter.'
      },
    ];

    for (final card in sampleCards) {
      await cardRepository.createCard(
        deckId: deckId,
        frontText: card['front']!,
        backText: card['back']!,
      );
    }

    setState(() {
      _deckId = deckId;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Study Session Demo'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Session Demo'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Task 1.6 - Study Session Screen',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimaryContainer,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This screen integrates:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _buildBullet(context, '✅ FlashCard widget (Task 1.4)'),
                    _buildBullet(context, '✅ RatingButtons widget (Task 1.5)'),
                    _buildBullet(context, '✅ SM-2 algorithm integration'),
                    _buildBullet(
                        context, '✅ Session state management (Riverpod)'),
                    _buildBullet(context, '✅ Progress tracking'),
                    _buildBullet(context, '✅ Completion screen'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Sample data info
            Card(
              color: colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.dataset_outlined,
                            color: colorScheme.secondary),
                        const SizedBox(width: 8),
                        Text(
                          'Demo Data',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Created a demo deck with 5 Flutter Q&A cards.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mode selector
            Text(
              'Select Study Mode',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<StudyMode>(
              segments: const [
                ButtonSegment(
                  value: StudyMode.basic,
                  label: Text('Basic Mode'),
                  icon: Icon(Icons.check_circle_outline),
                ),
                ButtonSegment(
                  value: StudyMode.smart,
                  label: Text('Smart Mode'),
                  icon: Icon(Icons.psychology_outlined),
                ),
              ],
              selected: {_selectedMode},
              onSelectionChanged: (Set<StudyMode> newSelection) {
                setState(() {
                  _selectedMode = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  _selectedMode == StudyMode.basic
                      ? 'Basic Mode: Shows all cards with Know/Forgot buttons'
                      : 'Smart Mode: Shows only due cards with Easy/Normal/Hard buttons (SRS)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_deckId != null) {
                    Navigator.pushNamed(
                      context,
                      Routes.studySession,
                      arguments: StudySessionArgs(
                        deckId: _deckId!,
                        mode: _selectedMode,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Study Session'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            Card(
              color: colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            color: colorScheme.tertiary),
                        const SizedBox(width: 8),
                        Text(
                          'How to Use',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onTertiaryContainer,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildBullet(context, '1. Tap card to flip and see answer'),
                    _buildBullet(context, '2. Rate your knowledge'),
                    _buildBullet(context, '3. Progress to next card'),
                    _buildBullet(context, '4. View results at the end'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
