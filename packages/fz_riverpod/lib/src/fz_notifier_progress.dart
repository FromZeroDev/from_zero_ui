part of 'fz_notifier.dart';

final fzProgressProvider = NotifierProvider
    .autoDispose //
    .family<ProgressNotifier, ProgressBase, FzNotifier<dynamic>>(
      _ProgressNotifierImpl.new,
    );

final fzWholeProgressProvider = NotifierProvider
    .autoDispose //
    .family<DerivedProgressNotifier, ProgressBase, FzNotifier<dynamic>>(
      _DerivedProgressNotifierImpl.new,
    );

abstract class ProgressBase {
  double? get count;
  double? get total;

  const ProgressBase();

  bool get isDeterminate => count != null && total != null;

  // PERF: 3 should we cache this?
  double? get progress => total == 0
      ? 1
      : count == null || total == null
      ? null
      : count! / total!;

  @override
  bool operator ==(Object other) => other is ProgressBase && count == other.count && total == other.total;

  @override
  int get hashCode => Object.hash(count, total);

  @override
  String toString() {
    return 'Progress($count/$total = $progress)';
  }
}

class Progress extends ProgressBase {
  @override
  final double? count;
  @override
  final double? total;

  const Progress(this.count, this.total);

  const Progress.indeterminate() : count = null, total = null;
}

class _ProgressMutable extends ProgressBase {
  @override
  double? count;
  @override
  double? total;

  _ProgressMutable([this.count, this.total]);
}

abstract class ProgressNotifier<T extends ProgressBase> extends Notifier<T> {
  T get progress => state;

  void setCount(double? count);
  void setTotal(double? count);
  void setValues(double? count, double? total);
  void reset();
}

abstract class DerivedProgressNotifier<T extends ProgressBase> extends Notifier<T> {}

class _ProgressNotifierImpl extends ProgressNotifier<ProgressBase> {
  final FzNotifier<dynamic> notifier;
  late final _ProgressMutable _progress;

  _ProgressNotifierImpl(this.notifier);

  @override
  _ProgressMutable build() {
    final keepAliveLink = ref.keepAlive();
    notifier.ref.onDispose(keepAliveLink.close);
    notifier.listenSelf((_, _) {
      if (notifier.isDone && !state.isDeterminate) {
        setValues(0, 0);
      }
    });
    _progress = notifier.isDone
        ? _ProgressMutable(0, 0) //
        : _ProgressMutable();
    return _progress;
  }

  @override
  void setCount(double? count) {
    if (count == state.count) return;
    _progress.count = count;
    ref.notifyListeners();
  }

  @override
  void setTotal(double? total) {
    if (total == state.total) return;
    _progress.total = total;
    ref.notifyListeners();
  }

  @override
  void setValues(double? count, double? total) {
    if (count == state.count && total == state.total) return;
    _progress.count = count;
    _progress.total = total;
    ref.notifyListeners();
  }

  @override
  void reset() {
    if (state.count == null && state.total == null) return;
    _progress.count = null;
    _progress.total = null;
    ref.notifyListeners();
  }
}

class _DerivedProgressNotifierImpl extends DerivedProgressNotifier<ProgressBase> {
  final FzNotifier<dynamic> notifier;

  _DerivedProgressNotifierImpl(this.notifier);

  @override
  Progress build() {
    final progress = ref.watch(notifier.selfProgress);
    double? count, total;
    int indeterminateCount = 0, determinateCount = 0;
    if (progress.isDeterminate) {
      determinateCount++;
      count = (count ?? 0) + progress.count!;
      total = (total ?? 0) + progress.total!;
    } else {
      indeterminateCount++;
    }
    for (final e in notifier._dependencies) {
      final notifier = ref.read(e.notifier);
      final progress = ref.watch(notifier.wholeProgress);
      if (progress.isDeterminate) {
        determinateCount++;
        count = (count ?? 0) + progress.count!;
        total = (total ?? 0) + progress.total!;
      } else {
        indeterminateCount++;
      }
    }
    if (indeterminateCount > 0 && determinateCount > 0) {
      final ratio = indeterminateCount / determinateCount;
      total = total! * (1 + ratio);
    }
    return Progress(count, total);
  }
}
