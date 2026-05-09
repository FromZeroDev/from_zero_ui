# fz_log

Logging utilities providing a configurable `log()` function and the `FzLgType` enum for categorizing log messages.

## Usage

```dart
import 'package:fz_log/fz_log.dart';

log(
  LgLvl.error,
  'Error while saving',
  e: exception,
  st: stackTrace,
  type: FzLgType.dao,
);
```

## Customizing logging

Override the global `log` function:

```dart
log = (level, msg, {type, e, st, data, extraTraceLineOffset, details}) {
  // Custom logging logic...
};
```
