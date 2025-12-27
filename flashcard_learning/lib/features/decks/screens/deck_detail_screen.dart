import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcard_learning/data/database/app_database.dart' as db;
import 'package:flashcard_learning/data/repositories/deck_repository.dart';
import 'package:flashcard_learning/data/repositories/card_repository.dart';
import 'package:flashcard_learning/core/navigation/routes.dart';
import 'package:flashcard_learning/features/study/screens/study_session_screen.dart' hide databaseProvider;
import 'package:flashcard_learning/features/decks/providers/deck_provider.dart';
import 'package:flashcard_learning/features/cards/screens/card_editor_screen.dart';

/// Provider for deck by ID (watches for changes in real-time)
final deckByIdProvider = StreamProvider.family<DeckWithCardCount?, String>((ref, deckId) {
  final repo = ref.watch(deckRepositoryProvider);
  // Watch all decks and filter for this specific deck ID
  // This ensures we get updates when the deck is renamed or card count changes
  return repo.watchAllDecks().map((decks) {
    try {
      return decks.firstWhere((deck) => deck.id == deckId);
    } catch (e) {
      // Deck not found, return null
      return null;
    }
  });
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
              _showDeckMenu(context, ref, deckAsync.value);
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
  
  void _showDeckMenu(BuildContext context, WidgetRef ref, DeckWithCardCount? deck) {
    if (deck == null) return;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Rename Deck'),
            onTap: () {
              Navigator.pop(context);
              _showRenameDialog(context, ref, deck);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete Deck', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context, ref, deck);
            },
          ),
        ],
      ),
    );
  }
  
  void _showRenameDialog(BuildContext context, WidgetRef ref, DeckWithCardCount deck) {
    final controller = TextEditingController(text: deck.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Deck'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Deck Name',
            hintText: 'Enter new name',
          ),
          autofocus: true,
          onSubmitted: (value) async {
            if (value.trim().isNotEmpty) {
              await ref.read(deckRepositoryProvider).updateDeck(
                deck.copyWith(name: value.trim()),
              );
              if (context.mounted) {
                Navigator.pop(context);
              }
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await ref.read(deckRepositoryProvider).updateDeck(
                  deck.copyWith(name: newName),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
  
  void _confirmDelete(BuildContext context, WidgetRef ref, DeckWithCardCount deck) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: Text(
          'Are you sure you want to delete "${deck.name}"? This will also delete all ${deck.cardCount} cards in this deck.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(deckRepositoryProvider).deleteDeck(deck.id);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to deck list
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CardEditorScreen(deckId: deck.id),
                  ),
                );
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CardEditorScreen(
                deckId: card.deckId,
                cardId: card.id,
              ),
            ),
          );
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
