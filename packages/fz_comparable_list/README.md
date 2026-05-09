# fz_comparable_list

List wrappers with deep equality semantics, useful for Riverpod provider families and list fields.

## Why

Flutter's default `List` equality is reference-based — two identically-valued lists are not equal. This matters when passing lists as arguments to Riverpod provider families, where argument equality controls when the provider re-fetches.

## Types

- **`DeepEqualityList<T>`** — Wraps a `List<T>` with deep equality via `DeepCollectionEquality`. Pass this to a provider family to avoid unnecessary re-fetches when the list contents haven't changed.
- **`ComparableList<T>`** — Wraps a `List<T extends Comparable>` with `copyWith`/`clone` support. Used by `ListField` in the DAO system.
- **`ComparableListBase<T>`** — Abstract base implementing `Comparable` and `ContainsValue<List<T>>`.

## Usage

```dart
import 'package:fz_comparable_list/fz_comparable_list.dart';

// Avoid re-fetching a provider when the list contents are unchanged:
final myProvider = FutureProvider.family<Data, DeepEqualityList<String>>((ref, ids) {
  return fetchByIds(ids.list);
});

// Pass a DeepEqualityList to the provider:
final result = ref.watch(myProvider(DeepEqualityList(list: ['a', 'b', 'c'])));

// Working with a ComparableList in a ListField:
final list = ComparableList<String>(list: ['foo', 'bar']);
list.add('baz');
final copy = list.copyWith(deepCopy: true);
```
