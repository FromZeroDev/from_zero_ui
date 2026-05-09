# fz_actions

An action system for toolbar buttons, context menus, and API operations with responsive breakpoints.

## Key types

- `ActionFromZero` — Configurable action with icon, title, breakpoints, and callback
- `ActionState` — Enum: `icon`, `text`, `iconAndText`, `overflow`, `popup`, `hidden`

## Usage

```dart
import 'package:fz_actions/fz_actions.dart';

ActionFromZero(
  title: 'Edit',
  icon: Icon(Icons.edit),
  breakpoints: {
    ScaffoldFromZero.screenSizeSmall: ActionState.overflow,
  },
  onTap: (context) {
    // handle action
  },
)
```
