# fz_copy_ensure_visible

> **Primarily for internal use** by DAO fields and expansion tiles — rarely needed directly.

Ensures a focused widget is visible in the scroll viewport, copied and customized from Flutter's `_EnsureVisibleWhenFocused`.

**Difference from Flutter's built-in**: exposed as a public reusable widget instead of an internal-only mixin, so DAO form fields can automatically scroll into view when focused.
