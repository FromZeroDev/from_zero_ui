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
| [fz_tooltip](packages/fz_tooltip/) | Rich customizable tooltip widget |
| [fz_scrollbar](packages/fz_scrollbar/) | Custom thin scrollbar |
| [fz_opacity_gradient](packages/fz_opacity_gradient/) | Scroll-fade gradient masks |
| [fz_ui_utility](packages/fz_ui_utility/) | Misc widgets: responsive insets, icon backgrounds, overflow scrolls |

### Leaf / Tiny

| Package | Description |
|---------|-------------|
| [fz_animations](packages/fz_animations/) | Custom transition animations |
| [fz_animated_switcher_image](packages/fz_animated_switcher_image/) | AnimatedSwitcher with snapshot-based child transitions |
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

## Changes planned
### New Packages
### Package Separations
### Package Deletion / Merging
- fz_copy_sticky_header should be deleted in favor of using sliver_tools. This requires code changes in the packages that use it and a lot of testing.
- Consider merging some of the packages that are only depended on by one package into that package. Especially for those that aren't meant for direct consumption.

## Dependency Graph

### No dependencies (leaf packages)

```
fz_animated_switcher_image  fz_animations         fz_gesture_relayer
fz_notification_relayer     fz_copy_ensure_visible  fz_copy_page_indicator
fz_copy_sticky_header       fz_copy_time_picker     fz_file_picker
fz_hack_focus_traversal     fz_localizations        fz_log
fz_logo                     fz_number_format        fz_opacity_gradient
fz_platform                 fz_selectable_icon      fz_simple_shadow
fz_translucent_ink_well     fz_value_string         fz_web_compile_file
fz_web_initial_config       fz_web_platform_impl
```

### Dependency tree (topological, deepest first)

```
fz_value_string
 └── fz_comparable_list

fz_platform
 ├── fz_tooltip
 │    ├── fz_dialog
 │    ├── fz_appbar
 │    ├── fz_date_picker
 │    ├── fz_combo
 │    └── ...
 ├── fz_scrollbar
 /* and almost everything else */

fz_localizations
 ├── fz_theme
 │    ├── fz_ui_scale
 │    └── fz_scaffold
 ├── fz_dao
 │    └── fz_table
 │         └── fz_export
 └── (used by nearly every widget package)

fz_log
 ├── fz_scaffold
 ├── fz_api_handling
 ├── fz_dao
 ├── fz_file_saver
 ├── fz_app_update
 ├── fz_image
 └── fz_table

fz_scaffold
 ├── fz_router
 ├── fz_snackbar
 ├── fz_appbar
 ├── fz_dialog
 ├── fz_drawer_menu
 ├── fz_popup
 ├── fz_actions
 ├── fz_app_update
 ├── fz_theme
 ├── fz_export
 ├── fz_dao
 ├── fz_table
 └── fz_ui_utility

fz_dao ←→ fz_table (mutual dependency)
```

### Full dependency listing

| Package | Depends on |
|---------|-----------|
| fz_actions | fz_api_handling, fz_tooltip, fz_future_handling, fz_scaffold |
| fz_api_handling | fz_animated_switcher_image, fz_animations, fz_dialog, fz_future_handling, fz_localizations, fz_log, fz_snackbar |
| fz_appbar | fz_actions, fz_platform, fz_popup, fz_scaffold |
| fz_app_update | fz_dialog, fz_file_saver, fz_localizations, fz_log, fz_platform, fz_scaffold |
| fz_combo | fz_api_handling, fz_tooltip, fz_dao, fz_future_handling, fz_localizations, fz_popup, fz_scrollbar, fz_table, fz_ui_utility |
| fz_comparable_list | fz_value_string |
| fz_tooltip | fz_platform, fz_scrollbar |
| fz_dao | fz_actions, fz_animations, fz_api_handling, fz_appbar, fz_combo, fz_comparable_list, fz_copy_ensure_visible, fz_tooltip, fz_date_picker, fz_dialog, fz_file_picker, fz_future_handling, fz_hack_focus_traversal, fz_localizations, fz_log, fz_platform, fz_popup, fz_scaffold, fz_scrollbar, fz_selectable_icon, fz_snackbar, fz_table, fz_translucent_ink_well, fz_ui_utility, fz_value_string |
| fz_date_picker | fz_copy_time_picker, fz_tooltip, fz_localizations, fz_popup, fz_ui_utility |
| fz_dialog | fz_animations, fz_appbar, fz_tooltip, fz_future_handling, fz_localizations, fz_platform, fz_scaffold, fz_scrollbar, fz_ui_utility |
| fz_drawer_menu | fz_actions, fz_tooltip, fz_expansion_tile, fz_popup, fz_router, fz_scaffold, fz_scrollbar, fz_ui_utility |
| fz_expansion_tile | fz_actions, fz_copy_ensure_visible, fz_drawer_menu, fz_future_handling, fz_translucent_ink_well, fz_ui_utility |
| fz_export | fz_copy_page_indicator, fz_dao, fz_dialog, fz_file_saver, fz_platform, fz_scaffold, fz_table, fz_theme, fz_ui_utility, fz_value_string |
| fz_file_saver | fz_api_handling, fz_localizations, fz_log, fz_platform, fz_snackbar |
| fz_future_handling | fz_animated_switcher_image, fz_animations, fz_dialog, fz_export, fz_localizations, fz_opacity_gradient, fz_scrollbar, fz_ui_utility |
| fz_image | fz_api_handling, fz_tooltip, fz_future_handling, fz_localizations, fz_log, fz_ui_utility, fz_web_compile_file |
| fz_popup | fz_actions, fz_platform, fz_scaffold, fz_scrollbar, fz_snackbar |
| fz_router | fz_scaffold |
| fz_scaffold | fz_actions, fz_animations, fz_appbar, fz_tooltip, fz_dialog, fz_localizations, fz_log, fz_platform, fz_router, fz_scrollbar, fz_simple_shadow, fz_snackbar, fz_theme, fz_ui_utility |
| fz_scrollbar | fz_platform, fz_opacity_gradient |
| fz_snackbar | fz_api_handling, fz_tooltip, fz_dialog, fz_future_handling, fz_localizations, fz_scaffold |
| fz_table | fz_actions, fz_animations, fz_api_handling, fz_appbar, fz_comparable_list, fz_copy_ensure_visible, fz_copy_sticky_header, fz_tooltip, fz_dao, fz_date_picker, fz_dialog, fz_export, fz_future_handling, fz_localizations, fz_log, fz_notification_relayer, fz_platform, fz_popup, fz_router, fz_scaffold, fz_scrollbar, fz_selectable_icon, fz_simple_shadow, fz_ui_utility, fz_value_string |
| fz_theme | fz_app_update, fz_combo, fz_tooltip, fz_localizations, fz_scaffold, fz_ui_utility |
| fz_ui_scale | fz_theme |
| fz_ui_utility | fz_animations, fz_tooltip, fz_dialog, fz_future_handling, fz_localizations, fz_logo, fz_scaffold, fz_scrollbar, fz_simple_shadow, fz_translucent_ink_well, fz_value_string |

Packages not listed have zero internal `fz_*` dependencies.
