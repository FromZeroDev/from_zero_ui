# fz_animated_switcher_image

An `AnimatedSwitcher` variant that captures a static image of outgoing children so they aren't rebuilt during the exit animation. This fixes many annoyances with the default `AnimatedSwitcher`, which keeps widgets alive until the animation finishes.

## Usage

```dart
import 'package:fz_animated_switcher_image/fz_animated_switcher_image.dart';

AnimatedSwitcherImage(
  duration: const Duration(milliseconds: 400),
  child: myWidget, // change this value to animate between children
)
```
