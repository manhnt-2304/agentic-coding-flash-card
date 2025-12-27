import 'package:flashcard_learning/core/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

/// Rating buttons for flashcard review
/// 
/// Supports two modes:
/// - Basic: Know (5) / Forgot (1)
/// - Smart: Easy (5) / Normal (3) / Hard (1)
/// 
/// Uses GetWidget (GFButton) per UI Design Standards:
/// - Primary action (Know/Easy): GFButtonType.solid
/// - Secondary actions (Forgot/Hard/Normal): GFButtonType.outline
/// - Spacing: 16dp between buttons
/// - Colors: Theme.of(context).colorScheme
class RatingButtons extends StatelessWidget {
  final StudyMode mode;
  final ValueChanged<int> onRate;
  final bool disabled;

  const RatingButtons({
    Key? key,
    required this.mode,
    required this.onRate,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: mode == StudyMode.basic
          ? _buildBasicButtons(context, colorScheme)
          : _buildSmartButtons(context, colorScheme),
    );
  }

  /// Basic mode: Know (5) and Forgot (1) buttons
  Widget _buildBasicButtons(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        // Forgot button (secondary action - outline)
        Expanded(
          child: GFButton(
            onPressed: disabled ? null : () => onRate(1),
            text: 'Forgot',
            type: GFButtonType.outline,
            shape: GFButtonShape.standard,
            size: GFSize.LARGE,
            color: colorScheme.error,
            textStyle: TextStyle(
              color: disabled ? colorScheme.onSurface.withOpacity(0.38) : colorScheme.error,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 16), // 16dp spacing per UI standards
        // Know button (primary action - solid)
        Expanded(
          child: GFButton(
            onPressed: disabled ? null : () => onRate(5),
            text: 'Know',
            type: GFButtonType.solid,
            shape: GFButtonShape.standard,
            size: GFSize.LARGE,
            color: disabled ? colorScheme.onSurface.withOpacity(0.12) : colorScheme.primary,
            textStyle: TextStyle(
              color: disabled ? colorScheme.onSurface.withOpacity(0.38) : colorScheme.onPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// Smart mode: Hard (1), Normal (3), Easy (5) buttons with emoji
  Widget _buildSmartButtons(BuildContext context, ColorScheme colorScheme) {
    return Row(
      children: [
        // Hard button (secondary action - outline)
        Expanded(
          child: GFButton(
            onPressed: disabled ? null : () => onRate(1),
            text: '😖 Hard\n(1 day)',
            type: GFButtonType.outline,
            shape: GFButtonShape.standard,
            size: GFSize.LARGE,
            color: colorScheme.error,
            textStyle: TextStyle(
              color: disabled ? colorScheme.onSurface.withOpacity(0.38) : colorScheme.error,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 16), // 16dp spacing
        // Normal button (secondary action - outline)
        Expanded(
          child: GFButton(
            onPressed: disabled ? null : () => onRate(3),
            text: '😐 Normal\n(3 days)',
            type: GFButtonType.outline,
            shape: GFButtonShape.standard,
            size: GFSize.LARGE,
            color: colorScheme.tertiary,
            textStyle: TextStyle(
              color: disabled ? colorScheme.onSurface.withOpacity(0.38) : colorScheme.tertiary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 16), // 16dp spacing
        // Easy button (primary action - solid)
        Expanded(
          child: GFButton(
            onPressed: disabled ? null : () => onRate(5),
            text: '😄 Easy\n(7 days)',
            type: GFButtonType.solid,
            shape: GFButtonShape.standard,
            size: GFSize.LARGE,
            color: disabled ? colorScheme.onSurface.withOpacity(0.12) : colorScheme.primary,
            textStyle: TextStyle(
              color: disabled ? colorScheme.onSurface.withOpacity(0.38) : colorScheme.onPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
