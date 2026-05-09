# fz_snackbar

A snackbar system with support for API-bound snackbars, block-UI mode, and status types (info, success, error, loading).

## Key types

- `SnackBarFromZero` — Custom snackbar widget with typed status
- `SnackBarHostFromZero` — Manages the snackbar queue and animation
- `APISnackBar` — Snackbar tied to an `ApiState` notifier (auto-dismisses on load/error/success)

## Usage

```dart
import 'package:fz_snackbar/fz_snackbar.dart';

// Manual snackbar:
SnackBarFromZero(
  context: context,
  title: 'Success',
  message: 'Item saved successfully',
  type: SnackBarFromZero.success,
);

// API-bound snackbar:
APISnackBar(
  context: context,
  stateNotifier: myApiState,
  successTitle: 'Saved',
  successMessage: 'Changes saved',
);
```
