# fz_riverpod

Core Riverpod abstractions for async state management. `FzNotifier<T>` is the base class — the others build on it. It tracks dependencies between providers, aggregates progress across them, handles errors, and provides retry. Widgets in `fz_flutter_riverpod` react to every state change automatically.

## Key types

- `FzNotifier<T>` — Base notifier with dependency tracking, progress aggregation, and retry logic. Use for sync providers or as the root for async ones.
- `FzFutureNotifier<T>` — Async notifier wrapping a `Future<T>`. Exposes loading/done/error status, keeps previous data while reloading.
- `FzStreamNotifier<T>` — Async notifier wrapping a `Stream<T>`. Exposes loading/partial/done/error status.

## Usage

```dart
import 'package:fz_riverpod/fz_riverpod.dart';

// Async provider with progress and caching:
final myListProvider = FzProvider<List<MyModel>?>(
  () => FzFutureNotifierBuilder((notifier) async {
    notifier.selfProgress.notifier.setValues(0, 3);
    final page1 = await fetchPage(1);
    notifier.selfProgress.notifier.setValues(1, 3);

    final page2 = await fetchPage(2);
    notifier.selfProgress.notifier.setValues(2, 3);

    final page3 = await fetchPage(3);
    notifier.selfProgress.notifier.setValues(3, 3);

    notifier.ref.addDisposeDelay(const Duration(minutes: 5));
    notifier.ref.addMaxTimeToLive(const Duration(minutes: 60));
    return [...page1, ...page2, ...page3];
  }),
);

// Watching dependencies — progress/retry graph is inherited automatically:
final dependentProvider = FzProvider<DerivedData?>(
  () => FzFutureNotifierBuilder((notifier) async {
    final deps = await notifier.watchFuture(dependencyProvider);
    return await transform(deps);
  }),
);

// Stream-based provider:
final streamProvider = FzProvider<Event?>(
  () => FzStreamNotifierBuilder((notifier) {
    return eventStream.map((e) => Event.from(e));
  }),
);
```

## Provider caching

Two extensions cover all caching needs — no separate `cacheTime`, `staleTime`, or `refetchInterval` concepts:

```dart
final myProvider = FzProvider<Data?>(
  () => FzFutureNotifierBuilder((notifier) async {
    final result = await fetchData();
    notifier.ref.addDisposeDelay(const Duration(minutes: 5));
    notifier.ref.addMaxTimeToLive(const Duration(minutes: 60));
    return result;
  }),
);
```

- Navigating away for less than 5 minutes? Data still there — no refetch.
- Gone longer than 5 minutes? Provider disposes, freeing memory.
- Page open for over 60 minutes? Provider auto-invalidates and re-fetches on next rebuild.

Note: usually, you want to call the cache functions right before returning, after all your async operations finished. This way, if the provider loses all its watchers before it finishes, it will be disposed immediately and won't be cached.
