part of 'fz_notifier.dart';

enum FutureNotifierStatus { loading, done, error }

abstract class FzFutureNotifier<T> extends FzAsyncNotifier<T> {
  late Future<T> future;
  FutureNotifierStatus status = FutureNotifierStatus.loading;

  bool get keepDataOnLoading => false;
  bool get keepDataOnError => false;

  Future<T> buildFuture();

  @override
  T? build() {
    status = FutureNotifierStatus.loading;
    ref.invalidate(selfProgress);
    ref.invalidate(wholeProgress);
    ref.invalidate(error);
    future = buildFuture();
    () async {
      try {
        final data = await future;
        if (!ref.mounted) return;
        status = FutureNotifierStatus.done;
        state = data;
      } catch (e, st) {
        log(LgLvl.error, 'Error caught in $runtimeType future', e: e, st: st);
        if (!ref.mounted) return;
        status = FutureNotifierStatus.error;
        if (!keepDataOnError) {
          state = null;
        }
      }
    }();
    return keepDataOnLoading && !ref.isFirstBuild
        ? state //
        : null;
  }

  @override
  bool get isDone => status == FutureNotifierStatus.done;

  @override
  bool get isError => status == FutureNotifierStatus.error;
}

class FzFutureNotifierBuilder<T> extends FzFutureNotifier<T> {
  Future<T> Function(FzFutureNotifierBuilder<T> notifier) builder;
  @override
  bool keepDataOnLoading;
  @override
  bool keepDataOnError;

  FzFutureNotifierBuilder(
    this.builder, {
    this.keepDataOnLoading = false,
    this.keepDataOnError = false,
  });

  @override
  Future<T> buildFuture() => builder(this);

  // remove protected warning
  @override
  Ref get ref => super.ref;
}
