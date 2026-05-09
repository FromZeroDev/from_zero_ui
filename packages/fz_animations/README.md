# fz_animations

Custom transition animations used across FromZero UI.

## Widgets

| Widget | Description |
|--------|-------------|
| `FadeUpwardsSlideTransition` | Slide-up part of `FadeUpwardsPageTransitionsBuilder` (no fade) |
| `FadeUpwardsFadeTransition` | Fade-in part of `FadeUpwardsPageTransitionsBuilder` (no slide) |
| `FixedSlideTransition` | Slide transition that clamps at 0 instead of going negative |
| `ZoomedFadeInFadeOutTransition` | Fades in with a slight zoom while fading out the previous child |
| `ZoomedFadeInTransition` | Entrance transition with slight zoom + opacity |
| `FadeOutTransition` | Exit transition that fades out |
| `FadeThroughPageTransitionsBuilder` | `FadeThroughTransition` without the fade — shows solid pages |
| `SharedAxisPageTransitionsBuilder` | `SharedAxisTransition` without the fade — solid shared-axis slides |
| `HeroesFromZero` | Utility for fading hero flights via `fadeThroughFlightShuttleBuilder` |

## Usage

```dart
import 'package:fz_animations/fz_animations.dart';

// Slide transition (no fade)
FadeUpwardsSlideTransition(
  animation: animation,
  child: MyPage(),
)

// Zoomed fade in + fade out
ZoomedFadeInFadeOutTransition(
  animation: animation,
  child: MyPage(),
)

// Hero fade-through shuttle
Hero(
  tag: 'my-tag',
  flightShuttleBuilder: HeroesFromZero.fadeThroughFlightShuttleBuilder,
  child: MyWidget(),
)
```
