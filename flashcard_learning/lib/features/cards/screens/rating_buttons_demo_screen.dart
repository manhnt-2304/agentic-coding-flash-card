import 'package:flashcard_learning/core/navigation/routes.dart';
import 'package:flashcard_learning/features/cards/widgets/rating_buttons.dart';
import 'package:flutter/material.dart';

/// Demo screen for RatingButtons widget (Task 1.5)
/// 
/// Showcases:
/// - Basic mode (Know/Forgot)
/// - Smart mode (Easy/Normal/Hard)
/// - Disabled state
/// - UI Design Standards compliance (GetWidget)
class RatingButtonsDemoScreen extends StatefulWidget {
  const RatingButtonsDemoScreen({Key? key}) : super(key: key);

  @override
  State<RatingButtonsDemoScreen> createState() => _RatingButtonsDemoScreenState();
}

class _RatingButtonsDemoScreenState extends State<RatingButtonsDemoScreen> {
  StudyMode _mode = StudyMode.basic;
  bool _disabled = false;
  int? _lastRating;
  final List<String> _ratingHistory = [];

  void _handleRating(int rating) {
    setState(() {
      _lastRating = rating;
      _ratingHistory.insert(
        0,
        '${DateTime.now().toLocal().toString().substring(11, 19)} - Rating: $rating (${_getRatingLabel(rating)})',
      );
    });
  }

  String _getRatingLabel(int rating) {
    if (_mode == StudyMode.basic) {
      return rating == 5 ? 'Know' : 'Forgot';
    } else {
      switch (rating) {
        case 5:
          return 'Easy';
        case 3:
          return 'Normal';
        case 1:
          return 'Hard';
        default:
          return 'Unknown';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('RatingButtons Demo'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info card
            Card(
              color: colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Task 1.5 - RatingButtons Widget',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This widget provides rating buttons for flashcard review with two modes:',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _buildBullet(context, 'Basic Mode: Simple Know/Forgot buttons'),
                    _buildBullet(context, 'Smart Mode: Easy/Normal/Hard with SRS intervals'),
                    _buildBullet(context, 'Uses GetWidget (GFButton) per UI standards'),
                    _buildBullet(context, 'Primary action: solid, Secondary: outline'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Mode selector
            Text(
              'Mode',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<StudyMode>(
              segments: const [
                ButtonSegment(
                  value: StudyMode.basic,
                  label: Text('Basic'),
                  icon: Icon(Icons.check_circle_outline),
                ),
                ButtonSegment(
                  value: StudyMode.smart,
                  label: Text('Smart'),
                  icon: Icon(Icons.psychology_outlined),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (Set<StudyMode> newSelection) {
                setState(() {
                  _mode = newSelection.first;
                  _lastRating = null;
                });
              },
            ),
            const SizedBox(height: 24),

            // Disabled toggle
            SwitchListTile(
              title: const Text('Disabled State'),
              subtitle: const Text('Test non-interactive buttons'),
              value: _disabled,
              onChanged: (value) {
                setState(() {
                  _disabled = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // RatingButtons widget
            Text(
              'Rating Buttons',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: RatingButtons(
                mode: _mode,
                onRate: _handleRating,
                disabled: _disabled,
              ),
            ),
            const SizedBox(height: 24),

            // Last rating display
            if (_lastRating != null) ...[
              Card(
                color: colorScheme.secondaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: colorScheme.secondary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Rating',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: colorScheme.onSecondaryContainer,
                                  ),
                            ),
                            Text(
                              'Rating: $_lastRating (${_getRatingLabel(_lastRating!)})',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
              const SizedBox(height: 16),
            ],

            // Rating history
            if (_ratingHistory.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rating History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _ratingHistory.clear();
                        _lastRating = null;
                      });
                    },
                    icon: const Icon(Icons.clear_all, size: 18),
                    label: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  itemCount: _ratingHistory.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.tertiaryContainer,
                        radius: 16,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onTertiaryContainer,
                          ),
                        ),
                      ),
                      title: Text(
                        _ratingHistory[index],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBullet(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
