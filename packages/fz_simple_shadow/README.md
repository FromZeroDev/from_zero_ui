# fz_simple_shadow

A `CustomPainter`-based shadow that avoids the visual glitches of Flutter's built-in `BoxShadow` (particularly the corner gap between border sides).

## Usage

```dart
import 'package:fz_simple_shadow/fz_simple_shadow.dart';

Container(
  decoration: ShapeDecoration(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    shadows: const [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 8,
      ),
    ],
  ),
  child: SimpleShadowPainter(
    child: YourWidget(),
  ),
)
```
