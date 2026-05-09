# fz_scrollbar

A custom scrollbar with `ScrollController` integration, thinner than Flutter's default scrollbar.

## Usage

```dart
import 'package:fz_scrollbar/fz_scrollbar.dart';

ScrollbarFromZero(
  controller: scrollController,
  child: ListView.builder(
    controller: scrollController,
    itemCount: 100,
    itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
  ),
)
```
