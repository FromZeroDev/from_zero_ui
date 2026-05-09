# fz_web_initial_config

Platform-conditional web URL config. On web, sets `PathUrlStrategy()` for clean URLs. On native, it's a no-op.

## What it does

Flutter web defaults to a hash-based URL strategy: the path after `#` is what go_router sees (`example.com/#/dashboard`). This looks ugly and breaks server-side redirects.

`initAppConfigWebSensitive()` calls `setUrlStrategy(PathUrlStrategy())` on web, which removes the hash — URLs become `example.com/dashboard`. On native platforms it does nothing, so you can call it unconditionally.

## Usage

```dart
import 'package:fz_web_initial_config/fz_web_initial_config.dart';

void main() {
  initAppConfigWebSensitive();  // call once before runApp
  runApp(MyApp());
}
```

Called automatically by `FromZeroAppContentWrapper` during setup. Rarely needed directly.
