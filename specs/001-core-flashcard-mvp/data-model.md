# Data Model: Core Flashcard Learning MVP

**Feature**: Core Flashcard Learning MVP  
**Date**: 2025-12-26  
**Database**: sqflite + drift (SQLite with type-safe queries)

## Entity Relationship Diagram

```
┌─────────────────┐
│  UserPreferences│
│                 │
│  - id (PK)      │
│  - ttsVoice     │
│  - autoPlay     │
│  - notifEnabled │
│  - notifTime    │
│  - theme        │
└─────────────────┘

┌─────────────────┐          ┌──────────────────────┐
│      Deck       │          │        Card          │
│                 │          │                      │
│  - id (PK)      │◄─────────│  - id (PK)           │
│  - name         │ 1      * │  - deckId (FK)       │
│  - createdAt    │          │  - frontText         │
│  - lastStudied  │          │  - backText          │
│  - cardCount    │          │  - frontImagePath    │
└─────────────────┘          │  - backImagePath     │
                             │  - createdAt         │
                             │  - lastReviewedAt    │
                             │  - nextReviewDate    │
                             │  - easeFactor        │
                             │  - reviewCount       │
                             │  - currentInterval   │
                             └──────────────────────┘
                                       △
                                       │
                                       │ *
┌─────────────────┐          ┌──────────────────────┐
│  StudySession   │          │    CardReview        │
│                 │          │                      │
│  - id (PK)      │◄─────────│  - id (PK)           │
│  - deckId (FK)  │ 1      * │  - sessionId (FK)    │
│  - startTime    │          │  - cardId (FK)       │
│  - endTime      │          │  - reviewTimestamp   │
│  - cardsReviewed│          │  - rating (1-5)      │
│  - cardsKnown   │          │  - timeSpent (sec)   │
│  - cardsForgot  │          └──────────────────────┘
└─────────────────┘
```

## Entities

### 1. Deck

**Purpose**: Collection of flashcards organized by topic/theme

**Attributes**:
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | string | PRIMARY KEY, UUID | Unique identifier |
| name | string | NOT NULL, max 100 chars | Deck name (e.g., "Animals", "IELTS Vocabulary") |
| createdAt | timestamp | NOT NULL, default NOW() | Creation timestamp |
| lastStudiedAt | timestamp | nullable | Last study session timestamp |
| cardCount | integer | NOT NULL, default 0 | Cached card count (denormalized for performance) |

**Indexes**:
- PRIMARY KEY on `id`
- INDEX on `lastStudiedAt` (for "recently studied" queries)

**Validation Rules**:
- `name`: 1-100 characters, alphanumeric + spaces + common punctuation
- `cardCount`: Auto-updated on card add/delete (trigger or application logic)

**Relationships**:
- One-to-many with Card (cascade delete: deleting deck deletes all cards)
- One-to-many with StudySession (cascade delete: deleting deck deletes sessions)

---

### 2. Card

**Purpose**: Individual flashcard with front (question) and back (answer)

**Attributes**:
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | string | PRIMARY KEY, UUID | Unique identifier |
| deckId | string | FOREIGN KEY (Deck.id), NOT NULL | Parent deck reference |
| frontText | string | NOT NULL, max 500 chars | Question/term/word on front |
| backText | string | NOT NULL, max 1000 chars | Answer/definition/translation on back |
| frontImagePath | string | nullable, max 255 chars | File path to front image (if any) |
| backImagePath | string | nullable, max 255 chars | File path to back image (if any) |
| createdAt | timestamp | NOT NULL, default NOW() | Creation timestamp |
| lastReviewedAt | timestamp | nullable | Last review timestamp |
| nextReviewDate | date | nullable | Next scheduled review date (SRS) |
| easeFactor | float | default 2.5, range 1.3-3.0 | SM-2 ease factor |
| reviewCount | integer | default 0 | Total number of reviews |
| currentInterval | integer | default 0, in days | Current SRS interval |

**Indexes**:
- PRIMARY KEY on `id`
- FOREIGN KEY on `deckId` (references Deck.id)
- INDEX on `deckId` (for deck filtering)
- INDEX on `nextReviewDate` (for due card queries)
- INDEX on `frontText` (for search functionality)

