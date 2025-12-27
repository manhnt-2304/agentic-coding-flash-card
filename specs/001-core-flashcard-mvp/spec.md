# Feature Specification: Core Flashcard Learning MVP

**Feature Branch**: `001-core-flashcard-mvp`  
**Created**: 2025-12-26  
**Status**: Ready for Planning  
**Input**: User description: "Core flashcard learning features with SRS algorithm, deck management, and basic statistics for vocabulary learning application targeting children and language learners"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create and Study Basic Flashcard Deck (Priority: P1)

A learner wants to create their first vocabulary deck and start studying immediately to see if the app helps them learn.

**Why this priority**: This is the absolute minimum viable product - without the ability to create cards and flip through them, there is no flashcard app. This delivers immediate value and validates the core learning loop.

**Independent Test**: A user can open the app, create a new deck called "Animals", add 5 flashcard pairs (e.g., "dog/chó", "cat/mèo"), then enter study mode and flip through all 5 cards marking each as "remembered" or "forgotten". After the session, they can see their deck still contains those 5 cards.

**Acceptance Scenarios**:

1. **Given** I am on the home screen, **When** I tap "Create New Deck", enter the name "Colors", and tap "Save", **Then** I see "Colors" deck in my deck list with 0 cards
2. **Given** I have opened the "Colors" deck, **When** I tap "Add Card", enter front "red", back "đỏ", and tap "Save", **Then** the card is added and I see "1 card" in the deck
3. **Given** my "Colors" deck has 5 cards, **When** I tap "Study", **Then** I see the front of the first card with a "Flip" button
4. **Given** I am viewing a card's front side, **When** I tap "Flip" or swipe, **Then** I see the back side with "Know" and "Forgot" buttons
5. **Given** I am viewing a card's back side, **When** I tap "Know", **Then** the card is marked as known and the next card appears (or session ends if last card)
6. **Given** I marked 3 cards as "Know" and 2 as "Forgot", **When** the study session ends, **Then** I see a summary showing "3 known, 2 to review"

---

### User Story 2 - Organize Cards into Thematic Decks (Priority: P1)

A learner wants to organize their vocabulary into separate decks by topic (Animals, Colors, IELTS) so they can focus on specific subjects.

**Why this priority**: Without deck organization, all cards become a jumbled mess. This is essential for any practical use beyond 10-20 cards. Still P1 because it's needed for real learning workflows.

**Independent Test**: A user can create 3 different decks ("Animals", "Colors", "Numbers"), add 5 unique cards to each deck, then study each deck independently and verify cards from "Animals" don't appear when studying "Colors".

**Acceptance Scenarios**:

1. **Given** I am on the home screen, **When** I create decks named "Animals", "Colors", and "Numbers", **Then** all 3 decks appear in my deck list
2. **Given** I have multiple decks, **When** I add "dog/chó" to "Animals" and "red/đỏ" to "Colors", **Then** each card only appears in its respective deck
3. **Given** I am viewing the "Animals" deck, **When** I tap "Study", **Then** only cards from "Animals" appear in the study session
4. **Given** I am viewing a deck, **When** I long-press a card and tap "Delete", **Then** the card is removed from that deck only
5. **Given** I have a deck named "Old Deck", **When** I long-press the deck, tap "Rename", enter "New Deck", and save, **Then** the deck name changes to "New Deck"

---

### User Story 3 - Import and Export Decks (Priority: P1)

A teacher wants to share vocabulary decks with students, or a learner wants to backup their cards, so they need to export and import deck files.

**Why this priority**: Data portability is a constitutional principle (Data Integrity & Privacy). Without import/export, users can't share content, backup data, or migrate between devices. This is P1 for trust and practicality.

**Independent Test**: A user can export their "Animals" deck (10 cards) as a JSON file, delete the deck from the app, then import the JSON file and verify all 10 cards are restored with correct front/back text.

**Acceptance Scenarios**:

