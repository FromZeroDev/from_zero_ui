# fz_expansion_tile

A Material expansion tile copied and customized from Flutter, used in DAO form views and the drawer menu.

## Differences from Flutter's default `ExpansionTile`

| Feature | Default `ExpansionTile` | `ExpansionTileFromZero` |
|---------|-------------------------|-------------------------|
| Programmatic control | `initiallyExpanded` only | `expanded` + `onPostExpansionChanged` for external state control |
| Prevent expansion | No | `onExpansionChanged` returns `FutureOr<bool>` — return `false` to block |
| Context menu | No | `contextMenuActions` + `addExpandCollapseContextMenuAction` for right-click |
| Ink well | Default Material | `InkWellTranslucent` (translucent splash) |
| Enabled/disabled | N/A | `enabled` + `inkWellEnabled` separately |
| Styling modes | N/A | `style` parameter for alternative render modes |
| Focus visibility | No | Auto-scrolls into view via `fz_copy_ensure_visible` |
| Border radius | N/A | `borderRadius` parameter |
| Title builder | N/A | `titleBuilder: (context, expanded) => ...` for dynamic titles |
| Children expansion | N/A | `childrenKeysForExpandCollapse` to expand/collapse nested tiles |

## Usage

```dart
import 'package:fz_expansion_tile/fz_expansion_tile.dart';

// Controlled externally:
ExpansionTileFromZero(
  title: Text('Advanced Options'),
  expanded: isExpanded,
  onExpansionChanged: (expanding) async {
    if (expanding && !hasData) return false; // block expansion
    setState(() => isExpanded = expanding);
    return true;
  },
  onPostExpansionChanged: (isExpanded) {
    // called after animation completes
  },
  children: [
    ListTile(title: Text('Option 1')),
    ListTile(title: Text('Option 2')),
  ],
)

// With context menu:
ExpansionTileFromZero(
  title: Text('Group'),
  addExpandCollapseContextMenuAction: true,
  contextMenuActions: [
    ActionFromZero(title: 'Select all', icon: Icon(Icons.select_all), onTap: (_) {}),
  ],
  children: [...],
)
```
