# fz_table

A highly customizable data table with sorting, multi-type filtering, column management, row selection, isolate-based computation, and export.

## Key types

| Type | Purpose |
|------|---------|
| `TableFromZero<T>` | The main table widget |
| `TableController<T>` | External state controller (initial filters, sort, selection) |
| `SimpleColModel<T>`, `NumColModel<T>`, `DateColModel<T>`, `BoolColModel<T>` | Column definitions with formatting, alignment, flex, filter config |
| `SimpleRowModel<T>` | Concrete row wrapper — holds the original data, child rows, selection |
| `ConditionFilter` subclasses | `FilterTextContains`, `FilterTextStartsWith`, `FilterTextEndsWith`, `FilterNumberEqualTo`, `FilterDateExactDay`, etc. |
| `RowAction<T>` | Per-row action with responsive breakpoints |

## Usage

```dart
import 'package:fz_table/fz_table.dart';

TableFromZero<MyModel>(
  rows: data.map((item) => SimpleRowModel(values: {
    'name': item.name,
    'date': item.date,
    'price': item.price,
  })).toList(),
  columns: {
    'name': SimpleColModel(
      name: 'Name',
      compactName: 'N.',
      flex: 200,
      alignment: Alignment.centerLeft,
    ),
    'date': DateColModel<MyModel>(name: 'Date', flex: 120),
    'price': NumColModel<MyModel>(
      name: 'Price',
      flex: 100,
      digitsAfterComma: 2,
      suffix: '€',
      alignment: Alignment.centerRight,
    ),
  },
  rowActions: [
    RowAction(
      title: 'Edit',
      icon: Icon(Icons.edit),
      onTap: (ctx, row, index) => editRow(row.data),
    ),
  ],
  tableController: TableController(
    initialConditionFilters: {'price': [FilterNumberGreaterThan(100)]},
    sortedColumn: 'name',
  ),
)
```

Rows use `SimpleRowModel.values` — a `Map<key, value>` where keys match the column names. The table reads `col.getValue(row, key)` to extract values.

## Features

### Sorting

Click a column header to sort. The arrow indicates ascending/descending. Null handling defaults to null-on-top via `sortNullOnTop`. Pre-set the initial sort:

```dart
TableController<T>(sortedColumn: 'name', sortedAscending: false)
```

### Filtering

Three filter mechanisms, applied in order:

**1. Condition filters** — per-column typed filters. Each `ColModel` subclass defines which filters are available via `getAvailableConditionFilters()`:

| Column type | Available condition filters |
|-------------|---------------------------|
| `SimpleColModel` (strings) | `FilterTextContains`, `FilterTextStartsWith`, `FilterTextEndsWith` |
| `NumColModel` | `FilterNumberEqualTo`, `FilterNumberGreaterThan`, `FilterNumberLessThan` |
| `DateColModel` | `FilterDateExactDay`, `FilterDateAfter`, `FilterDateBefore` |
| `BoolColModel` | (none by default) |

**Setting filters in the UI**: The table header shows a filter icon next to each column. Tapping it opens a filter popup via `showFilterPopupCallback`. The popup lists the column's available condition types — the user picks one, enters a value, and the filter is applied.

**Pre-setting filters**: Use `TableController` to start with filters already active:

```dart
TableController<MyModel>(
  initialConditionFilters: {
    'price': [FilterNumberGreaterThan(100), FilterNumberLessThan(500)],
    'name': [FilterTextContains('widget')],
  },
)
```

Multiple filters on the same column combine with AND logic.

**2. Custom row filter** — arbitrary exclusion via `extraFilters` on `TableController`:

```dart
TableController<MyModel>(
  extraFilters: [(rows) => rows.where((r) => r.data.isActive).toList()],
)
```

**3. Value filters** — each column declares an exhaustive list of `possibleValues`. Rows whose value isn't in that set are excluded. Pre-set with `initialValueFilters`:

```dart
TableController<MyModel>(
  initialValueFilters: {
    'category': {Category.foo: true, Category.bar: false}, // show foo, hide bar
  },
  initialValueFiltersExcludeAllElse: true, // exclude unlisted categories
)
```

Filters are computed in an **isolate** via `cancelable_compute`, keeping the UI responsive with many rows.

### Column management

The gear icon in the table header opens a popup where users can show/hide and reorder columns. Visibility is remembered via the table's `syncId`.

### Performance

- `enableFixedHeightForListRows: true` (default) — uses fixed-height layout for virtualized scrolling
- `enableSkipFrameWidgetForRows` — auto-enabled when row count exceeds 50, defers row rendering across frames to avoid jank
- Large `cacheExtent` to keep many rows alive in memory

### Row selection

Built-in select‑all checkbox with indeterminate state. Rows use `SimpleRowModel.selected`:

```dart
SimpleRowModel(values: {...}, selected: false)
```

### Styling

Alternating row colors (`alternateRowBackgroundBrightness`), configurable cell padding, dividers, compact column names for narrow screens, and custom cell rendering via `cellBuilder`.

### Export

Set `exportPathForExcel` to enable native export (Excel). PDF/PNG export uses `fz_export` with `widgetsKeys` and `buildExportShrunk(width)`.
