# fz_notification_relayer

Relays Flutter notifications (e.g. `ScrollNotification`, `ScrollUpdateNotification`) from one widget subtree to an ancestor in a different part of the widget tree. This allows scroll events happening inside a child to be picked up by a `ScrollController` or `NotificationListener` that isn't a direct parent.

Sibling to [fz_gesture_relayer](../fz_gesture_relayer/) which does the same for raw pointer events.

## How it works

Same three-piece pattern as `fz_gesture_relayer`:

1. **`NotificationRelayController`** — a shared bridge with a `shouldRelay` filter. Create one and pass it to both widgets.
2. **`NotificationRelayListener`** — the **source**. Wrap it around the widget whose notifications you want to capture. When a notification bubbles up through the listener, it calls `shouldRelay()` on the controller, and if it returns `true`, sends the notification to all registered receivers.
3. **`NotificationRelayer`** — the **bridge**. Place it near the target ancestor. When it receives a relayed notification from the controller, it calls `notification.dispatch(context)`, which walks UP the widget tree from the `NotificationRelayer`'s position, triggering any ancestor `NotificationListener` that matches the notification type.

## Why

Flutter notifications bubble up through the widget tree — but they can only reach **ancestors**. If your scroll widget and your scroll controller are in different branches of the tree (e.g., inside a `Stack`, `Overlay`, or across a `Navigator` boundary), the notification never reaches the controller. This package bridges that gap.

## Usage

```dart
import 'package:fz_notification_relayer/fz_notification_relayer.dart';

// 1. Create a shared controller with a filter
final controller = NotificationRelayController(
  (notification) => notification is ScrollNotification,
);

// 2. SOURCE: wrap the widget whose scroll events you need
NotificationRelayListener(
  controller: controller,
  consumeRelayedNotifications: false, // still let them bubble normally
  child: ListView.builder(
    controller: localScrollController,
    itemCount: 100,
    itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
  ),
)

// 3. BRIDGE: place near the target NotificationListener
NotificationRelayer(
  controller: controller,
  child: SizedBox.shrink(), // invisible bridge
)

// 4. TARGET: somewhere above NotificationRelayer in the tree
NotificationListener<ScrollNotification>(
  onNotification: (notification) {
    // receives scroll events from the ListView in step 2
    return false;
  },
  child: NotificationRelayer(controller: controller, child: ...),
)
```

## Comparison with fz_gesture_relayer

| | `fz_notification_relayer` | `fz_gesture_relayer` |
|---|---|---|
| What it relays | `Notification` (Flutter's notification system) | `PointerEvent` (raw touch/mouse events) |
| How it reaches target | `notification.dispatch(context)` — walks up the tree | `context.visitAncestorElements()` — finds nearest `Listener` |
| Filtering | `shouldRelay` function on the controller | No filtering — all pointer events relayed |
| Consumption | Optional `consumeRelayedNotifications` | No consumption option |
