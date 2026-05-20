// References:
// https://github.com/rrousselGit/riverpod/issues/1664
// https://codeberg.org/lucavenir/riverpod_suite/src/commit/b7c64202f71e301962c517998c41c789a4938f18/packages/riverpod_swiss_knife/lib/src/ref/add_dispose_delay.dart

import "dart:async";

import "package:flutter/widgets.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:fz_api_handling/src/api_provider.dart";

/// Extension on [Ref] to add a dispose delay.
extension AddDisposeDelayRef on Ref {
  /// Adds a delay before disposing the provider when all listeners are removed.
  ///
  /// This results in the provider being kept alive for at least the specified
  /// [delay] duration after the last listener is removed.
  void addDisposeDelay(Duration delay) {
    final link = keepAlive();

    Timer? timer;

    onCancel(() {
      timer = Timer(delay, link.close);
    });
    onResume(() {
      timer?.cancel();
    });
    onDispose(() {
      timer?.cancel();
    });
  }
}

/// Extension on [Ref] to add a max time to live.
extension AddMaxTimeToLiveRef on Ref {
  /// Adds a max ttl for the data in the provider.
  ///
  /// When a listener is added after the max ttl has been has been exceeded, the
  /// provider will be refreshed. The provider won't be refreshed until a new
  /// listener is added, even if ttl has been exceeded.
  void addMaxTimeToLive(Duration ttl) {
    final timestamp = DateTime.timestamp();

    onAddListener(() {
      if (DateTime.timestamp().difference(timestamp) > ttl) {
        // TODO: 1 calling invalidateSelf sync causes an error, find a clever way to do this on the same frame, instead of wasting a frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          invalidateSelfWhenUnpaused();
        });
      }
    });
  }
}

extension InvalidateWhenUnpausedRef on Ref {
  void invalidateSelfWhenUnpaused() {
    if (mounted && !isPaused) {
      invalidateSelf();
      return;
    }

    onAddListener(() {
      if (!mounted || isPaused) return;
      // TODO: 1 calling invalidateSelf sync causes an error, find a clever way to do this on the same frame, instead of wasting a frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || isPaused) return;
        invalidateSelf();
      });
    });
  }
}

extension ReadFutureRef on Ref {
  Future<T> readFuture<T>(ApiProviderInstance<T> provider) async {
    final subscription = listen(provider.notifier, (_, _) {});
    try {
      return await read(provider.notifier).future;
    } finally {
      subscription.close();
    }
  }
}

extension ReadFutureWidgetRef on WidgetRef {
  Future<T> readFuture<T>(ApiProviderInstance<T> provider) async {
    final subscription = listenManual(provider.notifier, (_, _) {});
    try {
      return await read(provider.notifier).future;
    } finally {
      subscription.close();
    }
  }
}

extension ReadFutureWidgetProviderContainer on ProviderContainer {
  Future<T> readFuture<T>(ApiProviderInstance<T> provider) async {
    final subscription = listen(provider.notifier, (_, _) {});
    try {
      return await read(provider.notifier).future;
    } finally {
      subscription.close();
    }
  }
}