1. **Given** I have a deck with 10 cards, **When** I tap the deck menu and select "Export as JSON", **Then** a JSON file is saved with all card data
2. **Given** I have a JSON file from another device, **When** I tap "Import Deck" and select the file, **Then** a new deck is created with all cards from the file
3. **Given** I have a deck with 10 cards, **When** I export it as CSV, **Then** I get a CSV file with columns "Front,Back" and 10 data rows
4. **Given** I have an exported JSON file, **When** I import it and there's already a deck with that name, **Then** the app asks if I want to "Replace", "Merge", or "Create New"
5. **Given** I import a corrupted JSON file, **When** the import fails, **Then** I see an error message "Invalid file format" and my existing decks are unchanged

---

### User Story 4 - Spaced Repetition Review Scheduling (Priority: P2)

A learner wants the app to automatically schedule card reviews based on how well they remember each card, so they can optimize learning efficiency.

**Why this priority**: This is what makes a flashcard app scientifically effective (Learning Science Foundation principle). However, the basic study loop (P1) must work first. This enhances learning effectiveness significantly.

**Independent Test**: A user studies 10 new cards, marks 5 as "Easy" and 5 as "Hard". The next day, only the 5 "Hard" cards are due for review. After marking them "Easy", those cards are scheduled for 3 days later while the original 5 "Easy" cards are scheduled for 7 days.

**Acceptance Scenarios**:

1. **Given** I am studying a card for the first time, **When** I mark it as "Easy", **Then** the card's next review is scheduled for 7 days later
2. **Given** I am studying a card for the first time, **When** I mark it as "Hard", **Then** the card's next review is scheduled for 1 day later
3. **Given** I have 15 cards with varying due dates, **When** I open a deck, **Then** I see "5 cards due today" (or appropriate count)
4. **Given** I am in study mode, **When** I complete all due cards, **Then** the session ends with "Great job! Come back tomorrow for 3 more cards"
5. **Given** a card is marked "Easy" consecutively 3 times, **When** I check its schedule, **Then** the interval has progressively increased (e.g., 1 day → 3 days → 7 days → 14 days)
6. **Given** a card I previously marked "Easy" is now marked "Hard", **When** I check its schedule, **Then** the interval is reduced (regression handling)

---

### User Story 5 - Self-Assessment During Review (Priority: P2)

A learner wants to tell the app how difficult each card was ("Easy", "Normal", "Hard") so the spaced repetition algorithm can adapt to their memory strength.

**Why this priority**: Required for effective SRS (pairs with User Story 4). This provides the input data for adaptive scheduling. Still P2 because it enhances the P1 basic "Know/Forgot" system.

**Independent Test**: During a study session, a user reviews 3 cards and marks them as "Easy", "Normal", and "Hard". The system schedules next reviews at 7 days, 3 days, and 1 day respectively, matching the SM-2 algorithm intervals.

**Acceptance Scenarios**:

1. **Given** I flip a card to see the answer, **When** I see the back, **Then** I have 3 buttons: "😖 Hard (1 day)", "😐 Normal (3 days)", "😄 Easy (7 days)" with intervals visible
2. **Given** I tap "😄 Easy", **When** the next card appears, **Then** the previous card is scheduled for review 7 days later
3. **Given** I tap "😖 Hard", **When** the next card appears, **Then** the previous card is scheduled for review 1 day later (or later today if already reviewed)
4. **Given** I accidentally tap "Easy" on a hard card, **When** I tap "Undo" within 3 seconds, **Then** the rating is removed and I can re-select
5. **Given** I complete a session with mixed ratings, **When** I view the session summary, **Then** I see a breakdown: "2 Easy, 3 Normal, 1 Hard"

---

### User Story 6 - Audio Pronunciation Support (Priority: P2)

A language learner wants to hear the pronunciation of vocabulary words when flipping cards, so they can learn proper pronunciation along with meaning.

**Why this priority**: Critical for language learning apps (especially for children and pronunciation practice). Enhances learning effectiveness. P2 because visual flashcards work first, audio adds significant value.

**Independent Test**: A user creates a card with front text "hello", enables auto-play, then studies the card. When the front is shown, the TTS system automatically speaks "hello" in English US accent. User can also tap a speaker icon to replay.

**Acceptance Scenarios**:

