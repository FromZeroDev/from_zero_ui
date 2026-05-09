# fz_table

A highly customizable data table system built on top of DAO.

## Key types

- `TableFromZero<T>` — The table widget
- `TableController<T>` — Controls table state (sorting, filtering, selection)
- `SimpleColModel` — Column definitions with flex, alignment, etc.
- `RowModel` — Row data model
- `TableFromZeroManagePopup` — Built-in column management popup
- `TableEmptyWidget` — Empty state with actions

## Usage

```dart
import 'package:fz_table/fz_table.dart';

TableFromZero<MyModel>(
  controller: TableController(
    data: items,
    columns: {
      'name': SimpleColModel(name: 'Name', flex: 200),
      'date': DateColModel(name: 'Date', flex: 120),
    },
    buildRow: (context, row, index) { ... },
    buildRowFilter: (context, controller) => DefaultFilter(...),
  ),
)

// With export:
TableFromZero<MyModel>(
  controller: controller,
  exportPathForExcel: '/path/to/export.xlsx',
)
```
