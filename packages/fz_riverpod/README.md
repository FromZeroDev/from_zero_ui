# fz_riverpod

Core Riverpod abstractions for Flutter/Dart. Provides base notifiers for sync, async (future), and stream-based state management, progress tracking, error handling, provider caching, and utility extensions.

## Key types

- `FzNotifier<T>` — Base notifier with progress tracking, dependency watching, and retry logic
- `FzFutureNotifier<T>` — Async notifier wrapping a Future with loading/done/error states
- `FzStreamNotifier<T>` — Async notifier wrapping a Stream with partial/done/error states
- `FzNotifierBuilder<T>` — Convenience notifier with a builder function
- `FzProviderInstance<T>` — Typedef for `NotifierProvider<FzNotifier<T>, T>`
- `FzProviderFamilyInstance<T, P>` — Typedef for parameterized provider family

### Progress tracking

- `ProgressBase` — Base class for progress (count/total/progress)
- `ProgressNotifier<T>` — Manages self-progress for a single notifier
- `DerivedProgressNotifier<T>` — Aggregates progress from a notifier and its dependencies

### Error handling

- `ErrorNotifier` — Tracks error state for async notifiers
- `ErrorData` — Error and stack trace container

### Caching

- `AddDisposeDelayRef` — Extension to add a dispose delay to a provider
- `AddMaxTimeToLiveRef` — Extension to set a max TTL for provider data
- `InvalidateWhenUnpausedRef` — Extension to safely invalidate a provider
- `ReadFutureRef` — Extensions to read a future from a provider safely

## Usage

```dart
import 'package:fz_riverpod/fz_riverpod.dart';

final myProvider = ApiProvider<MyData>(
  () => FzNotifierBuilder((notifier) {
    final dependencyData = notifier.watch(someOtherProvider);
    return MyData.from(dependencyData);
  }),
);

final myFutureProvider = ApiProvider<MyData?>(
  () => FzFutureNotifierBuilder((notifier) async {
    notifier.ref.addDisposeDelay(const Duration(minutes: 5));
    notifier.ref.addMaxTimeToLive(const Duration(minutes: 60));
    return await fetchData();
  }),
);
```
