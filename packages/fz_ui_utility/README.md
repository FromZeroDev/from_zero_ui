# fz_ui_utility

Catch-all utility widgets: responsive insets, icon button backgrounds, material key-value pairs, popup_from_zero builder, and various layout helpers.

## Notable widgets

- `ResponsiveHorizontalInsets` / `ResponsiveInsetsDialog` — Responsive padding
- `IconButtonBackground` — Circular background for icon buttons
- `MaterialKeyValuePair` — A Material key-value display row
- `OverflowScroll` — Scroll wrapper with overflow detection
- `TextIcon` — Text rendered as an icon
- `InitiallyAnimatedWidget` — Widget that plays an entrance animation once

## Usage

```dart
import 'package:fz_ui_utility/fz_ui_utility.dart';

ResponsiveHorizontalInsets(
  context: context,
  child: YourWidget(),
)
```
