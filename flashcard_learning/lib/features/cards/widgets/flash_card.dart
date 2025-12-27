import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A flashcard widget with flip animation
/// Displays front text/image or back text/image based on isFlipped state
class FlashCard extends StatefulWidget {
  final String frontText;
  final String backText;
  final String? frontImagePath;
  final String? backImagePath;
  final bool isFlipped;
  final VoidCallback onFlip;
  final bool autoPlayTTS;
  final String ttsVoice;

  const FlashCard({
    Key? key,
    required this.frontText,
    required this.backText,
    this.frontImagePath,
    this.backImagePath,
    required this.isFlipped,
    required this.onFlip,
    required this.autoPlayTTS,
    required this.ttsVoice,
  }) : super(key: key);

  @override
  State<FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<FlashCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Set initial state
    if (widget.isFlipped) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(FlashCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate when isFlipped changes
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onFlip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Calculate rotation angle
          final angle = _animation.value * math.pi;
          final isFrontVisible = angle < math.pi / 2;

          // Apply 3D transform
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(angle),
            child: isFrontVisible
                ? _buildCardSide(
                    text: widget.frontText,
                    imagePath: widget.frontImagePath,
                  )
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildCardSide(
                      text: widget.backText,
                      imagePath: widget.backImagePath,
                    ),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardSide({
    required String text,
    String? imagePath,
  }) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        constraints: const BoxConstraints(
          minHeight: 200,
          minWidth: double.infinity,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imagePath != null) ...[
              _buildImage(imagePath),
              const SizedBox(height: 16.0),
            ],
            Text(
              text,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    // Check if it's a local file or asset
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        height: 150,
        fit: BoxFit.contain,
      );
    } else {
      // Local file path
      final file = File(imagePath);
      return Image.file(
        file,
        height: 150,
        fit: BoxFit.contain,
      );
    }
  }
}