**Validation Rules**:
- `frontText`, `backText`: 1-1000 characters, supports Unicode (emoji, diacritics, CJK)
- `imagePaths`: Valid file paths or null, images must exist on filesystem
- `easeFactor`: Constrained to 1.3-3.0 per SM-2 algorithm
- `currentInterval`: Non-negative integer

**Relationships**:
- Many-to-one with Deck (parent relationship)
- One-to-many with CardReview (review history)

---

### 3. StudySession

**Purpose**: Record of a single study session for analytics/statistics

**Attributes**:
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | string | PRIMARY KEY, UUID | Unique identifier |
| deckId | string | FOREIGN KEY (Deck.id), NOT NULL | Deck studied |
| startTime | timestamp | NOT NULL | Session start timestamp |
| endTime | timestamp | nullable | Session end timestamp (null if in progress) |
| cardsReviewed | integer | default 0 | Count of cards reviewed |
| cardsKnown | integer | default 0 | Count marked "Know" or "Easy" |
| cardsForgot | integer | default 0 | Count marked "Forgot" or "Hard" |

**Indexes**:
- PRIMARY KEY on `id`
- FOREIGN KEY on `deckId` (references Deck.id)
- INDEX on `startTime` (for date range queries)
- INDEX on `deckId, startTime` (composite for deck-specific statistics)

**Validation Rules**:
- `endTime` >= `startTime` (if not null)
- `cardsReviewed` = `cardsKnown` + `cardsForgot` (consistency check)

**Relationships**:
- Many-to-one with Deck
- One-to-many with CardReview

---

### 4. CardReview

**Purpose**: Individual card review within a study session (granular tracking)

**Attributes**:
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | string | PRIMARY KEY, UUID | Unique identifier |
| sessionId | string | FOREIGN KEY (StudySession.id), NOT NULL | Parent session |
| cardId | string | FOREIGN KEY (Card.id), NOT NULL | Card reviewed |
| reviewTimestamp | timestamp | NOT NULL, default NOW() | Review timestamp |
| rating | integer | NOT NULL, range 1-5 | 1=Hard, 3=Normal, 5=Easy (SM-2 scale) |
| timeSpent | integer | default 0, in seconds | Time spent on this card |

**Indexes**:
- PRIMARY KEY on `id`
- FOREIGN KEY on `sessionId` (references StudySession.id)
- FOREIGN KEY on `cardId` (references Card.id)
- INDEX on `cardId` (for card history queries)
- INDEX on `reviewTimestamp` (for time-series analysis)

**Validation Rules**:
- `rating`: Must be 1, 3, or 5 (SM-2 convention: 1=Hard, 3=Normal, 5=Easy)
- `timeSpent`: Non-negative integer, reasonable max (~600 seconds = 10 min per card)

**Relationships**:
- Many-to-one with StudySession
- Many-to-one with Card

---

### 5. UserPreferences

**Purpose**: App settings and configuration (singleton-like entity)

**Attributes**:
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | string | PRIMARY KEY, fixed "user-prefs-singleton" | Singleton identifier |
| ttsVoice | string | default "en-US" | Selected TTS voice code |
| autoPlayEnabled | boolean | default false | Auto-play pronunciation on card flip |
| notificationEnabled | boolean | default false | Daily reminders enabled |
| notificationTime | string | default "19:00", format "HH:MM" | Daily reminder time (24h format) |
| theme | string | default "light", enum: light/dark | App theme preference |

**Indexes**:
- PRIMARY KEY on `id` (singleton)

**Validation Rules**:
- `ttsVoice`: One of supported voices (en-US, en-GB, vi-VN)
- `notificationTime`: Valid 24-hour time format (HH:MM)
- `theme`: Enum value ("light" or "dark")

**Relationships**: None (singleton entity)

---

## Derived/Computed Entities

### UserStatistics (Not Stored, Computed on Demand)

**Purpose**: Aggregated learning metrics for statistics screen

**Computed Attributes**:
| Field | Computation | Description |
|-------|-------------|-------------|
| totalCardsStudied | SUM(StudySession.cardsReviewed) | All-time cards reviewed |
| totalStudyTime | SUM(StudySession.endTime - startTime) | Total time spent studying |
| currentStreak | COUNT consecutive days with sessions | Current daily study streak |
| longestStreak | MAX consecutive days with sessions | Longest streak achieved |
| accuracyRate | SUM(cardsKnown) / SUM(cardsReviewed) * 100 | Overall accuracy percentage |
| sessionsCount | COUNT(StudySession) | Total sessions completed |
| lastStudyDate | MAX(StudySession.startTime) | Most recent study date |

