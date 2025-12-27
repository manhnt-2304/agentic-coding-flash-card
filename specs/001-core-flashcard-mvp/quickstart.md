# Developer Quickstart: Flashcard Learning MVP

**Last Updated**: 2025-12-26  
**Feature Branch**: `001-core-flashcard-mvp`  
**Target**: Flutter 3.16+ Mobile Application

---

## Prerequisites

Before you begin, ensure you have:

- **Flutter SDK**: 3.16+ (latest stable)
- **Dart SDK**: 3.x (bundled with Flutter)
- **Development Environment**:
  - For iOS: macOS with Xcode 15+
  - For Android: Android Studio with SDK 31+ and Android toolchain
- **Git**: For version control
- **VS Code** (recommended) with extensions:
  - Flutter
  - Dart
  - Flutter Widget Snippets
  - Dart Data Class Generator

---

## Quick Start (5 Minutes)

### 1. Clone and Setup

```bash
# Clone repository
git clone <repository-url>
cd flashcard_learning

# Checkout feature branch
git checkout 001-core-flashcard-mvp

# Verify Flutter installation
flutter doctor

# Get dependencies
flutter pub get

# Generate drift database code
dart run build_runner build
```

### 2. Run Development App

```bash
# List available devices
flutter devices

# Run on iOS simulator
flutter run -d ios

# Or run on Android emulator
flutter run -d android

# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal
```

### 3. Run Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests (requires device/emulator)
flutter test integration_test/
```

---

## Project Architecture

### Technology Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **Framework** | Flutter 3.16+ | Cross-platform mobile development |
| **Language** | Dart 3.x | Type-safe development |
| **Database** | sqflite + drift | Offline-first local storage with type safety |
| **Navigation** | Flutter Navigator 2.0 | Declarative routing |
| **UI Components** | Material/Cupertino widgets | Built-in UI components |
| **Testing** | flutter_test + integration_test | Unit, widget, integration testing |
| **State Management** | Riverpod or Provider | Reactive state management |
| **Text-to-Speech** | flutter_tts | Pronunciation playback |
| **File System** | path_provider + dart:io | Import/export functionality |
| **Image Handling** | cached_network_image | Optimized image loading |

### Project Structure

```
flashcard_learning/
├── lib/
│   ├── features/              # Feature-based organization
│   │   ├── decks/            # Deck management feature
│   │   │   ├── screens/      # deck_list_screen.dart, deck_detail_screen.dart
│   │   │   ├── widgets/      # deck_card.dart, deck_form.dart
│   │   │   ├── providers/    # deck_provider.dart
│   │   │   └── __tests__/    # Feature tests
│   │   ├── cards/            # Card CRUD feature
│   │   │   ├── screens/      # CardEditorScreen
│   │   │   ├── components/   # CardForm, ImagePicker
│   │   │   └── hooks/        # useCards, useCard
│   │   ├── study/            # Study session feature
│   │   │   ├── screens/      # StudySessionScreen, SessionSummary
│   │   │   ├── components/   # FlashCard, RatingButtons
│   │   │   ├── hooks/        # useStudySession, useCardReview
│   │   │   └── services/     # SM2 algorithm implementation
│   │   ├── statistics/       # Statistics and analytics
│   │   │   ├── screens/      # StatisticsScreen
│   │   │   ├── components/   # WeeklyChart, DeckStatistics
│   │   │   └── hooks/        # useStatistics
│   │   └── settings/         # User preferences
│   │       ├── screens/      # SettingsScreen
│   │       └── hooks/        # usePreferences
│   ├── shared/               # Shared utilities
│   │   ├── models/           # WatermelonDB models and schema
│   │   │   ├── schema.ts     # Database schema definition
│   │   │   ├── Deck.ts       # Deck model
│   │   │   ├── Card.ts       # Card model
│   │   │   └── ...
│   │   ├── services/         # Cross-feature services
│   │   │   ├── database.ts   # Database service wrapper
│   │   │   ├── tts.ts        # TTS service
│   │   │   ├── importExport.ts
│   │   │   └── notifications.ts
│   │   ├── utils/            # Helper functions
│   │   │   ├── validation.ts # Zod schemas
│   │   │   ├── dateUtils.ts
│   │   │   └── imageUtils.ts
│   │   ├── constants/        # App-wide constants
│   │   │   └── config.ts
│   │   └── types/            # Shared TypeScript types
│   │       └── index.ts
│   ├── navigation/           # Navigation configuration
│   │   ├── RootNavigator.tsx
│   │   └── types.ts
│   └── App.tsx               # App entry point
├── android/                  # Android native code
├── ios/                      # iOS native code
├── specs/                    # Speckit specifications
│   └── 001-core-flashcard-mvp/
│       ├── spec.md           # Feature requirements
│       ├── plan.md           # Implementation plan
│       ├── data-model.md     # Database schema
│       ├── contracts/        # API contracts
│       └── tasks.md          # (Generated) Task breakdown
├── __tests__/                # Root-level tests
│   └── e2e/                  # Detox E2E tests
├── .specify/                 # Speckit framework
│   ├── memory/               # Project constitution
│   └── scripts/              # Workflow automation
└── package.json
```

---

## Development Workflow

### Constitutional Principles

This project follows 7 core principles (see `.specify/memory/constitution.md`):

1. **User-First Testing**: Write user story tests before implementation
2. **TDD (Red-Green-Refactor)**: Write failing tests → implement → refactor
3. **Data Integrity & Privacy**: All data local, encrypted backups, no tracking
4. **Learning Science Foundation**: SM-2 algorithm, evidence-based design
5. **Progressive Enhancement**: Core features work offline, extras are additive
6. **Accessibility First**: WCAG 2.1 AA compliance, screen reader support
7. **Simplicity & Maintainability**: Prefer clear code over clever code

### TDD Workflow (Recommended)

```bash
# 1. Create feature branch
git checkout -b 001-core-flashcard-mvp

