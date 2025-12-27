# Component Contracts: Core Flashcard Learning MVP

**Feature**: Core Flashcard Learning MVP  
**Date**: 2025-12-26  
**Purpose**: Define interfaces for screens, widgets, providers, and services

## UI Design Standards

### Approved UI Component Libraries

This project uses the following libraries for consistent, professional UI:

#### **GetWidget** (v4.0.0+)
- **Usage**: Buttons, Cards, Badges, Ratings, Avatars
- **Why**: 1000+ pre-built Material 3 widgets, saves development time
- **Documentation**: https://www.getwidget.dev/
- **Examples**: See `lib/features/cards/screens/ui_showcase_screen.dart`

**Common Components:**
```dart
// Buttons
GFButton(
  onPressed: () {},
  text: 'Label',
  type: GFButtonType.solid, // or outline, transparent
  icon: Icon(Icons.icon_name),
)

// Cards
GFCard(
  title: GFListTile(title: Text('Title')),
  content: Text('Content'),
  buttonBar: GFButtonBar(children: [...]),
)

// Badges
GFBadge(text: 'Label', color: GFColors.SUCCESS)

// Ratings
GFRating(value: 3.5, onChanged: (v) {}, color: GFColors.WARNING)
```

#### **Shimmer** (v3.0.0+)
- **Usage**: Loading placeholders for lists and content
- **Why**: Professional loading UX during data fetching
- **Pattern**: Always show shimmer while loading, never empty states

```dart
if (isLoading) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: _buildSkeleton(),
  );
}
```

#### **Flutter Spinkit** (v5.2.0+)
- **Usage**: Loading indicators for actions (save, submit, sync)
- **Why**: Variety of animations for different contexts
- **Preferred**: `SpinKitFadingCircle`, `SpinKitThreeBounce`, `SpinKitWave`

```dart
SpinKitFadingCircle(
  color: Theme.of(context).colorScheme.primary,
  size: 50.0,
)
```

#### **Animations** (v2.0.11)
- **Usage**: Page transitions, shared element animations
- **Why**: Smooth, native-feeling transitions
- **Pattern**: Use `OpenContainer` for card → detail transitions

### UI Consistency Rules

1. **Material 3 First**: All components must use Material 3 design
2. **Theme Colors**: Use `Theme.of(context).colorScheme.*` for all colors
3. **Loading States**: 
   - Shimmer for content loading (lists, cards)
   - SpinKit for action loading (buttons, forms)
4. **Buttons**:
   - Primary actions: `GFButtonType.solid`
   - Secondary actions: `GFButtonType.outline`
   - Tertiary actions: `GFButtonType.transparent`
5. **Cards**: Use `GFCard` for all card layouts (decks, stats, info)
6. **Spacing**: Follow Material 3 spacing (8dp grid)
7. **Typography**: Use theme text styles, never hardcode sizes
8. **Accessibility**: All interactive elements must have semantic labels

---

## Navigation Structure

```dart
// Route names
class Routes {
  static const String mainTabs = '/';
  static const String studySession = '/study-session';
  static const String deckDetail = '/deck-detail';
  static const String cardEditor = '/card-editor';
  static const String settings = '/settings';
}

// Route arguments
class StudySessionArgs {
  final String deckId;
  final StudyMode mode; // StudyMode.basic or StudyMode.smart
  
  StudySessionArgs({required this.deckId, required this.mode});
}

class DeckDetailArgs {
  final String deckId;
  
  DeckDetailArgs({required this.deckId});
}

class CardEditorArgs {
  final String deckId;
  final String? cardId; // null = create new
  
  CardEditorArgs({required this.deckId, this.cardId});
}

enum StudyMode { basic, smart }
```

---

## Screen Contracts

### 1. DeckListScreen

**Purpose**: Display all decks, create new decks

