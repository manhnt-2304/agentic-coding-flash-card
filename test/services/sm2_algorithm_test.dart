import 'package:flutter_test/flutter_test.dart';
import 'package:flashcard_learning/services/sm2_algorithm.dart';

void main() {
  late SM2AlgorithmImpl algorithm;

  setUp(() {
    algorithm = SM2AlgorithmImpl();
  });

  group('SM2 Algorithm - First Review', () {
    test('rating 1 (Hard) should schedule 1 day interval', () {
      final result = algorithm.calculate(
        rating: 1,
        previousEaseFactor: 2.5,
        previousInterval: 0,
        reviewCount: 0,
      );

      expect(result.currentInterval, 1);
      expect(result.easeFactor, lessThan(2.5));
      expect(result.easeFactor, 2.3); // 2.5 - 0.2
    });

    test('rating 3 (Normal) should schedule 3 days interval', () {
      final result = algorithm.calculate(
        rating: 3,
        previousEaseFactor: 2.5,
        previousInterval: 0,
        reviewCount: 0,
      );

      expect(result.currentInterval, 3);
      expect(result.easeFactor, 2.5); // Unchanged
    });

    test('rating 5 (Easy) should schedule 7 days interval', () {
      final result = algorithm.calculate(
        rating: 5,
        previousEaseFactor: 2.5,
        previousInterval: 0,
        reviewCount: 0,
      );

      expect(result.currentInterval, 7);
      expect(result.easeFactor, greaterThan(2.5));
      expect(result.easeFactor, 2.65); // 2.5 + 0.15
    });
  });

  group('SM2 Algorithm - Subsequent Reviews', () {
    test('should multiply interval by ease factor', () {
      final result = algorithm.calculate(
        rating: 3,
        previousEaseFactor: 2.5,
        previousInterval: 3,
        reviewCount: 1,
      );

      expect(result.currentInterval, 8); // 3 * 2.5 = 7.5 rounded to 8
      expect(result.easeFactor, 2.5);
    });

    test('should increase ease factor for Easy rating', () {
      final result = algorithm.calculate(
        rating: 5,
        previousEaseFactor: 2.5,
        previousInterval: 7,
        reviewCount: 2,
      );

      expect(result.easeFactor, 2.65); // 2.5 + 0.15
      expect(result.currentInterval, 19); // 7 * 2.65 = 18.55 rounded to 19
    });

    test('should decrease ease factor for Hard rating', () {
      final result = algorithm.calculate(
        rating: 1,
        previousEaseFactor: 2.5,
        previousInterval: 7,
        reviewCount: 2,
      );

      expect(result.easeFactor, 2.3); // 2.5 - 0.2
      expect(result.currentInterval, 1); // Reset on hard
    });

    test('should handle progressive intervals correctly', () {
      // First review - Easy
      var result = algorithm.calculate(
        rating: 5,
        previousEaseFactor: 2.5,
        previousInterval: 0,
        reviewCount: 0,
      );
      expect(result.currentInterval, 7);
      expect(result.easeFactor, 2.65);

      // Second review - Easy
      result = algorithm.calculate(
        rating: 5,
        previousEaseFactor: result.easeFactor,
        previousInterval: result.currentInterval,
        reviewCount: 1,
      );
      expect(result.currentInterval, 20); // 7 * 2.8 = 19.6 rounded to 20
      expect(result.easeFactor, 2.8); // 2.65 + 0.15
    });
  });

  group('SM2 Algorithm - Edge Cases', () {
    test('ease factor should not go below 1.3', () {
      final result = algorithm.calculate(
        rating: 1,
        previousEaseFactor: 1.3,
        previousInterval: 1,
        reviewCount: 5,
      );

      expect(result.easeFactor, 1.3);
      expect(result.currentInterval, 1);
    });

    test('ease factor should not go above 3.0', () {
      final result = algorithm.calculate(
        rating: 5,
        previousEaseFactor: 2.9,
        previousInterval: 14,
        reviewCount: 10,
      );

      expect(result.easeFactor, lessThanOrEqualTo(3.0));
      expect(result.easeFactor, 3.0); // 2.9 + 0.15 = 3.05, clamped to 3.0
    });

    test('should throw on invalid rating', () {
      expect(
        () => algorithm.calculate(
          rating: 2,
          previousEaseFactor: 2.5,
          previousInterval: 0,
          reviewCount: 0,
        ),
        throwsArgumentError,
      );
    });

    test('should handle rating 1 with large interval', () {
      final result = algorithm.calculate(
        rating: 1,
        previousEaseFactor: 2.8,
        previousInterval: 30,
        reviewCount: 10,
      );

      expect(result.currentInterval, 1); // Always reset to 1 on rating 1
      expect(result.easeFactor, closeTo(2.6, 0.01)); // 2.8 - 0.2, with floating point tolerance
    });
  });

  group('SM2 Algorithm - nextReviewDate', () {
    test('should calculate correct next review date', () {
      final now = DateTime.now();
      final result = algorithm.calculate(
        rating: 3,
        previousEaseFactor: 2.5,
        previousInterval: 0,
        reviewCount: 0,
      );

      // Should be 3 days from now
      final expectedDate = now.add(Duration(days: 3));
      expect(
        result.nextReviewDate.difference(expectedDate).inHours.abs(),
        lessThan(1), // Within 1 hour tolerance
      );
    });
  });
}
