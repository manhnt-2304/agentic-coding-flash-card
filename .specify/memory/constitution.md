<!--
Sync Impact Report:
- Version change: 1.0.0 → 1.1.0 (MINOR: Added navigation standards)
- Date: 2025-12-27
- Changes:
  ✅ Added "Task Organization & Navigation Standards" section
  ✅ Navigation-first task ordering principle
  ✅ Vertical slice delivery guidelines
  ✅ Task planning template with navigation analysis
  ✅ Integration testing for navigation flows
  ✅ Updated Review Requirements (added navigation check)
  ✅ Added Spec Review Checklist
  ✅ Added Lessons Learned section (User Story 1&2 navigation gap)
- Impact:
  - All future specs must document navigation paths
  - Task ordering must follow user flow, not technical layers
  - Integration tests must validate navigation reachability
  - Demo routes only acceptable for showcases, not core features
- Templates affected:
  ⚠️ spec-template.md - should add navigation analysis section
  ⚠️ tasks-template.md - should add entry point documentation
  ⚠️ plan-template.md - should include navigation flow diagrams
- Follow-up TODOs:
  1. Update template files with navigation requirements
  2. Add navigation smoke test template
  3. Create navigation flow diagram examples
-->

# Flashcard Learning Application Constitution

## Core Principles

### I. User-First Testing (NON-NEGOTIABLE)

Every feature MUST be specified through prioritized, independently testable user stories before any implementation begins. Each user story represents a complete vertical slice of functionality that:

- Can be developed, tested, and deployed independently
- Delivers tangible value to end users on its own
- Has clear acceptance criteria in Given-When-Then format
- Is prioritized (P1, P2, P3...) by user value, not technical dependency

**Rationale**: Educational applications succeed when they solve real learning problems incrementally. Breaking features into independent stories ensures we can deliver MVPs quickly and validate learning effectiveness early.

### II. Test-First Development (NON-NEGOTIABLE)

Development follows strict Red-Green-Refactor TDD:

1. Write tests based on acceptance criteria
2. User/stakeholder approves tests represent requirements correctly
3. Verify tests FAIL (Red)
4. Implement minimal code to pass (Green)
5. Refactor while keeping tests green

**Test Types Required**:
- **Contract tests**: API/interface boundaries (only if feature has external contracts)
- **Integration tests**: User journey flows (required for all user-facing features)
- **Unit tests**: Business logic and algorithms (required for complex logic)

**Rationale**: Learning applications handle user data and progress tracking. Test-first development prevents data loss, progress corruption, and broken learning flows that erode user trust.

### III. Data Integrity & Privacy

All user data (flashcards, learning progress, preferences) MUST be:

- **Validated**: Input validation at all entry points
- **Persisted reliably**: ACID-compliant storage for progress data
- **Versioned**: Schema migrations for backwards compatibility
- **Protected**: No user data in logs; sensitive data encrypted at rest
- **Portable**: Users can export their complete data in standard formats (JSON/CSV)

**Rationale**: Learning is a long-term investment. Users must trust that their progress is safe, private, and not locked into our system.

### IV. Learning Science Foundation

Flashcard features MUST be based on validated learning science principles:

- **Spaced Repetition**: Implement proven algorithms (SM-2, Leitner, or equivalent)
- **Active Recall**: Present questions before answers
- **Immediate Feedback**: Show correctness and explanations immediately
- **Progress Tracking**: Visualize learning curves and retention rates
- **Adaptive Difficulty**: Adjust review intervals based on performance

Document the learning science rationale for each algorithm choice in specs.

**Rationale**: Educational software is only valuable if it actually improves learning outcomes. Features must be grounded in cognitive science research, not guesses.

### V. Progressive Enhancement

Build features in priority order (P1 → P2 → P3), where each increment is shippable:

- **P1 (MVP)**: Core learning loop must work end-to-end
- **P2**: Enhancements that significantly improve learning effectiveness
- **P3**: Nice-to-have features that increase engagement

Lower-priority features MUST NOT block higher-priority delivery.

**Rationale**: Ship working flashcard functionality early; validate learning effectiveness with real users; iterate based on actual learning outcomes.

### VI. Accessibility First