1. **Given** I am viewing a card with text "hello", **When** the card appears, **Then** I see a speaker icon 🔊 on the card
2. **Given** I am viewing a card, **When** I tap the speaker icon, **Then** I hear the text spoken in the selected language (English US by default)
3. **Given** I am in deck settings, **When** I enable "Auto-play pronunciation", **Then** cards automatically speak when flipped to front side
4. **Given** I am creating a card with front "cat", **When** I tap "Preview pronunciation", **Then** I hear how "cat" will be pronounced during study
5. **Given** I am in app settings, **When** I select voice preference, **Then** I can choose from: "English US", "English UK", "Vietnamese"
6. **Given** a card contains non-text content (only image), **When** the card is shown, **Then** no speaker icon appears (pronunciation unavailable)

---

### User Story 7 - Basic Learning Statistics (Priority: P2)

A learner wants to see their learning progress (cards studied, accuracy rate, study streak) to stay motivated and track improvement.

**Why this priority**: Statistics drive motivation and compliance with study habits (Gamification aspect). P2 because you need data from P1 study sessions first. Validates the learning effectiveness.

**Independent Test**: After studying 50 cards over 5 days with 80% accuracy, the user opens the statistics screen and sees: "50 cards studied", "80% accuracy", "5-day streak", and a simple chart showing daily study count.

**Acceptance Scenarios**:

1. **Given** I have studied 30 cards this week, **When** I open the Statistics screen, **Then** I see "30 cards studied this week"
2. **Given** I marked 20 cards as "Know" and 5 as "Forgot", **When** I check my accuracy, **Then** I see "80% accuracy rate"
3. **Given** I studied yesterday and today, **When** I view my streak, **Then** I see "🔥 2-day streak"
4. **Given** I studied 5 days this week, **When** I view weekly statistics, **Then** I see a bar chart showing study count per day
5. **Given** I have multiple decks, **When** I view deck-specific statistics, **Then** I see "Animals: 15 cards, 70% accuracy" for each deck
6. **Given** I haven't studied in 3 days, **When** I open the app, **Then** I see "Your 10-day streak ended. Start a new one today!"

---

### User Story 8 - Add Images to Flashcards (Priority: P3)

A visual learner wants to add images to flashcards (e.g., a picture of a dog for the word "dog") to improve memory retention through visual association.

**Why this priority**: Enhances learning effectiveness, especially for children and visual learners. P3 because text-only cards (P1) already deliver core value. This is an enhancement.

**Independent Test**: A user creates a card with front text "dog", uploads a dog photo, then studies the card and sees both the text "dog" and the dog image on the front side.

**Acceptance Scenarios**:

1. **Given** I am creating a new card, **When** I tap "Add Image" for the front side, **Then** I can select an image from my device gallery
2. **Given** I selected an image, **When** I save the card, **Then** the image appears on the card front during study
3. **Given** a card has both text and image, **When** I study it, **Then** the image displays above the text with proper sizing (not distorted)
4. **Given** I am editing a card with an image, **When** I tap "Remove Image", **Then** the image is deleted and the card shows text only
5. **Given** I export a deck with images, **When** I import it on another device, **Then** the images are preserved (embedded as base64 in JSON export file)

---

### User Story 9 - Daily Review Reminders (Priority: P3)

A busy learner wants the app to send daily notifications reminding them to review due cards, so they maintain consistent study habits.

**Why this priority**: Improves user retention and study consistency. P3 because users can manually check the app (P1/P2 deliver core learning). This is a habit-building enhancement.

**Independent Test**: A user enables daily reminders at 7:00 PM. The next day at 7:00 PM, they receive a notification saying "5 cards are due for review! Keep your streak going 🔥". Tapping the notification opens the app to the due cards.

**Acceptance Scenarios**:

1. **Given** I enable notifications, **When** I set reminder time to 7:00 PM, **Then** I receive a daily reminder at 7:00 PM if cards are due
2. **Given** I have 5 cards due today, **When** the reminder triggers, **Then** the notification says "5 cards ready to review!"
3. **Given** I have no cards due, **When** the scheduled reminder time arrives, **Then** no notification is sent
4. **Given** I tap the notification, **When** the app opens, **Then** I am taken directly to the study session for due cards
5. **Given** I have a 3-day streak, **When** the reminder triggers, **Then** the notification includes "Keep your 3-day streak! 🔥"

---

### Edge Cases