**State Management**:
```dart
class DeckListState {
  final List<Deck> decks;
  final bool isLoading;
  final String? error;
  
  DeckListState({
    required this.decks,
    required this.isLoading,
    this.error,
  });
}

// Riverpod provider
final deckListProvider = StateNotifierProvider<DeckListNotifier, DeckListState>((ref) {
  final deckRepository = ref.watch(deckRepositoryProvider);
  return DeckListNotifier(deckRepository);
});
```

**User Actions**:
- View list of decks (name, card count, due cards count)
- Tap deck → navigate to DeckDetailScreen
- Tap "+" FAB → show CreateDeckDialog
- Long-press deck → show bottom sheet (Rename, Export, Delete)

**Providers Used**:
- `deckListProvider`: Load and observe deck list
- `deckRepositoryProvider`: Create/delete deck operations

---

### 2. DeckDetailScreen

**Purpose**: View deck details, manage cards, start study session

**State Management**:
```dart
class DeckDetailState {
  final Deck? deck;
  final List<Card> cards;
  final int dueCardsCount;
  final bool isLoading;
  
  DeckDetailState({
    this.deck,
    required this.cards,
    required this.dueCardsCount,
    required this.isLoading,
  });
}

// Riverpod provider
final deckDetailProvider = StateNotifierProvider.family<DeckDetailNotifier, DeckDetailState, String>((ref, deckId) {
  final cardRepository = ref.watch(cardRepositoryProvider);
  return DeckDetailNotifier(deckId, cardRepository);
});
```

**User Actions**:
- View deck name, card count, due cards count
- Tap "Study" → show mode selection dialog → navigate to StudySession
- Tap "Add Card" FAB → navigate to CardEditor
- View card list (front text preview)
- Tap card → navigate to CardEditor (edit mode)
- Swipe card with Dismissible → delete card
- Tap menu (PopupMenuButton) → Export (JSON/CSV), Rename, Delete Deck

**Providers Used**:
- `deckDetailProvider(deckId)`: Load deck details and cards
- `dueCardsCountProvider(deckId)`: Count due cards
- `cardRepositoryProvider`: Delete card operations

---

### 3. CardEditorScreen

**Purpose**: Create or edit a flashcard

**State Management**:
```dart
class CardEditorState {
  final String frontText;
  final String backText;
  final String? frontImagePath;
  final String? backImagePath;
  final bool isValid;
  final Map<String, String> errors;
  final bool isSaving;
  
  CardEditorState({
    required this.frontText,
    required this.backText,
    this.frontImagePath,
    this.backImagePath,
    required this.isValid,
    required this.errors,
    required this.isSaving,
  });
}

// Riverpod provider
final cardEditorProvider = StateNotifierProvider.autoDispose
    .family<CardEditorNotifier, CardEditorState, CardEditorArgs>((ref, args) {
  final cardRepository = ref.watch(cardRepositoryProvider);
  return CardEditorNotifier(args, cardRepository);
});
```

**User Actions**:
- Input front text (TextField, 500 char limit)
- Input back text (TextField, 1000 char limit)
- Tap "Add Image" IconButton → show ImagePicker bottom sheet
- Tap image thumbnail → show full image preview (PhotoView)
- Tap "Remove Image" IconButton → delete image
- Tap "Preview Pronunciation" IconButton → play TTS
- Tap "Save" (AppBar action) → validate and save card
- Tap back button → discard changes (show confirmation dialog if edited)

**Providers Used**:
- `cardEditorProvider(args)`: Manage form state
- `cardRepositoryProvider`: Create/update card
- `imagePickerProvider`: Select image from gallery
- `ttsProvider`: Play pronunciation preview

---

### 4. StudySessionScreen

**Purpose**: Study flashcards with flip interaction and rating

