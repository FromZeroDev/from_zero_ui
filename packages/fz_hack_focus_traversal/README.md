# fz_hack_focus_traversal

A hack to force `FocusTraversalGroup` to include a widget tree that wasn't originally part of the ancestor focus group, used in complex layouts like modal dialogs with embedded form fields.

## Usage

```dart
import 'package:fz_hack_focus_traversal/fz_hack_focus_traversal.dart';

HackFocusTraversalGroupFix(
  child: YourFormField(),
)
```

Internal utility — rarely needed directly.
