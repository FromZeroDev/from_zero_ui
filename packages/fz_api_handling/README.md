# fz_api_handling

API state management with Riverpod and Dio for CRUD operations. `ApiState<T>` manages the lifecycle of an async fetch — it tracks progress (via `ValueNotifier`s for totals and percentages), retries, and exposes its loading/data/error state. Widgets bound to it via `ApiProviderBuilder` react automatically to every state change.

## Key types

- `ApiState<T>` — A `StateNotifier` that runs an async fetch, tracks progress, and exposes `AsyncValue<T>` state
- `ApiProvider<T>` — Typedef for `AutoDisposeStateNotifierProvider<ApiState<T>, AsyncValue<T>>`
- `ApiProviderBuilder<T>` — Widget that binds an `ApiProvider` to UI with sensible loading/error defaults

## Usage

```dart
import 'package:fz_api_handling/fz_api_handling.dart';
import 'package:fz_future_handling/fz_future_handling.dart';

// Define a provider with a fetch that updates progress:
final myListProvider = ApiProvider<List<MyModel>>(
  (ref) => ApiState(ref, (state) async {
    state.selfTotalNotifier.value = 3;           // 3 steps total
    state.selfProgressNotifier.value = 0;

    final page1 = await fetchPage(1);
    state.selfProgressNotifier.value = 1;
    // ↑ updates the loading indicator in real time

    final page2 = await fetchPage(2);
    state.selfProgressNotifier.value = 2;

    final page3 = await fetchPage(3);
    state.selfProgressNotifier.value = 3;

    return [...page1, ...page2, ...page3];
  }),
);
// Or you can use a download progress (downloaded vs. total to show progress)

// Use in a widget — loading and error states have sensible defaults:
ApiProviderBuilder<List<MyModel>>(
  provider: myListProvider,
  dataBuilder: (context, data) => MyListView(data: data),
)

// Optionally override loading/error builders:
ApiProviderBuilder<List<MyModel>>(
  provider: myListProvider,
  dataBuilder: (context, data) => MyListView(data: data),
  loadingBuilder: (context, progress) => MyCustomLoadingSpinner(progress: progress),
  errorBuilder: (context, error, stack, onRetry) => MyErrorWidget(onRetry: onRetry),
)

// Progress/retry graph is automatically inherited when watching other providers through your state
final dependentProvider = ApiProvider<MyData>(
  (ref) => ApiState(ref, (state) async {
    final deps = await state.watch(dependentProvider);
    return myFetch(deps);
  }),
);
```

## Default loading builder

The default `loadingBuilder` renders `LoadingSign` from `fz_future_handling` — a spinning indicator. When the `ApiState` provides a `progress` notifier (double 0‒1), it shows a percentage ring. No configuration needed — it just works.

## Default error builder

The default `errorBuilder` renders `ErrorSign` from `fz_future_handling` with:
- **Icon** — context-sensitive based on the error type (Dio status codes, timeouts, etc.)
- **Title + subtitle** — human-readable messages
- **Retry button** — calls `state.retry(ref)` to re-run the fetch
- **Details button** (debug only) — shows the raw error/stack trace

You can override any part via static setters on `ApiProviderBuilder`:
```dart
ApiProviderBuilder.getErrorIcon = (context, error, stack) => myErrorIcon;
ApiProviderBuilder.getErrorTitle = (context, error, stack) => 'Oops';
```
