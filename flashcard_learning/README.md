# Flashcard Learning App

A mobile-first flashcard learning application with spaced repetition algorithm (SM-2) for vocabulary learning, targeting children and language learners.

## Features

- 📚 **Deck Management**: Organize flashcards into thematic decks
- 🧠 **Spaced Repetition**: SM-2 algorithm for optimized learning schedule
- 🔊 **TTS Support**: Text-to-speech pronunciation for language learning
- 📊 **Statistics**: Track learning progress with streak and accuracy metrics
- 🖼️ **Image Support**: Add images to flashcards for visual learning
- 💾 **Import/Export**: Share decks via JSON/CSV format
- 🌙 **Dark Mode**: Support for light/dark themes
- ♿ **Accessibility**: WCAG 2.1 AA compliant

## Tech Stack

- **Framework**: Flutter 3.16+
- **Language**: Dart 3.x
- **State Management**: Riverpod
- **Database**: SQLite with Drift (type-safe queries)
- **Testing**: flutter_test, integration_test, mockito
- **TTS**: flutter_tts
- **Charts**: fl_chart
- **UI Components**: 
  - GetWidget (pre-built Material widgets)
  - Shimmer (loading placeholders)
  - Flutter Spinkit (loading indicators)
  - Animations (Google's official animation package)

## Project Structure

```
lib/
├── features/              # Feature-based organization
│   ├── decks/            # Deck management
│   ├── cards/            # Card CRUD
│   ├── study/            # Study sessions
│   ├── statistics/       # Analytics
│   └── settings/         # User preferences
├── data/                 # Data layer
│   ├── models/           # Drift table definitions
│   ├── database/         # Database setup
│   └── repositories/     # Data access layer
├── services/             # Business logic services
└── core/                 # Shared utilities, theme, constants
```

## Setup Instructions

### Prerequisites

- Flutter SDK 3.16 or later
- Dart SDK 3.x or later
- Android Studio / Xcode for mobile development

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Generate Drift database code:
```bash
flutter pub run build_runner build
```

3. Run the app:
```bash
flutter run
```

## Development

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

### Code Generation

```bash
# Watch mode
flutter pub run build_runner watch

# One-time build
flutter pub run build_runner build
```

## Architecture

### SM-2 Algorithm

- Rating 1 (Hard): 1 day interval
- Rating 3 (Normal): Standard interval
- Rating 5 (Easy): 7 days first review
- Ease factor range: 1.3 to 3.0

### UI Component Libraries

This project uses carefully selected UI libraries to accelerate development while maintaining code quality:

- **GetWidget**: Provides 1000+ pre-built Material widgets (buttons, cards, badges) that comply with Material Design 3 guidelines
- **Shimmer**: Creates professional loading placeholders for better UX during data fetching
- **Flutter Spinkit**: Offers variety of loading animations for different contexts (saving, loading, processing)
- **Animations**: Google's official animation package for smooth page transitions and shared element animations

**Justification**: These libraries reduce development time for common UI patterns while maintaining accessibility and performance standards. All components are Material 3 compatible and don't affect core learning algorithms or data integrity.

See [UI_COMPONENTS.md](./UI_COMPONENTS.md) for detailed usage guide.

## Performance Goals

- Card flip: <100ms
- Deck load: <2s for 1000 cards
- Memory: <200MB for 1000 cards

