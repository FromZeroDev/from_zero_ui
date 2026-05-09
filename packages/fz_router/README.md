# fz_router

GoRouter extensions for FromZero scaffolding, including drawer integration and route grouping.

## Usage

```dart
import 'package:fz_router/fz_router.dart';

final routes = GoRouteGroupFromZero(
  drawerItem: DrawerMenuFromZero(
    title: 'Traffic',
    icon: Icon(Icons.directions_bus),
  ),
  routes: [
    GoRouteFromZero(
      path: '/et',
      pageBuilder: (context, state) => const ETPage(),
    ),
  ],
);
```
