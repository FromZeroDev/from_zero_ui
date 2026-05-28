# fz_snackbar

A queue-based snackbar system with typed visual states, block-UI mode, API-bound auto‑snackbars, and desktop-aware positioning.

### `SnackBarFromZero` — manual snackbar

Call `.show()` to push it into the host queue. Each snackbar has a visual **type** that sets default colors/icons:

| Type | Constant | Default icon | Default color |
|------|----------|-------------|---------------|
| Info | `SnackBarFromZero.info` | Info icon | Blue |
| Success | `SnackBarFromZero.success` | Check circle | Green |
| Error | `SnackBarFromZero.error` | Warning icon | Red |
| Loading | `SnackBarFromZero.loading` | Circular progress | Blue |
| Warning | `SnackBarFromZero.warning` | Warning icon | Orange |

Two **behaviours** control positioning:

| Behaviour | Description |
|-----------|-------------|
| `SnackBarFromZero.behaviourFixed` | Full width, attached to the bottom edge |
| `SnackBarFromZero.behaviourFloating` | Floating card with rounded corners and margin |

Key options:

- **`blockUI`** — darkens the background (via a `ValueNotifier<bool>`, so it can be toggled live)
- **`progressIndicator`** — shows a linear progress bar (with remaining time via `showProgressIndicatorForRemainingTime`)
- **`dismissable`** — whether the user can swipe it away
- **`pushScreen`** — pushes content up so the snackbar doesn't cover it
- **`width`** — fixed width (mainly for floating behaviour)
- **`actions`** — buttons / action widgets
- **`widget`** — replaces title + message with a completely custom widget
- **`onCancel`** — callback if the snackbar expires or is dismissed

```dart
SnackBarFromZero(
  context: context,
  type: SnackBarFromZero.success,
  title: Text('Saved'),
  message: Text('Item saved successfully'),
  behaviour: SnackBarFromZero.behaviourFloating,
  duration: Duration(seconds: 4),
).show();
```


### `APISnackBar` — API-bound auto-snackbar

Extends `SnackBarFromZero` and binds to an `FzNotifier<T>`. It watches the state and automatically:

- Shows a **loading** snackbar when the state is `AsyncLoading`
- Shows an **error** snackbar when the state is `AsyncError` (with details)
- Dismisses on **success** (or shows a custom success title/message)
- Controls `blockUI` based on the state and `APISnackBarBlockUIType`

```dart
APISnackBar<MyData>(
  context: context,
  stateNotifier: myFzNotifier,
  successTitle: 'Saved',
  successMessage: 'Changes saved successfully',
  cancelable: true,                // user can dismiss
  blockUIType: APISnackBarBlockUIType.whileLoadingOrError,
).show();
```

`APISnackBarBlockUIType` options:
- `never` — never block the UI
- `always` — always block
- `whileLoading` — block only while loading
- `whileLoadingOrError` — block while loading or on error (default)

### `SnackBarHostFromZero` — the queue

Wraps the app content and displays one snackbar at a time from a queue. Included automatically by `FromZeroAppContentWrapper`. The global `fromZeroSnackBarHostControllerProvider` exposes `dismiss()`, `dismissFirst()`, `dismissAll()`.

#### How the queue works

1. `snackBar.show()` finds the nearest `SnackBarHostFromZero` ancestor via `context.findAncestorStateOfType`
2. It pushes the snackbar into the host controller's queue
3. The host shows the **first** item in the queue; the rest wait
4. When a snackbar is dismissed (timeout, swipe, or programmatic `dismiss()`), the next one appears
5. If the same snackbar is shown again (identical `key`), it's treated as already displayed and skipped

> **Requires** `FromZeroAppContentWrapper` at the app root for `fromZeroScreenProvider` and related providers. See [fz_scaffold](../fz_scaffold/#fromzeroappcontentwrapper----the-app-root) for setup.
