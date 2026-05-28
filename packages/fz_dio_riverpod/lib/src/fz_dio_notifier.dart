import 'package:dio/dio.dart';
import 'package:fz_log/fz_log.dart';
import 'package:fz_riverpod/fz_riverpod.dart';
import 'package:riverpod/riverpod.dart';

abstract class FzDioFutureNotifierBase<T> extends FzFutureNotifier<T> {
  final List<CancelToken> _cancelTokens = [];

  @override
  T? build() {
    if (!keepDataOnLoading) {
      status = FutureNotifierStatus.loading;
    }
    ref.invalidate(selfProgress);
    ref.invalidate(wholeProgress);
    ref.invalidate(error);
    ref.onDispose(cancelRequests);
    future = buildFuture();
    () async {
      try {
        final data = await future;
        if (!ref.mounted) return;
        status = FutureNotifierStatus.done;
        state = data;
      } catch (e, st) {
        if (e is DioException) {
          // // this logging should be done in DIO interceptors. That is the only way to ensure it is logged only once for each call.
          // if (err.response == null) {
          //   log(LgLvl.info, 'Dio Connection Error caught in $runtimeType future', e: err, type: FzLgType.network);
          // } else {
          //   log(LgLvl.warning, 'Dio Error with response caught in $runtimeType future', e: err, type: FzLgType.network);
          // }
        } else {
          log(LgLvl.error, 'Error caught in ApiState<$T> future', e: e, st: st);
        }
        if (!ref.mounted) return;
        status = FutureNotifierStatus.error;
        state = null;
      }
    }();
    return keepDataOnLoading && !ref.isFirstBuild
        ? state //
        : null;
  }

  void addCancelToken(CancelToken ct) {
    _cancelTokens.add(ct);
  }

  void cancelRequests() {
    for (final c in _cancelTokens) {
      try {
        c.cancel('PROVIDER CANCELLED');
      } catch (_) {}
    }
    _cancelTokens.clear();
  }

  /// utility to use with dio request onReceiveProgress callback
  void onReceiveProgress(int count, int total) {
    if (!ref.mounted) return;
    ref.read(selfProgress.notifier).setValues(count.toDouble(), total.toDouble());
  }
}

class FzDioFutureNotifier<T> extends FzDioFutureNotifierBase<T> {
  Future<T> Function(FzDioFutureNotifier<T> notifier) builder;

  FzDioFutureNotifier(this.builder);

  @override
  Future<T> buildFuture() => builder(this);

  // remove protected warning
  @override
  Ref get ref => super.ref;
}
