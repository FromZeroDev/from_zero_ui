# fz_api_handling

API state management with Riverpod and Dio for CRUD operations.

## Key types

- `ApiState<T>` — A Riverpod `StateNotifier` that manages async data fetching
- `ApiProvider<T>` — Typedef for `StateNotifierProvider<ApiState<T>, AsyncValue<T>>`
- `ApiProviderBuilder<T>` — Widget that binds an `ApiProvider` to UI

## Usage

```dart
import 'package:fz_api_handling/fz_api_handling.dart';

// Define a provider:
final myListProvider = ApiProvider<List<MyModel>>(
  (ref) => ApiState(apiFetchList: myApi.fetchList),
);

// Use in a widget:
ApiProviderBuilder<List<MyModel>>(
  provider: myListProvider,
  dataBuilder: (context, data) => MyListView(data: data),
)
```
