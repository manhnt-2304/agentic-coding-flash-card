import 'package:flutter/material.dart';
import 'package:flashcard_learning/features/cards/widgets/flash_card.dart';

/// Demo screen to showcase FlashCard widget functionality
/// This is a temporary screen for testing Task 1.4 completion
class FlashCardDemoScreen extends StatefulWidget {
  const FlashCardDemoScreen({Key? key}) : super(key: key);

  @override
  State<FlashCardDemoScreen> createState() => _FlashCardDemoScreenState();
}

class _FlashCardDemoScreenState extends State<FlashCardDemoScreen> {
  bool _isFlipped = false;
  int _currentCardIndex = 0;

  // Sample cards for demonstration
  final List<Map<String, String>> _sampleCards = [
    {
      'front': 'What is Flutter?',
      'back': 'A UI toolkit by Google for building natively compiled applications',
    },
    {
      'front': 'What is Dart?',
      'back': 'A client-optimized programming language for building fast apps',
    },
    {
      'front': 'What is Widget?',
      'back': 'The basic building blocks of Flutter UI',
    },
    {
      'front': 'What is StatelessWidget?',
      'back': 'A widget that does not require mutable state',
    },
    {
      'front': 'What is StatefulWidget?',
      'back': 'A widget that has mutable state',
    },
  ];

  void _handleFlip() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  void _handleNext() {
    setState(() {
      if (_currentCardIndex < _sampleCards.length - 1) {
        _currentCardIndex++;
        _isFlipped = false; // Reset flip state for new card
      }
    });
  }

  void _handlePrevious() {
    setState(() {
      if (_currentCardIndex > 0) {
        _currentCardIndex--;
        _isFlipped = false; // Reset flip state for new card
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentCard = _sampleCards[_currentCardIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlashCard Demo'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Card counter
              Text(
                'Card ${_currentCardIndex + 1} / ${_sampleCards.length}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // FlashCard widget
              Expanded(
                child: Center(
                  child: FlashCard(
                    frontText: currentCard['front']!,
                    backText: currentCard['back']!,
                    isFlipped: _isFlipped,
                    onFlip: _handleFlip,
                    autoPlayTTS: false,
                    ttsVoice: 'en-US',
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tap the card to flip',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.swipe_left,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Use buttons to navigate',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous button
                  ElevatedButton.icon(
                    onPressed: _currentCardIndex > 0 ? _handlePrevious : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),

                  // Next button
                  ElevatedButton.icon(
                    onPressed: _currentCardIndex < _sampleCards.length - 1
                        ? _handleNext
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Flip button (alternative to tapping card)
              OutlinedButton.icon(
                onPressed: _handleFlip,
                icon: Icon(
                  _isFlipped ? Icons.flip_to_front : Icons.flip_to_back,
                ),
                label: Text(_isFlipped ? 'Show Front' : 'Show Back'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