**State Management**:
```dart
class StudySessionState {
  final List<Card> cards;
  final int currentIndex;
  final bool isFlipped;
  final String sessionId;
  final DateTime startTime;
  final int cardsReviewed;
  final int cardsKnown;
  final int cardsForgot;
  final bool canUndo; // Within 3 second window
  final CardRating? lastRating;
  
  StudySessionState({
    required this.cards,
    required this.currentIndex,
    required this.isFlipped,
    required this.sessionId,
    required this.startTime,
    required this.cardsReviewed,
    required this.cardsKnown,
    required this.cardsForgot,
    required this.canUndo,
    this.lastRating,
  });
  
  Card? get currentCard => currentIndex < cards.length ? cards[currentIndex] : null;
  bool get isComplete => currentIndex >= cards.length;
}

class CardRating {
  final String cardId;
  final int rating;
  final DateTime timestamp;
  
  CardRating({required this.cardId, required this.rating, required this.timestamp});
}

// Riverpod provider
final studySessionProvider = StateNotifierProvider.autoDispose
    .family<StudySessionNotifier, StudySessionState, StudySessionArgs>((ref, args) {
  final cardRepository = ref.watch(cardRepositoryProvider);
  final reviewRepository = ref.watch(reviewRepositoryProvider);
  return StudySessionNotifier(args, cardRepository, reviewRepository);
});
```

**User Actions**:
- View card front (question) with AnimatedSwitcher
- Tap "Flip" button or swipe gesture → show card back (answer)
- Tap rating button (Basic: Know/Forgot, Smart: Easy/Normal/Hard)
- Tap "Undo" button (within 3 seconds) → revert last rating
- Automatic progression to next card after rating
- Session ends when all cards reviewed → navigate to SessionSummaryScreen

**Providers Used**:
- `studySessionProvider(args)`: Initialize session, load due cards, manage state
- `reviewRepositoryProvider`: Record card review and update SRS schedule
- `ttsProvider`: Auto-play pronunciation (if enabled in preferences)

---

### 5. SessionSummaryScreen

**Purpose**: Display study session results

**State Management**:
```dart
class SessionSummaryData {
  final int cardsReviewed;
  final int cardsKnown;
  final int cardsForgot;
  final double accuracyRate; // Percentage
  final int duration; // Seconds
  final int nextReviewCount; // Cards due tomorrow
  
  SessionSummaryData({
    required this.cardsReviewed,
    required this.cardsKnown,
    required this.cardsForgot,
    required this.accuracyRate,
    required this.duration,
    required this.nextReviewCount,
  });
}

// Riverpod provider
final sessionSummaryProvider = FutureProvider.family<SessionSummaryData, String>((ref, sessionId) async {
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  return sessionRepository.getSessionSummary(sessionId);
});
```

**User Actions**:
- View session statistics (cards reviewed, accuracy, duration)
- Tap "Review Mistakes" button → restart session with only forgotten cards
- Tap "Done" button → navigate back to deck list

**Providers Used**:
- `sessionSummaryProvider(sessionId)`: Load session statistics

---

### 6. StatisticsScreen

**Purpose**: Display overall learning progress and metrics

**State Management**:
```dart
class StatisticsData {
  final int totalCardsStudied;
  final int totalStudyTime; // Seconds
  final int currentStreak; // Days
  final int longestStreak; // Days
  final double accuracyRate; // Percentage
  final List<WeeklyBreakdownItem> weeklyBreakdown;
  final List<DeckStatisticsItem> deckStatistics;
  
  StatisticsData({
    required this.totalCardsStudied,
    required this.totalStudyTime,
    required this.currentStreak,
    required this.longestStreak,
    required this.accuracyRate,
    required this.weeklyBreakdown,
    required this.deckStatistics,
  });
}

class WeeklyBreakdownItem {
  final DateTime date;
  final int cardsStudied;
  
  WeeklyBreakdownItem({required this.date, required this.cardsStudied});
}

class DeckStatisticsItem {
  final String deckId;
  final String deckName;
  final int cardsStudied;
  final double accuracyRate;
  
  DeckStatisticsItem({
    required this.deckId,
    required this.deckName,
    required this.cardsStudied,
    required this.accuracyRate,
  });
}

// Riverpod provider
final statisticsProvider = FutureProvider<StatisticsData>((ref) async {
  final statisticsRepository = ref.watch(statisticsRepositoryProvider);
  return statisticsRepository.getStatistics();
});
```

