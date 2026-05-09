# fz_drawer_menu

A responsive navigation drawer that adapts between sidebar and bottom navigation based on screen size.

## Usage

```dart
import 'package:fz_drawer_menu/fz_drawer_menu.dart';

// GoRoutes automatically integrate with the drawer:
final routes = GoRouteFromZero(
  path: '/my-page',
  drawerItem: DrawerMenuFromZero(
    title: 'My Page',
    icon: Icon(Icons.home),
  ),
  pageBuilder: (context, state) => const MyPage(),
);
```
