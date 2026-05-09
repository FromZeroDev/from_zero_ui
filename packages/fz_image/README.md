# fz_image

An image widget with fullscreen zoom, pinch/double-tap gestures, hero transitions, and loading states — built on `extended_image`.

## Features

| Feature | Description |
|---------|-------------|
| Source auto-detect | `ImageSourceType.assets`, `.file`, or `.network` — inferred from the URL automatically |
| Fullscreen zoom | Pinch-zoom and double-tap with `ExtendedImageGesture` |
| Slide to dismiss | Fullscreen image swipes away with `SlideAxis.both` |
| Hero animation | Smooth hero transition between thumbnail and fullscreen view |
| Retryable loading | `retryable: true` wraps in `ApiProviderBuilder` with error+retry UI |
| Web CORS workaround | `renderAsHtmlOnWebToAvoidCors` renders as an `<img>` tag instead of a canvas |
| Web fullscreen | `fullscreenAsNewTabOnWeb` opens the image in a browser tab on web |
| Actions | `actions` rendered as a toolbar overlay, with `applySafeAreaToActions: true` |
| Progress fade-in | Loading state cross-fades to the loaded image with a 300ms curve |

## Fullscreen modes

```dart
enum FullscreenType {
  none,              // no fullscreen
  onClick,           // tap to open fullscreen
  asAction,          // fullscreen icon in the actions toolbar
  onClickAndAsAction, // both tap and icon button
}
```

## Usage

```dart
import 'package:fz_image/fz_image.dart';

// Simple network image:
ImageFromZero(
  url: 'https://example.com/photo.jpg',
)

// Fullscreen with double-tap zoom and actions:
ImageFromZero(
  url: imageUrl,
  fullscreenType: FullscreenType.onClickAndAsAction,
  gesturesEnabled: true,
  maxScale: 3.0,
  minScale: 0.8,
  retryable: true,
  heroTag: 'photo-1',
  actions: [
    TooltipFromZero(
      message: 'Open in browser',
      child: IconButtonBackground(
        child: IconButton(
          icon: Icon(Icons.open_in_browser),
          onPressed: () => launchUrl(Uri.parse(imageUrl)),
        ),
      ),
    ),
  ],
)

// Programmatically push fullscreen:
ImageFromZero.pushFullscreenImage(
  context: context,
  url: imageUrl,
  gesturesEnabled: true,
  actions: [...],
)
```
