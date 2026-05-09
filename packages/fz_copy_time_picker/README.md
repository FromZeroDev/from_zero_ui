# fz_copy_time_picker

A time picker dialog copied and customized from Flutter's Material time picker, used by `DatePickerFromZero`.

## Usage

```dart
import 'package:fz_copy_time_picker/fz_copy_time_picker.dart';

final time = await showTimePickerDialogFromZero(
  context: context,
  initialTime: TimeOfDay.now(),
);
```
