# fz_opacity_gradient

Applies a fading gradient mask to content edges — like a "content continues here" indicator — without requiring a scroll container. Comes in a static version and a scroll-aware dynamic version.

## How it works

Both widgets use `ShaderMask` + `BlendMode.dstIn` to fade content toward transparent at the edges. They render nothing on web (`kIsWeb` returns the child as-is, since web scroll bars are native and the fade would look wrong).

### `OpacityGradient` — static version

Fades content at one or two edges with a fixed size or percentage. Not tied to scroll — works on any widget.

| Direction constant | Fades at |
|-------------------|----------|
| `left` | Left edge |
| `right` | Right edge |
| `top` | Top edge |
| `bottom` | Bottom edge |
| `horizontal` | Both left and right |
| `vertical` | Both top and bottom |

```dart
OpacityGradient(
  direction: OpacityGradient.bottom,
  size: 20,    // fade out 20px at the bottom edge
  child: Text('...'),
)
```

### `ScrollOpacityGradient` — dynamic version

Same fade effect, but the gradient size dynamically adjusts based on the `ScrollController`'s scroll position. When the user is **at the very top**, the top fade is zero; as they scroll down, the top fade grows (capped at `maxSize`). Same for the bottom. This gives a natural "more content here" visual cue.

- `applyAtStart: true` — fade when not at the top (or left)
- `applyAtEnd: true` — fade when not at the bottom (or right)
- Set either to `false` to disable that edge entirely

```dart
ScrollOpacityGradient(
  scrollController: scrollController,
  maxSize: 16,
  direction: OpacityGradient.vertical,
  applyAtStart: true,
  applyAtEnd: true,
  child: ListView.builder(
    controller: scrollController,
    itemCount: 100,
    itemBuilder: (ctx, i) => ListTile(title: Text('Item $i')),
  ),
)
```

## Usage

```dart
import 'package:fz_opacity_gradient/fz_opacity_gradient.dart';

// Static: always fade the bottom 20px
OpacityGradient(
  direction: OpacityGradient.bottom,
  size: 20,
  child: YourWidget(),
)

// Dynamic: fade top/bottom only when not at scroll edges
ScrollOpacityGradient(
  scrollController: myScrollController,
  direction: OpacityGradient.horizontal, // fade left/right
  child: SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    controller: myScrollController,
    child: Row(children: [...]),
  ),
)
```
