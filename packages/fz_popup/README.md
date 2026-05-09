# fz_popup

Popup menu and right-click context menu, with anchor-aware positioning, animated open/close, and action inheritance. One of our coolest features.

## `showPopupFromZero`

A popup dialog attached to a widget or a screen position. Uses `showDialog` with a dismissible barrier.

### Anchored to a widget

```dart
import 'package:fz_popup/fz_popup.dart';

final anchorKey = GlobalKey();

IconButton(
  key: anchorKey,
  icon: Icon(Icons.more_vert),
  onPressed: () {
    showPopupFromZero(
      context: context,
      anchorKey: anchorKey,
      builder: (ctx) => SizedBox(
        width: 280,
        child: Column(children: [/* content */]),
      ),
    );
  },
)
```

### Anchored to a position (e.g. mouse cursor)

```dart
showPopupFromZero(
  context: context,
  referencePosition: Offset(x, y),
  referenceSize: Size(1, 1),
  builder: (ctx) => MyPopupContent(),
)
```

### Alignment options

Two parameters control positioning:

| Parameter | What it is | Default |
|-----------|-----------|---------|
| `anchorAlignment` | Point **on the anchor** where the popup attaches | `topCenter` |
| `popupAlignment` | Point **on the popup** that aligns to the anchor point | `bottomCenter` |

Think of it as placing the popup's alignment point ON the anchor's alignment point:

```
// Appear BELOW, centered (default):
anchorAlignment: topCenter    // attach to bottom-center of anchor
popupAlignment: bottomCenter  // align popup's top-center to that point

// Appear ABOVE-LEFT of anchor (context menu default):
anchorAlignment: bottomRight  // attach to bottom-right of anchor
popupAlignment: bottomRight   // align popup's bottom-right to that point

// Appear LEFT, vertically centered:
anchorAlignment: centerLeft
popupAlignment: centerRight

// Appear RIGHT, vertically centered:
anchorAlignment: centerRight
popupAlignment: centerLeft
```

### Responsive padding

The popup automatically adds safe-area padding based on screen width:
- Small screens (<612px): 0px
- Medium screens (612‒840px): 16px
- Large screens (>840px): 24px

The popup width defaults to the anchor's width + 8 (minimum 312px). All positions auto-clamp to keep the popup on-screen.

### Fine-tuning

```dart
showPopupFromZero(
  context: context,
  anchorKey: anchorKey,
  offsetCorrection: Offset(0, 4),  // nudge 4px down
  padding: EdgeInsets.all(0),       // override auto-padding
  width: 320,                       // override auto-width
  barrierColor: Colors.transparent, // invisible barrier
  builder: (ctx) => MyContent(),
)
```

## `ContextMenuFromZero`

A right-click (or long-press on mobile) context menu built on `showPopupFromZero`. Uses a custom `TransparentTapGestureRecognizer` that fires instantly instead of waiting for the tap timeout, making menus feel snappy.

### Automatic right-click / long-press

```dart
ContextMenuFromZero(
  actions: [
    ActionFromZero(
      title: 'Edit',
      icon: Icon(Icons.edit),
      onTap: (ctx) { /* edit */ },
    ),
    ActionFromZero(
      title: 'Delete',
      icon: Icon(Icons.delete),
      onTap: (ctx) { /* delete */ },
    ),
    ActionFromZero.divider(),
    ActionFromZero(
      title: 'Properties',
      icon: Icon(Icons.info),
      onTap: (ctx) { /* properties */ },
    ),
  ],
  child: MyWidget(),
)
```

Right-click (or long-press on mobile) on `MyWidget` opens the menu. Dividers between actions are automatically trimmed from the edges.

### `useCursorLocation`

When `true` (default), the menu opens at the mouse cursor position. When `false`, it opens anchored to the widget itself. This matters for programs where a widget's context menu should always appear in a fixed spot regardless of mouse position.

### `addAncestorContextMenuActions`

When `true` (default), the menu automatically inherits actions from a parent `ContextMenuFromZero` in the widget tree. Parent actions appear below a divider at the end of the menu. This means a table cell gets both its own row actions AND the table-level actions, without manual wiring.

### Programmatic trigger

If you want to control the menu manually (e.g. attached to a button click):

```dart
final contextMenuKey = GlobalKey<ContextMenuFromZeroState>();

ContextMenuFromZero(
  key: contextMenuKey,
  addGestureDetector: false,  // don't auto-trigger on right-click
  useCursorLocation: false,   // position relative to widget, not mouse
  actions: actions,
  child: MyWidget(),
)

// Trigger from a button:
onPressed: () {
  contextMenuKey.currentState!.showContextMenu();
}
```

### `ContextMenuButton`

A convenience widget that stacks an invisible `ContextMenuFromZero` behind a button:

```dart
ContextMenuButton(
  actions: actions,
  buttonBuilder: (context, onTap) => IconButton(
    icon: Icon(Icons.more_vert),
    onPressed: onTap,
  ),
)
```

## Cursor-positioned context menu on mobile

On mobile, `ContextMenuFromZero` uses a long-press instead of right-click. The menu still supports `useCursorLocation` via the long-press touch position.


> **Requires** `FromZeroAppContentWrapper` at the app root for `fromZeroScreenProvider` and related providers. See [fz_scaffold](../fz_scaffold/#fromzeroappcontentwrapper----the-app-root) for setup.
