# fz_value_string

Value wrapper types and utility widgets used throughout FromZero UI.

## Key types

- `ValueString` / `SimpleValueString` — Wraps a value with a string representation
- `ContainsValue` — A widget that can report whether it still contains a given value (used by `ComparableList` and filters)
- `NumGroupComparingBySum` / `NumGroupComparingByAverage` — Number grouping utilities
- `fromZeroDefaultShortcuts` — Default keyboard shortcuts for FromZero apps

## Usage

```dart
import 'package:fz_value_string/fz_value_string.dart';

final value = SimpleValueString(42, 'forty-two');

// Add FromZero default shortcuts to your app
MaterialApp(
  shortcuts: {
    ...WidgetsApp.defaultShortcuts,
    ...fromZeroDefaultShortcuts,
  },
  // ...
);
```
