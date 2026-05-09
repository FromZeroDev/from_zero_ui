# fz_platform

Platform detection and utilities. Provides `PlatformExtended` with web-safe platform checks and `windowsDesktopBitsdojoWorking` for desktop window support.

## Usage

```dart
import 'package:fz_platform/fz_platform.dart';

if (PlatformExtended.isMobile) {
  // iOS or Android
} else if (PlatformExtended.isWindows) {
  if (PlatformExtended.appWindow != null) {
    appWindow.maximize();
  }
}

// Override download directory
PlatformExtended.customDownloadsDirectory = '/path/to/downloads';
final dir = await PlatformExtended.getDownloadsDirectory();
```
