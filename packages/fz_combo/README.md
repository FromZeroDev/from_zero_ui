# fz_combo

A combo box / dropdown widget with search, multiple selection, and table integration.

## Usage

```dart
import 'package:fz_combo/fz_combo.dart';

ComboFromZero<MyModel>(
  values: items,
  selectedValue: selected,
  onChanged: (value) => setState(() => selected = value),
  displayString: (item) => item.name,
)
```

Searching a fixed list of values ignores dots and commas by default, so typing `IVA` matches `I.V.A. 21%`. Pass `ignorePunctuationInSearch: false` to compare the text as-is. Filters supplied via `filteredValues`/`filteredValuesFuture`/`filteredValuesProvider` receive the raw query.

Also available as a DAO field:

```dart
ComboField<DAO<MyModel>>(
  value: dao,
  uiNameGetter: (field, dao) => 'My Field',
  possibleValuesProviderGetter: (context, field, dao) => myProvider.daos,
  validatorsGetter: (field, dao) => [fieldValidatorRequired],
)
```
