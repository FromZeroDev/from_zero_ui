# fz_future_handling

Widgets for handling async operations with loading, error, and data states.

## Widgets

- `FutureBuilderFromZero` — Generic future builder with loading/error states
- `AsyncValueBuilder` — Riverpod `AsyncValue` builder
- `ApiProviderBuilder` — Binds an API provider to a widget
- `LoadingSign` / `ErrorSign` — Animated loading and error indicators

## Usage

```dart
import 'package:fz_future_handling/fz_future_handling.dart';

// Riverpod AsyncValue:
AsyncValueBuilder<MyData>(
  value: asyncValue,
  dataBuilder: (context, data) => MyDataWidget(data: data),
  loadingBuilder: (context) => LoadingSign(),
  errorBuilder: (context, error, stack) => ErrorSign(error),
)

// API provider:
ApiProviderBuilder<List<MyModel>>(
  provider: myListProvider,
  animatedSwitcherType: AnimatedSwitcherType.normal,
  dataBuilder: (context, data) => ListView(...),
)
```
