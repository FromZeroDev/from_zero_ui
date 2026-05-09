# fz_opacity_gradient

Opacity gradient widgets that fade content edges in a scrollable container.

- `OpacityGradient` — Static gradient mask (left/right/top/bottom/horizontal/vertical)
- `ScrollOpacityGradient` — Dynamic gradient that fades based on scroll position

## Usage

```dart
import 'package:fz_opacity_gradient/fz_opacity_gradient.dart';

ScrollOpacityGradient(
  scrollController: scrollController,
  child: ListView(controller: scrollController, children: [...]),
)

// Or a simple static gradient:
OpacityGradient(
  direction: OpacityGradient.bottom,
  child: YourWidget(),
)
```