**User Actions**:
- View overall statistics (total cards, study time, streaks, accuracy)
- View weekly study chart (bar chart with 7 days)
- View per-deck statistics (list with tap to navigate)
- Tap deck → navigate to DeckDetailScreen

**Providers Used**:
- `statisticsProvider`: Load and compute statistics
- `weeklyBreakdownProvider`: Load weekly chart data
- `deckStatisticsProvider`: Load per-deck metrics

---

### 7. SettingsScreen

**Purpose**: Configure app preferences

**State Management**:
```dart
class UserPreferencesState {
  final String ttsVoice; // 'en-US', 'en-GB', 'vi-VN'
  final bool autoPlayEnabled;
  final bool notificationEnabled;
  final TimeOfDay notificationTime;
  final ThemeMode theme; // ThemeMode.light, ThemeMode.dark, ThemeMode.system
  
  UserPreferencesState({
    required this.ttsVoice,
    required this.autoPlayEnabled,
    required this.notificationEnabled,
    required this.notificationTime,
    required this.theme,
  });
}

// Riverpod provider
final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferencesState>((ref) {
  final preferencesRepository = ref.watch(preferencesRepositoryProvider);
  return UserPreferencesNotifier(preferencesRepository);
});
```

**User Actions**:
- Select TTS voice (DropdownButton with list of available voices)
- Toggle auto-play pronunciation (SwitchListTile)
- Toggle daily reminders (SwitchListTile)
- Set reminder time (showTimePicker dialog)
- Select theme (SegmentedButton: Light/Dark/System)
- Tap "Test Voice" button → play sample pronunciation
- View app version and about info (ListTile)

**Providers Used**:
- `userPreferencesProvider`: Load and update user preferences
- `ttsProvider`: Test voice selection
- `availableVoicesProvider`: Get list of available TTS voices

---

## Widget Contracts

### FlashCard Widget

**Purpose**: Animated flashcard with flip interaction

**Properties**:
```dart
class FlashCard extends StatefulWidget {
  final String frontText;
  final String backText;
  final String? frontImagePath;
  final String? backImagePath;
  final bool isFlipped;
  final VoidCallback onFlip;
  final bool autoPlayTTS;
  final String ttsVoice;
  
  const FlashCard({
    Key? key,
    required this.frontText,
    required this.backText,
    this.frontImagePath,
    this.backImagePath,
    required this.isFlipped,
    required this.onFlip,
    required this.autoPlayTTS,
    required this.ttsVoice,
  }) : super(key: key);
}
```

**Behavior**:
- Renders front text and image when `isFlipped == false`
- Renders back text and image when `isFlipped == true`
- Calls `onFlip()` when tapped (GestureDetector) or swiped
- Uses AnimationController with Transform for flip animation
- Plays TTS automatically if `autoPlayTTS == true` (via initState)
- Shows IconButton with speaker icon for manual TTS playback

---

### RatingButtons Widget

**Purpose**: Display rating buttons (Basic or Smart mode)

**UI Library**: **GetWidget** (GFButton) - Follow UI Design Standards

**Properties**:
```dart
class RatingButtons extends StatelessWidget {
  final StudyMode mode;
  final ValueChanged<int> onRate; // 1=Hard/Forgot, 3=Normal, 5=Easy/Know
  final bool disabled;
  
  const RatingButtons({
    Key? key,
    required this.mode,
    required this.onRate,
    this.disabled = false,
  }) : super(key: key);
}
```

**Behavior**:
- Basic mode: Shows "Know" (5) and "Forgot" (1) buttons (Row with 2 GFButtons)
- Smart mode: Shows "😖 Hard (1 day)", "😐 Normal (3 days)", "😄 Easy (7 days)" (Row with 3 GFButtons)
- Calls `onRate(rating)` when button pressed
- Disables buttons if `disabled == true` (grayed out, non-interactive)

