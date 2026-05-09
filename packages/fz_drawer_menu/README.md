# fz_drawer_menu

Responsive navigation that adapts between a sidebar (desktop/tablet) and a bottom navigation bar (mobile), with tree-style expansion and go_router integration.

## Responsive behavior

`DrawerMenuFromZero` itself renders the sidebar menu (expansion tiles, tree items, dividers). The **scaffold** (`fz_scaffold`) handles the responsive switch:

| Screen width | Layout | How |
|-------------|--------|-----|
| ≥ `bottomNavigationBarBreakpoint` (612px default) | Sidebar drawer | `drawerContentBuilder` renders `DrawerMenuFromZero` |
| < `bottomNavigationBarBreakpoint` | Bottom nav bar | `bottomNavigationBarBuilder` renders a `BottomNavigationBar` |

Items provide `asBottomNavigationBarItem()` so the same `ResponsiveDrawerMenuItem` list works in both modes. On mobile the hamburger menu still opens a drawer for secondary actions.

## Route integration

Define your routes with icons and titles, then convert them to drawer items:

```dart
import 'package:fz_router/fz_router.dart';
import 'package:fz_drawer_menu/fz_drawer_menu.dart';

// Step 1: define routes with metadata
final routes = [
  GoRouteFromZero(
    path: '/dashboard',
    title: 'Dashboard',
    icon: Icon(Icons.dashboard),
    pageBuilder: (c, s) => DashboardPage(),
  ),
  GoRouteFromZero(
    path: '/orders',
    title: 'Orders',
    icon: Icon(Icons.receipt),
    pageBuilder: (c, s) => OrdersPage(),
  ),
  GoRouteGroupFromZero(
    title: 'Settings',
    icon: Icon(Icons.settings),
    routes: [
      GoRouteFromZero(
        path: '/settings/profile',
        title: 'Profile',
        pageBuilder: (c, s) => ProfilePage(),
      ),
    ],
  ),
];

// Step 2: convert to drawer items
final menuItems = ResponsiveDrawerMenuItem.fromGoRoutes(
  routes: routes,
  excludeRoutesThatDontWantToShow: true,
);
```

## Scaffold integration

Pass items to the scaffold that handles both sidebar and bottom nav:

```dart
ScaffoldFromZero(
  drawerContentBuilder: (context) => DrawerMenuFromZero(
    tabs: menuItems,
    useGoRouter: true,
  ),
  // Optional: bottom nav for mobile (uses same items)
  bottomNavigationBarBuilder: (context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewPadding.bottom),
    child: BottomNavigationBar(
      items: menuItems.map((e) => e.asBottomNavigationBarItem()).toList(),
      currentIndex: currentIndex,
      onTap: (i) { /* navigate */ },
    ),
  ),
)
```

## Tree mode

Set `style: DrawerMenuFromZero.styleTree` for a tree-style navigation with indentation and connecting lines:

```dart
DrawerMenuFromZero(
  tabs: menuItems,
  style: DrawerMenuFromZero.styleTree,
  depth: 0,
)
```

## Programmatic navigation

Items navigate via go_router by default. Set `pushType` for custom behavior:

- `DrawerMenuFromZero.go` — default, router navigation
- `DrawerMenuFromZero.push` — pushes a new route
- `DrawerMenuFromZero.replace` — replaces current route


> **Requires** `FromZeroAppContentWrapper` at the app root for `fromZeroScreenProvider` and related providers. See [fz_scaffold](../fz_scaffold/#fromzeroappcontentwrapper----the-app-root) for setup.
