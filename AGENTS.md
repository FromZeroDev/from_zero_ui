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
- `lib/<name>.dart` — barrel export
- `lib/src/` — source files
- `README.md` — description + usage examples

## When making changes

- **Never change existing behavior** — this is a pure refactoring from a single-package library
- **No `package:from_zero_ui/` imports** in sub-packages — use sibling package imports
- **Each package's pubspec** must list only its own dependencies
- **Update the sub-package's README** when changing its public API or adding significant features
- **Update the root README** when adding/removing packages or when dependencies between packages change
- **Update the dependency graph section** in root README when deps change
- **Run `flutter analyze` on changed packages** to verify no errors

## Package layers

1. **Leaf** (0 deps) — `fz_number_format`, `fz_animations`, etc.
2. **Foundation** — `fz_value_string`, `fz_platform`, `fz_localizations`, `fz_log`
3. **Mid-level widgets** — `fz_copy_tooltip`, `fz_scrollbar`, etc.
4. **Heavy** — `fz_dao`, `fz_table`, `fz_scaffold`, `fz_export`
