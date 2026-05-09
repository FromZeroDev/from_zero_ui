# fz_number_format

Extended number formatting on top of `package:intl`'s `NumberFormat`.

## Improvements over default `NumberFormat`

| Feature | Default `NumberFormat` | `ExtendedNumberFormat` |
|---------|------------------------|-------------------------|
| Null values | `format(null)` throws | `format(null)` returns `''` |
| Negative zero | Formats as `"-0"` | Converts to `0` before formatting |
| NaN | Returns `"NaN"` string | Returns `''` |
| Safe formatting | `format()` can throw | `tryFormat()` / `tryParse()` catch exceptions |
| Empty placeholder | N/A | `EmptyNumberFormat` always returns `''` |
| Pre-built formatters | Must define pattern manually | 15 static formatters for common needs |

## Pre-built formatters

No need to remember pattern strings:

```dart
import 'package:fz_number_format/fz_number_format.dart';

ExtendedNumberFormat.doubleDecimalNumberFormatter.format(123.4);    // "123.40"
ExtendedNumberFormat.tripleDecimalNumberFormatter.format(123.4567); // "123.457"
ExtendedNumberFormat.noDecimalNumberFormatter.format(1234);         // "1,234"
ExtendedNumberFormat.percentageDecimalNumberFormatter.format(0.5);  // "50.00%"
ExtendedNumberFormat.percentageSingleDecimalNumberFormatter.format(0.5); // "50.0%"
ExtendedNumberFormat.emptyNumberFormatter.format(42);               // ""
```

## Usage

```dart
import 'package:fz_number_format/fz_number_format.dart';

final formatter = ExtendedNumberFormat("###,##0.00");
formatter.format(1234567.89);  // "1,234,567.89"
formatter.format(null);        // "" (no crash)
formatter.format(double.nan);  // "" (no crash)
formatter.format(-0);          // "0" (not "-0")

formatter.tryFormat('invalid'); // null (no crash)
formatter.tryParse('not a num');// null (no crash)
```
