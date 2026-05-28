# fz_dio_flutter_riverpod

Flutter widgets for Dio error handling. Provides Dio-aware error display functions and the `PartialSuccessError` class.

## Key types

- `FzDioProviderBuilder` — Static methods that provide Dio-specific error icons, titles, subtitles, and retryability
- `PartialSuccessError<T>` — Error class representing a partial success (e.g., some items saved successfully while others failed)

## Usage

```dart
import 'package:fz_dio_flutter_riverpod/fz_dio_flutter_riverpod.dart';

// Override default error display for Dio-specific errors:
FzProviderBuilder.getErrorIcon = FzDioProviderBuilder.defaultGetErrorIcon;
FzProviderBuilder.getErrorTitle = FzDioProviderBuilder.defaultGetErrorTitle;
FzProviderBuilder.getErrorSubtitle = FzDioProviderBuilder.defaultGetErrorSubtitle;
FzProviderBuilder.isErrorRetryable = FzDioProviderBuilder.defaultIsErrorRetryable;
FzProviderBuilder.shouldShowErrorDetails = FzDioProviderBuilder.defaultShouldShowErrorDetails;

// Use PartialSuccessError:
throw PartialSuccessError(result: partialData, titleOverride: 'Some items failed');
```
