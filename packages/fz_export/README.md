# fz_export

Export functionality for tables: PDF, PNG, and Excel.

## Usage

```dart
import 'package:fz_export/fz_export.dart';

Export.fromTable(
  context: context,
  controller: myTableController,
  fileName: 'report',
  format: ExportFormat.pdf,
);
```
