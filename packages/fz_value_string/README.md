# fz_value_string

Value wrapper types that decouple the **display string** from the **sort/comparison value**. This lets tables, combos, and lists sort by the underlying typed value while displaying a formatted string.

## The core idea

Consider a table column that shows formatted prices. If you pass raw strings (`"€ 1,234.56"`, `"€ 9.99"`), sorting is lexicographic and wrong. If you pass raw numbers (`1234.56`, `9.99`), the table can sort correctly but can't display the formatted string.

`ValueString<T>` solves this: it holds both the **value** (for sorting, filtering, comparison) and the **string** (for display).

```dart
final price = ValueString(1234.56, '€ 1,234.56');

// Sorting compares the value:
price.compareTo(ValueString(9.99, '€ 9.99')) // => 1 (1234.56 > 9.99)

// Display uses the string:
print(price); // "€ 1,234.56"
```

Tables, combos, DAO fields, and filters all fall back to `toString()` for display and `value`/`compareTo` for logic. You never need to worry about the mismatch.

## Key types

| Type | Description |
|------|-------------|
| `ValueString<T>` | Holds `T value` + `String string`. Implements `Comparable` so it sorts by value. Equality matches on value only, ignoring the string. |
| `SimpleValueString<T>` | Same as `ValueString` but without `Comparable`. For cases where the value is not comparable. |
| `ValueStringNum<T extends num>` | A `ValueString` specialized for numbers: takes a value and a `NumberFormat`, auto-generates the string via `formatter.format(value)`. |
| `ContainsValue<T>` | Abstract interface. Any class implementing this can be queried for its underlying value — used by filter systems. |
| `NumGroupComparingBySum` | Wraps a list of numbers, exposing the sum as the comparison value and formatting via `NumberFormat`. |
| `NumGroupComparingByAverage` | Same as sum, but comparison value is the average. |

## Usage

```dart
import 'package:fz_value_string/fz_value_string.dart';

// Basic: separate sort value from display string
final item = SimpleValueString(42, 'forty-two');

// For a table column: ValueString handles sort + display automatically
final row = SimpleRowModel(values: {
  'name': 'Widget A',
  'price': ValueString(1234.56, '€ 1,234.56'),   // sorts numerically, displays formatted
  'stock': ValueStringNum(42, ExtendedNumberFormat.noDecimalNumberFormatter),  // auto-formatted
});
```
