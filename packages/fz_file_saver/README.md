# fz_file_saver

Cross-platform file saving with progress tracking, download snackbars, automatic duplicate handling, and platform-specific workarounds.

## Platform annoyances it solves

| Platform | Problem | Solution |
|----------|---------|----------|
| **Web** | No filesystem access | Creates a browser download via `Blob` + invisible anchor click |
| **Windows** | No standard Downloads folder path | Uses `PlatformExtended.getDownloadsDirectory()` (Documents folder) |
| **Android** | Storage permissions required | Calls `requestDefaultFilePermission()` automatically |
| **All** | Filename collisions | Appends ` (2)`, ` (3)`, etc. when a file already exists |
| **All** | Invalid characters in filename | `sanitizeFilename()` cleans up before saving |
| **All** | Concurrency | Tracks ongoing downloads by hash, rejects duplicates |
| **All** | File associations | `open_filex` opens saved files, `pasteboard` copies paths |

## Features

- **Progress snackbar** — auto-shows download progress with percentage and cancel button
- **Result snackbar** — success/failure with open-file and copy-path actions (8s duration)
- **Auto-open** — `autoOpenOnFinish: true` or set `saveFileFromZeroDefaultAutoOpenOnFinish` globally
- **Multiple downloads** — `multipleDownloads` + `multipleDownloadsNames` for batch saves with unified result snackbar
- **Cancellation** — user can cancel mid-download from the progress snackbar
- **Custom success messages** — `successTitle` and `successMessage` override defaults

## Usage

```dart
import 'package:fz_file_saver/fz_file_saver.dart';

// Basic save with progress:
await saveFileFromZero(
  context: context,
  data: () async => myBytes,
  pathAppend: 'reports',
  name: 'monthly_report.pdf',
  downloadedAmount: myProgressNotifier,
  fileSize: myTotalNotifier,
  autoOpenOnFinish: true,
);

// Batch download:
await saveFileFromZero(
  context: context,
  name: 'batch',
  data: () => downloadFile(currentIndex),
  multipleDownloads: [download1, download2, download3],
  multipleDownloadsNames: ['file_a.pdf', 'file_b.pdf', 'file_c.pdf'],
);

// Global default:
saveFileFromZeroDefaultAutoOpenOnFinish = true;
```