All interfaces (CLI, web, mobile) MUST be accessible:

- **Keyboard navigation**: Full functionality without mouse/touch
- **Screen readers**: Semantic HTML, ARIA labels, meaningful alt text
- **Visual design**: WCAG 2.1 AA contrast ratios minimum
- **Error messages**: Clear, actionable, human-readable
- **Internationalization**: UTF-8 support, localizable strings

**Rationale**: Learning should be available to everyone. Accessibility is not optional; it's a fundamental requirement for educational tools.

### VII. Simplicity & Maintainability

Favor simple, explicit implementations over clever abstractions:

- **YAGNI**: Build only what current user stories require
- **Clear naming**: Variables, functions, and files use domain language (deck, card, review, retention)
- **Minimal dependencies**: Justify each external library; prefer standard libraries
- **Documentation**: Code comments explain WHY, not WHAT; README covers setup in <5 minutes

**Rationale**: Educational software evolves as we learn about learning. Keeping the codebase simple ensures we can adapt quickly when evidence suggests better approaches.

## Quality Standards

### Performance Baselines

- **Review latency**: Card flip response <100ms (p95)
- **Session start**: Deck loads in <2 seconds for 1000 cards
- **Data sync**: Progress saves within 500ms of review completion
- **Memory usage**: <200MB for typical usage (1000 active cards)

### Security Requirements

- **Authentication**: Required for all user-specific data access
- **Authorization**: Users only access their own decks/progress
- **Input sanitization**: All user-generated content (card text, deck names) sanitized to prevent XSS
- **Dependency scanning**: Weekly automated checks for vulnerable dependencies

### Observability Requirements

- **Logging**: Structured logs (JSON) for all user actions (anonymized)
- **Metrics**: Track review count, accuracy rates, session duration
- **Error tracking**: All exceptions logged with context (no sensitive data)
- **Audit trail**: Learning algorithm changes versioned and documented

### Task Organization & Navigation Standards

#### Navigation-First Task Ordering

Tasks MUST be ordered by **user navigation flow**, not technical architecture layers:

- ✅ **DO**: Ensure screens have natural entry points before implementing their functionality
- ✅ **DO**: Create navigation paths that match user mental models
- ❌ **DON'T**: Implement complex screens without a way for users to reach them naturally
- ❌ **DON'T**: Leave demo routes as the only way to access core features

**Example**:
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

**Rationale**: Users navigate by intent, not by technical layers. Implementing screens in navigation order ensures each feature is immediately usable and testable in context.

#### Vertical Slice Delivery

Complete one user flow end-to-end before moving to the next:

- Build a **minimal navigable path** through the app first
- Each user story should result in a **usable feature**, not just technical components
- Avoid accumulating unconnected screens that require "demo" routes

**Example**:
```
✅ GOOD: DeckList → DeckDetail → Study → Summary (complete flow)
❌ BAD: All repositories → All screens → Wire up navigation later
```

#### Task Planning Template

When creating tasks for a user story, explicitly document:

**Navigation Analysis**:
- **Entry Point**: How does the user reach this screen?
- **Exit Points**: What screens does this navigate to?
- **Route Type**: Named route / Generated route / Direct navigation / Demo only

**Prerequisites**:
- Previous screen exists (entry point)
- Data models available (e.g., deckId parameter)
- Repositories ready (if needed for data fetching)

**Demo Route Policy**:
- ✅ **Acceptable**: UI showcases, component testing, developer tools
- ❌ **Unacceptable**: Core features with no other access path
- **Refactoring Rule**: Convert demo routes to real navigation within 2 sprints

#### Integration Testing for Navigation

Integration tests MUST validate:
- **Navigation paths**: Can user reach the feature from home screen?
- **End-to-end journeys**: Complete user flows, not just isolated components
- **Navigation smoke tests**: All core features reachable without demo routes

**Example**:
```dart
// ✅ GOOD: Tests complete navigation flow
test('User can study deck from list', () {
  // 1. Tap deck in list → 2. Navigate to deck detail
  // 3. Tap study button → 4. Complete study session → 5. View summary
});

// ❌ BAD: Tests only data layer
test('Study session records review', () {
  // Only tests repository methods, no navigation validation
});
```

