# fz_localizations

Localization (i18n) support for FromZero apps. Loads JSON translation files from `assets/i18n/`.

## Setup

Add to your `MaterialApp.router`:

```dart
import 'package:fz_localizations/fz_localizations.dart';

MaterialApp.router(
  supportedLocales: const [Locale('es'), Locale('en')],
  localizationsDelegates: const [
    ...GlobalMaterialLocalizations.delegates,
    FromZeroLocalizations.delegate,
  ],
);
```

## Usage

```dart
final t = FromZeroLocalizations.of(context).translate('save');
```

Asset files (e.g., `assets/i18n/en.json`) contain key-value pairs:

```json
{
  "save": "Save",
  "cancel": "Cancel"
}
```