# 2. Write widget tests (user story acceptance criteria)
# Edit: test/widget/deck_list_test.dart

# 3. Run tests (should fail - RED)
flutter test --watch

# 4. Implement minimum code to pass tests (GREEN)
# Edit: lib/features/decks/screens/deck_list_screen.dart

# 5. Refactor for quality (REFACTOR)
# Improve code structure, extract widgets, add types

# 6. Write unit tests for business logic
# Edit: test/unit/services/deck_service_test.dart

# 7. Commit when all tests pass
git add .
git commit -m "feat(decks): implement deck list with create/delete"
```

### Commit Message Format

Follow conventional commits:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types**: `feat`, `fix`, `test`, `refactor`, `docs`, `chore`, `style`  
**Scopes**: `decks`, `cards`, `study`, `stats`, `settings`, `db`, `tts`, `ui`

**Examples**:
```
feat(decks): add deck creation with validation
fix(study): correct SM-2 interval calculation for first review
test(cards): add widget tests for card editor
refactor(db): extract validation to shared utils
docs(readme): update setup instructions
```

---

## Key Workflows

### Creating a New Deck

```dart
// lib/data/repositories/deck_repository.dart
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';

class DeckRepository {
  final AppDatabase _db;
  
  DeckRepository(this._db);

  Future<Deck> createDeck(String name) async {
    // Validate name
    final validation = validateDeckName(name);
    if (!validation.valid) {
      throw ValidationException(validation.error!);
    }
    
    // Create deck
    return _db.into(_db.decks).insert(
      DecksCompanion.insert(
        id: const Uuid().v4(),
        name: name,
        createdAt: DateTime.now(),
        cardCount: 0,
      ),
    );
  }
}
    
    // Create deck
    const deck = await database.write(async () => {
      return await database.collections
        .get<DeckModel>('decks')
        .create(deck => {
          deck.name = validated;
          deck.createdAt = new Date();
        });
    });

    return deck;
  };

  return { createDeck };
}
```

### Study Session with SM-2 Algorithm

```dart
// lib/features/study/providers/study_session_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/sm2_algorithm.dart';

class StudySessionNotifier extends StateNotifier<StudySessionState> {
  final CardRepository _cardRepo;
  final ReviewRepository _reviewRepo;

  StudySessionNotifier(this._cardRepo, this._reviewRepo) 
    : super(StudySessionState.initial());

