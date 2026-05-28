# fz_dio_riverpod

Dio integration with Riverpod. Extends `FzFutureNotifier` with Dio-specific features like cancel tokens and `onReceiveProgress` callback.

## Key types

- `FzDioFutureNotifierBase<T>` — Base class for Dio-based future notifiers with cancel token management
- `FzDioFutureNotifier<T>` — Convenience notifier with a builder function

## Usage

```dart
import 'package:fz_dio_riverpod/fz_dio_riverpod.dart';

final myProvider = FzProvider<MyData?>(
  () => FzDioFutureNotifier((notifier) async {
    final cancelToken = CancelToken();
    notifier.addCancelToken(cancelToken);

    final response = await dio.get(
      '/api/data',
      cancelToken: cancelToken,
      onReceiveProgress: notifier.onReceiveProgress,
    );
    return MyData.fromJson(response.data);
  }),
);
```
