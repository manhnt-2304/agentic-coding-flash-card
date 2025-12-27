// Route names for navigation
class Routes {
  static const String mainTabs = '/';
  static const String studySession = '/study-session';
  static const String deckDetail = '/deck-detail';
  static const String cardEditor = '/card-editor';
  static const String settings = '/settings';
  static const String flashCardDemo = '/flash-card-demo';
  static const String uiShowcase = '/ui-showcase';
}

// Study mode enum
enum StudyMode {
  basic, // Simple Know/Forgot buttons
  smart, // Easy/Normal/Hard buttons with SRS
}

// Route arguments
class StudySessionArgs {
  final String deckId;
  final StudyMode mode;

  StudySessionArgs({
    required this.deckId,
    required this.mode,
  });
}

class DeckDetailArgs {
  final String deckId;

  DeckDetailArgs({required this.deckId});
}

class CardEditorArgs {
  final String deckId;
  final String? cardId; // null = create new

  CardEditorArgs({
    required this.deckId,
    this.cardId,
  });
}
