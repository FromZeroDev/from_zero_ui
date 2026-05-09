# fz_comparable_list

Provides `ComparableList<T>` — a list-like structure that maintains comparable semantics for efficient deduplication and lookup.

Used extensively by `DAO`, `FieldList`, and table systems.

## Usage

```dart
import 'package:fz_comparable_list/fz_comparable_list.dart';

final list = ComparableList<String>();
list.add('hello');
list.add('world');
list.add('hello'); // deduplicated
```
