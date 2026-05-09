# fz_selectable_icon

An icon widget with a border/background that highlights when `selected=true`, useful for icons that indicate a toggleable state (acting kinda like a switch).

## Usage

```dart
import 'package:fz_selectable_icon/fz_selectable_icon.dart';

SelectableIcon(
  icon: Icon(Icons.favorite),
  selected: isSelected,
  onTap: () => toggleSelection(),
)
```
