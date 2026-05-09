# fz_scaffold

The main scaffolding for FromZero apps. Provides the app content wrapper, screen size management, responsive breakpoints, drawer integration, and window controls.

## Key components

- `FromZeroAppContentWrapper` — Wraps the entire app with providers, snackbar host, routing, and desktop window support
- `ScaffoldFromZero` — The page scaffold with app bar, drawer, and responsive layout
- `ScreenFromZero` — Screen size change notifier with `fromZeroScreenProvider`
- `WindowBar` — Custom desktop title bar with close/minimize/maximize buttons
- `CloseConfirmDialog` — Platform-aware close confirmation

## Setup (main.dart)

```dart
FromZeroAppContentWrapper.windowsProcessName = 'myapp.exe';
FromZeroAppContentWrapper.appNameForCloseConfirmation = 'My App';
initAppConfigWebSensitive();

// Override theme provider:
fromZeroThemeParametersProvider = myThemeProvider;

// In the builder:
FromZeroAppContentWrapper(
  goRouter: router,
  child: child,
)
```
