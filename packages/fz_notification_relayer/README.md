# fz_notification_relayer

Re-broadcasts Flutter scroll notifications from a child to an ancestor that might not be a direct parent in the widget tree.

## Usage

```dart
import 'package:fz_notification_relayer/fz_notification_relayer.dart';

NotificationRelayer(
  relayTo: someGlobalKey,
  child: ScrollableChild(),
)
```
