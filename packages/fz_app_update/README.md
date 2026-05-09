# fz_app_update

App update checking and installation for Windows (MSI) and Android (APK). Uses a DAO-based workflow for checking updates via API.

## Usage

```dart
import 'package:fz_app_update/fz_app_update.dart';

final updateDao = DAO<CheckUpdateResults>(
  uiNameGetter: (dao) => '',
  classUiNameGetter: (dao) => '',
  onSaveAPI: (context, e) => checkForUpdatesApi(context),
);
final results = await updateDao.save(context, showDefaultSnackBar: false);
if (results.updateExecution != null) {
  await results.updateExecution!();
}
```
