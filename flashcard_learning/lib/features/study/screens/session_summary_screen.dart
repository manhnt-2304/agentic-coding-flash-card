import 'package:flashcard_learning/data/repositories/session_repository.dart';
import 'package:flashcard_learning/data/database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';

// Provider for database
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Provider for session repository
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final database = ref.watch(databaseProvider);
  return SessionRepositoryImpl(database);
});

// Provider for session summary data
final sessionSummaryProvider =
    FutureProvider.family<SessionSummaryData, String>((ref, sessionId) async {
  final repository = ref.watch(sessionRepositoryProvider);
  return repository.getSessionSummary(sessionId);
});

// Provider for forgotten card IDs
final forgottenCardIdsProvider =
    FutureProvider.family<List<String>, String>((ref, sessionId) async {
  final repository = ref.watch(sessionRepositoryProvider);
  return repository.getForgottenCardIds(sessionId);
});

/// Session Summary Screen (Task 1.7)
///
/// Displays study session results including:
/// - Cards reviewed
/// - Accuracy rate
/// - Session duration
/// - Next review count
///
/// Actions:
/// - Review Mistakes: Restart with forgotten cards
/// - Done: Navigate back to deck list
class SessionSummaryScreen extends ConsumerWidget {
  final String sessionId;

  const SessionSummaryScreen({
    Key? key,
    required this.sessionId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(sessionSummaryProvider(sessionId));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Session Complete!'),
        backgroundColor: colorScheme.primaryContainer,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: summaryAsync.when(
        data: (summary) => _buildSummaryContent(context, ref, summary),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading summary: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryContent(
    BuildContext context,
    WidgetRef ref,
    SessionSummaryData summary,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final forgottenIdsAsync = ref.watch(forgottenCardIdsProvider(sessionId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Celebration icon
          Center(
            child: Icon(
              Icons.celebration,
              size: 80,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Main stats card
          GFCard(
            color: colorScheme.primaryContainer,
            elevation: 4,
            content: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Great Job!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                  ),
                  const SizedBox(height: 24),
                  _buildStatRow(
                    context,
                    Icons.style,
                    'Cards Reviewed',
                    '${summary.cardsReviewed}',
                    colorScheme.onPrimaryContainer,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    context,
                    Icons.check_circle,
                    'Cards Known',
                    '${summary.cardsKnown}',
                    Colors.green,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    context,
                    Icons.cancel,
                    'Cards Forgot',
                    '${summary.cardsForgot}',
                    Colors.red,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    context,
                    Icons.percent,
                    'Accuracy Rate',
                    '${summary.accuracyRate.toStringAsFixed(1)}%',
                    colorScheme.tertiary,
                  ),
                  const Divider(height: 24),
                  _buildStatRow(
                    context,
                    Icons.timer,
                    'Duration',
                    _formatDuration(summary.duration),
                    colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Next review info
          if (summary.nextReviewCount > 0)
            GFCard(
              color: colorScheme.secondaryContainer,
              content: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: colorScheme.secondary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Next Review',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(
                                  color: colorScheme.onSecondaryContainer,
                                ),
                          ),
                          Text(
                            '${summary.nextReviewCount} cards due tomorrow',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),

          // Action buttons
          forgottenIdsAsync.when(
            data: (forgottenIds) {
              if (forgottenIds.isNotEmpty) {
                return Column(
                  children: [
                    // Review Mistakes button
                    SizedBox(
                      width: double.infinity,
                      child: GFButton(
                        onPressed: () => _reviewMistakes(context, forgottenIds),
                        type: GFButtonType.outline,
                        size: GFSize.LARGE,
                        text: 'Review Mistakes (${forgottenIds.length} cards)',
                        icon: const Icon(Icons.replay),
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Done button
                    SizedBox(
                      width: double.infinity,
                      child: GFButton(
                        onPressed: () => _done(context),
                        type: GFButtonType.solid,
                        size: GFSize.LARGE,
                        text: 'Done',
                        icon: const Icon(Icons.check),
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                );
              } else {
                // Perfect score - only Done button
                return SizedBox(
                  width: double.infinity,
                  child: GFButton(
                    onPressed: () => _done(context),
                    type: GFButtonType.solid,
                    size: GFSize.LARGE,
                    text: 'Done',
                    icon: const Icon(Icons.check),
                    color: colorScheme.primary,
                  ),
                );
              }
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => SizedBox(
              width: double.infinity,
              child: GFButton(
                onPressed: () => _done(context),
                type: GFButtonType.solid,
                size: GFSize.LARGE,
                text: 'Done',
                icon: const Icon(Icons.check),
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
        ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '$seconds sec';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final secs = seconds % 60;
      return '${minutes}m ${secs}s';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '${hours}h ${minutes}m';
    }
  }

  void _reviewMistakes(BuildContext context, List<String> forgottenCardIds) {
    // TODO: Navigate to study session with only forgotten cards
    // For now, show a message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Review Mistakes: ${forgottenCardIds.length} cards (Task 5.2 - Coming soon)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _done(BuildContext context) {
    // Navigate back to deck list (pop all routes)
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}
