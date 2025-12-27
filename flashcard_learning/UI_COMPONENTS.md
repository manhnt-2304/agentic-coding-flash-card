# UI Components Guide

## 📦 Available UI Libraries

This project includes several professional UI component libraries to accelerate development:

### 1. **GetWidget** (v4.0.0+)
- **1000+ Pre-built Widgets**
- Documentation: https://www.getwidget.dev/

#### Components Available:
- **Buttons**: Solid, Outline, Transparent, Icon buttons
- **Cards**: Standard cards with images, titles, content
- **Badges**: Labels, tags, status indicators
- **Rating**: Star ratings, custom icons
- **Avatars**: Circle, square avatars with images
- **Alerts**: Toast messages, snackbars
- **Carousels**: Image sliders, content carousels
- **Accordions**: Expandable content sections
- **Dropdowns**: Custom dropdown menus
- **Lists**: Advanced list tiles
- **Timelines**: Vertical/horizontal timelines
- **SearchBars**: Customizable search inputs

#### Usage Example:
```dart
import 'package:getwidget/getwidget.dart';

// Button
GFButton(
  onPressed: () {},
  text: 'Start Studying',
  icon: Icon(Icons.play_arrow, size: 16),
  type: GFButtonType.solid,
)

// Card
GFCard(
  title: GFListTile(
    title: Text('Study Session'),
    subTitle: Text('10 cards remaining'),
  ),
  content: Text('Complete today\'s review'),
  buttonBar: GFButtonBar(
    children: [
      GFButton(text: 'Start', onPressed: () {}),
    ],
  ),
)

// Badge
GFBadge(
  text: '5 Day Streak',
  color: GFColors.SUCCESS,
)
```

---

### 2. **Shimmer** (v3.0.0+)
- **Loading Placeholders**
- Creates shimmering loading effects

#### Usage Example:
```dart
import 'package:shimmer/shimmer.dart';

Shimmer.fromColors(
  baseColor: Colors.grey[300]!,
  highlightColor: Colors.grey[100]!,
  child: Container(
    width: double.infinity,
    height: 200,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
```

#### Use Cases:
- ✅ Loading deck lists
- ✅ Loading card content
- ✅ Loading statistics
- ✅ Profile/avatar loading

---

### 3. **Flutter Spinkit** (v5.2.0+)
- **Beautiful Loading Indicators**
- 30+ animation types

#### Available Spinners:
- `SpinKitWave` - Wave animation
- `SpinKitRotatingCircle` - Rotating circle
- `SpinKitFadingCircle` - Fading circle
- `SpinKitPulse` - Pulsing animation
- `SpinKitThreeBounce` - Three bouncing dots
- `SpinKitFoldingCube` - Folding cube animation
- `SpinKitDualRing` - Dual ring spinner
- `SpinKitRipple` - Ripple effect

#### Usage Example:
```dart
import 'package:flutter_spinkit/flutter_spinkit.dart';

SpinKitFadingCircle(
  color: Theme.of(context).colorScheme.primary,
  size: 50.0,
)
```

#### Use Cases:
- ✅ Study session loading
- ✅ Data synchronization
- ✅ Image upload progress
- ✅ Network requests

---

### 4. **Animations** (v2.0.11)
- **Google's Official Animation Package**
- Smooth page transitions
- Shared element animations

#### Usage Example:
```dart
import 'package:animations/animations.dart';

OpenContainer(
  closedBuilder: (context, action) => DeckCard(),
  openBuilder: (context, action) => DeckDetailScreen(),
  transitionType: ContainerTransitionType.fade,
)
```

---

## 🎨 UI Showcase Screen

Access the showcase to see all components in action:

### How to Access:
1. Open the app
2. Tap the **palette icon** (🎨) in the AppBar
3. Or navigate: `Navigator.pushNamed(context, '/ui-showcase')`

### Sections:
- **GetWidget Components**: Cards, Badges, Ratings
- **Shimmer Effects**: Loading placeholders
- **Loading Indicators**: All SpinKit animations
- **Buttons & Cards**: Various button styles

---

## 🚀 Integration Examples for Flashcard App

### Study Session Loading State:
```dart
// Show shimmer while loading cards
if (isLoading) {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: _buildCardSkeleton(),
  );
}
```

### Achievement Badges:
```dart
// Show streak badge
GFBadge(
  text: '$streakDays Day Streak 🔥',
  color: GFColors.WARNING,
  size: GFSize.LARGE,
)
```

### Loading Indicator During Study:
```dart
// Show while saving review data
Center(
  child: SpinKitThreeBounce(
    color: Theme.of(context).colorScheme.primary,
    size: 30.0,
  ),
)
```

### Rating Card Difficulty:
```dart
// User rates card difficulty
GFRating(
  value: card.difficulty,
  onChanged: (rating) {
    // Update card difficulty
  },
  color: GFColors.WARNING,
  size: 28,
)
```

---

## 📝 Best Practices

### 1. **Consistent Loading States**
- Use Shimmer for content loading
- Use SpinKit for action loading (submit, save)
- Keep loading indicators consistent across app

### 2. **Performance**
- Shimmer is lightweight, safe for lists
- SpinKit animations are GPU-accelerated
- GetWidget components are optimized

### 3. **Theming**
- All components respect Material 3 theme
- Use `Theme.of(context).colorScheme` for colors
- GetWidget colors: `GFColors.PRIMARY`, `GFColors.SUCCESS`, etc.

### 4. **Accessibility**
- Add semantic labels to custom widgets
- Ensure sufficient contrast for badges
- Test with screen readers

---

## 🔧 Additional Resources

- **GetWidget Docs**: https://docs.getwidget.dev/
- **Shimmer Examples**: https://pub.dev/packages/shimmer
- **SpinKit Gallery**: https://pub.dev/packages/flutter_spinkit
- **Animations Guide**: https://pub.dev/packages/animations

---

## 🎯 Next Steps

Now that UI components are ready, you can:

1. ✅ Use GetWidget for **RatingButtons** (Task 1.5)
2. ✅ Add Shimmer to **DeckListScreen** loading
3. ✅ Use SpinKit in **Study Session** loading
4. ✅ Add badges for achievements
5. ✅ Create smooth page transitions with Animations

**Ready to build beautiful UIs! 🚀**
