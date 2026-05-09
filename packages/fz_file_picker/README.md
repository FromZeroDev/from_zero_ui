# fz_file_picker

A file picker widget with native `file_picker` dialog, drag-and-drop via `desktop_drop`, and DAO field integration.

## Features

| Feature | Description |
|---------|-------------|
| Native file dialog | Uses `file_picker` package on all platforms |
| Drag and drop | `enableDragAndDrop` renders a desktop drop target around the child |
| Full-screen drag | `allowDragAndDropInWholeScreen` inserts an `OverlayEntry` so files can be dropped anywhere on screen |
| Drag-only mode | `onlyForDragAndDrop` disables the tap-to-open-dialog, accepting files only via drag |
| Multiple files | `allowMultiple: true` (default) for multi-file selection |
| File type filter | `fileType` (any, image, video, audio, custom) + `allowedExtensions` list |
| Directory picking | `pickDirectory: true` for selecting folders |
| Initial directory | `initialDirectory` sets the starting folder |
| Enabled/disabled | `enabled` controls both tap and drag |

## Usage

```dart
import 'package:fz_file_picker/fz_file_picker.dart';

FilePickerFromZero(
  onSelected: (files) {
    for (final file in files) {
      print(file.path);
    }
  },
  allowMultiple: true,
  fileType: FileType.custom,
  allowedExtensions: ['.pdf', '.xlsx'],
  child: ElevatedButton.icon(
    icon: Icon(Icons.attach_file),
    label: Text('Select files'),
  ),
)
```

## DAO integration

`FileField` in `fz_dao` wraps `FilePickerFromZero` for form use:

```dart
import 'package:fz_dao/fz_dao.dart';

FileField(
  value: existingFiles,
  uiNameGetter: (field, dao) => 'Attachments',
  allowedExtensions: ['.pdf', '.jpg', '.png'],
  validatorsGetter: (field, dao) => [fieldValidatorRequired],
)
```

The field renders as a button showing file count (e.g. "3 files"), opens the picker on tap, and supports clear/remove for individual files.
