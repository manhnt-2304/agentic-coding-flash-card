# Research: Core Flashcard Learning MVP

**Feature**: Core Flashcard Learning MVP  
**Date**: 2025-12-26  
**Status**: Complete

## Research Questions

### 1. Mobile Development Platform Selection

**Question**: React Native vs Flutter vs Native (iOS/Android) for flashcard app?

**Decision**: **Flutter**

**Rationale**:
- **Cross-platform**: Single codebase for iOS/Android reduces development time
- **Performance**: Excellent performance with Skia rendering engine - easily meets <100ms flip requirement
- **Native compilation**: Compiles to native ARM code (faster than JavaScript bridge)
- **UI consistency**: Same UI rendering across platforms (no platform-specific quirks)
- **Hot reload**: Instant feedback during development
- **Developer experience**: Strong tooling, comprehensive widget library, Dart DevTools
- **Animation support**: Built-in animation APIs (AnimationController, Hero animations)

**Alternatives Considered**:
- **React Native**: Mature ecosystem, but JavaScript bridge can cause performance bottlenecks. Bridge overhead for animations.
- **Native iOS/Android**: Best performance and platform integration, but 2x development cost. Overkill for MVP.
- **Ionic/Cordova**: Web view approach causes performance issues for smooth animations (card flips).

**Key Libraries**:
- **UI**: Flutter Material/Cupertino widgets (built-in)
- **Storage**: sqflite (SQLite wrapper, ACID transactions) + drift (type-safe SQL)
- **TTS**: flutter_tts (cross-platform TTS wrapper)
- **File System**: path_provider + dart:io (built-in)
- **Images**: cached_network_image (caching, optimization)
- **Notifications**: flutter_local_notifications (local notifications)
- **State Management**: Riverpod or Provider (reactive state)

---

### 2. Local Database Selection

**Question**: Which embedded database provides ACID compliance, performance, and Flutter compatibility?

**Decision**: **sqflite + drift** (built on SQLite)

**Rationale**:
- **ACID compliant**: Transactions supported, rollback on errors (Constitutional requirement III)
- **Performance**: Direct SQLite access, optimized queries, handles 10,000+ records efficiently
- **Type-safe**: drift provides compile-time type checking and code generation
- **Flutter integration**: Async/await API, Stream support for reactive updates
- **Offline-first**: Built for offline apps, no server dependency
- **Migrations**: Schema versioning built-in (Constitutional requirement III: data versioning)
- **Battle-tested**: SQLite is industry standard, used by millions of apps

**Alternatives Considered**:
- **Hive**: NoSQL key-value store. Fast but no SQL relations, harder to query complex data.
- **Moor (old name for drift)**: Same as drift, just older version.
- **ObjectBox**: Fast NoSQL database, but commercial licensing for larger apps.
- **Isar**: Fast NoSQL with good querying, but newer (less proven), no SQL standard.

**Schema Design Considerations**:
- Tables: `decks`, `cards`, `study_sessions`, `card_reviews`, `user_preferences`
- Indexes: card front text (search), next_review_date (due cards query), deck_id (filtering)
- Relationships: Deck → Cards (one-to-many), StudySession → CardReviews (one-to-many)
- Use drift for type-safe queries and automatic serialization

---

### 3. Spaced Repetition Algorithm (SM-2)

**Question**: How to implement SM-2 algorithm for optimal learning intervals?

**Decision**: **Implement SM-2 algorithm with standard parameters**

**Rationale**:
- **Proven effectiveness**: SuperMemo-2 algorithm (1987) is well-researched, used by Anki
- **Simple implementation**: ~50 lines of code, deterministic (Constitutional requirement VI: algorithm consistency)
- **Configurable intervals**: Initial intervals (Hard: 1 day, Normal: 3 days, Easy: 7 days) match user expectations
- **Ease factor**: Tracks card difficulty (starts at 2.5, adjusts based on ratings)
- **Constitutional alignment**: Learning Science Foundation (Principle IV) - evidence-based algorithm

