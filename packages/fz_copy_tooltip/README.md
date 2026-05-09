# fz_copy_tooltip

A Material tooltip with rich customization options, scrollbar support, and platform-aware behavior.

## Usage

```dart
import 'package:fz_copy_tooltip/fz_copy_tooltip.dart';

TooltipFromZero(
  message: 'Help text',
  child: IconButton(icon: Icon(Icons.info), onPressed: () {}),
)
```

Also available as a wrapped builder method on any widget:

```dart
YourWidget().withTooltip('Tooltip text')
```
