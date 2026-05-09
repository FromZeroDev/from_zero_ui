# fz_localizations

Localization (i18n) for FromZero apps. Loads JSON translation files and provides a simple `translate(key)` API.

## Setup

Add the delegate in `MaterialApp.router`:

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

## How loading works

The `load()` method has two sources, tried in order:

```dart
// 1. Try the package's bundled translations first
try {
  jsonString = await rootBundle.loadString(
    'packages/from_zero_ui/assets/i18n/${locale.languageCode}.json',
  );
} catch (_) {
  // 2. If not found, fall back to the app's own assets/i18n/ folder
  jsonString = await rootBundle.loadString(
    'assets/i18n/${locale.languageCode}.json',
  );
}
```

The root `from_zero_ui` package bundles `en.json` and `es.json`. This means:

- **English and Spanish work out of the box** — zero setup needed
- The fallback (`assets/i18n/`) is only reached for **languages the package doesn't bundle**

## Usage

```dart
final t = FromZeroLocalizations.of(context).translate('save');
// → "Save" (en) or "Guardar" (es)
```

## Good and bad of this approach

**Good:**
- `en` and `es` work immediately with no configuration
- Adding a **new language** (e.g. `fr`) is straightforward: extend `isSupported`, add `assets/i18n/fr.json` to your app, register it in your pubspec.yaml
- No code changes to the package needed for new languages

**Bad:**
- You **cannot add custom keys to an existing language** (`en`/`es`) without copying ALL the built-in keys into your app's `assets/i18n/` folder. Even then, the package's file loads first, so your copy would never be used (the fallback only triggers when the package file is missing).
- You **cannot override individual translations** in a built-in language — the package file always takes priority.
- There is no merging of translations from multiple sources.

## Adding a new language

```dart
// Extend the delegate to accept additional locales
class MyAppLocalizationsDelegate extends _FromZeroLocalizationsDelegate {
  @override
  bool isSupported(Locale locale) {
    return super.isSupported(locale) || ['fr'].contains(locale.languageCode);
  }
}
```

```json
// assets/i18n/fr.json — the package has no French file, so the fallback loads your file
{
  "save": "Enregistrer",
  "cancel": "Annuler",
  "delete": "Supprimer",
  "my_custom_key": "Ma clé personnalisée"
}
```

```yaml
# your app's pubspec.yaml
flutter:
  assets:
    - assets/i18n/
```

Then use your delegate in `localizationsDelegates` instead of `FromZeroLocalizations.delegate`.

## If you need to customize existing-language translations

The package doesn't support partial overrides out of the box. Options:

1. **Copy** the package's JSON files into your app's `assets/i18n/`, modify them, and **remove** the package's asset registration (not recommended — it's fragile across updates)
2. **Create a separate localization class** that loads its own JSON and merges translations programmatically with `FromZeroLocalizations`
3. **Use an extension method** on `FromZeroLocalizations` that falls back to a hardcoded map for your custom keys
