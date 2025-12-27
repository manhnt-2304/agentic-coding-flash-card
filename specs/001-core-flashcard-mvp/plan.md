# Implementation Plan: Core Flashcard Learning MVP

**Branch**: `001-core-flashcard-mvp` | **Date**: 2025-12-26 | **Spec**: [spec.md](./spec.md)  
**Input**: Feature specification from `/specs/001-core-flashcard-mvp/spec.md`

**Note**: This plan follows the constitutional development workflow with phases for research, design, and task breakdown.

## Summary

Build a mobile-first flashcard learning application with spaced repetition algorithm (SM-2), deck management, import/export capabilities, TTS pronunciation, and basic learning statistics. Target users are children and language learners. The MVP focuses on offline-first architecture with local data persistence, supporting both basic study (Know/Forgot) and smart study (SRS with Easy/Normal/Hard ratings). Key constitutional requirements: test-first development, data integrity with ACID-compliant storage, learning science foundation (validated SRS algorithm), and accessibility-first design.

## Technical Context

**Language/Version**: Dart 3.x with Flutter 3.16+  
**Primary Dependencies**: 
- **UI**: Flutter Material/Cupertino widgets (built-in)
- **Database**: sqflite + drift (SQLite-backed with type-safe queries, ACID-compliant)
- **State Management**: Riverpod or Provider (reactive state management)
- **Testing**: flutter_test + integration_test + mockito
- **TTS**: flutter_tts (platform-native speech engines)
- **File System**: path_provider + dart:io (built-in)
- **Image Handling**: cached_network_image (optimized loading with caching)
- **Notifications**: flutter_local_notifications (local reminders)

**Storage**: sqflite with drift for type-safe queries (ACID-compliant, reactive streams)  
**Testing**: flutter_test (unit + widget), integration_test, mockito for mocking  
**Target Platform**: Mobile-first iOS 13+ and Android 8+ (cross-platform with Flutter)  
**Project Type**: Flutter mobile application with Dart  
**Performance Goals**: Card flip <100ms (p95), deck load <2s for 1000 cards, session save <500ms, app launch <3s  
**Constraints**: <200MB memory for 1000 active cards, offline-first (no internet dependency), <5% battery per hour active use  
**Scale/Scope**: Single-user local app, ~10-20 screens/views, support 10,000 cards with images (~1GB data)  
**Architecture**: Feature-based folder structure, offline-first with reactive data layer, TDD with widget → unit → integration test flow

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. User-First Testing ✅
- **Status**: PASS
- **Evidence**: Spec defines 9 user stories with independent tests and Given-When-Then acceptance criteria
- **Action**: Ensure tasks group by user story for independent delivery

### II. Test-First Development ✅
- **Status**: PASS
- **Evidence**: TDD workflow required; spec has testable acceptance scenarios
- **Action**: Generate contract and integration tests before implementation tasks

### III. Data Integrity & Privacy ✅
- **Status**: PASS
- **Evidence**: ACID-compliant local storage required (FR-032), input validation (FR-033), export/import for portability (FR-014-017)
- **Action**: Select database with transaction support; implement validation layer; add backup/restore capability

### IV. Learning Science Foundation ✅
- **Status**: PASS
- **Evidence**: SM-2 spaced repetition algorithm specified (FR-011), learning science rationale required in specs
- **Action**: Research SM-2 implementation; document algorithm parameters; validate against learning science literature

### V. Progressive Enhancement ✅
- **Status**: PASS
- **Evidence**: User stories prioritized P1 (MVP), P2 (Enhanced), P3 (Nice-to-have)
- **Action**: Implement in priority order; each P1 story must be independently shippable

### VI. Accessibility First ✅
- **Status**: PASS
- **Evidence**: NFR-010 requires keyboard navigation, NFR-009 requires clear error messages, WCAG 2.1 AA mentioned
- **Action**: Plan accessibility testing; ensure semantic HTML/native controls; test with screen readers

### VII. Simplicity & Maintainability ✅
- **Status**: PASS
- **Evidence**: YAGNI scope (out-of-scope section comprehensive), minimal dependencies encouraged, domain-language naming
- **Action**: Justify each external dependency in research.md; prefer platform-native solutions

### Performance Baselines ✅
- **Status**: PASS
- **Evidence**: Specific targets defined (card flip <100ms, deck load <2s, save <500ms, memory <200MB)
- **Action**: Add performance test tasks; profile critical paths

### Security Requirements ✅
- **Status**: PASS  
- **Evidence**: Input sanitization required (FR-033, NFR-005), no sensitive data in logs, dependency scanning
- **Action**: Plan input validation strategy; set up dependency scanning in CI

### Observability Requirements ✅
- **Status**: PASS
- **Evidence**: Structured logging, metrics tracking (FR-025-029), error handling, audit trail for algorithm changes
- **Action**: Design logging strategy; implement statistics tracking; version algorithm changes

