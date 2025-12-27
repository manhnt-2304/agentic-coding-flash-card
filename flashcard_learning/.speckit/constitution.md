# Speckit Constitution

This document defines the core principles and guidelines for organizing and implementing tasks in this project.

## 1. Task Organization Principles

### 1.1 User Flow First (Navigation-Driven Development)
**Problem**: Tasks organized by technical layers may not align with natural user navigation flows.

**Solution**: When planning task sequences, prioritize **user navigation flow** over technical architecture layers.

**Guideline**:
- ✅ **DO**: Ensure screens have natural entry points before implementing their functionality
- ✅ **DO**: Create navigation paths that match user mental models
- ❌ **DON'T**: Implement complex screens without a way for users to reach them naturally
- ❌ **DON'T**: Leave demo routes as the only way to access core features

**Example from User Story 1 & 2**:
```
❌ WRONG ORDER (Architecture-first):
  1. DeckListScreen
  2. StudySessionScreen (no natural way to reach it!)
  3. DeckDetailScreen (added later)
  
✅ CORRECT ORDER (Navigation-first):
  1. DeckListScreen
  2. DeckDetailScreen (navigation: tap deck)
  3. StudySessionScreen (navigation: tap "Study" button)
```

### 1.2 Vertical Slice Over Horizontal Layers
**Principle**: Complete one user flow end-to-end before moving to the next.

**Guideline**:
- Build a **minimal navigable path** through the app first
- Each user story should result in a **usable feature**, not just technical components
- Avoid accumulating unconnected screens that require "demo" routes

**Example**:
```
✅ GOOD: DeckList → DeckDetail → Study → Summary (complete flow)
❌ BAD: All repositories → All screens → Wire up navigation later
```

### 1.3 Navigation Route Planning
**Guideline**: When creating tasks for a user story, explicitly plan:
1. **Entry Point**: How does the user reach this screen?
2. **Navigation Path**: What screens lead to/from this screen?
3. **Demo Routes**: Only for showcasing isolated components, not core features

**Template for Task Planning**:
```markdown
## Task X.Y: Screen Name

### Navigation
- **Entry Point**: [Screen/Action that navigates here]
- **Exit Points**: [Screens this navigates to]
- **Route Type**: 
  - [ ] Named route (e.g., '/deck-detail')
  - [ ] Generated route (e.g., onGenerateRoute with arguments)
  - [ ] Direct navigation (e.g., Navigator.push)
  - [ ] Demo only (temporary, to be replaced)

### Prerequisites
- [ ] Previous screen exists (entry point)
- [ ] Data models available (e.g., deckId parameter)
- [ ] Repositories ready (if needed for data fetching)
```

## 2. Task Dependencies

### 2.1 Explicit Prerequisites
Every task MUST list its prerequisites clearly:
```markdown
**Prerequisites**:
- Task X.Y (reason: provides data model)
- Task X.Z (reason: navigation entry point)
```

### 2.2 Circular Dependency Detection
If Task A needs Task B, but Task B also needs Task A:
- **Solution 1**: Split one task into smaller parts (A1, A2)
- **Solution 2**: Create a minimal stub/interface first
- **Document** the decision in task notes

## 3. Demo vs Production Code

### 3.1 Demo Routes Policy
**Purpose**: Demo routes are for **isolated component testing during development**, NOT for core user flows.

**Guidelines**:
- ✅ **Acceptable Demo Routes**:
  - UI component showcases (e.g., `/ui-showcase`)
  - Widget testing screens (e.g., `/flash-card-demo`)
  - Developer tools (e.g., `/debug-settings`)

- ❌ **Unacceptable Demo Routes**:
  - Core features with no other access path (e.g., `/study-session-demo` as only way to study)
  - Screens that should be part of normal navigation

**Refactoring Rule**: 
- When a demo route becomes a core feature, **refactor to real navigation** within 2 sprints
- Add a TODO comment: `// TODO: Remove demo route after navigation implemented in Task X.Y`

### 3.2 Demo Route Naming Convention
```dart
// ✅ GOOD: Clearly marked as demo
'/flash-card-demo'
'/ui-showcase'
'/rating-buttons-demo'

// ❌ BAD: Looks like production route
'/study-session'  // (but only accessible via demo route)
'/cards'          // (no navigation from app)
```

## 4. Integration Testing Strategy

### 4.1 Test Navigation Flows
Integration tests MUST include:
- Navigation path validation (can user reach the feature?)
- End-to-end user journey (not just isolated widgets)
- Edge case: What if navigation fails?

**Example**:
```dart
// ✅ GOOD: Tests complete navigation flow
test('User can study deck from list', () {
  // 1. Tap deck in list
  // 2. Navigate to deck detail
  // 3. Tap study button
  // 4. Complete study session
  // 5. View summary
});

// ❌ BAD: Tests only data layer
test('Study session records review', () {
  // Only tests repository methods
});
```

### 4.2 Navigation Smoke Tests
For each user story, add a **smoke test** that validates:
```dart
test('All screens are reachable from home', () {
  // Start at home screen
  // Verify each feature is accessible via navigation
  // No demo routes required
});
```

## 5. Spec Review Checklist

Before marking a spec as "ready to implement", verify:

- [ ] **Navigation Path**: Every screen has a clear entry point
- [ ] **Task Order**: Follows user flow, not just technical layers
- [ ] **Dependencies**: All prerequisites listed and achievable
- [ ] **Demo Policy**: No core features rely solely on demo routes
- [ ] **Integration Test**: Includes navigation flow validation
- [ ] **Vertical Slice**: Each user story results in a usable feature

## 6. Lessons Learned

### From User Story 1 & 2:
**Issue**: User Story 1 implemented StudySessionScreen before DeckDetailScreen, leaving no natural navigation path. Users could only access study via demo route.

**Impact**:
- Confusing user experience (where's the study button?)
- Extra refactoring needed later
- Integration test didn't catch navigation gap

**Prevention**:
1. Add **Task 2.1 (DeckDetailScreen)** earlier in sequence
2. Require navigation smoke test in integration tests
3. Flag tasks with "demo route only" access as incomplete

**Corrective Action Taken**:
- Prioritize Task 2.1 immediately after User Story 1
- Update constitution.md with these guidelines
- Add navigation checklist to task template

---

## Meta: Updating This Constitution

This constitution should be updated when:
- A new pattern/anti-pattern is discovered
- A task ordering issue causes rework
- A best practice emerges from code reviews

**Process**:
1. Document the issue in "Lessons Learned"
2. Add preventive guideline in relevant section
3. Update task templates if needed
4. Notify team in standup/retro

---

**Version**: 1.0  
**Last Updated**: 2025-12-27  
**Next Review**: After User Story 3 completion
