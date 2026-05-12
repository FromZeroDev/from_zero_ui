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

## When making changes

- **No `package:from_zero_ui/` imports** in sub-packages — use sibling package imports
- **Each package's pubspec** must list only its own dependencies
- **Update the sub-package's README** when changing its public API or adding significant features
- **Update the root README** when adding/removing packages or when dependencies between packages change
- **Update the dependency graph section** in root README when deps change
- **Run `flutter analyze` on changed packages** to verify no errors