**Implementation Requirements**:
- Use `GFButton` from GetWidget library
- Primary action (Know/Easy): `GFButtonType.solid` with full width
- Secondary actions (Forgot/Hard/Normal): `GFButtonType.outline`
- Follow spacing rules: 16dp between buttons (SizedBox)
- Use theme colors: `Theme.of(context).colorScheme.primary`
- Example:
  ```dart
  GFButton(
    onPressed: disabled ? null : () => onRate(5),
    type: GFButtonType.solid,
    text: "Know",
    fullWidthButton: true,
    color: Theme.of(context).colorScheme.primary,
  )
  ```


---

### DeckCard Widget

**Purpose**: Display deck summary in list

**Properties**:
```dart
class DeckCard extends StatelessWidget {
  final Deck deck;
  final int dueCardsCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  
  const DeckCard({
    Key? key,
    required this.deck,
    required this.dueCardsCount,
    required this.onTap,
    required this.onLongPress,
  }) : super(key: key);
}
```

**Behavior**:
- Card widget with InkWell for tap interactions
- Shows deck name (Text with headline style)
- Shows total cards and due cards count (Text with caption style)
- Shows "Last studied: X days ago" if `lastStudiedAt != null` (calculated with timeago package)
- Calls `onTap()` when tapped
- Calls `onLongPress()` for bottom sheet menu

---

### WeeklyChart Widget

**Purpose**: Bar chart showing weekly study activity

**Properties**:
```dart
class WeeklyChart extends StatelessWidget {
  final List<WeeklyBreakdownItem> data;
  
  const WeeklyChart({
    Key? key,
    required this.data,
  }) : super(key: key);
}
```

**Behavior**:
- Renders 7-day bar chart using fl_chart package
- Highlights current day with different color
- Shows card count on bar tap (Tooltip)
- Y-axis shows card count, X-axis shows day labels (Mon, Tue, etc.)

---

## Provider Contracts

### DeckRepository

**Purpose**: Load and observe all decks

**Interface**:
```dart
abstract class DeckRepository {
  Stream<List<Deck>> watchAllDecks();
  Future<Deck?> getDeckById(String deckId);
  Future<void> createDeck(String name);
  Future<void> updateDeck(Deck deck);
  Future<void> deleteDeck(String deckId);
}
```

**Provider**:
```dart
final deckRepositoryProvider = Provider<DeckRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return DeckRepositoryImpl(database);
});

final deckListProvider = StreamProvider<List<Deck>>((ref) {
  final repo = ref.watch(deckRepositoryProvider);
  return repo.watchAllDecks();
});
```

**Behavior**:
- Returns reactive list of decks via Stream (updates automatically on changes)
- Sorted by `lastStudiedAt` desc (most recent first)
- StreamProvider handles loading and error states

---

### StudySessionNotifier

**Purpose**: Manage study session state and card progression

**State Class**:
```dart
class StudySessionState {
  final Card? currentCard;
  final int currentIndex;
  final int totalCards;
  final bool isFlipped;
  final String sessionId;
  final SessionStatistics statistics;
  final bool isSessionComplete;
  
  StudySessionState({
    this.currentCard,
    required this.currentIndex,
    required this.totalCards,
    this.isFlipped = false,
    required this.sessionId,
    required this.statistics,
    this.isSessionComplete = false,
  });
}

class SessionStatistics {
  final int cardsReviewed;
  final int cardsKnown;
  final int cardsForgot;
  
  const SessionStatistics({
    this.cardsReviewed = 0,
    this.cardsKnown = 0,
    this.cardsForgot = 0,
  });
}
```

