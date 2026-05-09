# fz_future_handling

Widgets for handling async operations with loading, error, and data states.

## Three builder types

### `ApiProviderBuilder` (recommended)

The recommended way to bind async state to UI. Wraps a Riverpod `ApiProvider<T>` and handles loading/error/data with sensible defaults (progress‑aware `LoadingSign`, context‑sensitive `ErrorSign` with retry, animated transitions). Provides progress tracking, retry, and state caching.

```dart
import 'package:fz_api_handling/fz_api_handling.dart';
import 'package:fz_future_handling/fz_future_handling.dart';

final myProvider = ApiProvider<List<Item>>(
  (ref) => ApiState(ref, (state) async {
    state.selfTotalNotifier.value = 3;
    // ... fetch with progress updates ...
    return items;
  }),
);

// In widget:
ApiProviderBuilder<List<Item>>(
  provider: myProvider,
  dataBuilder: (context, data) => ListView.builder(
    itemCount: data.length,
    itemBuilder: (ctx, i) => Text(data[i].name),
  ),
)
```

### `AsyncValueBuilder`

Binds a Riverpod `AsyncValue<T>` directly. Use when you already have an `AsyncValue` (e.g. from `.watch()` on a provider) and don't need the full API provider machinery. Simple cases only.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fz_future_handling/fz_future_handling.dart';

final myValue = ref.watch(someProvider);

AsyncValueBuilder<List<Item>>(
  asyncValue: myValue,
  dataBuilder: (context, data) => MyListWidget(data),
  // Defaults to LoadingSign / ErrorSign if not overridden
)
```

### `FutureBuilderFromZero`

Wraps a raw `Future<T>`. For compatibility with non-Riverpod code or simple API-less futures. Lacks progress tracking, retry, and the full reactivity of the Riverpod-based builders.

```dart
import 'package:fz_future_handling/fz_future_handling.dart';

FutureBuilderFromZero<List<Item>>(
  future: fetchItems(),
  initialData: cachedItems,
  keepPreviousDataWhileLoading: true,
  successBuilder: (context, data) => MyListWidget(data),
)
```

## Shared features

All three builders share:
- **Animated transitions** — `AnimatedSwitcherType` controls fade/zoom/slide between loading → data
- **Keep-previous-data** — `keepPreviousDataWhileLoading` / `addLoadingStateAsValueKeys` avoids flickering
- **Customizable loading/error** — override `loadingBuilder`, `errorBuilder`, `transitionBuilder`
