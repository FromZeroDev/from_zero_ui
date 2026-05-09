# fz_scaffold

The main scaffolding for FromZero apps: `ScaffoldFromZero` for pages and `FromZeroAppContentWrapper` for the app root. Provides screen size management, responsive breakpoints, drawer/bottom-nav layout, desktop window controls, and providers that the rest of the ecosystem depends on.

## `ScaffoldFromZero` vs Flutter's `Scaffold`

| Feature | Flutter `Scaffold` | `ScaffoldFromZero` |
|---------|-------------------|---------------------|
| Responsive drawer | Manual | Sidebar on desktop (≥612px), hamburger drawer + bottom nav on mobile |
| App bar | Standard Material | `AppbarFromZero` with window dragging, expandable actions, context menu |
| Desktop title bar | No | Custom `WindowBar` with min/max/close on Windows |
| Compact drawer | No | `useCompactDrawerInsteadOfClose` keeps sidebar visible at reduced width |
| Bottom navigation | Manual layout | `bottomNavigationBarBuilder` auto-reacts to screen size breakpoints |
| Screen size notifiers | None | `ScreenFromZero` with `fromZeroScreenProvider` (small/medium/large/xLarge) |
| App bar elevation | Material default | Configurable `appbarElevation` with drop shadow |
| Close confirmation | `PopScope` manually | `CloseConfirmDialog` built-in |
| Android system nav bar | Manual | `androidSystemNavigationBarOverlay` + `androidSystemNavigationBarColor` |

### Integrations

`ScaffoldFromZero` wires together multiple FZ packages automatically:

- **[fz_appbar](../fz_appbar/)** — renders the app bar with actions, expandable search, context menu
- **[fz_router](../fz_router/)** — reads `GoRouteFromZero.title`, `actions`, `pageScaffoldId` from the current route
- **[fz_drawer_menu](../fz_drawer_menu/)** — passes `drawerContentBuilder` and `bottomNavigationBarBuilder`

### Usage

```dart
ScaffoldFromZero(
  title: Text('Dashboard'),
  actions: [
    ActionFromZero(
      title: 'Search',
      icon: Icon(Icons.search),
      breakpoints: {
        ScaffoldFromZero.screenSizeSmall: ActionState.expanded,
      },
      onTap: (ctx) {},
    ),
    ActionFromZero(
      title: 'Settings',
      icon: Icon(Icons.settings),
      breakpoints: {
        ScaffoldFromZero.screenSizeSmall: ActionState.overflow,
      },
      onTap: (ctx) {},
    ),
  ],
  drawerContentBuilder: (ctx) => myDrawerMenu,
  bottomNavigationBarBuilder: (ctx) => myBottomNav,
  bottomNavigationBarBreakpoint: ScaffoldFromZero.screenSizeMedium,
  appbarElevation: 3,
)
```

### Screen size breakpoints

```
screenSizeSmall   = 0    (phone portrait)
screenSizeMedium  = 612  (phone landscape / tablet)
screenSizeLarge   = 848  (tablet landscape / small desktop)
screenSizeXLarge  = 1280 (large desktop)
```

These drive responsive layout decisions: sidebar vs bottom nav, action state resolution, dialog padding, etc.

### Responsive layout: sidebar → hamburger drawer → bottom nav

The scaffold reads `fromZeroScreenProvider` (which updates on every window resize) and automatically switches between three layouts at the `screenSizeMedium` (612px) boundary:

| Screen width | Layout | Drawer behavior | Nav |
|-------------|--------|-----------------|-----|
| **Desktop** (≥612px) | Sidebar pushed into content | Sidebar visible inline, animated width via `fromZeroScaffoldChangeNotifierProvider` | None (sidebar replaces it) |
| **Mobile** (<612px) | Hamburger drawer | Standard `Drawer` slides from the left | `bottomNavigationBarBuilder` shown at the bottom |

