part of 'fz_notifier.dart';

enum StreamNotifierStatus { loading, partial, done, error }

abstract class FzStreamNotifier<T> extends FzAsyncNotifier<T> {
  late Stream<T> stream;
  StreamNotifierStatus status = StreamNotifierStatus.loading;

  bool get keepDataOnLoading => false;
  bool get keepDataOnError => false;

  Stream<T> buildStream();

  @override
  T? build() {
    status = StreamNotifierStatus.loading;
    ref.invalidate(selfProgress);
    ref.invalidate(wholeProgress);
    ref.invalidate(error);
    stream = buildStream().asBroadcastStream();
    () async {
      await for (final data in stream) {
        try {
          if (!ref.mounted) return;
          status = StreamNotifierStatus.partial;
          state = data;
        } catch (e, st) {
          log(LgLvl.error, 'Error caught in $runtimeType stream', e: e, st: st);
          if (!ref.mounted) return;
          status = StreamNotifierStatus.error;
          if (!keepDataOnError) {
            state = null;
          }
        }
      }
      status = StreamNotifierStatus.done;
    }();
    return keepDataOnLoading && !ref.isFirstBuild
        ? state //
        : null;
  }

  @override
  bool get isDone => status == StreamNotifierStatus.done;

  @override
  bool get isError => status == StreamNotifierStatus.error;
}

class FzStreamNotifierBuilder<T> extends FzStreamNotifier<T> {
  Stream<T> Function(FzStreamNotifierBuilder<T> notifier) builder;
  @override
  bool keepDataOnLoading;
  @override
  bool keepDataOnError;

  FzStreamNotifierBuilder(
    this.builder, {
    this.keepDataOnLoading = false,
    this.keepDataOnError = false,
  });

  @override
  Stream<T> buildStream() => builder(this);

  // remove protected warning
  @override
  Ref get ref => super.ref;
}
