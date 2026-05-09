# fz_gesture_relayer

Relays pointer events (down and signal) from one widget subtree to a `Listener` in another part of the tree. This allows a touch or drag in one area to trigger a gesture handler somewhere else.

Sibling to [fz_notification_relayer](../fz_notification_relayer/) which does the same for Flutter notifications.

## How it works

The pattern uses three pieces:

1. **`GestureRelayController`** — a shared bridge that holds the list of listeners. Create one and pass it to both widgets.
2. **`GestureRelayListener`** — the **source**. Wrap it around the widget where the user's touch originates. It captures `onPointerDown` and `onPointerSignal` and sends them via the controller.
3. **`GestureRelayer`** — the **bridge**. Place it near the target. When it receives a relayed event from the controller, it walks up the widget tree looking for the first `Listener` ancestor and fires its callback.

## Usage

```dart
import 'package:fz_gesture_relayer/fz_gesture_relayer.dart';

// 1. Create a shared controller
final controller = GestureRelayController();

// 2. SOURCE: wrap the widget that should trigger the gesture
GestureRelayListener(
  controller: controller,
  child: AreaWhereUserTouches(...),
)

// 3. BRIDGE: place near the target Listener's subtree
GestureRelayer(
  controller: controller,
  child: AreaNearTheTargetWhereEventsShouldBeRelayed(...),
)

// 4. TARGET: somewhere above the GestureRelayer in the tree:
Listener(
  onPointerDown: (event) { /* triggered by the relayed touch */ },
  child: GestureRelayer(
    controller: controller,
    child: ...,
  ),
)
```

The typical use case is relaying drag gestures to a `Drawer` from outside its bounds — for example, dragging from the edge of the screen to open a responsive drawer.
