# fz_actions

An action system for toolbar buttons, context menus, and API operations with responsive breakpoints.

## Key types

- `ActionFromZero` — Configurable action with icon, title, breakpoints, and callback
- `ActionState` — Enum: `none`, `popup`, `overflow`, `icon`, `button`, `expanded`

## Usage contexts

Actions are consumed by multiple packages, each rendering them differently:

| Context | Package | Behavior |
|---------|---------|----------|
| AppBar primary toolbar | `fz_appbar` | Renders `icon`/`button`/`expanded` inline; `overflow` goes to a popup menu; `popup` opens a sub-menu |
| AppBar bottom toolbar | `fz_appbar` | Same as primary, via `AppbarFromZero.bottomActions` |
| Context menu (right-click) | `fz_popup` | Shows all `shownOnContextMenu` actions in a popup |
| Table row actions | `fz_table` | Renders per-row action buttons; `overflow` → row context menu |
| Table column manage popup | `fz_table` | Shows column management actions in a dialog |
| Table empty widget | `fz_table` | Shows actions when the table has no data |
| Table header | `fz_table` | Global table actions in the header area |
| DAO field actions | `fz_dao` | Per-field action buttons (copy, clear, etc.) via `fieldActions` |
| Expansion tile | `fz_expansion_tile` | Action buttons in the expansion header |
| Dialog actions | `fz_dialog` | `DialogButton` wraps actions for modal dialogs |
| Drawer menu | `fz_drawer_menu` | Actions in the drawer's bottom section |
| Scaffold | `fz_scaffold` | Passes toolbar actions from routes to the AppBar |

### Responsive breakpoints

Each action declares which `ScreenFromZero` sizes it should appear in and at what `ActionState`:

```dart
ActionFromZero(
  breakpoints: {
    ScaffoldFromZero.screenSizeSmall: ActionState.overflow,
    ScaffoldFromZero.screenSizeMedium: ActionState.icon,
    ScaffoldFromZero.screenSizeLarge: ActionState.button,
  },
)
```

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
