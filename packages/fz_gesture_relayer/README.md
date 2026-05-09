# fz_gesture_relayer

Wraps a child and relays gesture events to another widget (like a `Drawer`), allowing gestures in one subtree to trigger effects in another.

## Usage

```dart
import 'package:fz_gesture_relayer/fz_gesture_relayer.dart';

GestureRelayer(
  relayTo: someGlobalKey,
  child: YourWidget(),
)
```
