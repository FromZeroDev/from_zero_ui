# from_zero_ui

UI generalizations and utility classes for Flutter, now split into modular packages for granular imports.

This is the root compatibility package — importing `from_zero_ui` gives you everything. For more selective imports, use the individual packages below.

## Packages

### Scaffolding & App Setup

| Package | Description |
|---------|-------------|
| [fz_scaffold](packages/fz_scaffold/) | App content wrapper, screen size management, responsive breakpoints, drawer, window controls |
| [fz_theme](packages/fz_theme/) | Theme system (light/dark), theme switcher, locale switcher, Hive-backed persistence |
| [fz_router](packages/fz_router/) | GoRouter extensions with drawer integration and route grouping |
| [fz_appbar](packages/fz_appbar/) | App bar widget with window dragging, drawer toggle, action overflow |
| [fz_drawer_menu](packages/fz_drawer_menu/) | Responsive navigation drawer (sidebar on desktop, bottom nav on mobile) |
| [fz_localizations](packages/fz_localizations/) | i18n support with JSON translation files |

### Data & Tables

| Package | Description |
|---------|-------------|
| [fz_dao](packages/fz_dao/) | Data Access Objects: CRUD, form fields, validation |
| [fz_table](packages/fz_table/) | Highly customizable data table with sorting, filtering, selection |
| [fz_export](packages/fz_export/) | Table export to PDF, PNG, Excel |
| [fz_api_handling](packages/fz_api_handling/) | Riverpod-based API state management with Dio |
| [fz_future_handling](packages/fz_future_handling/) | Async UI widgets (loading, error, data states) |

### Widgets

| Package | Description |
|---------|-------------|
| [fz_combo](packages/fz_combo/) | Combo box / dropdown with search and multi-select |
| [fz_popup](packages/fz_popup/) | Popup menu and context menu widgets |
| [fz_dialog](packages/fz_dialog/) | Modal dialog system with desktop title bar support |
| [fz_snackbar](packages/fz_snackbar/) | Snackbar system with API binding and block-UI mode |
| [fz_date_picker](packages/fz_date_picker/) | Date picker with optional time selection |
| [fz_file_picker](packages/fz_file_picker/) | File picker with drag-and-drop support |
| [fz_image](packages/fz_image/) | Image widget with fullscreen zoom |
| [fz_actions](packages/fz_actions/) | Action system for toolbar buttons and context menus |
| [fz_expansion_tile](packages/fz_expansion_tile/) | Material expansion tile (customized) |
| [fz_ui_scale](packages/fz_ui_scale/) | UI scale/zoom slider |

### Utilities

| Package | Description |
|---------|-------------|
| [fz_platform](packages/fz_platform/) | Platform detection (web-safe), desktop window support |
| [fz_log](packages/fz_log/) | Configurable logging with log-level filtering |
| [fz_value_string](packages/fz_value_string/) | Value wrappers, keyboard shortcuts, utilities |
| [fz_comparable_list](packages/fz_comparable_list/) | Deduplicating comparable list |
| [fz_copy_tooltip](packages/fz_copy_tooltip/) | Rich customizable tooltip widget |
| [fz_scrollbar](packages/fz_scrollbar/) | Custom thin scrollbar |
| [fz_opacity_gradient](packages/fz_opacity_gradient/) | Scroll-fade gradient masks |
| [fz_ui_utility](packages/fz_ui_utility/) | Misc widgets: responsive insets, icon backgrounds, overflow scrolls |

### Leaf / Tiny

| Package | Description |
|---------|-------------|
| [fz_animations](packages/fz_animations/) | Custom transition animations |
| [fz_simple_shadow](packages/fz_simple_shadow/) | CustomPainter-based shadow |
| [fz_selectable_icon](packages/fz_selectable_icon/) | Selectable icon with highlight state |
| [fz_logo](packages/fz_logo/) | FromZero brand logo |
| [fz_number_format](packages/fz_number_format/) | Extended number formatting |
| [fz_gesture_relayer](packages/fz_gesture_relayer/) | Gesture event relay between widget subtrees |
| [fz_notification_relayer](packages/fz_notification_relayer/) | Scroll notification re-broadcasting |
| [fz_translucent_ink_well](packages/fz_translucent_ink_well/) | Translucent-splash InkWell |
| [fz_hack_focus_traversal](packages/fz_hack_focus_traversal/) | Focus traversal hack |
| [fz_copy_ensure_visible](packages/fz_copy_ensure_visible/) | Ensure focused widget visibility |
| [fz_copy_page_indicator](packages/fz_copy_page_indicator/) | Arrow page indicator |
| [fz_copy_sticky_header](packages/fz_copy_sticky_header/) | Sliver sticky header |
| [fz_copy_time_picker](packages/fz_copy_time_picker/) | Time picker dialog |

### Web & File

| Package | Description |
|---------|-------------|
| [fz_web_compile_file](packages/fz_web_compile_file/) | Platform-conditional file creation for web |
| [fz_web_initial_config](packages/fz_web_initial_config/) | Platform-conditional initial config for web |
| [fz_web_platform_impl](packages/fz_web_platform_impl/) | Platform-conditional web implementations |
| [fz_file_saver](packages/fz_file_saver/) | File saving with native dialogs |
| [fz_app_update](packages/fz_app_update/) | App update checking and installation |

## Quick start

Import everything:

```dart
import 'package:from_zero_ui/from_zero_ui.dart';
```

Or import only what you need:

```dart
import 'package:fz_dao/fz_dao.dart';
import 'package:fz_table/fz_table.dart';
```

Add individual packages to your `pubspec.yaml`:

```yaml
dependencies:
  fz_dao:
    path: packages/fz_dao
  fz_table:
    path: packages/fz_table
```