**Algorithm Summary**:
```
For each card review:
  1. If rating = Hard (1): interval = 1 day, ease_factor -= 0.2 (min 1.3)
  2. If rating = Normal (3): interval = current_interval * ease_factor
  3. If rating = Easy (5): interval = current_interval * ease_factor * 1.3, ease_factor += 0.15
  4. next_review_date = today + interval (rounded to days)
```

**Alternatives Considered**:
- **Leitner System**: Box-based system. Simpler but less adaptive. SM-2 provides better personalization.
- **SuperMemo 11+**: More complex algorithms (17 variables). Overkill for MVP, harder to explain to users.
- **Custom heuristics**: Reinventing the wheel. SM-2 is proven and expected by flashcard users.

**Implementation Library**:
- Use existing SM-2 libraries (e.g., `sm2` npm package) or implement from specification
- Document algorithm in code comments with references to original paper
- Add unit tests for edge cases (first review, ease factor bounds, interval calculations)

**References**:
- Original SM-2 Paper: Wozniak, P. A. (1990). "Algorithm SM-2"
- Anki's SM-2 implementation: Open-source reference

---

### 4. Image Storage Strategy

**Question**: How to handle base64 embedding in JSON exports without excessive memory usage?

**Decision**: **Lazy encoding/decoding with size warnings**

