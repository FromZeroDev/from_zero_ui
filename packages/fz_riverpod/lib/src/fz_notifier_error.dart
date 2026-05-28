part of 'fz_notifier.dart';

final fzErrorProvider = NotifierProvider
    .autoDispose //
    .family<ErrorNotifier, ErrorData?, FzAsyncNotifier<dynamic>>(
      ErrorNotifier.new,
    );

class ErrorNotifier extends Notifier<ErrorData?> {
  final FzNotifier<dynamic> notifier;

  ErrorNotifier(this.notifier);

  @override
  ErrorData? build() {
    final keepAliveLink = ref.keepAlive();
    notifier.ref.onDispose(keepAliveLink.close);
    return null;
  }

  void reset() => state = null;

  void setValues(Object e, StackTrace st) => state = ErrorData(e, st);
}

class ErrorData {
  final Object error;
  final StackTrace stackTrace;

  const ErrorData(this.error, this.stackTrace);

  @override
  bool operator ==(Object other) => other is ErrorData && error == other.error && stackTrace == other.stackTrace;

  @override
  int get hashCode => Object.hash(error, stackTrace);
}
