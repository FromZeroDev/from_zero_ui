# fz_app_update

App update checking and installation for Windows (MSI/exe) and Android (APK).

## Flow

1. **Create** an `UpdateFromZero` instance with your current version, a JSON endpoint URL, and a download URL
2. **Check** — call `checkUpdate()` which fetches the version JSON, reads the platform-specific version number, and sets `updateAvailable`
3. **Prompt or execute** — if `updateAvailable`, call `promptUpdate(context)` to show a dialog, or `executeUpdate(context)` to download and install directly

## Usage

```dart
import 'package:fz_app_update/fz_app_update.dart';

final update = UpdateFromZero(
  currentVersion,                              // e.g. 42
  '${baseUrl}/update/version.json',           // JSON endpoint
  '${baseUrl}/update/app.apk',                // download URL
  dio: myDio,                                  // optional custom Dio instance
);

// Option 1: pre-load version info (if you already fetched it)
update.versionInfo = preloadedJson;
await update.checkUpdate();

// Option 2: let checkUpdate() fetch it
await update.checkUpdate();

if (update.updateAvailable) {
  // Prompt the user with a dialog
  final didUpdate = await update.promptUpdate(context);

  // Or download and install without a prompt
  await update.executeUpdate(context);
}
```

## Version JSON format

The endpoint should return JSON with per-platform version numbers:

```json
{
  "windows": 43,
  "android": 42,
  "ios": 41,
  "windows_last_supported": 30,
  "android_last_supported": 28
}
```

- `checkUpdate()` reads the key matching the current platform (`getPlatformString()`)
- `updateAvailable` is `true` when the server version exceeds `currentVersion`
- The `{platform}_last_supported` fields can be used to force outdated apps to update

## Hint: blocking UI during check

If you need to block the UI while checking (e.g. on app startup), wrap the flow in a DAO save:

```dart
final dao = DAO<CheckUpdateResults>(
  uiNameGetter: (_) => '',
  classUiNameGetter: (_) => '',
  onSaveAPI: (context, _) => FzNotifier.noProvider((state) {
    // ... checkForUpdates logic ...
  }),
);
final results = await dao.save(context, showDefaultSnackBar: false);
if (results != null && results.updateExecution != null) {
  await results.updateExecution!();
}
```

This lets the `FzProviderBuilder` show a loading indicator while the version check runs.


> **Requires** `FromZeroAppContentWrapper` at the app root for `fromZeroScreenProvider` and related providers. See [fz_scaffold](../fz_scaffold/#fromzeroappcontentwrapper----the-app-root) for setup.