**StateNotifier**:
```dart
class StudySessionNotifier extends StateNotifier<StudySessionState> {
  final String deckId;
  final StudyMode mode;
  final CardRepository cardRepository;
  final ReviewRepository reviewRepository;
  
  StudySessionNotifier({
    required this.deckId,
    required this.mode,
    required this.cardRepository,
    required this.reviewRepository,
  }) : super(StudySessionState(
    currentIndex: 0,
    totalCards: 0,
    sessionId: const Uuid().v4(),
    statistics: const SessionStatistics(),
  )) {
    _loadCards();
  }
  
  Future<void> _loadCards() async { /* ... */ }
  void flip() { /* ... */ }
  Future<void> rate(int rating) async { /* ... */ }
  void undo() { /* ... */ }
  bool get canUndo => /* ... */;
}
```

**Provider**:
```dart
final studySessionProvider = StateNotifierProvider.family
  .autoDispose<StudySessionNotifier, StudySessionState, StudySessionArgs>(
    (ref, args) {
      final cardRepo = ref.watch(cardRepositoryProvider);
      final reviewRepo = ref.watch(reviewRepositoryProvider);
      return StudySessionNotifier(
        deckId: args.deckId,
        mode: args.mode,
        cardRepository: cardRepo,
        reviewRepository: reviewRepo,
      );
    },
);
```

**Behavior**:
- Loads due cards (Smart mode) or all cards (Basic mode) via `_loadCards()`
- Tracks current card index and flip state in immutable state
- Records reviews and updates SRS schedule via `rate()`
- Allows undo within 3-second window via Timer
- Signals session completion when all cards reviewed (`isSessionComplete`)

---

### ReviewRepository

**Purpose**: Record card review and update SRS schedule

**Interface**:
```dart
abstract class ReviewRepository {
  Future<void> recordReview({
    required String cardId,
    required String sessionId,
    required int rating,
  });
}
```

**Provider**:
```dart
final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final database = ref.watch(databaseProvider);
  final algorithm = ref.watch(sm2AlgorithmProvider);
  return ReviewRepositoryImpl(database, algorithm);
});
```

**Behavior**:
- Creates CardReview record
- Calls SM-2 algorithm to calculate next review date
- Updates Card entity (nextReviewDate, easeFactor, reviewCount, currentInterval)
- Updates StudySession statistics in transaction

---

### TTSService

**Purpose**: Text-to-speech functionality

**Interface**:
```dart
abstract class TTSService {
  Future<void> speak(String text, {String? voice});
  Future<void> stop();
  Stream<bool> get isSpeaking;
  Future<bool> get isAvailable;
  Future<List<String>> getAvailableVoices();
}
```

**Provider**:
```dart
final ttsServiceProvider = Provider<TTSService>((ref) {
  return TTSServiceImpl();
});

final isSpeakingProvider = StreamProvider<bool>((ref) {
  final tts = ref.watch(ttsServiceProvider);
  return tts.isSpeaking;
});
```

**Behavior**:
- Wraps flutter_tts library
- Handles voice availability checks
- Provides graceful fallback if TTS unavailable

---

### ImportExportService

**Purpose**: Import and export decks

**State Class**:
```dart
class ImportExportState {
  final bool isProcessing;
  final String? error;
  
  const ImportExportState({
    this.isProcessing = false,
    this.error,
  });
}
```

**StateNotifier**:
```dart
class ImportExportNotifier extends StateNotifier<ImportExportState> {
  final DeckRepository deckRepository;
  final CardRepository cardRepository;
  
  ImportExportNotifier({
    required this.deckRepository,
    required this.cardRepository,
  }) : super(const ImportExportState());
  
  Future<String> exportJSON(String deckId) async { /* ... */ }
  Future<String> exportCSV(String deckId) async { /* ... */ }
  Future<String> importJSON(String filePath) async { /* ... */ }
  Future<ImportResult> importCSV(String filePath) async { /* ... */ }
}

class ImportResult {
  final String deckId;
  final int skipped;
  
  const ImportResult({required this.deckId, this.skipped = 0});
}
```

