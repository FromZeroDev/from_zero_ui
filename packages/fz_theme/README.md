# fz_theme

The theming system for FromZero apps. Provides `ThemeParametersFromZero` with light/dark theme support, a theme switcher, locale switcher, and Hive-backed persistence.

## Setup

Override `ThemeParametersFromZero` in your app:

```dart
import 'package:fz_theme/fz_theme.dart';

class ThemeParameters extends ThemeParametersFromZero {
  @override
  ThemeData get defaultLightTheme => myLightTheme;

  @override
  ThemeData get defaultDarkTheme => myDarkTheme;
}

// In main():
themeParametersProvider = ChangeNotifierProvider((ref) => ThemeParameters());
fromZeroThemeParametersProvider = themeParametersProvider;

// In build():
MaterialApp.router(
  themeMode: themeParameters.themeMode,
  theme: themeParameters.lightTheme,
  darkTheme: themeParameters.darkTheme,
);
```

## Key components

- `ThemeParametersFromZero` — Base theme parameters with Light/Dark support
- `ThemeSwitcher` — A combo widget for selecting theme mode
- `LocaleSwitcher` — A combo widget for selecting locale
- `LoadingApp` — Loading screen shown during Hive initialization
- `initHive` — Initializes Hive with the app's settings path

## Theming cascades properly

`ThemeParametersFromZero` uses an opinionated cascade:

```
defaultLightTheme → opaqueLightTheme → lightTheme → ThemeData
defaultDarkTheme → opaqueDarkTheme → darkTheme → ThemeData
```

Each tier overrides specific properties, so you can extend any level.


> **Requires** `FromZeroAppContentWrapper` at the app root for `fromZeroScreenProvider` and related providers. See [fz_scaffold](../fz_scaffold/#fromzeroappcontentwrapper----the-app-root) for setup.
