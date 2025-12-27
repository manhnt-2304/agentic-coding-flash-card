import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcard_learning/features/decks/screens/deck_list_screen.dart';
import 'package:flashcard_learning/features/cards/screens/flash_card_demo_screen.dart';
import 'package:flashcard_learning/features/cards/screens/ui_showcase_screen.dart';
import 'package:flashcard_learning/features/cards/screens/rating_buttons_demo_screen.dart';
import 'package:flashcard_learning/features/study/screens/study_session_demo_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flashcard Learning',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const DeckListScreen(),
      routes: {
        '/flash-card-demo': (context) => const FlashCardDemoScreen(),
        '/ui-showcase': (context) => const UIShowcaseScreen(),
        '/rating-buttons-demo': (context) => const RatingButtonsDemoScreen(),
        '/study-session-demo': (context) => const StudySessionDemoScreen(),
      },
    );
  }
}
