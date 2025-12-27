import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcard_learning/data/database/app_database.dart' as db;
import 'package:flashcard_learning/features/decks/screens/deck_detail_screen.dart' 
    show cardRepositoryProvider;

class CardEditorScreen extends ConsumerStatefulWidget {
  final String deckId;
  final String? cardId; // null = create mode, non-null = edit mode

  const CardEditorScreen({
    required this.deckId,
    this.cardId,
    super.key,
  });

  @override
  ConsumerState<CardEditorScreen> createState() => _CardEditorScreenState();
}

class _CardEditorScreenState extends ConsumerState<CardEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _frontTextController = TextEditingController();
  final _backTextController = TextEditingController();
  
  bool _isLoading = true;
  db.Card? _existingCard;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  @override
  void dispose() {
    _frontTextController.dispose();
    _backTextController.dispose();
    super.dispose();
  }

  Future<void> _loadCard() async {
    if (widget.cardId != null) {
      final cardRepo = ref.read(cardRepositoryProvider);
      final card = await cardRepo.getCardById(widget.cardId!);
      
      if (card != null) {
        setState(() {
          _existingCard = card;
          _frontTextController.text = card.frontText;
          _backTextController.text = card.backText;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final cardRepo = ref.read(cardRepositoryProvider);

    try {
      if (_existingCard != null) {
        // Edit mode - update existing card
        final updatedCard = _existingCard!.copyWith(
          frontText: _frontTextController.text,
          backText: _backTextController.text,
        );
        await cardRepo.updateCard(updatedCard);
      } else {
        // Create mode - create new card
        await cardRepo.createCard(
          deckId: widget.deckId,
          frontText: _frontTextController.text,
          backText: _backTextController.text,
        );
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving card: $e')),
        );
      }
    }
  }

  Future<void> _deleteCard() async {
    if (_existingCard == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: const Text('Are you sure you want to delete this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final cardRepo = ref.read(cardRepositoryProvider);
      await cardRepo.deleteCard(_existingCard!.id);
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.cardId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Card' : 'Add Card'),
        actions: [
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteCard,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Front Text Field
                    TextFormField(
                      controller: _frontTextController,
                      decoration: const InputDecoration(
                        labelText: 'Front (Question)',
                        hintText: 'Enter question or term',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter front text';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Back Text Field
                    TextFormField(
                      controller: _backTextController,
                      decoration: const InputDecoration(
                        labelText: 'Back (Answer)',
                        hintText: 'Enter answer or definition',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter back text';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    ElevatedButton(
                      onPressed: _saveCard,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save'),
                    ),
                    const SizedBox(height: 12),

                    // Cancel Button
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