- **Empty deck study attempt**: When user tries to study a deck with 0 cards, show message "This deck is empty. Add cards to start studying."
- **Network-less operation**: All core features (create, study, basic SRS) work completely offline. Import/export work with local files only (no cloud sync in MVP).
- **Very large decks**: System handles decks with 1000+ cards without performance degradation (<2 seconds to load deck per constitution).
- **Duplicate cards**: When importing, if a card with identical front/back text exists, ask user: "Skip duplicates" or "Import anyway"
- **Interrupted study session**: If user exits app mid-session, save progress (cards already reviewed keep their ratings). Allow "Resume" or "Start Over" next time.
- **Corrupted data**: If deck data file is corrupted on load, show error and offer "Restore from backup" if backup exists, or "Delete corrupted deck"
- **TTS unavailable**: If device doesn't support selected language TTS, show message "Pronunciation unavailable for this language. Please select another voice in settings."
- **Image too large**: If user selects image >5MB, compress automatically or show warning "Image too large (XMB). Please select smaller image or crop."
- **Special characters**: Support all Unicode characters in card text (emoji, Vietnamese diacritics, Chinese characters, etc.)
- **Review scheduling conflicts**: If user marks a card differently than algorithm suggests (e.g., marks "Easy" when algorithm suggests "Hard"), respect user input (user knows their memory best).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST allow users to create named decks (collections of flashcards)
- **FR-002**: System MUST allow users to add flashcards with front (question) and back (answer) text to decks
- **FR-003**: System MUST allow users to edit existing flashcard content (front and back text)
- **FR-004**: System MUST allow users to delete flashcards from decks
- **FR-005**: System MUST allow users to delete entire decks
- **FR-006**: System MUST allow users to rename decks
- **FR-007**: System MUST provide a study mode that displays one card at a time
- **FR-008**: System MUST allow users to flip cards to reveal the answer side
- **FR-009**: System MUST provide two study modes: "Basic Study" (Know/Forgot buttons) and "Smart Study" (Easy/Normal/Hard buttons with SRS scheduling)
- **FR-009a**: Users MUST be able to explicitly select study mode from deck menu before starting a session
- **FR-010**: System MUST allow users to rate cards as "Easy", "Normal", or "Hard" in Smart Study mode with visible scheduling intervals
- **FR-011**: System MUST implement a spaced repetition algorithm (SM-2 or equivalent) that schedules card reviews based on user ratings
- **FR-012**: System MUST track next review date for each card
- **FR-013**: System MUST show count of cards due for review today in each deck
- **FR-014**: System MUST allow users to export decks in JSON format with images embedded as base64-encoded data
- **FR-015**: System MUST allow users to export decks in CSV format (text only, no images)
- **FR-016**: System MUST allow users to import decks from JSON files with embedded images
- **FR-017**: System MUST allow users to import decks from CSV files with columns: Front,Back (text only)
- **FR-018**: System MUST handle import conflicts (duplicate deck names) by offering Replace/Merge/Create New options
- **FR-019**: System MUST provide text-to-speech (TTS) pronunciation for card text
- **FR-020**: System MUST support voice selection: English US, English UK, Vietnamese (minimum)
- **FR-021**: System MUST provide manual pronunciation playback via speaker icon
- **FR-022**: System MUST provide optional auto-play pronunciation when cards are displayed
- **FR-023**: System MUST allow users to attach image files to card front and/or back
- **FR-024**: System MUST display images on cards during study mode
- **FR-025**: System MUST track total cards studied per deck
- **FR-026**: System MUST track accuracy rate (percentage of cards marked as "Know" or "Easy")
- **FR-027**: System MUST track consecutive days studied (streak counter)
- **FR-028**: System MUST display weekly study statistics with daily breakdown
- **FR-029**: System MUST provide deck-specific statistics (cards studied, accuracy per deck)
- **FR-030**: System MUST send daily push notifications when cards are due (if enabled by user)
- **FR-031**: System MUST allow users to configure notification time preference
- **FR-032**: System MUST persist all deck and card data locally on device
- **FR-033**: System MUST validate all user input (deck names, card text) to prevent data corruption
- **FR-034**: System MUST prevent data loss during study session interruptions (save progress on each card rating)
- **FR-035**: System MUST provide undo functionality for accidental card ratings (within 3 seconds)
- **FR-036**: System MUST handle decks with 1000+ cards without performance degradation

