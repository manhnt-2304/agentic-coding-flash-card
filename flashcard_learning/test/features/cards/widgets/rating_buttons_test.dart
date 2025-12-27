import 'package:flashcard_learning/core/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flashcard_learning/features/cards/widgets/rating_buttons.dart';
import 'package:getwidget/getwidget.dart';

void main() {
  group('RatingButtons Widget', () {
    testWidgets('Basic mode shows Know and Forgot buttons', (tester) async {
      int? ratedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              mode: StudyMode.basic,
              onRate: (rating) => ratedValue = rating,
            ),
          ),
        ),
      );

      // Find buttons by text
      expect(find.text('Know'), findsOneWidget);
      expect(find.text('Forgot'), findsOneWidget);

      // Should NOT show Smart mode buttons
      expect(find.textContaining('Hard'), findsNothing);
      expect(find.textContaining('Normal'), findsNothing);
      expect(find.textContaining('Easy'), findsNothing);
    });

    testWidgets('Smart mode shows Easy, Normal, Hard buttons', (tester) async {
      int? ratedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              mode: StudyMode.smart,
              onRate: (rating) => ratedValue = rating,
            ),
          ),
        ),
      );

      // Find buttons by emoji/text
      expect(find.textContaining('😖'), findsOneWidget); // Hard
      expect(find.textContaining('😐'), findsOneWidget); // Normal
      expect(find.textContaining('😄'), findsOneWidget); // Easy

      // Should NOT show Basic mode buttons
      expect(find.text('Know'), findsNothing);
      expect(find.text('Forgot'), findsNothing);
    });

    testWidgets('Basic mode: Know button calls onRate(5)', (tester) async {
      int? ratedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              mode: StudyMode.basic,
              onRate: (rating) => ratedValue = rating,
            ),
          ),
        ),
      );

      // Tap Know button
      await tester.tap(find.text('Know'));
      await tester.pumpAndSettle();

      expect(ratedValue, equals(5));
    });

    testWidgets('Basic mode: Forgot button calls onRate(1)', (tester) async {
      int? ratedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              mode: StudyMode.basic,
              onRate: (rating) => ratedValue = rating,
            ),
          ),
        ),
      );

      // Tap Forgot button
      await tester.tap(find.text('Forgot'));
      await tester.pumpAndSettle();

      expect(ratedValue, equals(1));
    });

    testWidgets('Smart mode: Easy button calls onRate(5)', (tester) async {
      int? ratedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              mode: StudyMode.smart,
              onRate: (rating) => ratedValue = rating,
            ),
          ),
        ),
      );

      // Tap Easy button
      await tester.tap(find.textContaining('😄'));
      await tester.pumpAndSettle();

      expect(ratedValue, equals(5));
    });

    testWidgets('Smart mode: Normal button calls onRate(3)', (tester) async {
      int? ratedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              mode: StudyMode.smart,
              onRate: (rating) => ratedValue = rating,
            ),
          ),
        ),
      );

      // Tap Normal button
      await tester.tap(find.textContaining('😐'));
      await tester.pumpAndSettle();

      expect(ratedValue, equals(3));
    });

    testWidgets('Smart mode: Hard button calls onRate(1)', (tester) async {
      int? ratedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              mode: StudyMode.smart,
              onRate: (rating) => ratedValue = rating,
            ),
          ),
        ),
      );

      // Tap Hard button
      await tester.tap(find.textContaining('😖'));
      await tester.pumpAndSettle();

      expect(ratedValue, equals(1));
    });

    testWidgets('Disabled buttons are non-interactive', (tester) async {
      int? ratedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              mode: StudyMode.basic,
              onRate: (rating) => ratedValue = rating,
              disabled: true,
            ),
          ),
        ),
      );

      // Try to tap Know button
      await tester.tap(find.text('Know'));
      await tester.pumpAndSettle();

      // Should not trigger callback
      expect(ratedValue, isNull);
    });

    testWidgets('Uses GFButton from GetWidget library', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              mode: StudyMode.basic,
              onRate: (_) {},
            ),
          ),
        ),
      );

      // Verify GFButton widgets exist
      expect(find.byType(GFButton), findsAtLeastNWidgets(2));
    });

    testWidgets('Basic mode: Know button is solid type (primary)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              mode: StudyMode.basic,
              onRate: (_) {},
            ),
          ),
        ),
      );

      // Find GFButton widgets
      final gfButtons = tester.widgetList<GFButton>(find.byType(GFButton));
      
      // Know button should be solid type
      final knowButton = gfButtons.firstWhere(
        (btn) => btn.text == 'Know',
      );
      expect(knowButton.type, equals(GFButtonType.solid));
    });

    testWidgets('Basic mode: Forgot button is outline type (secondary)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              mode: StudyMode.basic,
              onRate: (_) {},
            ),
          ),
        ),
      );

      // Find GFButton widgets
      final gfButtons = tester.widgetList<GFButton>(find.byType(GFButton));
      
      // Forgot button should be outline type
      final forgotButton = gfButtons.firstWhere(
        (btn) => btn.text == 'Forgot',
      );
      expect(forgotButton.type, equals(GFButtonType.outline));
    });

    testWidgets('Smart mode: Easy button is solid type (primary)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              mode: StudyMode.smart,
              onRate: (_) {},
            ),
          ),
        ),
      );

      // Find GFButton widgets
      final gfButtons = tester.widgetList<GFButton>(find.byType(GFButton));
      
      // Easy button should be solid type
      final easyButton = gfButtons.firstWhere(
        (btn) => btn.text!.contains('😄'),
      );
      expect(easyButton.type, equals(GFButtonType.solid));
    });

    testWidgets('Smart mode: Hard and Normal buttons are outline type', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingButtons(
              mode: StudyMode.smart,
              onRate: (_) {},
            ),
          ),
        ),
      );

      // Find GFButton widgets
      final gfButtons = tester.widgetList<GFButton>(find.byType(GFButton));
      
      // Hard button should be outline type
      final hardButton = gfButtons.firstWhere(
        (btn) => btn.text!.contains('😖'),
      );
      expect(hardButton.type, equals(GFButtonType.outline));

      // Normal button should be outline type
      final normalButton = gfButtons.firstWhere(
        (btn) => btn.text!.contains('😐'),
      );
      expect(normalButton.type, equals(GFButtonType.outline));
    });
  });
}
