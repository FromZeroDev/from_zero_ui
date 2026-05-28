import 'package:flutter_riverpod/misc.dart' show ProviderOrFamily;
import 'package:fz_log/fz_log.dart';
import 'package:fz_riverpod/src/riverpod_caching.dart';
import 'package:fz_riverpod/src/riverpod_util.dart';
import 'package:riverpod/misc.dart' show NotifierProviderFamily;
import 'package:riverpod/riverpod.dart';
// ignore: implementation_imports
import 'package:riverpod/src/builder.dart';

part 'fz_notifier_progress.dart';
part 'fz_notifier_error.dart';
part 'fz_future_notifier.dart';
part 'fz_stream_notifier.dart';

typedef FzProviderInstance<T> = NotifierProvider<FzNotifier<T>, T>;

typedef FzProviderFamilyInstance<T, P> = NotifierProviderFamily<FzNotifier<T>, T, P>;

// ignore: non_constant_identifier_names
FzProviderInstance<T> FzProvider<T>(
  FzNotifier<T> Function() create, {
  String? name,
  Iterable<ProviderOrFamily>? dependencies,
  Retry? retry,
}) {
  return const AutoDisposeNotifierProviderBuilder()<FzNotifier<T>, T>(
    create,
    name: name,
    dependencies: dependencies,
    retry: retry,
  );
}

// ignore: non_constant_identifier_names
FzProviderFamilyInstance<T, P> FzProviderFamily<T, P>(
  FzNotifier<T> Function(P param) create, {
  String? name,
  Iterable<ProviderOrFamily>? dependencies,
  Retry? retry,
}) {
  return const AutoDisposeNotifierProviderFamilyBuilder()<FzNotifier<T>, T, P>(
    create,
    name: name,
    dependencies: dependencies,
    retry: retry,
  );
}

abstract class FzNotifier<T> extends Notifier<T> {
  NotifierProvider<ProgressNotifier, ProgressBase> get selfProgress => fzProgressProvider.call(this);
  NotifierProvider<DerivedProgressNotifier, ProgressBase> get wholeProgress => fzWholeProgressProvider.call(this);

  // TODO: 2 can we infer this with riverpod somehow, so we don't have to manually track it ?
  final List<FzProviderInstance<dynamic>> _dependencies = [];

  bool get isDone => true;

  bool get isError {
    try {
      state;
    } catch (_) {
      return true;
    }
    return false;
  }

  D watch<D>(FzProviderInstance<D> provider) {
    _addDependency(provider);
    return ref.watch(provider);
  }

  Future<D> watchFuture<D>(NotifierProvider<FzFutureNotifier<D>, D?> provider) {
    _addDependency(provider);
    return ref.watch(provider.notifier).future;
  }

  Stream<D> watchStream<D>(NotifierProvider<FzStreamNotifier<D>, D?> provider) {
    _addDependency(provider);
    return ref.watch(provider.notifier).stream;
  }

  void _addDependency(FzProviderInstance<dynamic> provider) {
    if (!_dependencies.contains(provider)) {
      _dependencies.add(provider);
      ref.invalidate(wholeProgress);
    }
  }

  /// Refresh this and all its dependencies only if they are on an error state
  bool retry() {
    bool refreshed = false;
    if (isError) {
      refreshed = true;
      ref.invalidateSelfWhenUnpaused();
    }
    for (final e in _dependencies) {
      try {
        final notifier = ref.read(e.notifier);
        if (notifier.retry()) {
          refreshed = true;
        }
      } catch (_) {}
    }
    return refreshed;
  }

  /// Refresh this and all its dependencies
  void fullRefresh() {
    ref.invalidateSelfWhenUnpaused();
    for (final e in _dependencies) {
      ref.invalidate(e);
    }
  }
}

class FzNotifierBuilder<T> extends FzNotifier<T> {
  T Function(FzNotifierBuilder<T> notifier) builder;

  FzNotifierBuilder(this.builder);

  @override
  T build() => builder(this);

  // remove protected warning
  @override
  Ref get ref => super.ref;
}

sealed class FzAsyncNotifier<T> extends FzNotifier<T?> {
  NotifierProvider<ErrorNotifier, ErrorData?> get error => fzErrorProvider.call(this);
}

typedef FzAsyncProviderInstance<T> = NotifierProvider<FzAsyncNotifier<T>, T?>;
typedef FzFutureProviderInstance<T> = NotifierProvider<FzFutureNotifier<T>, T?>;
typedef FzStreamProviderInstance<T> = NotifierProvider<FzStreamNotifier<T>, T?>;