### Key Entities

- **Deck**: A named collection of flashcards organized by topic/theme
  - Attributes: Unique ID, Name, Creation date, Card count, Last studied date
  - Relations: Contains multiple Cards

- **Card**: A flashcard with front (question) and back (answer) content
  - Attributes: Unique ID, Front text, Back text, Front image (optional), Back image (optional), Creation date, Last reviewed date, Next review date, Ease factor (for SRS), Review count, Current interval (days)
  - Relations: Belongs to one Deck

- **Study Session**: A record of a learning session
  - Attributes: Session ID, Deck ID, Start time, End time, Cards reviewed count, Cards marked "Know"/"Easy", Cards marked "Forgot"/"Hard"
  - Relations: References one Deck, records multiple Card Reviews

- **Card Review**: A record of a single card review within a session
  - Attributes: Card ID, Session ID, Review timestamp, Rating ("Know"/"Forgot" or "Easy"/"Normal"/"Hard"), Time spent (seconds)
  - Relations: References one Card and one Study Session

- **User Statistics**: Aggregated learning metrics
  - Attributes: Total cards studied, Total study time, Current streak (days), Longest streak, Accuracy rate (percentage), Study sessions count, Last study date
  - Relations: Computed from Study Sessions and Card Reviews

- **User Preferences**: App settings and configuration
  - Attributes: TTS voice selection, Auto-play pronunciation enabled, Notification enabled, Notification time, Theme preference
  - Relations: One per user/installation

### Non-Functional Requirements

- **NFR-001**: Card flip response time MUST be <100ms (p95) per constitution performance baseline
- **NFR-002**: Deck loading MUST complete in <2 seconds for 1000 cards per constitution
- **NFR-003**: Progress saves MUST complete within 500ms of card rating per constitution
- **NFR-004**: Memory usage MUST stay <200MB for typical usage (1000 active cards) per constitution
- **NFR-005**: All user input fields MUST sanitize input to prevent data corruption
- **NFR-006**: Card text MUST support full Unicode (emoji, diacritics, CJK characters)
- **NFR-007**: Images MUST be compressed if >5MB to maintain performance
- **NFR-008**: All core features MUST work completely offline (no internet dependency for MVP)
- **NFR-009**: App MUST provide error messages in clear, actionable language (per Accessibility First principle)
- **NFR-010**: All interactive elements MUST support keyboard navigation (per Accessibility First principle)
- **NFR-011**: TTS failure MUST degrade gracefully (show error, allow continuing without audio)
- **NFR-012**: Corrupted data MUST be detected and handled with recovery options (restore backup or delete)

## Success Criteria *(mandatory)*

1. **Core Learning Loop**: A new user can create a deck, add 10 cards, and complete a full study session in under 5 minutes
2. **Learning Effectiveness**: Users can demonstrate vocabulary retention improvement (measured by increasing accuracy rate over 7 days of use)
3. **Data Reliability**: Zero data loss incidents during study sessions, even with app interruptions (force close, low battery, incoming calls)
4. **SRS Accuracy**: The spaced repetition algorithm correctly schedules cards based on ratings (Easy → 7 days, Normal → 3 days, Hard → 1 day for new cards)
5. **Content Portability**: Users can export and re-import a 100-card deck with 100% data fidelity (all text and metadata preserved)
6. **Performance Target**: Study sessions remain responsive (<100ms card flip) even with 1000-card decks
7. **User Engagement**: 60% of users complete at least one study session per day for 7 consecutive days (streak metric)
8. **Pronunciation Quality**: TTS pronunciation is clear and understandable for 90% of common vocabulary words (validated through user testing)
9. **Accessibility Baseline**: Users can complete all core tasks (create deck, add cards, study) using keyboard only, without mouse/touch
10. **Offline Capability**: All P1 features work with zero network connectivity

## Assumptions & Dependencies *(optional)*

### Assumptions

