# fz_future_handling

Widgets for handling async operations with loading, error, and data states. Framework-agnostic — works with raw `Future`, Riverpod `AsyncValue`, and `FutureProvider`.

## Key types

- `LoadingSign` — Animated loading indicator with optional progress ring (0–1)
- `ErrorSign` — Error display widget with icon, title, subtitle
- `AsyncValueBuilder<T>` — Binds a Riverpod `AsyncValue<T>` to UI with loading/data/error states and animated transitions
- `AsyncValueMultiBuilder<T>` — Like `AsyncValueBuilder`, but waits for multiple providers simultaneously
- `FutureBuilderFromZero<T>` — Wraps a raw `Future<T>` with loading/error/data, keep‑previous‑data, and animated transitions
- `FutureProviderBuilder<T>` — Binds a Riverpod `FutureProvider<T>` with the same loading/error handling
- `AnimatedContainerFromChildSize` — Animated container that auto-sizes to its child content

All builders share animated transitions (`AnimatedSwitcherType`: fade, zoom, or slide), customizable loading/error builders, and keep‑previous‑data to avoid flickering.

## Usage

```dart
import 'package:fz_future_handling/fz_future_handling.dart';

// Wrap a raw Future:
FutureBuilderFromZero<List<Item>>(
  future: fetchItems(),
  keepPreviousDataWhileLoading: true,
  successBuilder: (context, data) => MyListWidget(data),
);

// Wrap a Riverpod AsyncValue:
AsyncValueBuilder<List<Item>>(
  asyncValue: ref.watch(someProvider),
  dataBuilder: (context, data) => MyListWidget(data),
);

// Custom loading widget:
LoadingSign(value: 0.5); // ring at 50 %
```