**Query Patterns**:
```sql
-- Current streak calculation
SELECT COUNT(*) 
FROM (
  SELECT DATE(startTime) as studyDate
  FROM StudySession
  WHERE startTime >= DATE('now', '-30 days')
  GROUP BY DATE(startTime)
  ORDER BY studyDate DESC
) 
WHERE studyDate = DATE('now', '-' || (ROW_NUMBER() OVER () - 1) || ' days')

-- Accuracy rate
SELECT 
  (SUM(cardsKnown) * 100.0 / SUM(cardsReviewed)) as accuracyRate
FROM StudySession

-- Weekly breakdown
SELECT 
  DATE(startTime) as studyDate,
  SUM(cardsReviewed) as cardsCount
FROM StudySession
WHERE startTime >= DATE('now', '-7 days')
GROUP BY DATE(startTime)
ORDER BY studyDate
```

---

## Schema Migrations

### Migration V1: Initial Schema

```dart
// Drift schema v1
import 'package:drift/drift.dart';

// Decks table
class Decks extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastStudiedAt => dateTime().nullable()();
  IntColumn get cardCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// Cards table
class Cards extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get deckId => text().withLength(min: 36, max: 36)();
  TextColumn get frontText => text().withLength(max: 500)();
  TextColumn get backText => text().withLength(max: 1000)();
  TextColumn get frontImagePath => text().nullable()();
  TextColumn get backImagePath => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastReviewedAt => dateTime().nullable()();
  DateTimeColumn get nextReviewDate => dateTime().nullable()();
  RealColumn get easeFactor => real().withDefault(const Constant(2.5))();
  IntColumn get reviewCount => integer().withDefault(const Constant(0))();
  IntColumn get currentInterval => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Set<Column>> get uniqueKeys => [];
  
  // Indexes defined in database class
}

// StudySessions table
class StudySessions extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get deckId => text().withLength(min: 36, max: 36)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get cardsReviewed => integer().withDefault(const Constant(0))();
  IntColumn get cardsKnown => integer().withDefault(const Constant(0))();
  IntColumn get cardsForgot => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// CardReviews table
class CardReviews extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get sessionId => text().withLength(min: 36, max: 36)();
  TextColumn get cardId => text().withLength(min: 36, max: 36)();
  DateTimeColumn get reviewTimestamp => dateTime()();
  IntColumn get rating => integer().check(rating.isBetweenValues(1, 5))();
  IntColumn get timeSpent => integer()(); // seconds

  @override
  Set<Column> get primaryKey => {id};
}

// UserPreferences table (singleton)
class UserPreferences extends Table {
  TextColumn get id => text().withLength(min: 36, max: 36)();
  TextColumn get ttsVoice => text().withDefault(const Constant('en-US'))();
  BoolColumn get autoPlayEnabled => boolean().withDefault(const Constant(false))();
  BoolColumn get notificationEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get notificationTime => text().withDefault(const Constant('09:00'))();
  TextColumn get theme => text().withDefault(const Constant('light'))();

  @override
  Set<Column> get primaryKey => {id};
}

// Database class with indexes
@DriftDatabase(tables: [Decks, Cards, StudySessions, CardReviews, UserPreferences])
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      
      // Create indexes
      await customStatement(
        'CREATE INDEX idx_cards_deck_id ON cards(deck_id)',
      );
      await customStatement(
        'CREATE INDEX idx_cards_front_text ON cards(front_text)',
      );
      await customStatement(
        'CREATE INDEX idx_cards_next_review_date ON cards(next_review_date)',
      );
      await customStatement(
        'CREATE INDEX idx_study_sessions_deck_id ON study_sessions(deck_id)',
      );
      await customStatement(
        'CREATE INDEX idx_study_sessions_start_time ON study_sessions(start_time)',
      );
      await customStatement(
        'CREATE INDEX idx_card_reviews_session_id ON card_reviews(session_id)',
      );
      await customStatement(
        'CREATE INDEX idx_card_reviews_card_id ON card_reviews(card_id)',
      );
    },
  );
}
```

