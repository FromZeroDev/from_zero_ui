# fz_ui_scale

A slider for adjusting the UI scale of the entire application. Ranges from 1.0× to 1.5× with 10 divisions.

## The problem with Flutter's OS text scaling

`MediaQuery.textScaleFactorOf(context)` reads the OS accessibility zoom setting. Flutter applies it by **only scaling text** — leaving icons, buttons, spacers, and layout at their original size. At 1.5×, text becomes gigantic while everything else stays tiny. The result looks broken and disproportionate.

## What `fromZeroScreenProvider.scale` does

Instead of scaling only text, the scale is distributed across both text and layout by the `FromZeroAppContentWrapper`:

```dart
final extraScale = (scale - 1).clamp(0, 0.5);   // e.g. 1.5 → 0.5
final textScale = 1 + (extraScale * 0.3);        // text grows mildly (1.15)
final uiScale = 1 - (extraScale * 0.7);          // screen size shrinks (0.65)

MediaQuery.of(context).copyWith(
  textScaleFactor: textScale,
  size: screenSize * uiScale,                     // everything appears larger
);
```

The zoom is split 30% to text enlargement and 70% to viewport shrink, which together make the **entire UI** scale up proportionally — buttons, icons, spacers, and text grow together, keeping the design intact.

## How the picker works

Two modes:

- **Default** (checkbox checked) — uses the OS text scale factor, clamped to 1.0‒1.5. The slider is disabled.
- **Custom** (checkbox unchecked) — the user picks a specific value. The slider is enabled.

The value is persisted to Hive (`'ui_scale'`) and applied to `fromZeroScreenProvider.scale`. It's restored on app restart.

## Usage

```dart
import 'package:fz_ui_scale/fz_ui_scale.dart';

UiScalePicker()
```

Included automatically in the theme settings page (`fz_theme`). No manual setup needed.

> **Requires** `FromZeroAppContentWrapper` at the app root for `fromZeroScreenProvider`. See [fz_scaffold](../fz_scaffold/#fromzeroappcontentwrapper----the-app-root) for setup.
