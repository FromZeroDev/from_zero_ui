# fz_selectable_icon

An icon widget with a border/background that highlights on tap, useful for toolbar-like icon buttons.

## Usage

```dart
import 'package:fz_selectable_icon/fz_selectable_icon.dart';

SelectableIcon(
  icon: Icon(Icons.favorite),
  selected: isSelected,
  onTap: () => toggleSelection(),
)
```
