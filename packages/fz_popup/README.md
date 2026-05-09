# fz_popup

Popup menu and context menu widgets.

## Usage

```dart
import 'package:fz_popup/fz_popup.dart';

showPopupFromZero(
  context: context,
  items: [
    PopupMenuItem(child: Text('Option 1'), onTap: () {}),
    PopupMenuItem(child: Text('Option 2'), onTap: () {}),
  ],
)

// Context menu with actions
final actions = [
  ActionFromZero(title: 'Edit', icon: Icon(Icons.edit), onTap: (ctx) {}),
  ActionFromZero(title: 'Delete', icon: Icon(Icons.delete), onTap: (ctx) {}),
];
ContextMenuFromZero(actions: actions)
```