1. **Platform**: Targeting mobile devices (iOS/Android) as primary platform, though architecture should support web deployment later
2. **Storage**: Device has sufficient storage for user-generated content (assumes max 1GB for 10,000 cards with images)
3. **TTS Availability**: Device OS provides built-in TTS engines for English and Vietnamese (iOS: AVSpeechSynthesizer, Android: TextToSpeech API)
4. **User Language**: UI will initially support English and Vietnamese (based on user requirements mentioning Vietnamese examples)
5. **Internet**: No internet required for core functionality (offline-first design), though future features may add cloud sync
6. **User Literacy**: Target users can read and create basic text content (appropriate for age 6+ with parent assistance)
7. **Image Format**: Standard formats supported (JPEG, PNG, GIF) with auto-compression for large files
8. **Study Behavior**: Users will self-report card difficulty honestly (algorithm depends on accurate user feedback)
9. **Time Zone**: All scheduling calculations use device local time (no multi-timezone complexity in MVP)
10. **Authentication**: No user accounts or authentication in MVP (single-user device model, data stored locally only)

### Dependencies

1. **TTS Engine**: Device OS must provide TTS capability for pronunciation feature (FR-019 to FR-022)
2. **File System Access**: App needs permission to read/write files for import/export (FR-014 to FR-017)
3. **Push Notifications**: OS notification framework required for daily reminders (FR-030 to FR-031)
4. **Local Database**: Need embedded database solution (e.g., SQLite, Realm, CoreData) for ACID-compliant data persistence per constitution (Principle III)
5. **Image Library**: Need image handling library for compression, display, and storage optimization
6. **SRS Algorithm**: Implementation of SM-2 (or equivalent) algorithm - can use open-source libraries or implement from specification

### Out of Scope for MVP

1. **Cloud Sync**: No server-side storage or multi-device synchronization (local-only in MVP)
2. **User Accounts**: No authentication, user profiles, or social features
3. **AI Card Generation**: No automatic flashcard creation from documents/text (manual creation only)
4. **Gamification**: No badges, levels, or points system (basic statistics only per FR-025 to FR-029)
5. **Parent Controls**: No parental dashboard or time limits (mentioned in user requirements but deferred to post-MVP)
6. **Collaborative Decks**: No sharing or co-editing decks with other users (export/import is one-way only)
7. **Spaced Repetition Customization**: Using fixed algorithm parameters (no user-adjustable SM-2 settings)
8. **Advanced Media**: No video or audio recording (TTS only, no custom audio files)
9. **Handwriting Input**: Text input only (no drawing or handwriting recognition)
10. **Deck Templates**: No pre-made template decks (users create from scratch or import)

## Technical Constraints *(optional)*

1. **Mobile-First Design**: UI must be optimized for mobile screens (4-7 inch displays), touch gestures primary interaction
2. **Storage Limit**: Must handle gracefully when device storage is low (warn user before import, compress images aggressively)
3. **Battery Efficiency**: TTS and notification features must not cause significant battery drain (<5% per hour of active use)
4. **Cold Start Time**: App must launch to home screen in <3 seconds on mid-range devices (2-year-old models)
5. **Data Backup**: While no cloud sync, must provide local backup/restore to prevent total data loss
6. **Algorithm Consistency**: SRS scheduling must be deterministic (same ratings always produce same intervals) for predictability

## Design Decisions *(resolved)*

### 1. Image Storage Strategy
**Decision**: Images embedded as base64 in JSON export files  
**Rationale**: Provides self-contained, shareable files ideal for teachers distributing decks to students. Users accept larger file sizes for the convenience of single-file sharing. CSV exports remain text-only for spreadsheet compatibility.

### 2. Study Mode Selection
**Decision**: Two explicit study modes - "Basic Study" and "Smart Study (SRS)"  
**Rationale**: Clear user control and distinction between simple learning (P1) and advanced spaced repetition (P2). Users choose mode from deck menu before starting session. Supports both novice users (Basic) and power users (Smart Study) with explicit opt-in to complexity.

### 3. CSV Import Format
**Decision**: Minimal 2-column format (Front,Back) only  
**Rationale**: Maintains Excel compatibility and simplicity. Supports quick deck creation and editing in spreadsheet tools. Users needing full data fidelity (images, scheduling metadata) use JSON format instead. Clear separation: CSV for text content, JSON for complete backups.
