# fz_focus_traversal

Provides `SingleFocusTraversal`, a custom `FocusTraversalPolicy` for `FocusTraversalGroup`.

## Problem

A `FocusTraversalGroup` normally iterates through **all** focusable descendants when the user presses Tab. In complex form fields (like a `BoolField` with a checkbox, a label, and an error message), pressing Tab would cycle through each internal sub-widget instead of jumping to the next form field.

## Solution

`SingleFocusTraversal` overrides the traversal logic so the group behaves as if it contains only **one** focusable node. No matter what's focused inside the group, pressing Tab (or Shift+Tab) jumps directly to the specified `FocusNode`.

## How it works

```dart
// Create a policy pointing at the field's main focus node
final policy = SingleFocusTraversal(myFieldFocusNode);

// Wrap the field in a FocusTraversalGroup with that policy
FocusTraversalGroup(
  policy: policy,                 // overrides default traversal
  child: MyComplexFormField(),    // many internal widgets, but Tab goes straight to myFieldFocusNode
)
```

When focus enters the group from outside, Tab always lands on `myFieldFocusNode`. When focus is already on it, Tab exits the group normally to the next field in the parent traversal order.

## Usage

```dart
import 'package:fz_focus_traversal/fz_focus_traversal.dart';

final policy = SingleFocusTraversal(focusNode);

FocusTraversalGroup(
  policy: policy,
  child: /* form field with many internal widgets */,
)
```

Used internally by `BoolField` in `fz_dao` so Tab jumps between fields rather than cycling through the checkbox, label, and error text within a single field.
