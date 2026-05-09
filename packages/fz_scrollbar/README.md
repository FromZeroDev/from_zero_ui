# fz_scrollbar

A wrapper around Flutter's `Scrollbar` that fixes several edge-case issues, especially on desktop. Not thinner — it IS Flutter's `Scrollbar` underneath, just with better behavior.

## Improvements over Flutter's default `Scrollbar`

| Feature | Default `Scrollbar` | `ScrollbarFromZero` |
|---------|---------------------|---------------------|
| Desktop always-visible | Breaks when controller hasn't attached yet (scrollbar never shows) | `AlwaysAttachedScrollController` provides a dummy position until the real one attaches |
| Attach/detach notifications | Controller doesn't notify on attach/detach | `ScrollControllerFromZero` notifies listeners on attach and detach |
| Layout-change updates | `ScrollMetricsNotification` is ignored | Catches and forwards `ScrollMetricsNotification` to the controller, forcing scrollbar to update on layout changes |
| Built-in opacity gradient | Wrap manually with `OpacityGradient` | Optional `applyOpacityGradientToChildren` automatically adds `ScrollOpacityGradient` at scroll edges |
| Window edge adjustment | Scrollbar position ignores window borders | `mainScrollbar: true` adjusts `crossAxisMargin` so the scrollbar doesn't overlap the window title bar when unmaximized |
| Device padding | Extends into screen notch/safe area | `ignoreDevicePadding: true` (default) removes safe area padding around the scrollbar |

## How it works

The core problem on desktop: Flutter's `Scrollbar` only shows when the controller `hasClients`. But between widget creation and the first scroll listener attachment, `hasClients` is `false` — so the scrollbar stays hidden until the user scrolls. On desktop, where scrollbars should be **always visible**, this means the scrollbar either flickers or never appears.

`AlwaysAttachedScrollController` wraps your real controller and always returns `hasClients: true`, providing a `DummyScrollPosition` as fallback. Once the real controller attaches, it delegates everything to it seamlessly.

## Usage

```dart
import 'package:fz_scrollbar/fz_scrollbar.dart';

ScrollbarFromZero(
  controller: scrollController,
  child: ListView.builder(
    controller: scrollController,
    itemCount: 100,
    itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
  ),
)

// With built-in opacity gradient:
ScrollbarFromZero(
  controller: scrollController,
  applyOpacityGradientToChildren: true, // adds ScrollOpacityGradient at edges
  opacityGradientSize: 20,
  child: ListView(controller: scrollController, children: [...]),
)

// Main window scaffold scrollbar:
ScrollbarFromZero(
  controller: scrollController,
  mainScrollbar: true,     // adjusts margin for window title bar
  ignoreDevicePadding: true, // extends to screen edge (default)
  child: Scaffold(body: ...),
)

// Always shown (even without user interaction):
ScrollbarFromZero(
  controller: scrollController,
  isAlwaysShown: true,
  child: ListView(...),
)
```
