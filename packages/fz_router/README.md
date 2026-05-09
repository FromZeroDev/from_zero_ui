# fz_router

GoRouter extensions for FromZero scaffolding with drawer integration, route-level navigation methods, page-scaffold animations, and sticky route parameters.

> **Note on GoRouter version**: we're pinned to `go_router: 10.0.0`, an old version. Upgrading to a newer GoRouter API would require significant work — the `routerDelegate` internals changed substantially after v10, and our `Replace` extension, `OnlyOnActiveBuilder`, and navigation helpers all depend on the v10 delegate structure. This is known technical debt; PRs welcome.

## Improvements over plain `GoRouter`

### Route metadata for UI

`GoRouteFromZero` carries `title`, `subtitle`, and `icon` — metadata used by `fz_appbar` for the page title, and by `fz_drawer_menu` for sidebar entries. Plain `GoRoute` has no such metadata.

```dart
GoRouteFromZero(
  path: '/orders',
  title: 'Orders',
  subtitle: 'View and manage orders',
  icon: Icon(Icons.receipt),
  pageBuilder: (c, s) => OrdersPage(),
)
```

### Scaffold-level animations

Two routes with **different** `pageScaffoldId` trigger a full-scaffold `SharedZAxisTransition` animation instead of just animating the body. Use `pageScaffoldDepth` for parent/child relationship hints.

```dart
GoRouteFromZero(
  path: '/dashboard',
  pageScaffoldId: 'dashboard',
  builder: (context) => DashboardPage(),
)

GoRouteFromZero(
  path: '/reports',
  pageScaffoldId: 'reports',  // different ID = scaffold-level animation
  builder: (context) => ReportsPage(),
)
```

### Sticky route parameters

Override `defaultPathParameters`, `defaultQueryParameters`, or `defaultExtra` on a route to automatically append parameters to every navigation:

```dart
class MyRoute extends GoRouteFromZero {
  MyRoute()
    : super(
        path: '/items',
        builder: (context) => ItemsPage(),
      );

  @override
  Map<String, String> get defaultQueryParameters => {'from': 'nav'};
}
```

### Convenience navigation

Each route has `go()`, `push()`, and `pushReplacement()` methods:

```dart
myRoute.push(context, queryParameters: {'id': '42'});
```

Plus `GoRouter` extensions: `popUntil()`, `pushReplacementNamed()`, `pushNamedAndRemoveUntil()`, `removeLast()`.

### `OnlyOnActiveBuilder`

Pages are wrapped in `OnlyOnActiveBuilder` by default, keeping inactive routes in the widget tree without building them. This preserves scroll positions and state when navigating back. Disable with a custom `pageBuilder`.

### Route grouping

`GoRouteGroupFromZero` groups child routes with shared metadata for the drawer:

```dart
GoRouteGroupFromZero(
  title: 'Settings',
  icon: Icon(Icons.settings),
  routes: [
    GoRouteFromZero(
      path: '/settings/profile',
      title: 'Profile',
      builder: (c) => ProfilePage(),
    ),
  ],
)
```

## Drawer integration

Routes are converted to drawer items via `ResponsiveDrawerMenuItem.fromGoRoutes()` in `fz_drawer_menu`. The route's `title`, `icon`, `childrenAsDropdownInDrawerNavigation`, and `showInDrawerNavigation` control how it renders in the sidebar.

See [fz_drawer_menu](../fz_drawer_menu/) for the full flow.

## Scaffold integration

`ScaffoldFromZero` reads `pageScaffoldId` from the current `GoRouteFromZero` and plays scaffold-level transitions. `AppbarFromZero` reads `title` and `actions` from the route.

```dart
GoRouteFromZero(
  path: '/page',
  title: 'My Page',
  icon: Icon(Icons.home),
  pageScaffoldId: 'main',
  builder: (context) => ScaffoldFromZero(
    title: Text('My Page'),
    actions: myActions,
  ),
)
```

## Usage

```dart
import 'package:fz_router/fz_router.dart';

final routes = [
  GoRouteFromZero(
    path: '/dashboard',
    title: 'Dashboard',
    icon: Icon(Icons.dashboard),
    builder: (context) => DashboardPage(),
  ),
  GoRouteFromZero(
    path: '/orders',
    title: 'Orders',
    icon: Icon(Icons.receipt),
    builder: (context) => OrdersPage(),
    routes: [
      GoRouteFromZero(
        path: ':orderId',
        pageScaffoldId: 'order-detail',
        builder: (context) => OrderDetailPage(),
      ),
    ],
  ),
];
```


> **Requires** `FromZeroAppContentWrapper` at the app root for `fromZeroScreenProvider` and related providers. See [fz_scaffold](../fz_scaffold/#fromzeroappcontentwrapper----the-app-root) for setup.
