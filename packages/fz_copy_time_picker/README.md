# fz_copy_time_picker

> **Primarily for internal use** by `fz_date_picker` — use `DatePickerFromZero` to get both date and time in one widget.

A time picker dialog copied and customized from Flutter's Material time picker.

**Difference from Flutter's built-in**: customized styling and integrated with `DatePickerFromZero` for unified date+time picking.

## Usage

```dart
import 'package:fz_copy_time_picker/fz_copy_time_picker.dart';

final time = await showTimePickerDialogFromZero(
  context: context,
  initialTime: TimeOfDay.now(),
);
```
