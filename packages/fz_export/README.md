# fz_export

Export tables and custom content to PDF, PNG, or Excel, with auto‑export (insta‑save) or user‑choice dialogs.

## Export types

### PDF

Renders each page as a Flutter widget via the `pdf` package, capturing table rows, headers, and custom layouts into a multipage PDF document. Supports:
- Page size selection (Letter, A4, 4:3, 16:9)
- Portrait / landscape orientation
- Scale factor
- Page-by-page navigation for preview

### PNG

Captures the rendered widget tree as a high-resolution image. Each page is rendered at `devicePixelRatio × page dimensions` for sharp output. The same size/orientation/scale controls apply.

### Excel

Uses the `excel` package. Requires a `excelSheets: () => Map<String, TableController>` callback mapping sheet names to `TableController` instances. The export reads column definitions and cell data directly from the table controller.

## Usage modes

### Auto-export (insta-save)

Default behavior. Renders and saves the file immediately without showing any UI:

```dart
import 'package:fz_export/fz_export.dart';

Export(
  path: outputPath,
  title: 'Report',
  scaffoldContext: scaffoldContext,
  childBuilder: (context, index, size, portrait, scale, format) {
    return MyExportPage(index: index);
  },
  childrenCount: (size, portrait, scale, format) => totalPages,
  themeParameters: myTheme,
)
```

The widget is typically embedded inside a `showModalFromZero` dialog, auto-exports on frame load, and pops the navigator when done.

### Dialog with user choice

Set `autoExport: false` to show a format picker letting the user choose:

```dart
Export(
  path: outputPath,
  title: 'Report',
  scaffoldContext: scaffoldContext,
  childBuilder: ...,
  childrenCount: ...,
  themeParameters: myTheme,
  autoExport: false,  // show picker UI
  isPdfFormatAvailable: true,
  isPngFormatAvailable: true,
  actions: [
    ExportButton(...), // custom action buttons
  ],
)
```

The dialog shows a page preview with size, orientation, scale, and format (PDF/PNG) controls before the user presses export.

### Excel only

```dart
Export.excelOnly(
  path: '/path/to/report.xlsx',
  title: 'Excel Report',
  scaffoldContext: context,
  excelSheets: () => {
    'Sheet 1': tableController1,
    'Sheet 2': tableController2,
  },
)
```

### Table integration

The most common use case — export a table directly from its `TableController`:

```dart
// PDF/PNG from a table
showModalFromZero<void>(
  context: context,
  builder: (context) => Export.scrollable(
    path: '/path/to/export.pdf',
    title: 'Report',
    scaffoldContext: context,
    themeParameters: themeProvider,
    isPdfFormatAvailable: true,
    isPngFormatAvailable: true,
    scrollableChildBuilder: (context, index, size, portrait, scale, format, scrollController) {
      return SingleChildScrollView(
        controller: scrollController,
        child: myTableController.buildExportShrunk(size.width),
      );
    },
    significantWidgetsKeys: myTableController.widgetsKeys,
  ),
);
```
