# fz_dialog

Modal dialog system with platform-aware window support (desktop title bar, close confirmation).

## Usage

```dart
import 'package:fz_dialog/fz_dialog.dart';

showModalFromZero<void>(
  context: context,
  builder: (context) {
    return DialogFromZero(
      title: const Text('My Dialog'),
      dialogActions: [
        DialogButton.accept(
          onPressed: () => Navigator.of(context).pop(),
        ),
        DialogButton.cancel(
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  },
);
```

With API integration:

```dart
final result = await updateDao.save(
  context,
  showDefaultSnackBar: false,
);
if (!result.areUpdatesAvailable && context.mounted) {
  await showModalFromZero<void>(
    context: context,
    builder: (context) => DialogFromZero(
      title: const Text('No updates available'),
      dialogActions: [
        DialogButton.accept(onPressed: () => Navigator.of(context).pop()),
      ],
    ),
  );
}
```
