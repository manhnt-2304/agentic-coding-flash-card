import 'package:flashcard_learning/core/navigation/routes.dart';
import 'package:flashcard_learning/data/database/app_database.dart';
import 'package:flashcard_learning/data/repositories/card_repository.dart';
import 'package:flashcard_learning/data/repositories/review_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

/// State for study session
class StudySessionState {
  final List<Card> cards;
  final int currentIndex;
  final bool isFlipped;
  final String sessionId;
  final DateTime startTime;
  final int cardsReviewed;
  final int cardsKnown;
  final int cardsForgot;

  StudySessionState({
    required this.cards,
    required this.currentIndex,
    required this.isFlipped,
    required this.sessionId,
    required this.startTime,
    required this.cardsReviewed,
    required this.cardsKnown,
    required this.cardsForgot,
  });

  Card? get currentCard =>
      currentIndex < cards.length ? cards[currentIndex] : null;
  bool get isComplete => currentIndex >= cards.length;

  StudySessionState copyWith({
    List<Card>? cards,
    int? currentIndex,
    bool? isFlipped,
    String? sessionId,
    DateTime? startTime,
    int? cardsReviewed,
    int? cardsKnown,
    int? cardsForgot,
  }) {
    return StudySessionState(
      cards: cards ?? this.cards,
      currentIndex: currentIndex ?? this.currentIndex,
      isFlipped: isFlipped ?? this.isFlipped,
      sessionId: sessionId ?? this.sessionId,
      startTime: startTime ?? this.startTime,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      cardsKnown: cardsKnown ?? this.cardsKnown,
      cardsForgot: cardsForgot ?? this.cardsForgot,
    );
  }
}

/// Notifier for managing study session state
class StudySessionNotifier extends StateNotifier<StudySessionState> {
  final StudySessionArgs args;
  final CardRepository _cardRepository;
  final ReviewRepository _reviewRepository;

  StudySessionNotifier({
    required this.args,
    required CardRepository cardRepository,
    required ReviewRepository reviewRepository,
  })  : _cardRepository = cardRepository,
        _reviewRepository = reviewRepository,
        super(StudySessionState(
          cards: [],
          currentIndex: 0,
          isFlipped: false,
          sessionId: const Uuid().v4(),
          startTime: DateTime.now(),
          cardsReviewed: 0,
          cardsKnown: 0,
          cardsForgot: 0,
        )) {
    _loadCards();
  }

  /// Load cards for study session
  Future<void> _loadCards() async {
    final List<Card> cards;

    if (args.mode == StudyMode.smart) {
      // Smart mode: Load only due cards
      cards = await _cardRepository.getDueCards(args.deckId);
    } else {
      // Basic mode: Load all cards
      final allCards =
          await _cardRepository.watchCardsByDeck(args.deckId).first;
      cards = allCards;
    }

    state = state.copyWith(cards: cards);
  }

  /// Flip the current card
  void flip() {
    state = state.copyWith(isFlipped: !state.isFlipped);
  }

  /// Rate the current card and move to next
  Future<void> rate(int rating) async {
    if (state.currentCard == null) return;

    // Record review
    await _reviewRepository.recordReview(
      cardId: state.currentCard!.id,
      sessionId: state.sessionId,
      rating: rating,
    );

    // Update statistics
    final newCardsReviewed = state.cardsReviewed + 1;
    final newCardsKnown = rating == 5 ? state.cardsKnown + 1 : state.cardsKnown;
    final newCardsForgot =
        rating == 1 ? state.cardsForgot + 1 : state.cardsForgot;

    // Move to next card
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      isFlipped: false, // Reset flip state
      cardsReviewed: newCardsReviewed,
      cardsKnown: newCardsKnown,
      cardsForgot: newCardsForgot,
    );
  }

  /// Get session statistics
  Map<String, dynamic> get statistics => {
        'cardsReviewed': state.cardsReviewed,
        'cardsKnown': state.cardsKnown,
        'cardsForgot': state.cardsForgot,
        'totalCards': state.cards.length,
        'accuracyRate': state.cardsReviewed > 0
            ? (state.cardsKnown / state.cardsReviewed * 100).toStringAsFixed(1)
            : '0.0',
      };
}