**Provider**:
```dart
final importExportProvider = StateNotifierProvider
  <ImportExportNotifier, ImportExportState>((ref) {
    final deckRepo = ref.watch(deckRepositoryProvider);
    final cardRepo = ref.watch(cardRepositoryProvider);
    return ImportExportNotifier(
      deckRepository: deckRepo,
      cardRepository: cardRepo,
    );
});
```

**Behavior**:
- Exports deck with images embedded as base64 (JSON) via File API
- Exports deck as text-only (CSV) via csv package
- Imports with conflict resolution (Replace/Merge/Create New) via dialog
- Shows progress during processing via `isProcessing` state

---

## Service Contracts

### SM2Algorithm

**Purpose**: Calculate next review intervals using SM-2 algorithm

**Result Class**:
```dart
class SM2Result {
  final DateTime nextReviewDate;
  final double easeFactor;
  final int currentInterval;
  
  const SM2Result({
    required this.nextReviewDate,
    required this.easeFactor,
    required this.currentInterval,
  });
}
```

**Function Signature**:
```dart
abstract class SM2Algorithm {
  SM2Result calculate({
    required int rating, // 1=Hard, 3=Normal, 5=Easy
    required double previousEaseFactor, // Default 2.5
    required int previousInterval, // Days since last review
    required int reviewCount, // Total times reviewed
  });
}
```

**Provider**:
```dart
final sm2AlgorithmProvider = Provider<SM2Algorithm>((ref) {
  return SM2AlgorithmImpl();
});
```

**Algorithm**:
1. Adjust ease factor based on rating
   - rating=1: EF -= 0.2 (min 1.3)
   - rating=3: EF unchanged
   - rating=5: EF += 0.15 (max 3.0)
2. Calculate interval
   - First review: 1, 3, or 7 days (Hard, Normal, Easy)
   - Subsequent: interval *= easeFactor
3. Return next review date = today + interval

---

### DatabaseService

**Purpose**: CRUD operations with validation and transactions

**Interface**:
```dart
abstract class DatabaseService {
  // Decks
  Future<Deck> createDeck(String name);
  Future<Deck> updateDeck(String id, DeckUpdate updates);
  Future<void> deleteDeck(String id);
  Future<Deck?> getDeck(String id);
  Stream<List<Deck>> observeDecks();

  // Cards
  Future<Card> createCard(String deckId, CardInput data);
  Future<Card> updateCard(String id, CardUpdate updates);
  Future<void> deleteCard(String id);
  Stream<List<Card>> observeCards(String deckId);
  Future<List<Card>> getDueCards(String deckId);

  // Study Sessions
  Future<StudySession> createSession(String deckId);
  Future<void> endSession(String sessionId);
  Future<void> recordCardReview(CardReviewInput data);

  // Statistics
  Future<UserStatistics> getStatistics();
  Future<List<WeeklyData>> getWeeklyBreakdown();
  Future<List<DeckStatistics>> getDeckStatistics();
}
```

**Provider**:
```dart
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(() => database.close());
  return database;
});
```

---

## Type Definitions

