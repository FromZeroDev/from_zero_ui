# fz_web_platform_impl

Platform-conditional bridge for `platform_detect`. On web, re-exports `operatingSystem` (browser detection). On native, provides a stub that throws.

## What it does

`package:platform_detect` only works on web — it uses `dart:html` to read the browser's user agent. Importing it directly on native would break compilation.

This package uses conditional exports:
- **Web**: re-exports `platform_detect` — `operatingSystem` returns the browser's OS string
- **Native**: provides a stub `operatingSystem` getter that throws `UnimplementedError`

Code can import `operatingSystem` unconditionally without worrying about the target platform.

## Usage

```dart
import 'package:fz_web_platform_impl/fz_web_platform_impl.dart';

void checkPlatform() {
  try {
    final os = operatingSystem;  // works on web, throws on native
    print(os);
  } on UnimplementedError {
    // running on native
  }
}
```

Internal utility — rarely used directly.
