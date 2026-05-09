# fz_appbar

The FromZero app bar with window dragging (desktop), drawer toggle, action overflow, and expandable action support.

## Key features

- **Desktop window integration** — drags the window, shows min/max/close buttons
- **Responsive actions** — actions resolve to `icon`, `button`, `expanded`, or `overflow` based on available width
- **Expandable actions** — one action can expand to fill the title area (e.g. a search bar)
- **Context menu** — right-click on the app bar shows all contextual actions
- **Overflow menu** — overflowed actions collapse into a `ContextMenuButton` popup

## How actions work

Actions are `ActionFromZero` widgets that declare `breakpoints` mapping `ScreenFromZero` size categories to `ActionState` values. The app bar's `LayoutBuilder` measures the available width and resolves each action's state:

| State | Behavior |
|-------|----------|
| `none` | Hidden entirely |
| `popup` | Only shown in the context menu (right-click) |
| `overflow` | Moved to the overflow popup menu |
| `icon` | Shown as an icon button |
| `button` | Shown as a Material text button |
| `expanded` | Replaces the title area with the action's expanded widget |

Overflow actions collapse into a single `···` icon button. If there's only one overflow action with an icon, it stays in the toolbar instead.

## Usage

```dart
import 'package:fz_appbar/fz_appbar.dart';
import 'package:fz_actions/fz_actions.dart';

AppbarFromZero(
  title: Text('My App'),
  mainAppbar: true,             // enables window dragging and min/max/close
  mainAppbarShowButtons: true,  // show title bar buttons on desktop
  addContextMenu: true,         // right-click shows context menu
  actions: [
    ActionFromZero(
      title: 'Search',
      icon: Icon(Icons.search),
      breakpoints: {
        ScaffoldFromZero.screenSizeSmall: ActionState.expanded,
        ScaffoldFromZero.screenSizeMedium: ActionState.icon,
        ScaffoldFromZero.screenSizeLarge: ActionState.icon,
      },
      onTap: (context) { /* start search */ },
    ),
    ActionFromZero(
      title: 'Settings',
      icon: Icon(Icons.settings),
      breakpoints: {
        ScaffoldFromZero.screenSizeSmall: ActionState.overflow,
      },
      onTap: (context) { /* open settings */ },
    ),
  ],
)
```

## Expandable actions

When an action has `ActionState.expanded` in its breakpoints, it replaces the title with a custom widget. Use `initialExpandedAction` to start with an action already expanded:

```dart
final controller = AppbarFromZeroController();

AppbarFromZero(
  controller: controller,
  initialExpandedAction: searchAction,
  onExpanded: (action) { /* action expanded */ },
  onUnexpanded: () { /* action collapsed */ },
  actions: [searchAction, ...otherActions],
)

// Programmatically collapse:
controller.setExpanded?.call(null);
```

## Scaffold integration

When using `ScaffoldFromZero`, actions are passed through automatically:

```dart
ScaffoldFromZero(
  title: pageTitle,
  actions: myActions,
  initialExpandedAction: mySearchAction,
  onAppbarActionUnexpanded: () { /* cleanup */ },
)
```