---

## Data Validation Layer

### Input Validation (Constitutional Requirement: FR-033, NFR-005)

**Deck Name Validation**:
```dart
class ValidationResult {
  final bool valid;
  final String? error;
  
  ValidationResult({required this.valid, this.error});
}

ValidationResult validateDeckName(String name) {
  if (name.trim().isEmpty) {
    return ValidationResult(valid: false, error: 'Deck name cannot be empty');
  }
  if (name.length > 100) {
    return ValidationResult(valid: false, error: 'Deck name must be 100 characters or less');
  }
  // Allow alphanumeric, spaces, and common punctuation
  final validPattern = RegExp(r'^[\p{L}\p{N}\s\-_.,!?()]+$', unicode: true);
  if (!validPattern.hasMatch(name)) {
    return ValidationResult(valid: false, error: 'Deck name contains invalid characters');
  }
  return ValidationResult(valid: true);
}
```

**Card Text Validation**:
```dart
ValidationResult validateCardText(String text, int maxLength) {
  if (text.trim().isEmpty) {
    return ValidationResult(valid: false, error: 'Card text cannot be empty');
  }
  if (text.length > maxLength) {
    return ValidationResult(
      valid: false, 
      error: 'Card text must be $maxLength characters or less'
    );
  }
  // Support full Unicode (emoji, diacritics, CJK) - NFR-006
  return ValidationResult(valid: true);
}
```

**Image Path Validation**:
```dart
import 'dart:io';

Future<ValidationResult> validateImagePath(String? path) async {
  if (path == null || path.isEmpty) {
    return ValidationResult(valid: true); // Optional field
  }
  
  final file = File(path);
  if (!await file.exists()) {
    return ValidationResult(valid: false, error: 'Image file does not exist');
  }
  
  final stats = await file.stat();
  if (stats.size > 5 * 1024 * 1024) { // 5MB limit (NFR-007)
    return ValidationResult(valid: false, error: 'Image file too large (max 5MB)');
  }
  
  return ValidationResult(valid: true);
}
```

---

## Performance Considerations

### Query Optimization

**Due Cards Query** (Critical Path):
```dart
// Efficient query for cards due today using drift
Future<List<Card>> getDueCards(String deckId) async {
  final now = DateTime.now();
  return (select(cards)
    ..where((c) => c.deckId.equals(deckId))
    ..where((c) => c.nextReviewDate.isSmallerOrEqualValue(now))
    ..orderBy([(c) => OrderingTerm.asc(c.nextReviewDate)]))
    .get();
}
```

**Deck List with Card Counts** (Denormalized):
```dart
// Fast deck list (no joins needed)
Future<List<Deck>> getDecks() async {
  return (select(decks)
    ..orderBy([(d) => OrderingTerm.desc(d.lastStudiedAt)]))
    .get();
  // cardCount already cached in Deck entity
}
```

### Caching Strategy

- **Deck card counts**: Denormalized in Deck entity (updated on card add/delete)
- **User preferences**: Loaded once on app start, cached in memory with Provider/Riverpod
- **Images**: cached_network_image provides LRU cache automatically

---

## Backup/Restore Strategy (Constitutional Requirement: Data Integrity)

### Backup Format
```json
{
  "version": "1.0",
  "timestamp": "2025-12-26T10:00:00Z",
  "decks": [...],
  "cards": [...],
  "study_sessions": [...],
  "card_reviews": [...],
  "user_preferences": {...}
}
```

### Backup Process
1. Export all tables to JSON
2. Include images as base64 (optional, can be skipped for smaller backups)
3. Save to device storage (Documents directory)
4. Offer share sheet for cloud backup (user-initiated)

### Restore Process
1. Parse backup JSON
2. Validate schema version compatibility
3. Clear existing database (with user confirmation)
4. Import all records in transaction (ACID compliance)
5. Restore images from base64 or file references
6. Rebuild indexes

---

## Next Steps

- ✅ Data model defined with relationships and constraints
- ⏭️ Define component contracts (screen props, provider APIs)
- ⏭️ Generate Drift table classes and database
- ⏭️ Create repository layer with validation
