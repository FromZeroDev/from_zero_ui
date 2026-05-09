# fz_date_picker

A date and time picker widget and dialog, with inline form integration and DAO field support.

## Improvements over Flutter's default `showDatePicker`

| Feature | Default `showDatePicker` | `DatePickerFromZero` |
|---------|--------------------------|----------------------|
| Widget type | Dialog only | Inline widget (`DatePickerFromZero`) or dialog (`showDatePickerDialogFromZero`) |
| Form embedding | Requires manual wiring | Built-in focus node, enabled/disabled, form-ready |
| Button render | N/A | Renders as a button showing the selected date, with `buttonChildBuilder` for full customization |
| Clear / reset | N/A | `clearable` + `showClearButton` to reset to `null` |
| Popup from button | N/A | Opens a popup anchored to the button |
| Time picker | Separate dialog | `DateTimePickerType.time` mode integrates directly |
| DAO integration | No | Used as `DateField` in `fz_dao` form views |
| Tooltips | No | Built-in tooltip via `fz_tooltip` |

## Usage

```dart
import 'package:fz_date_picker/fz_date_picker.dart';

// Inline widget (for forms):
DatePickerFromZero(
  value: selectedDate,
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  onSelected: (value) => setState(() => selectedDate = value),
  clearable: true,
)

// Dialog:
final date = await showDatePickerDialogFromZero(
  context: context,
  initialDate: DateTime.now(),
);

// Time mode:
DatePickerFromZero(
  value: selectedTime,
  type: DateTimePickerType.time,
  onSelected: (value) { /* TimeOfDay.fromDateTime(value) */ },
)

// As a DAO field:
DateField(
  value: originalModel?.fecha,
  uiNameGetter: (field, dao) => 'Date',
  includeTime: true,
  clearableGetter: (field, dao) => false,
  validatorsGetter: (field, dao) => [fieldValidatorRequired],
)
```
