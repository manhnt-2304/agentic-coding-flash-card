import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcard_learning/data/database/app_database.dart' as db;
import 'package:flashcard_learning/data/repositories/deck_repository.dart';
import 'package:flashcard_learning/data/repositories/card_repository.dart';
import 'package:flashcard_learning/core/navigation/routes.dart';
import 'package:flashcard_learning/features/study/screens/study_session_screen.dart' hide databaseProvider;
import 'package:flashcard_learning/features/decks/providers/deck_provider.dart';

/// Provider for deck by ID (converts Future to Stream for AsyncValue)
final deckByIdProvider = StreamProvider.family<DeckWithCardCount?, String>((ref, deckId) async* {
  final repo = ref.watch(deckRepositoryProvider);
  final deck = await repo.getDeckById(deckId);
  yield deck;
});

/// Provider for card repository (TODO: Move to shared providers file)
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return CardRepositoryImpl(database);
});

/// Provider for cards by deck ID
final cardsByDeckProvider = StreamProvider.family<List<db.Card>, String>((ref, deckId) {
  final repo = ref.watch(cardRepositoryProvider);
  return repo.watchCardsByDeck(deckId);
});

/// DeckDetailScreen - Shows deck information and card list
/// 
/// This screen fixes the navigation gap from User Story 1 by providing
/// a natural entry point to study sessions. Users can:
/// - View deck details (name, card count, last studied date)
/// - Browse cards in the deck
/// - Start a study session with the "Study" button
/// - Add new cards (placeholder for Task 2.2)
class DeckDetailScreen extends ConsumerWidget {
  final String deckId;
  
  const DeckDetailScreen({required this.deckId, super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckAsync = ref.watch(deckByIdProvider(deckId));
    final cardsAsync = ref.watch(cardsByDeckProvider(deckId));
    
    return Scaffold(
      appBar: AppBar(
        title: deckAsync.when(
          data: (deck) => Text(deck?.name ?? 'Deck'),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO Task 2.3: Show menu (rename, delete)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Menu coming in Task 2.3')),
              );
            },
          ),
        ],
      ),
      body: deckAsync.when(
        data: (deck) {
          if (deck == null) {
            return const Center(
              child: Text('Deck not found'),
            );
          }
          
          return Column(
            children: [
              // Deck Info Card
              _DeckInfoCard(deck: deck),
              
              // Card List
              Expanded(
                child: cardsAsync.when(
                  data: (cards) {
                    if (cards.isEmpty) {
                      return _EmptyState(
                        onAddCard: () => _showComingSoon(context),
                      );
                    }
                    
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        return _CardPreviewTile(card: cards[index]);
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Text('Error loading cards: $error'),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Text('Error loading deck: $error'),
        ),
      ),
      floatingActionButton: deckAsync.when(
        data: (deck) {
          if (deck == null || deck.cardCount == 0) return null;
          
          return FloatingActionButton.extended(
            onPressed: () {
              // Navigate to StudySessionScreen with correct args
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StudySessionScreen(
                    args: StudySessionArgs(
                      deckId: deckId,
                      mode: StudyMode.basic, // Use basic mode for now
                    ),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Study'),
          );
        },
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }
  
  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming in Task 2.2')),
    );
  }
}

/// Widget displaying deck information (card count, last studied date)
class _DeckInfoCard extends StatelessWidget {
  final DeckWithCardCount deck;
  
  const _DeckInfoCard({required this.deck});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${deck.cardCount} cards',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (deck.lastStudiedAt != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last studied: ${_formatDate(deck.lastStudiedAt!)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO Task 2.2: Navigate to CardEditorScreen
                // For now, show placeholder message
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Card'),
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Widget displaying a card preview in the list
class _CardPreviewTile extends StatelessWidget {
  final db.Card card;
  
  const _CardPreviewTile({required this.card});
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          _truncate(card.frontText, 50),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_truncate(card.backText, 50)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO Task 2.5: Navigate to CardEditorScreen for editing
        },
      ),
    );
  }
  
  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}

/// Widget showing empty state when deck has no cards
class _EmptyState extends StatelessWidget {
  final VoidCallback onAddCard;
  
  const _EmptyState({required this.onAddCard});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.style_outlined,
            size: 64,
            color: Theme.of(context).disabledColor,
          ),
          const SizedBox(height: 16),
          Text(
            'No cards yet',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add cards to start studying',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAddCard,
            icon: const Icon(Icons.add),
            label: const Text('Add First Card'),
          ),
        ],
      ),
    );
  }
}
