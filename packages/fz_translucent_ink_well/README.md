# fz_translucent_ink_well

A copy of Flutter's `InkWell` with two key changes: the hitbox no longer blocks widgets behind it, and the mouse cursor doesn't override underlying widgets when disabled.

## Differences from Flutter's default `InkWell`

| Change | Default `InkWell` | `InkWellTranslucent` |
|--------|-------------------|---------------------|
| Hitbox blocking | `GestureDetector` sits **below** the child with opaque hit testing, absorbing all pointer events — widgets behind it can't be tapped | `GestureDetector` sits **above** the child in a `Stack` with `HitTestBehavior.translucent`, letting pointers pass through to widgets behind |
| Disabled cursor | Forces `SystemMouseCursors.clickable` even when disabled | `MouseCursor.defer` — doesn't interfere with the cursor of widgets underneath |

## Why this matters

Flutter's normal `InkWell` renders its `GestureDetector` in the standard widget tree below the child. Because the `GestureDetector` absorbs hit tests, anything behind that widget area (e.g. a `ContextMenuFromZero` overlay, or a parent row's tap handler) gets blocked. This breaks contexts where a parent needs to receive taps through a child `InkWell`.

`InkWellTranslucent` fixes this by placing the `GestureDetector` on **top** of the child in a `Stack` with `HitTestBehavior.translucent`. The ink splash still renders visually, but pointer events pass through to whatever is behind.

## Usage

```dart
import 'package:fz_translucent_ink_well/fz_translucent_ink_well.dart';

Stack(
  children: [
    YourWidget(),
    Positined.fill(
      child: InkWellTranslucent(onTap: () {}),
    ),
  ],
)

// equivalent in normal flutter
InkWell(
  onTap: () {},
  child: YourWidget(),
)
```
