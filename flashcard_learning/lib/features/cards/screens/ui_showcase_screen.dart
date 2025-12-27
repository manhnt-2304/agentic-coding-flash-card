import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

/// Showcase screen for new UI components
/// Demonstrates GetWidget, Shimmer, and Flutter Spinkit
class UIShowcaseScreen extends StatefulWidget {
  const UIShowcaseScreen({Key? key}) : super(key: key);

  @override
  State<UIShowcaseScreen> createState() => _UIShowcaseScreenState();
}

class _UIShowcaseScreenState extends State<UIShowcaseScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UI Components Showcase'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('GetWidget Components'),
          const SizedBox(height: 16),
          _buildGetWidgetSection(),
          
          const SizedBox(height: 32),
          _buildSectionTitle('Shimmer Effects'),
          const SizedBox(height: 16),
          _buildShimmerSection(),
          
          const SizedBox(height: 32),
          _buildSectionTitle('Loading Indicators'),
          const SizedBox(height: 16),
          _buildSpinKitSection(),
          
          const SizedBox(height: 32),
          _buildSectionTitle('Buttons & Cards'),
          const SizedBox(height: 16),
          _buildButtonsSection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildGetWidgetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // GF Card
        GFCard(
          boxFit: BoxFit.cover,
          titlePosition: GFPosition.start,
          title: const GFListTile(
            avatar: GFAvatar(
              backgroundImage: NetworkImage(
                'https://via.placeholder.com/150',
              ),
            ),
            title: Text('Study Session'),
            subTitle: Text('Complete 10 cards today'),
          ),
          content: const Text(
            'You\'re on a 5-day streak! Keep going to improve your vocabulary.',
          ),
          buttonBar: GFButtonBar(
            children: [
              GFButton(
                onPressed: () {},
                text: 'Start',
                icon: const Icon(Icons.play_arrow, size: 16),
                type: GFButtonType.solid,
              ),
              GFButton(
                onPressed: () {},
                text: 'Later',
                type: GFButtonType.outline,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // GF Badges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            GFBadge(
              text: '5 Day Streak',
              color: GFColors.SUCCESS,
            ),
            GFBadge(
              text: '100 Cards',
              color: GFColors.PRIMARY,
            ),
            GFBadge(
              text: 'Expert',
              color: GFColors.WARNING,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // GF Rating
        Row(
          children: [
            const Text('Difficulty: '),
            GFRating(
              value: 3.5,
              onChanged: (value) {},
              color: GFColors.WARNING,
              size: 24,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerSection() {
    return Column(
      children: [
        // Shimmer loading card
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Toggle button
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _isLoading = !_isLoading;
            });
          },
          icon: Icon(_isLoading ? Icons.stop : Icons.play_arrow),
          label: Text(_isLoading ? 'Stop Loading' : 'Show Loading'),
        ),
      ],
    );
  }

  Widget _buildSpinKitSection() {
    return Wrap(
      spacing: 24,
      runSpacing: 24,
      alignment: WrapAlignment.center,
      children: [
        _buildSpinner(
          'Wave',
          SpinKitWave(
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
        ),
        _buildSpinner(
          'Rotating Circle',
          SpinKitRotatingCircle(
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
        ),
        _buildSpinner(
          'Fading Circle',
          SpinKitFadingCircle(
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
        ),
        _buildSpinner(
          'Pulse',
          SpinKitPulse(
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
        ),
        _buildSpinner(
          'Three Bounce',
          SpinKitThreeBounce(
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
        ),
        _buildSpinner(
          'Folding Cube',
          SpinKitFoldingCube(
            color: Theme.of(context).colorScheme.primary,
            size: 40,
          ),
        ),
      ],
    );
  }

  Widget _buildSpinner(String label, Widget spinner) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: spinner),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildButtonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // GF Button variations
        GFButton(
          onPressed: () {},
          text: 'Solid Button',
          icon: const Icon(Icons.check, size: 16),
          type: GFButtonType.solid,
          fullWidthButton: true,
        ),
        
        const SizedBox(height: 12),
        
        GFButton(
          onPressed: () {},
          text: 'Outline Button',
          icon: const Icon(Icons.favorite_border, size: 16),
          type: GFButtonType.outline,
          fullWidthButton: true,
        ),
        
        const SizedBox(height: 12),
        
        GFButton(
          onPressed: () {},
          text: 'Transparent Button',
          icon: const Icon(Icons.info_outline, size: 16),
          type: GFButtonType.transparent,
          fullWidthButton: true,
        ),
        
        const SizedBox(height: 16),
        
        // Icon buttons row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GFIconButton(
              onPressed: () {},
              icon: const Icon(Icons.thumb_up),
              type: GFButtonType.solid,
              shape: GFIconButtonShape.circle,
            ),
            GFIconButton(
              onPressed: () {},
              icon: const Icon(Icons.favorite),
              type: GFButtonType.solid,
              shape: GFIconButtonShape.circle,
              color: Colors.red,
            ),
            GFIconButton(
              onPressed: () {},
              icon: const Icon(Icons.share),
              type: GFButtonType.outline,
              shape: GFIconButtonShape.circle,
            ),
            GFIconButton(
              onPressed: () {},
              icon: const Icon(Icons.bookmark),
              type: GFButtonType.solid,
              shape: GFIconButtonShape.square,
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Info card
        GFCard(
          color: Theme.of(context).colorScheme.primaryContainer,
          content: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'These UI components are now available throughout your app!',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
