# fz_appbar

The FromZero app bar with window dragging (desktop), drawer toggle, and action overflow support.

## Usage

```dart
import 'package:fz_appbar/fz_appbar.dart';

AppbarFromZero(
  title: 'My App',
  actions: [
    ActionFromZero(
      title: 'Settings',
      icon: Icon(Icons.settings),
      breakpoints: {ScaffoldFromZero.screenSizeSmall: ActionState.overflow},
      onTap: (context) => Navigator.pushNamed(context, '/settings'),
    ),
  ],
)
```