## Development Workflow

### Feature Development Lifecycle

1. **Specify** (`/speckit.specify`): Define user stories with priorities and acceptance criteria
2. **Plan** (`/speckit.plan`): Design architecture, data models, and technical approach
3. **Tasks** (`/speckit.tasks`): Break down into implementable, testable tasks grouped by user story
4. **Analyze** (`/speckit.analyze`): Validate consistency across spec, plan, and tasks
5. **Implement** (`/speckit.implement`): Execute tasks in priority order with TDD

### Branch Strategy

- **Feature branches**: `###-feature-name` format (e.g., `001-spaced-repetition-algorithm`)
- **One branch per feature**: Complete spec/plan/tasks/implementation cycle
- **Merge criteria**: All tests pass, constitution principles verified, peer reviewed

### Review Requirements

All code changes MUST pass:
- **Automated tests**: 100% of tests passing (CI/CD enforced)
- **Constitution check**: Reviewer verifies compliance with all 7 core principles
- **Accessibility check**: Keyboard navigation and screen reader compatibility verified
- **Data safety check**: No risk of data loss or progress corruption
- **Navigation check**: Feature is reachable via natural user flow (no demo-only access)

### Spec Review Checklist

Before marking a spec as "ready to implement", verify:

- [ ] **Navigation Path**: Every screen has a clear, natural entry point
- [ ] **Task Order**: Follows user flow, not just technical layers
- [ ] **Dependencies**: All prerequisites listed and achievable
- [ ] **Demo Policy**: No core features rely solely on demo routes
- [ ] **Integration Test**: Includes navigation flow validation
- [ ] **Vertical Slice**: Each user story results in a usable, navigable feature

## Governance

### Authority Hierarchy

1. **Constitution principles**: Non-negotiable unless constitution is formally amended
2. **Specification documents**: Define feature requirements and acceptance criteria
3. **Implementation plans**: Technical decisions within constitutional constraints
4. **Code review feedback**: Must align with constitution and specs

### Amendment Process

Constitution changes require:
- **Proposal**: Documented reason for change with impact analysis
- **Version bump**: Semantic versioning (MAJOR for breaking changes, MINOR for additions, PATCH for clarifications)
- **Template sync**: All dependent templates updated before ratification
- **Ratification date**: Recorded in version line below

### Compliance Verification

- **Pre-implementation**: `/speckit.analyze` must report zero CRITICAL issues
- **During development**: Tests verify acceptance criteria before code written
- **Pre-merge**: Reviewer checks constitution compliance explicitly
- **Post-deployment**: Learning metrics monitored to validate effectiveness

## Lessons Learned

### User Story 1 & 2: Navigation Gap (2025-12-27)

**Issue**: User Story 1 implemented `StudySessionScreen` before `DeckDetailScreen`, leaving no natural navigation path. Users could only access study functionality via demo route (`/study-session-demo`).

**Impact**:
- Confusing user experience (no visible way to start studying)
- Integration tests didn't catch navigation gap (only tested data layer)
- Required retrofitting navigation in User Story 2
- Extra refactoring work to remove demo route dependency

**Root Cause**: Tasks were ordered by technical architecture (repositories → widgets → screens) rather than user navigation flow (list → detail → action).

**Prevention**:
1. **Task Ordering**: Always follow navigation flow, not technical layers
2. **Entry Point Check**: Every screen MUST have documented entry point before implementation
3. **Integration Tests**: Must validate navigation paths, not just data operations
4. **Demo Route Policy**: Flag any core feature accessible only via demo route as incomplete
5. **Spec Review**: Use navigation checklist before marking spec "ready"

**Corrective Action Taken**:
- Added "Task Organization & Navigation Standards" to constitution (Section III)
- Updated Review Requirements to include navigation check
- Prioritized Task 2.1 (DeckDetailScreen) immediately after User Story 1
- Will add navigation smoke test to future integration test suites

**Lesson**: **Navigation-first task ordering prevents orphaned screens and ensures every feature is immediately usable in context.**

**Version**: 1.1.0 | **Ratified**: 2025-12-25 | **Last Amended**: 2025-12-27
