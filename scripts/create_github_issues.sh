#!/bin/bash

# Script to create GitHub issues from tasks.md
# Prerequisites: Install GitHub CLI (gh) and authenticate with `gh auth login`

REPO="owner/flashcard_learning"  # Update with your GitHub username/repo

echo "Creating GitHub issues from tasks.md..."

# Phase 0: Project Setup & Foundation
gh issue create \
  --title "Task 0.1: Project Initialization 🏗️" \
  --body "**Description**: Set up Flutter project structure and base dependencies

**Acceptance Criteria**:
- Flutter project created with feature-based folder structure
- pubspec.yaml configured with all required dependencies  
- Git repository initialized with .gitignore for Dart/Flutter
- README.md with project overview and setup instructions

**Dependencies**: None

**Estimated Effort**: 1 hour

**Status**: ✅ Completed" \
  --label "setup,phase-0" \
  --milestone "Phase 0"

gh issue create \
  --title "Task 0.2: Database Schema Setup 💾🧪" \
  --body "**Description**: Define Drift database schema with tables for decks, cards, sessions, reviews, and preferences

**Acceptance Criteria**:
- Drift table definitions match data-model.md schema
- Database migration script creates all tables with proper indexes
- Database initialization test passes
- Foreign key constraints enforced

**Dependencies**: Task 0.1

**Estimated Effort**: 2 hours

**Status**: ✅ Completed" \
  --label "data-layer,test,phase-0" \
  --milestone "Phase 0"

gh issue create \
  --title "Task 0.3: SM-2 Algorithm Service 🔧🧪" \
  --body "**Description**: Implement SM-2 spaced repetition algorithm with unit tests

**Acceptance Criteria**:
- Algorithm matches SM-2 specification from research.md
- All rating scenarios tested (1=Hard, 3=Normal, 5=Easy)
- Edge cases handled (min/max ease factor, first review)
- Performance: <1ms per calculation

**Dependencies**: Task 0.1

**Estimated Effort**: 2 hours

**Status**: ✅ Completed" \
  --label "service,test,phase-0" \
  --milestone "Phase 0"

# Phase 1: User Story 1
gh issue create \
  --title "Task 1.1: Deck Repository Implementation 💾🧪" \
  --body "**Description**: Implement deck CRUD operations with Drift queries

**Acceptance Criteria**:
- Repository implements DeckRepository interface from contracts
- All CRUD operations tested
- Stream-based deck observation works
- Card count computed correctly

**Dependencies**: Task 0.2

**Estimated Effort**: 3 hours" \
  --label "data-layer,test,user-story-1" \
  --milestone "US1 - Basic Study"

gh issue create \
  --title "Task 1.2: Card Repository Implementation 💾🧪" \
  --body "**Description**: Implement card CRUD operations with SRS field management

**Acceptance Criteria**:
- Repository implements CardRepository interface from contracts
- Card creation with validation
- Get due cards query works correctly
- Cascade delete when deck deleted

**Dependencies**: Task 0.2, Task 1.1

**Estimated Effort**: 3 hours" \
  --label "data-layer,test,user-story-1" \
  --milestone "US1 - Basic Study"

gh issue create \
  --title "Task 1.3: DeckList Screen UI 🎨🧪" \
  --body "**Description**: Build deck list screen with FAB to create decks

**Acceptance Criteria**:
- Screen matches contract from contracts/components.md
- Shows deck list with card counts
- FAB opens create deck dialog
- Long-press shows action menu
- Widget tests pass

**Dependencies**: Task 1.1

**Estimated Effort**: 4 hours" \
  --label "ui,test,user-story-1" \
  --milestone "US1 - Basic Study"

gh issue create \
  --title "Task 1.4: FlashCard Widget 🎨🧪" \
  --body "**Description**: Build animated flashcard widget with flip animation

**Acceptance Criteria**:
- Card flips on tap with smooth animation
- Shows front/back content
- Supports image display
- Widget tests pass

**Dependencies**: None

**Estimated Effort**: 3 hours" \
  --label "ui,test,user-story-1" \
  --milestone "US1 - Basic Study"

gh issue create \
  --title "Task 1.5: RatingButtons Widget 🎨🧪" \
  --body "**Description**: Build rating buttons for Basic and Smart modes

**Acceptance Criteria**:
- Basic mode: Know/Forgot buttons
- Smart mode: Hard/Normal/Easy buttons (3 options)
- Clear visual feedback
- Widget tests pass

**Dependencies**: None

**Estimated Effort**: 2 hours" \
  --label "ui,test,user-story-1" \
  --milestone "US1 - Basic Study"

gh issue create \
  --title "Task 1.6: Study Session Screen 🎨🧪" \
  --body "**Description**: Build study session screen with card progression

**Acceptance Criteria**:
- Shows current card position (e.g., 3/10)
- Integrates FlashCard and RatingButtons widgets
- Handles card rating and progression
- Shows completion when finished
- State management with Riverpod

**Dependencies**: Task 1.2, Task 1.4, Task 1.5

**Estimated Effort**: 4 hours" \
  --label "ui,test,user-story-1" \
  --milestone "US1 - Basic Study"

gh issue create \
  --title "Task 1.7: Session Summary Screen 🎨🧪" \
  --body "**Description**: Build session summary screen with statistics

**Acceptance Criteria**:
- Shows cards reviewed, known, forgot counts
- Displays session duration
- Button to return to deck list
- Widget tests pass

**Dependencies**: Task 1.6

**Estimated Effort**: 2 hours" \
  --label "ui,test,user-story-1" \
  --milestone "US1 - Basic Study"

gh issue create \
  --title "Task 1.8: Integration Test - Complete Study Flow 🔗" \
  --body "**Description**: End-to-end integration test for complete study flow

**Acceptance Criteria**:
- Test creates deck → adds cards → starts study → rates cards → views summary
- All screens transition correctly
- Data persists correctly
- Integration test passes

**Dependencies**: Task 1.7

**Estimated Effort**: 2 hours" \
  --label "integration-test,user-story-1" \
  --milestone "US1 - Basic Study"

echo "✅ Created issues for Phase 0 and User Story 1"
echo "📝 Note: Update REPO variable with your GitHub username/repo"
echo "📝 Note: You need to create milestones 'Phase 0' and 'US1 - Basic Study' on GitHub first"
