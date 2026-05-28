# fz_flutter_riverpod

Flutter widgets for `FzNotifier` providers. Provides reactive builders that automatically handle loading, error, and data states for any `FzProviderInstance`.

## Key types

- `FzProviderBuilder<T>` — Widget that binds an `FzProviderInstance` to UI with sensible loading/error defaults
- `SliverFzProviderBuilder<T>` — Sliver variant of `FzProviderBuilder`
- `FzProviderMultiBuilder<T>` — Binds multiple providers to UI
- `FzNotifierAsyncBuilder<T>` — Widget that binds an `FzNotifier` directly (not through a provider)

## Usage

```dart
import 'package:fz_flutter_riverpod/fz_flutter_riverpod.dart';

// Use in a widget — loading and error states have sensible defaults:
FzProviderBuilder<List<MyModel>>(
  provider: myListProvider,
  dataBuilder: (context, data) => MyListView(data: data),
)

// Optionally override loading/error builders:
FzProviderBuilder<List<MyModel>>(
  provider: myListProvider,
  dataBuilder: (context, data) => MyListView(data: data),
  loadingBuilder: (context, progress, count, total) => MyCustomLoadingSpinner(progress: progress),
  errorBuilder: (context, error, stack, onRetry) => MyErrorWidget(onRetry: onRetry),
)
```

## Default loading builder

Renders `LoadingSign` from `fz_future_handling`. When a `progress` notifier is available, it shows a percentage ring.

## Default error builder

Renders `ErrorSign` from `fz_future_handling` with an icon, human-readable messages, and a retry button. You can override parts via static setters on `FzProviderBuilder`.