The transition is smooth and automatic — a single `Consumer` widget watches `fromZeroScreenProvider.select((v) => v.isMobileLayout)` and rebuilds the entire layout. The sidebar width animates via `fromZeroScaffoldChangeNotifierProvider` with configurable `drawerAnimationDuration` and `drawerAnimationCurve`.

The FAB auto-repositions with `AnimatedPadding` — on desktop it's offset by the drawer width (right-justified to the content area), on mobile it's centered at the bottom above the nav bar.

`useCompactDrawerInsteadOfClose` (default `true`) keeps the sidebar visible at a reduced width instead of fully collapsing, preserving navigation context even when the user wants maximum content space.

## `FromZeroAppContentWrapper` — the app root

Wraps the entire Flutter app in `MaterialApp.router(builder:)`. It sets up three providers that the rest of the ecosystem depends on:

| Provider | Type | Purpose |
|----------|------|---------|
| `fromZeroScreenProvider` | `ScreenFromZero` | Screen dimensions, scale, breakpoint, keyboard visibility |
| `fromZeroScaffoldChangeNotifierProvider` | `ScaffoldFromZeroChangeNotifier` | Drawer state, scaffold-level animation control |
| `fromZeroAppbarChangeNotifierProvider` | `AppbarChangeNotifier` | App bar dimensions and type |

These are global `ChangeNotifierProvider`s — top-level `var` declarations in `app_content_wrapper.dart`. They must be placed **above** `FromZeroAppContentWrapper` in the widget tree.

### Packages that need it

The following packages access these providers and **require** `FromZeroAppContentWrapper` at the root:

| Package | What it needs |
|---------|--------------|
| [fz_popup](../fz_popup/) | `fromZeroScreenProvider` for UI scale correction in popup positioning |
| [fz_dialog](../fz_dialog/) | `isMouseOverWindowBar` to prevent close when clicking the title bar |
| [fz_drawer_menu](../fz_drawer_menu/) | `fromZeroScreenProvider` for responsive breakpoint; `fromZeroScaffoldChangeNotifierProvider` for drawer state |
| [fz_router](../fz_router/) | `fromZeroScaffoldChangeNotifierProvider` for scaffold-level route animations |
| [fz_snackbar](../fz_snackbar/) | `fromZeroScreenProvider` for positioning; `fromZeroAppbarChangeNotifierProvider` for avoiding app bar overlap |
| [fz_app_update](../fz_app_update/) | `FromZeroAppContentWrapper` instance for context |
| [fz_theme](../fz_theme/) | `fromZeroThemeParametersProvider` (override before wrapping) |
| [fz_ui_utility](../fz_ui_utility/) | `fromZeroScreenProvider` for responsive insets |

### Good and bad of this approach

**Good:**
- Single setup point — one widget in `main.dart`, everything else just works
- Providers are globally accessible via `ref.read(fromZeroScreenProvider)` from any widget
- Screen size, scale, and keyboard state are computed once and shared everywhere

**Bad:**
- Tight coupling — any app using FZ widgets MUST wrap in `FromZeroAppContentWrapper`, no way to opt out of specific providers
- Global mutability — `fromZeroScreenProvider` and friends are top-level `var` declarations; any code can reassign them
- Hard to test — the global providers are implicit dependencies of many widgets
- Package bloat — even lightweight packages like `fz_popup` pull in the entire `fz_scaffold` dependency tree just to read screen scale

### Setup

```dart
import 'package:fz_scaffold/fz_scaffold.dart';

// Before MaterialApp:
FromZeroAppContentWrapper.windowsProcessName = 'myapp.exe';
FromZeroAppContentWrapper.appNameForCloseConfirmation = 'My App';
fromZeroThemeParametersProvider = myThemeProvider; // override default theme

// In MaterialApp.router builder:
MaterialApp.router(
  // ...
  routerConfig: router,
  builder: (context, child) => FromZeroAppContentWrapper(
    goRouter: router,
    child: child!,
  ),
);
```
