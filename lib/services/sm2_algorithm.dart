abstract class SM2Algorithm {
  SM2Result calculate({
    required int rating,
    required double previousEaseFactor,
    required int previousInterval,
    required int reviewCount,
  });
}

class SM2Result {
  final DateTime nextReviewDate;
  final double easeFactor;
  final int currentInterval;

  const SM2Result({
    required this.nextReviewDate,
    required this.easeFactor,
    required this.currentInterval,
  });
}

class SM2AlgorithmImpl implements SM2Algorithm {
  static const double minEF = 1.3;
  static const double maxEF = 3.0;
  static const double defaultEF = 2.5;

  @override
  SM2Result calculate({
    required int rating,
    required double previousEaseFactor,
    required int previousInterval,
    required int reviewCount,
  }) {
    double newEF = previousEaseFactor;
    int newInterval;

    // Adjust ease factor based on rating
    switch (rating) {
      case 1: // Hard
        newEF = (previousEaseFactor - 0.2).clamp(minEF, maxEF);
        break;
      case 3: // Normal
        // EF unchanged
        break;
      case 5: // Easy
        newEF = (previousEaseFactor + 0.15).clamp(minEF, maxEF);
        break;
      default:
        throw ArgumentError('Invalid rating: $rating. Must be 1, 3, or 5.');
    }

    // Calculate interval
    if (reviewCount == 0) {
      // First review
      switch (rating) {
        case 1:
          newInterval = 1;
          break;
        case 3:
          newInterval = 3;
          break;
        case 5:
          newInterval = 7;
          break;
        default:
          newInterval = 1;
      }
    } else {
      // Subsequent reviews
      if (rating == 1) {
        // Reset interval on hard rating
        newInterval = 1;
      } else {
        newInterval = (previousInterval * newEF).round();
      }
    }

    final nextReviewDate = DateTime.now().add(Duration(days: newInterval));

    return SM2Result(
      nextReviewDate: nextReviewDate,
      easeFactor: newEF,
      currentInterval: newInterval,
    );
  }
}
