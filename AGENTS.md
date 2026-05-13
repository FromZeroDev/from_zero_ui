# AGENTS.md

Monorepo of 47 Flutter/Dart packages. Root `from_zero_ui` is a compatibility wrapper re-exporting all packages.

## Project structure

```
packages/fz_*        # 47 independent sub-packages
lib/from_zero_ui.dart # Root barrel re-exports all packages
pubspec.yaml          # Root compat package, depends on all sub-packages
```

## Package naming

All sub-packages use the `fz_` prefix. Each has:
- `pubspec.yaml` — only its own external dependencies + path deps on sibling packages
- `lib/<name>.dart` — package export
- `lib/src/` — source files
- `README.md` — description + usage examples

## Pubspec format

- **`resolution: workspace`** — all sub-packages use Dart workspace resolution (insert after `version:`, followed by a blank line before `environment:`)
- **Blank line before `environment:`**
- **Blank line between `environment:` and `dependencies:`**
- **Dependencies ordering**: `flutter` SDK dep first, then a blank line, then external deps alphabetically, then a blank line, then `fz_*` path deps alphabetically
- **No `dependency_overrides` in sub-packages** — overrides live in the root pubspec only
- **Blank line before `dev_dependencies:`**

## When making changes

- **No `package:from_zero_ui/` imports** in sub-packages — use sibling package imports
- **Each package's pubspec** must list only its own dependencies
- **Update the sub-package's README** when changing its public API or adding significant features
- **Update the root README** when adding/removing packages or when dependencies between packages change
- **Update the dependency graph section** in root README when deps change
- **Run `flutter analyze` on changed packages** to verify no errors
- **Update `lib/packages/`** when a sub-package's root export files (in `lib/`, not `src/`) change:
  - Each sub-package's main export gets one file: `lib/packages/<package_name>.dart` containing `export 'package:<package_name>/<package_name>.dart';`
  - If a sub-package has additional root-level export files (e.g. `fz_animations` has `no_fading_transitions.dart`), create a file named `<package_name>_<extra_filename_without_dart>.dart`
  - When adding a new sub-package, create all corresponding files here
