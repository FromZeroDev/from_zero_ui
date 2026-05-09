# fz_date_picker

A date picker with optional time selection.

## Usage

```dart
import 'package:fz_date_picker/fz_date_picker.dart';

final date = await showDatePickerDialogFromZero(
  context: context,
  initialDate: DateTime.now(),
);

// As a DAO field:
DateField(
  value: originalModel?.fecha,
  uiNameGetter: (field, dao) => 'Date',
  includeTime: true,
  clearableGetter: (field, dao) => false,
  validatorsGetter: (field, dao) => [fieldValidatorRequired],
)
```