**Rationale**:
- **Export**: Encode images to base64 only during export operation (not stored as base64 in DB)
- **Size limit**: Warn user if export will exceed 50MB (e.g., 50+ high-res images)
- **Compression**: Auto-compress images to max 800x800px, JPEG quality 85% before encoding
- **Import**: Decode base64, validate format, re-compress, store as files with refs in DB
- **Memory efficiency**: Stream encoding/decoding for large exports (don't load full JSON into memory)

**Technical Details**:
- Image storage in DB: Store file path reference, not base64 (Constitutional: performance, memory <200MB)
- Export process: Read file → compress → base64 → JSON
- Import process: Parse JSON → decode base64 → validate → save file → insert DB record
- Use `path_provider` for app directory, `dart:io` for file operations, `image` package for compression

**CSV handling**: CSV exports skip images (text-only), document this limitation clearly

---

### 5. TTS (Text-to-Speech) Integration

**Question**: Best approach for cross-platform pronunciation with English US/UK/Vietnamese?

**Decision**: **flutter_tts library with platform-native engines**

**Rationale**:
- **Cross-platform**: Single API for iOS (AVSpeechSynthesizer) and Android (TextToSpeech)
- **Quality**: Uses platform-native voices (high quality, no internet required for common languages)
- **Languages**: English US/UK/Vietnamese supported on both platforms out-of-box
- **Control**: Playback control (play, pause, stop), speech rate, pitch adjustable
- **Offline**: No network dependency (Constitutional: offline-first)

**Implementation**:
- Check voice availability on app start: `await flutterTts.getLanguages()`
- Fallback: If Vietnamese not available, show error per NFR-011 (graceful degradation)
- Auto-play: Trigger TTS on card render if preference enabled
- Manual play: Speaker icon triggers `await flutterTts.speak(text)`

**Edge Cases**:
- Image-only cards: Hide speaker icon (no text to speak)
- Long text (>200 chars): Truncate or warn (TTS becomes awkward for paragraphs)
- Special characters: TTS engine handles Unicode, but test with Vietnamese diacritics

**Alternatives Considered**:
- **Cloud TTS (Google/AWS)**: Better quality, more voices, but requires internet. Violates offline-first principle.
- **Embedded TTS engine**: Packages voices with app (~100MB per language). Excessive storage cost.

---

### 6. Testing Strategy

**Question**: How to implement TDD workflow with contract, integration, and unit tests?

**Decision**: **flutter_test + integration_test + mockito**

**Rationale**:
- **Unit tests**: flutter_test (built-in, fast, mocking support)
- **Widget tests**: flutter_test (render widgets, simulate user actions, assert UI state)
- **Integration tests**: integration_test package (full app flows on real device/emulator)
- **Mocking**: mockito for mocking database, services, external dependencies
- **Golden tests**: Compare widget screenshots for UI regression testing

**Test Structure**:
```
test/
├── unit/
│   ├── services/
│   │   └── sm2_algorithm_test.dart     # SM-2 calculation tests
│   ├── utils/
│   │   └── validation_test.dart        # Input sanitization tests
├── widget/
│   ├── deck_management_test.dart       # Deck CRUD widget tests
│   ├── study_session_test.dart         # Study mode widget tests
│   ├── import_export_test.dart         # File I/O widget tests
├── integration/
│   └── user_stories_test.dart          # Full P1 user story flows
```

**TDD Workflow** (Constitutional Principle II):
1. Write test for acceptance criteria (Given-When-Then)
2. Verify test fails (Red)
3. Implement minimal code to pass (Green)
4. Refactor while keeping green
5. Repeat for next acceptance scenario

**Coverage Targets**:
- Unit tests: >80% coverage (algorithms, utilities, business logic)
- Widget tests: All user stories have at least one test
- Integration tests: P1 user stories (3 critical paths)

---

### 7. Performance Optimization

**Question**: How to achieve <100ms card flip, <2s deck load for 1000 cards?

**Decision**: **ListView.builder + cached images + indexed queries**

**Rationale**:
- **Card flip**: Use Flutter's built-in AnimationController with Transform widget (runs at 60fps)
- **Deck loading**: ListView.builder lazy-loads items (renders only visible), sqflite indexed queries
- **Image loading**: cached_network_image caches images, loads asynchronously (doesn't block UI)
- **Query optimization**: Index deck_id, next_review_date columns for fast filtering

**Performance Techniques**:
1. **Lazy lists**: ListView.builder only builds visible items (reduces initial load)
2. **Const widgets**: Use const constructors where possible (reduces rebuilds)
3. **Image compression**: Resize on upload (max 800x800), compress JPEG to 85% quality
4. **Pagination**: Load decks/cards in batches (50 at a time) if >1000 items
5. **GPU animations**: Flutter's Skia engine runs animations on GPU thread

**Profiling Plan**:
- Use Flutter DevTools (performance overlay) to profile rebuilds and janky frames
- Test on mid-range devices (2-year-old Android, iPhone 11)
- Measure metrics: flip animation FPS, deck load time, memory usage

---

### 8. Accessibility Implementation

**Question**: How to ensure WCAG 2.1 AA compliance and keyboard navigation?

**Decision**: **Flutter Semantics widget + testing with screen readers**

**Rationale**:
- **Screen readers**: Use Semantics widget with label, hint, value properties
- **Platform integration**: Flutter automatically bridges to iOS VoiceOver and Android TalkBack
- **Focus management**: FocusNode API for keyboard navigation order
- **Contrast**: Use Material Theme with proper contrast ratios (built-in AA compliance)
- **Testing**: Test with iOS VoiceOver and Android TalkBack

**Implementation Checklist**:
- [ ] All buttons wrapped in Semantics with labels ("Flip card", "Mark as Easy")
- [ ] Card content readable by screen reader (announces front, then back on flip)
- [ ] Navigation: Tab order logical (deck list → study button → cards)
- [ ] Color contrast: Text on backgrounds meets 4.5:1 ratio (AA standard)
- [ ] Error messages: Announced by screen reader, not just visual

**Testing Tools**:
- iOS: Enable VoiceOver in Simulator, navigate app
- Android: Enable TalkBack, test navigation
- Automated: Use semantics testing in flutter_test

---

### 9. Project Structure Decision

**Question**: Mobile app structure - where to place code?

**Decision**: **Feature-based folder structure with shared utilities**

**Rationale**:
- **Feature modules**: Group related screens, components, hooks by feature (easier to navigate)
- **Shared code**: Separate folder for database models, utils, services
- **Scalability**: Easy to add new features without cluttering root

**Structure**:
```
lib/
├── features/
│   ├── decks/
│   │   ├── screens/
│   │   │   ├── deck_list_screen.dart
│   │   │   ├── deck_detail_screen.dart
│   │   │   └── create_deck_screen.dart
│   │   ├── widgets/
│   │   │   ├── deck_card.dart
│   │   │   └── deck_list_item.dart
│   │   └── providers/
│   │       └── deck_provider.dart
│   ├── cards/
│   │   ├── screens/
│   │   │   ├── card_editor_screen.dart
│   │   │   └── card_list_screen.dart
│   │   └── widgets/
│   │       └── card_form.dart
│   ├── study/
│   │   ├── screens/
│   │   │   ├── study_mode_selection_screen.dart
│   │   │   ├── study_session_screen.dart
│   │   │   └── session_summary_screen.dart
│   │   ├── widgets/
│   │   │   ├── flash_card.dart
│   │   │   ├── rating_buttons.dart
│   │   │   └── card_flip_animation.dart
│   │   └── providers/
│   │       └── study_session_provider.dart
│   ├── statistics/
│   │   ├── screens/
│   │   │   └── statistics_screen.dart
│   │   └── widgets/
│   │       ├── streak_display.dart
│   │       └── weekly_chart.dart
│   └── settings/
│       ├── screens/
│       │   └── settings_screen.dart
│       └── widgets/
│           └── settings_item.dart
├── data/
│   ├── models/
│   │   ├── deck.dart
│   │   ├── card.dart
│   │   ├── study_session.dart
│   │   ├── card_review.dart
│   │   └── user_preferences.dart
│   ├── database/
│   │   ├── app_database.dart       # drift database definition
│   │   └── app_database.g.dart     # generated code
│   └── repositories/
│       ├── deck_repository.dart
│       ├── card_repository.dart
│       └── statistics_repository.dart
├── services/
│   ├── srs/
│   │   ├── sm2_algorithm.dart
│   │   └── scheduling_service.dart
│   ├── storage/
│   │   ├── image_service.dart
│   │   └── backup_service.dart
│   ├── import_export/
│   │   ├── json_importer.dart
│   │   ├── csv_importer.dart
│   │   └── exporter.dart
│   ├── tts/
│   │   └── pronunciation_service.dart
│   └── statistics/
│       └── analytics_service.dart
├── core/
│   ├── utils/
│   │   ├── validation.dart
│   │   ├── date_utils.dart
│   │   └── constants.dart
│   ├── theme/
│   │   ├── app_colors.dart
│   │   ├── app_typography.dart
│   │   └── app_theme.dart
│   └── router/
│       └── app_router.dart
└── main.dart

test/
├── unit/
├── widget/
└── integration/
```

---

## Research Summary

**All NEEDS CLARIFICATION items resolved:**

1. ✅ **Language/Version**: Flutter (latest stable, ~3.16+), Dart 3.x
2. ✅ **Primary Dependencies**: sqflite + drift (database), flutter_tts (TTS), cached_network_image (images), flutter_local_notifications
3. ✅ **Testing**: flutter_test, integration_test, mockito

**Key Technical Decisions**:
- Flutter for cross-platform mobile development with native performance
- sqflite + drift for ACID-compliant local storage with type safety
- SM-2 algorithm for spaced repetition (scientifically validated)
- Platform-native TTS for pronunciation (offline-capable)
- Feature-based architecture for scalability
- Comprehensive testing strategy (unit, widget, integration)

**Risk Mitigation**:
- **Performance**: Profiling plan, virtualization, animation optimization
- **Accessibility**: Built-in from start, testing with screen readers
- **Data integrity**: ACID transactions, input validation, backup/restore
- **Learning effectiveness**: SM-2 algorithm proven, will validate with user testing

**Next Steps**: Proceed to Phase 1 - Design data models and component contracts
