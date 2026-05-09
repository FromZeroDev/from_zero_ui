# fz_file_saver

File saving with native download dialogs and auto-open support.

## Usage

```dart
import 'package:fz_file_saver/fz_file_saver.dart';

await saveFileFromZero(
  context: context,
  bytes: fileBytes,
  fileName: 'document.pdf',
);

// Configure global behavior:
saveFileFromZeroDefaultAutoOpenOnFinish = true;
```