**GATE RESULT**: ✅ **ALL CHECKS PASSED** - Proceed to Phase 0 Research

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
flashcard_learning/
├── lib/
│   ├── features/              # Feature-based organization
│   │   ├── decks/            # US1: Deck management
│   │   │   ├── screens/      # deck_list_screen.dart, deck_detail_screen.dart
│   │   │   ├── widgets/      # deck_card.dart, deck_form.dart, export_dialog.dart
│   │   │   ├── providers/    # deck_provider.dart (Riverpod state)
│   │   │   └── __test__/     # Widget, unit tests
│   │   ├── cards/            # US2, US3: Card CRUD
│   │   │   ├── screens/      # card_editor_screen.dart
│   │   │   ├── widgets/      # card_form.dart, image_picker.dart, tts_button.dart
│   │   │   ├── providers/    # card_provider.dart
│   │   │   └── __test__/
│   │   ├── study/            # US4, US5, US6: Study sessions
│   │   │   ├── screens/      # study_session_screen.dart, session_summary_screen.dart
│   │   │   ├── widgets/      # flash_card.dart, rating_buttons.dart, undo_button.dart
│   │   │   ├── providers/    # study_session_provider.dart
│   │   │   └── __test__/
│   │   ├── statistics/       # US7, US8: Analytics
│   │   │   ├── screens/      # statistics_screen.dart
│   │   │   ├── widgets/      # weekly_chart.dart, deck_statistics.dart, streak_display.dart
│   │   │   ├── providers/    # statistics_provider.dart
│   │   │   └── __test__/
│   │   └── settings/         # US9: Preferences
│   │       ├── screens/      # settings_screen.dart
│   │       ├── widgets/      # voice_selector.dart, theme_picker.dart
│   │       ├── providers/    # settings_provider.dart
│   │       └── __test__/
│   ├── data/                 # Data layer
│   │   ├── models/           # Drift table definitions
│   │   │   ├── deck.dart     # Deck model with relations
│   │   │   ├── card.dart     # Card model with SRS fields
│   │   │   ├── study_session.dart
│   │   │   ├── card_review.dart
│   │   │   └── user_preferences.dart
│   │   ├── database/
│   │   │   ├── app_database.dart   # Drift database definition
│   │   │   └── app_database.g.dart # Generated code
│   │   └── repositories/     # Data access layer
│   │       ├── deck_repository.dart
│   │       ├── card_repository.dart
│   │       ├── study_repository.dart
│   │       └── statistics_repository.dart
│   ├── services/             # Business logic services
│   │   ├── srs/
│   │   │   ├── sm2_algorithm.dart      # SM-2 calculation
│   │   │   └── scheduling_service.dart
│   │   ├── storage/
│   │   │   ├── image_service.dart
│   │   │   └── backup_service.dart
│   │   ├── import_export/
│   │   │   ├── json_importer.dart
│   │   │   ├── csv_importer.dart
│   │   │   └── exporter.dart
│   │   ├── tts/
│   │   │   └── pronunciation_service.dart
│   │   └── statistics/
│   │       └── analytics_service.dart
│   ├── core/                 # Core utilities and config
│   │   ├── utils/
│   │   │   ├── validation.dart
│   │   │   ├── date_utils.dart
│   │   │   └── constants.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_typography.dart
│   │   │   └── app_theme.dart
│   │   └── router/
│   │       └── app_router.dart  # Navigation routing
│   └── main.dart             # App entry point
├── android/                  # Android native code
├── ios/                      # iOS native code
├── test/
│   ├── unit/                 # Unit tests
│   │   ├── services/
│   │   │   └── sm2_algorithm_test.dart
│   │   └── utils/
│   │       └── validation_test.dart
│   ├── widget/               # Widget tests
│   │   ├── deck_management_test.dart
│   │   ├── study_session_test.dart
│   │   └── import_export_test.dart
│   └── integration/          # Integration tests
│       └── user_stories_test.dart
├── specs/
│   └── 001-core-flashcard-mvp/
│       ├── spec.md           # Feature requirements
│       ├── plan.md           # This file
│       ├── research.md       # Technical decisions (9 decisions documented)
│       ├── data-model.md     # Database schema (5 entities with ERD)
│       ├── quickstart.md     # Developer onboarding guide
│       ├── contracts/        # API contracts
│       │   └── components.md # Screen/widget/provider interfaces
│       └── tasks.md          # (Generated by /speckit.tasks)
├── .specify/
│   ├── memory/
│   │   └── constitution.md   # Project governance (7 principles)
│   └── scripts/              # Speckit workflow automation
└── pubspec.yaml              # Dart dependencies
```

**Structure Decision**: Selected Flutter mobile application architecture. Features are organized by domain (decks, cards, study, statistics, settings) to support independent user story delivery. Data layer (models, database, repositories) is separated from presentation layer (screens, widgets, providers). This structure aligns with constitutional principle of simplicity - each feature folder contains everything needed for that user story (screens, widgets, providers, tests) enabling independent development and testing with clean separation of concerns.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

**No violations detected.** All constitutional checks passed. No additional complexity justifications required.