```dart
// Core domain types - these correspond to Drift tables
class Deck {
  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime? lastStudiedAt;
  final int cardCount; // Computed from cards table
  
  const Deck({
    required this.id,
    required this.name,
    required this.createdAt,
    this.lastStudiedAt,
    required this.cardCount,
  });
}

class Card {
  final String id;
  final String deckId;
  final String frontText;
  final String backText;
  final String? frontImagePath;
  final String? backImagePath;
  final DateTime createdAt;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewDate;
  final double easeFactor;
  final int reviewCount;
  final int currentInterval;
  
  const Card({
    required this.id,
    required this.deckId,
    required this.frontText,
    required this.backText,
    this.frontImagePath,
    this.backImagePath,
    required this.createdAt,
    this.lastReviewedAt,
    this.nextReviewDate,
    required this.easeFactor,
    required this.reviewCount,
    required this.currentInterval,
  });
}

class StudySession {
  final String id;
  final String deckId;
  final DateTime startTime;
  final DateTime? endTime;
  final int cardsReviewed;
  final int cardsKnown;
  final int cardsForgot;
  
  const StudySession({
    required this.id,
    required this.deckId,
    required this.startTime,
    this.endTime,
    required this.cardsReviewed,
    required this.cardsKnown,
    required this.cardsForgot,
  });
}

class CardReview {
  final String id;
  final String sessionId;
  final String cardId;
  final DateTime reviewTimestamp;
  final int rating;
  final int timeSpent;
  
  const CardReview({
    required this.id,
    required this.sessionId,
    required this.cardId,
    required this.reviewTimestamp,
    required this.rating,
    required this.timeSpent,
  });
}

enum ThemeMode { light, dark, system }

class UserPreferences {
  final String id;
  final String ttsVoice;
  final bool autoPlayEnabled;
  final bool notificationEnabled;
  final String notificationTime; // HH:mm format
  final ThemeMode theme;
  
  const UserPreferences({
    required this.id,
    required this.ttsVoice,
    required this.autoPlayEnabled,
    required this.notificationEnabled,
    required this.notificationTime,
    required this.theme,
  });
}

// Input types for mutations
class CardInput {
  final String frontText;
  final String backText;
  final String? frontImagePath;
  final String? backImagePath;
  
  const CardInput({
    required this.frontText,
    required this.backText,
    this.frontImagePath,
    this.backImagePath,
  });
}

class DeckUpdate {
  final String? name;
  final DateTime? lastStudiedAt;
  
  const DeckUpdate({this.name, this.lastStudiedAt});
}

class CardUpdate {
  final String? frontText;
  final String? backText;
  final String? frontImagePath;
  final String? backImagePath;
  final DateTime? nextReviewDate;
  final double? easeFactor;
  final int? reviewCount;
  final int? currentInterval;
  
  const CardUpdate({
    this.frontText,
    this.backText,
    this.frontImagePath,
    this.backImagePath,
    this.nextReviewDate,
    this.easeFactor,
    this.reviewCount,
    this.currentInterval,
  });
}

class CardReviewInput {
  final String sessionId;
  final String cardId;
  final int rating;
  final int timeSpent;
  
  const CardReviewInput({
    required this.sessionId,
    required this.cardId,
    required this.rating,
    required this.timeSpent,
  });
}
```

---

## Validation Rules

```dart
// Validation functions for runtime checks
class DeckNameValidator {
  static const int minLength = 1;
  static const int maxLength = 100;
  static final RegExp validCharacters = RegExp(r'^[\p{L}\p{N}\s\-_.,!?()]+$', unicode: true);
  
  static String? validate(String name) {
    if (name.isEmpty) {
      return 'Deck name cannot be empty';
    }
    if (name.length > maxLength) {
      return 'Deck name must be $maxLength characters or less';
    }
    if (!validCharacters.hasMatch(name)) {
      return 'Invalid characters in deck name';
    }
    return null; // Valid
  }
}

class CardTextValidator {
  static const int minLength = 1;
  static const int maxLength = 500;
  
  static String? validate(String text) {
    if (text.isEmpty) {
      return 'Card text cannot be empty';
    }
    if (text.length > maxLength) {
      return 'Card text too long (max $maxLength characters)';
    }
    return null; // Valid
  }
}

class RatingValidator {
  static const List<int> validRatings = [1, 3, 5]; // Hard/Forgot, Normal, Easy/Know
  
  static String? validate(int rating) {
    if (!validRatings.contains(rating)) {
      return 'Rating must be 1, 3, or 5';
    }
    return null; // Valid
  }
}
```

---

## Next Steps

- ✅ Screen and widget contracts defined (Flutter)
- ✅ Provider interfaces specified (Riverpod)
- ✅ Service contracts outlined (Dart)
- ✅ Type definitions converted (Dart classes)
- ✅ Validation schemas converted (Dart validators)
- ⏭️ Generate tasks.md with Flutter context using /speckit.tasks
- ⏭️ Run /speckit.analyze to validate consistency
