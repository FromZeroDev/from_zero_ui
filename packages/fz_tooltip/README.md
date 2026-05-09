# fz_tooltip

A Material tooltip with rich customization and desktop-aware behavior, forked and customized from Flutter's built-in `Tooltip`.

## Improvements over Flutter's default `Tooltip`

| Feature | Default `Tooltip` | `TooltipFromZero` |
|---------|-------------------|-------------------|
| Scrollable content | No | Tooltip content wraps in a `ScrollbarFromZero` when it overflows |
| Desktop hover timing | Same for all platforms | Shorter show delays and longer display duration on desktop |
| Timing customization | `waitDuration`, `showDuration` | Same, with platform-sensitive defaults |
| Styling | `decoration`, `textStyle`, `height`, `padding`, `margin`, `verticalOffset` | All available |
| Rich content | Text only | Any widget via `richMessage` |
| Theme integration | `TooltipTheme` | Same plus custom defaults |

## Usage

```dart
import 'package:fz_tooltip/fz_tooltip.dart';

TooltipFromZero(
  message: 'Helpful explanation text',
  child: IconButton(icon: Icon(Icons.info), onPressed: () {}),
)

// With rich content and custom styling:
TooltipFromZero(
  richMessage: Row(children: [
    Icon(Icons.warning, size: 16),
    Text('Rich tooltip'),
  ]),
  decoration: BoxDecoration(
    color: Colors.red.shade50,
    borderRadius: BorderRadius.circular(8),
  ),
  child: MyWidget(),
)
```
