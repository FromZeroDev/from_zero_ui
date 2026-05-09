# fz_animations

Custom animation widgets used across FromZero UI, including:

- `FadeUpwardsSlideTransition` — slides up while fading in
- `FadeUpwardsFadeTransition` — fades upwards
- `FixedSlideTransition` — a slide transition that doesn't move below 0
- `AnimatedSwitcherImage` — animated image switcher (fades between images)
- `HeroesFromZero` — tweaked hero animations
- Custom `SharedAxisTransition` and `FadeThroughTransition` variants without fading

## Usage

```dart
import 'package:fz_animations/fz_animations.dart';

FadeUpwardsSlideTransition(
  animation: animation,
  child: YourWidget(),
)
```