  Future<void> rateCard(int rating) async {
    final card = state.currentCard;
    if (card == null) return;
    
    // Calculate next review using SM-2
    final sm2Result = calculateSM2(
      rating: rating,
      previousEaseFactor: card.easeFactor,
      previousInterval: card.currentInterval,
      reviewCount: card.reviewCount,
    );

    // Update card
    await _cardRepo.update(
      card.copyWith(
        lastReviewedAt: DateTime.now(),
        nextReviewDate: sm2Result.nextReviewDate,
        easeFactor: sm2Result.easeFactor,
        currentInterval: sm2Result.currentInterval,
        reviewCount: card.reviewCount + 1,
      ),
    );

    // Record review
    await _reviewRepo.createReview(
      sessionId: state.sessionId,
      cardId: card.id,
      rating: rating,
      timeSpent: DateTime.now().difference(state.cardStartTime).inSeconds,
    );

### Database Queries with Drift

```dart
// Query due cards for study
Future<List<Card>> getDueCards(String deckId) async {
  final now = DateTime.now();
  return (select(cards)
    ..where((c) => c.deckId.equals(deckId))
    ..where((c) => c.nextReviewDate.isSmallerOrEqualValue(now))
    ..orderBy([(c) => OrderingTerm.asc(c.nextReviewDate)]))
    .get();
}

// Watch decks (reactive updates with streams)
Stream<List<Deck>> watchDecks() {
  return (select(decks)
    ..orderBy([(d) => OrderingTerm.desc(d.lastStudiedAt)]))
    .watch();
}

// Use in widget with StreamBuilder or Riverpod
final decksProvider = StreamProvider<List<Deck>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchDecks();
});
```

---

## Testing Guide

### Test Types

1. **Unit Tests** (Business logic)
2. **Widget Tests** (UI components)
   - Test widget rendering and user interactions
   - Use flutter_test and testWidgets
   - Located: `test/widget/**/*_test.dart`

3. **Integration Tests** (Full app flows)
   - Test complete user journeys on device/emulator
   - Use integration_test package
   - Located: `integration_test/**/*_test.dart`

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/services/sm2_algorithm_test.dart

# Run tests with coverage
flutter test --coverage
lcov --summary coverage/lcov.info

# Run integration tests (requires device)
flutter test integration_test/

# Run integration tests on specific device
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/user_stories_test.dart \
  -d <device_id>
```

### Writing Tests (Example)

```dart
// test/widget/deck_list_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  group('User Story: US1 - Create and manage flashcard decks', () {
    testWidgets('allows user to create a new deck', (tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: DeckListScreen(),
        ),
      );

      // Tap "+" button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter deck name
      await tester.enterText(
        find.byType(TextField),
        'Spanish Vocab',
      );

      // Tap "Create" button
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify deck appears in list
      expect(find.text('Spanish Vocab'), findsOneWidget);
    });
  });
}
```

---

## Common Commands

```bash
# Development
flutter run                  # Run app on connected device
flutter run -d ios           # Run on iOS simulator
flutter run -d android       # Run on Android emulator
flutter analyze              # Run static analysis
dart format .                # Format code

# Testing
flutter test                 # Run all tests
flutter test --coverage      # Run tests with coverage
flutter drive --target=...   # Run integration tests

# Database
dart run build_runner build  # Generate drift code
dart run build_runner watch  # Watch and regenerate
flutter clean                # Clean build artifacts
npm run db:seed              # Seed with sample data (dev only)

# Code Quality
npm run typecheck            # TypeScript type checking
npm run lint:fix             # Auto-fix linting errors
npm run format:check         # Check formatting without changes

# Build
npm run build:ios            # Build iOS app
npm run build:android        # Build Android APK
```

---

## Troubleshooting

### iOS Build Fails

```bash
# Clean Flutter build
flutter clean
flutter pub get

# Clean iOS build
cd ios
rm -rf Pods Podfile.lock
pod deintegrate  
pod install
cd ..

# Rebuild
flutter run -d ios
```

### Android Build Fails

```bash
# Clean Flutter build
flutter clean
flutter pub get

# Clean Gradle cache
cd android
./gradlew clean
cd ..

# Rebuild
flutter run -d android
```

### Hot Reload Not Working

```bash
# Restart with clean
flutter run --no-hot

# Or perform hot restart
# Press 'R' in terminal while app is running
```

### Database Issues

```bash
# Regenerate drift code
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs

# Reset local database (WARNING: deletes all data)
# Delete app and reinstall
flutter clean && flutter run
```

### Test Failures

```bash
# Clean test cache
flutter clean
flutter pub get
flutter test

# Run tests individually
flutter test test/unit/services/sm2_algorithm_test.dart
```

---

## Resources

### Documentation

- **Flutter**: https://flutter.dev/docs
- **Dart**: https://dart.dev/guides
- **sqflite**: https://pub.dev/packages/sqflite
- **drift**: https://drift.simonbinder.eu/docs/
- **flutter_tts**: https://pub.dev/packages/flutter_tts
- **Riverpod**: https://riverpod.dev/docs

### Internal Docs

- **Constitution**: `.specify/memory/constitution.md` - Core principles
- **Feature Spec**: `specs/001-core-flashcard-mvp/spec.md` - Requirements
- **Data Model**: `specs/001-core-flashcard-mvp/data-model.md` - Database schema
- **Contracts**: `specs/001-core-flashcard-mvp/contracts/components.md` - API interfaces

### Code Examples

- **SM-2 Algorithm**: See `lib/services/srs/sm2_algorithm.dart`
- **Database Queries**: See `lib/data/repositories/*.dart`
- **TTS Integration**: See `lib/services/tts/pronunciation_service.dart`
- **Import/Export**: See `lib/services/import_export/*.dart`

---

## Getting Help

1. **Check the Constitution**: Understand core principles first
2. **Read the Spec**: Review feature requirements and acceptance criteria
3. **Review Contracts**: Check API interfaces and data models
4. **Search Tests**: See how features are tested for usage examples
5. **Ask the Team**: Open a GitHub issue or discussion

---

## Next Steps

After setup, follow this order:

1. ✅ Read constitution and understand principles
2. ✅ Review feature specification and user stories
3. ✅ Study data model and database schema
4. ⏭️ Review task breakdown in `tasks.md` (will be generated)
5. ⏭️ Pick a task and start TDD workflow
6. ⏭️ Submit PR when feature complete

Happy coding! 🎉
