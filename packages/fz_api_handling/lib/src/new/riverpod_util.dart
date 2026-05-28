// copied from riverpod because they don't expose it
typedef Retry = Duration? Function(int retryCount, Object error);
