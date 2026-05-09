# fz_dialog

Modal dialog system with desktop title bar integration, custom transitions, responsive insets, and rich button support.

## `showModalFromZero` vs Flutter's `showDialog`

| Feature | `showDialog` | `showModalFromZero` |
|---------|-------------|---------------------|
| Default transition | `DialogRoute` (platform-adaptive) | `FadeScaleTransition` with custom barrier color |
| Desktop title bar | No | `WindowBar` shown on Windows when `showWindowBarOnDesktop: true` |
| Barrier color hack | Opacity-based fade | Separate `ColoredBox` + `ScaleTransition` — avoids the default DialogRoute's fade-over-scale glitch |
| Default config | `barrierDismissible: false` | `FromZeroModalConfiguration` with `barrierDismissible: true` |
| Transition duration | 150ms default | Same, with separate reverse duration (75ms) |

`showModalFromZero` is a thin wrapper around `showModal` from the `animations` package, presetting `FromZeroModalConfiguration` that includes the desktop window bar.

## `DialogFromZero` vs Flutter's `Dialog` / `AlertDialog`

| Feature | `Dialog` / `AlertDialog` | `DialogFromZero` |
|---------|---------------------------|------------------|
| Title bar | `AlertDialog.title` | `title` + optional `appBarActions` renders an inline `AppbarFromZero` with close button |
| Custom app bar | No | `appBar` parameter to replace the entire title bar |
| Action buttons | `AlertDialog.actions` lists widgets | `dialogActions` with `Wrap` alignment options, auto-wrapper inside `DefaultDialogAction` |
| Static overflow scrolling | Manual | Built-in `OverflowScroll` wraps content |
| Responsive insets | Default Material padding | `useReponsiveInsets: true` adds `ResponsiveInsetsDialog` on smaller screens |
| Max width | Via `ConstrainedBox` manually | `maxWidth` parameter built-in |
| Ctrl+Enter shortcut | No | `acceptCallback` auto-bound — last `DialogButton.accept` gets triggered |
| Content padding | Via `titlePadding`/`contentPadding` | Single `contentPadding` (default 16px horizontal) |

## Dialog buttons

```dart
// Accept button (right-aligned, default text "Accept")
DialogButton.accept(
  onPressed: () => Navigator.of(context).pop(true),
)

// Cancel button (default text "Cancel")
DialogButton.cancel(
  onPressed: () => Navigator.of(context).pop(),
)

// Custom button
DialogButton(
  child: Text('Delete'),
  color: Colors.red,
  onPressed: () { /* ... */ },
  tooltip: 'Delete this item',
)

// With leading icon
DialogButton.accept(
  leading: Icon(Icons.save),
  onPressed: () { /* ... */ },
)
```

Buttons auto-wrap via `Wrap` with configurable alignment. Accept/cancel constructors provide default localized text via `FromZeroLocalizations`.

## Usage

```dart
import 'package:fz_dialog/fz_dialog.dart';

// Simple confirm dialog
final confirmed = await showModalFromZero<bool>(
  context: context,
  builder: (context) => DialogFromZero(
    title: const Text('Confirm'),
    content: const Text('Are you sure?'),
    dialogActions: [
      DialogButton.cancel(onPressed: () => Navigator.of(context).pop(false)),
      DialogButton.accept(onPressed: () => Navigator.of(context).pop(true)),
    ],
  ),
);

// With scrollable content and wide layout
await showModalFromZero<void>(
  context: context,
  builder: (context) => DialogFromZero(
    title: const Text('Settings'),
    appBarActions: [mySettingsAction],
    content: Column(children: [ /* many fields */ ]),
    maxWidth: 800,
    useReponsiveInsets: true,
    dialogActions: [
      DialogButton.accept(onPressed: () => Navigator.of(context).pop()),
    ],
  ),
);
```
