import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fz_animated_switcher_image/fz_animated_switcher_image.dart';
import 'package:fz_dialog/fz_dialog.dart';
import 'package:fz_future_handling/fz_future_handling.dart';
import 'package:fz_localizations/fz_localizations.dart';
import 'package:fz_riverpod/fz_riverpod.dart';

typedef FzLoadingBuilder = Widget Function(BuildContext context, double? progress, double? count, double? total);
typedef FzErrorBuilder =
    Widget Function(BuildContext context, Object error, StackTrace stackTrace, VoidCallback? onRetry);

// TODO: 3 implement proper direct support for FzProvider in these widgets, so we don't
// have to do this hack that converts it to AsyncValue.
extension FzProviderAsyncValue<T> on FzNotifier<T> {
  AsyncValue<T> asAsyncValue() {
    if (isDone) {
      // ignore: invalid_use_of_protected_member
      return AsyncValue.data(state);
    }
    if (isError) {
      if (this case final FzAsyncNotifier<T> asyncNotifer) {
        // ignore: invalid_use_of_protected_member
        final err = ref.read(asyncNotifer.error)!;
        return AsyncValue.error(err.error, err.stackTrace);
      } else {
        try {
          // ignore: invalid_use_of_protected_member
          state;
        } catch (error, stackTrace) {
          return AsyncValue.error(error, stackTrace);
        }
        throw Exception(
          'Sync provider reported isError=true, but calling .state didn\'t throw,'
          ' this should never happen',
        );
      }
    }
    // ignore: invalid_use_of_protected_member
    return AsyncLoading(progress: ref.read(wholeProgress).progress);
  }
}

class FzProviderBuilder<T> extends ConsumerWidget {
  final FzProviderInstance<T> provider;
  final DataBuilder<T> dataBuilder;
  final FzLoadingBuilder loadingBuilder;
  final FzErrorBuilder errorBuilder;
  final FutureTransitionBuilder transitionBuilder;
  final Duration transitionDuration;
  final Curve transitionInCurve;
  final Curve transitionOutCurve;
  final bool applyAnimatedContainerFromChildSize;
  final AnimatedSwitcherImageLayoutBuilder layoutBuilder;
  final Alignment? alignment; // used for animated switches
  final Clip? clipBehaviour;
  final AnimatedSwitcherType animatedSwitcherType;
  final bool addLoadingStateAsValueKeys;

  const FzProviderBuilder({
    required this.provider,
    required this.dataBuilder,
    this.loadingBuilder = FzProviderBuilder.defaultLoadingBuilder,
    this.errorBuilder = FzProviderBuilder.defaultErrorBuilder,
    this.transitionBuilder = AsyncValueBuilder.defaultTransitionBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionInCurve = Curves.easeOutCubic,
    this.transitionOutCurve = Curves.easeInCubic,
    this.applyAnimatedContainerFromChildSize = false,
    this.layoutBuilder = AnimatedSwitcherImage.defaultLayoutBuilder,
    this.alignment,
    this.clipBehaviour,
    this.addLoadingStateAsValueKeys = true,
    this.animatedSwitcherType = AnimatedSwitcherType.image,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(provider.notifier);
    // ignore: unused_local_variable
    final value = ref.watch(provider);
    return AsyncValueBuilder<T>(
      // using stateNotifier.state instead of value because value is kept when reloading, so loading state is never shown
      // ignore: invalid_use_of_protected_member
      asyncValue: notifier.asAsyncValue(),
      dataBuilder: dataBuilder,
      alignment: alignment,
      loadingBuilder: (context) {
        final progress = ref.watch(ref.read(provider.notifier).wholeProgress);
        return loadingBuilder(context, progress.progress, progress.count, progress.total);
      },
      errorBuilder: (context, error, stackTrace) {
        return errorBuilder(context, error, stackTrace, () => ref.read(provider.notifier).retry());
      },
      transitionBuilder: transitionBuilder,
      transitionDuration: transitionDuration,
      transitionInCurve: transitionInCurve,
      transitionOutCurve: transitionOutCurve,
      applyAnimatedContainerFromChildSize: applyAnimatedContainerFromChildSize,
      layoutBuilder: layoutBuilder,
      clipBehaviour: clipBehaviour,
      addLoadingStateAsValueKeys: addLoadingStateAsValueKeys,
      animatedSwitcherType: animatedSwitcherType,
    );
  }

  static Widget defaultLoadingBuilder(
    BuildContext context,
    double? progress,
    _,
    _, {
    double? size,
  }) {
    return LoadingSign(
      value: progress,
      size: size ?? 48,
    );
  }

  static Widget defaultErrorBuilder(
    BuildContext context,
    Object? error,
    StackTrace? stackTrace,
    VoidCallback? onRetry,
  ) {
    final isRetryable = isErrorRetryable(error, stackTrace);
    return ErrorSign(
      key: ValueKey(error),
      icon: getErrorIcon(context, error, stackTrace),
      title: getErrorTitle(context, error, stackTrace),
      subtitle: getErrorSubtitle(context, error, stackTrace),
      onRetry: !kReleaseMode || isRetryable ? onRetry : null,
      retryButton: !kReleaseMode || shouldShowErrorDetails(error, stackTrace)
          ? buildErrorDetailsButton(context, error, stackTrace, !kReleaseMode || isRetryable ? onRetry : null)
          : null,
    );
  }

  static Widget Function(BuildContext context, Object? error, StackTrace? stackTrace) getErrorIcon =
      defaultGetErrorIcon;
  static Widget defaultGetErrorIcon(BuildContext context, Object? error, StackTrace? stackTrace) {
    return const Icon(Icons.report_problem_outlined);
  }

  static String Function(BuildContext context, Object? error, StackTrace? stackTrace) getErrorTitle =
      defaultGetErrorTitle;
  static String defaultGetErrorTitle(BuildContext context, Object? error, StackTrace? stackTrace) {
    return "Error Inesperado";
  }

  static String? Function(BuildContext context, Object? error, StackTrace? stackTrace) getErrorSubtitle =
      defaultGetErrorSubtitle;
  static String? defaultGetErrorSubtitle(BuildContext context, Object? error, StackTrace? stackTrace) {
    return "Por favor, notifique a su administrador de sistema";
  }

  static bool Function(Object? error, StackTrace? stackTrace) isErrorRetryable = defaultIsErrorRetryable;
  static bool defaultIsErrorRetryable(Object? error, StackTrace? stackTrace) {
    return false;
  }

  static bool Function(Object? error, StackTrace? stackTrace) shouldShowErrorDetails = defaultShouldShowErrorDetails;
  static bool defaultShouldShowErrorDetails(Object? error, StackTrace? stackTrace) {
    return true;
  }

  static Widget Function(BuildContext context, Object? error, StackTrace? stackTrace, [VoidCallback? onRetry])
  buildErrorDetailsButton = defaltBuildErrorDetailsButton;
  static Widget defaltBuildErrorDetailsButton(
    BuildContext context,
    Object? error,
    StackTrace? stackTrace, [
    VoidCallback? onRetry,
  ]) {
    Widget result = DialogButton.cancel(
      leading: const Icon(Icons.info_outlined),
      child: const Text('Detalles del Error'), // TODO: 3 internationalize
      onPressed: () => showErrorDetailsDialog(context, error, stackTrace),
    );
    if (onRetry != null) {
      result = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          result,
          const SizedBox(height: 8),
          DialogButton.accept(
            leading: const Icon(Icons.refresh),
            onPressed: onRetry,
            child: Text(FromZeroLocalizations.of(context).translate("retry")),
          ),
        ],
      );
    }
    return result;
  }

  static void showErrorDetailsDialog(BuildContext context, Object? error, StackTrace? stackTrace) {
    showModalFromZero<dynamic>(
      context: context,
      builder: (context) {
        return DialogFromZero(
          title: const Text('Detalles del Error'),
          content: SelectableText("$error\r\n\r\n$stackTrace}"),
          dialogActions: const [
            DialogButton.cancel(
              child: Text('CERRAR'), // TODO: 3 internationalize
            ),
          ],
        );
      },
    );
  }
}

class SliverFzProviderBuilder<T> extends FzProviderBuilder<T> {
  const SliverFzProviderBuilder({
    required super.provider,
    required super.dataBuilder,
    super.transitionDuration = const Duration(milliseconds: 300),
    super.loadingBuilder = SliverFzProviderBuilder.defaultLoadingBuilder,
    super.errorBuilder = SliverFzProviderBuilder.defaultErrorBuilder,
    super.transitionBuilder = SliverAsyncValueBuilder.defaultTransitionBuilder,
    super.layoutBuilder = AnimatedSwitcherImage.sliverLayoutBuilder,
    super.animatedSwitcherType = AnimatedSwitcherType.normal,

    /// AnimatedSwitcherImage doesn't support slivers, because of the RepaintBoundary
    super.key,
  }) : super(
         applyAnimatedContainerFromChildSize: false,
       );

  static Widget defaultLoadingBuilder(BuildContext context, double? progress, double? count, double? total) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 256,
        child: FzProviderBuilder.defaultLoadingBuilder(context, progress, count, total),
      ),
    );
  }

  static Widget defaultErrorBuilder(
    BuildContext context,
    Object? error,
    StackTrace? stackTrace,
    VoidCallback? onRetry,
  ) {
    return SliverToBoxAdapter(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 256),
        child: FzProviderBuilder.defaultErrorBuilder(context, error, stackTrace, onRetry),
      ),
    );
  }
}

class FzProviderMultiBuilder<T> extends ConsumerWidget {
  final List<FzProviderInstance<T>> providers;
  final DataMultiBuilder<T> dataBuilder;
  final FzLoadingBuilder loadingBuilder;
  final FzErrorBuilder errorBuilder;
  final FutureTransitionBuilder transitionBuilder;
  final Duration transitionDuration;
  final Curve transitionInCurve;
  final Curve transitionOutCurve;
  final bool applyAnimatedContainerFromChildSize;
  final AnimatedSwitcherImageLayoutBuilder layoutBuilder;
  final Alignment? alignment; // used for animated switches
  final Clip? clipBehaviour;
  final AnimatedSwitcherType animatedSwitcherType;
  final bool addLoadingStateAsValueKeys;

  const FzProviderMultiBuilder({
    required this.providers,
    required this.dataBuilder,
    this.loadingBuilder = FzProviderBuilder.defaultLoadingBuilder,
    this.errorBuilder = FzProviderBuilder.defaultErrorBuilder,
    this.transitionBuilder = AsyncValueBuilder.defaultTransitionBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionInCurve = Curves.easeOutCubic,
    this.transitionOutCurve = Curves.easeInCubic,
    this.applyAnimatedContainerFromChildSize = false,
    this.layoutBuilder = AnimatedSwitcherImage.defaultLayoutBuilder,
    this.alignment,
    this.clipBehaviour,
    this.addLoadingStateAsValueKeys = true,
    this.animatedSwitcherType = AnimatedSwitcherType.image,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<FzNotifier<T>> stateNotifiers = [];
    List<T> values = [];
    for (final e in providers) {
      stateNotifiers.add(ref.watch(e.notifier));
      values.add(ref.watch(e));
    }
    return AsyncValueMultiBuilder<T>(
      asyncValues: stateNotifiers.map((e) => e.asAsyncValue()).toList(),
      dataBuilder: dataBuilder,
      alignment: alignment,
      loadingBuilder: (context) {
        double? count, total;
        int indeterminateCount = 0, determinateCount = 0;
        for (final notifier in stateNotifiers) {
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
        final progress = Progress(count, total);
        return loadingBuilder(context, progress.progress, progress.count, progress.total);
      },
      errorBuilder: (context, error, stackTrace) {
        return errorBuilder(context, error, stackTrace, () {
          for (final e in stateNotifiers) {
            e.retry();
          }
        });
      },
      transitionBuilder: transitionBuilder,
      transitionDuration: transitionDuration,
      transitionInCurve: transitionInCurve,
      transitionOutCurve: transitionOutCurve,
      applyAnimatedContainerFromChildSize: applyAnimatedContainerFromChildSize,
      layoutBuilder: layoutBuilder,
      clipBehaviour: clipBehaviour,
      addLoadingStateAsValueKeys: addLoadingStateAsValueKeys,
      animatedSwitcherType: animatedSwitcherType,
    );
  }
}

class SliverFzProviderMultiBuilder<T> extends FzProviderMultiBuilder<T> {
  const SliverFzProviderMultiBuilder({
    required super.providers,
    required super.dataBuilder,
    super.transitionDuration = const Duration(milliseconds: 300),
    super.loadingBuilder = SliverFzProviderBuilder.defaultLoadingBuilder,
    super.errorBuilder = SliverFzProviderBuilder.defaultErrorBuilder,
    super.transitionBuilder = SliverAsyncValueBuilder.defaultTransitionBuilder,
    super.layoutBuilder = AnimatedSwitcherImage.sliverLayoutBuilder,
    super.animatedSwitcherType = AnimatedSwitcherType.normal,

    /// AnimatedSwitcherImage doesn't support slivers, because of the RepaintBoundary
    super.key,
  }) : super(
         applyAnimatedContainerFromChildSize: false,
       );
}

class MultiValueListenable<T> extends ChangeNotifier {
  final Iterable<ValueListenable<T>> _listenables;
  MultiValueListenable(this._listenables) {
    for (final e in _listenables) {
      e.addListener(notifyListeners);
    }
  }
  @override
  void dispose() {
    for (final e in _listenables) {
      e.removeListener(notifyListeners);
    }
    super.dispose();
  }

  List<T> get values => _listenables.map((e) => e.value).toList();
}

class UnitedValueListenable<T> extends ChangeNotifier implements ValueListenable<T> {
  final Iterable<ValueListenable<T>> _listenables;
  final T Function(Iterable<T>) _unificator;
  UnitedValueListenable(this._listenables, this._unificator) {
    for (final e in _listenables) {
      e.addListener(notifyListeners);
    }
  }
  @override
  void dispose() {
    for (final e in _listenables) {
      e.removeListener(notifyListeners);
    }
    super.dispose();
  }

  @override
  T get value => _unificator(_listenables.map((e) => e.value));
}

class FzNotifierAsyncBuilder<T> extends ConsumerStatefulWidget {
  final FzNotifier<T> stateNotifier;
  final DataBuilder<T> dataBuilder;
  final FzLoadingBuilder loadingBuilder;
  final FzErrorBuilder errorBuilder;
  final FutureTransitionBuilder transitionBuilder;
  final Duration transitionDuration;
  final Curve transitionInCurve;
  final Curve transitionOutCurve;
  final bool applyAnimatedContainerFromChildSize;
  final AnimatedSwitcherImageLayoutBuilder layoutBuilder;
  final Alignment? alignment; // used for animated switches
  final Clip? clipBehaviour;
  final AnimatedSwitcherType animatedSwitcherType;
  final bool addLoadingStateAsValueKeys;

  const FzNotifierAsyncBuilder({
    required this.stateNotifier,
    required this.dataBuilder,
    this.loadingBuilder = FzProviderBuilder.defaultLoadingBuilder,
    this.errorBuilder = FzProviderBuilder.defaultErrorBuilder,
    this.transitionBuilder = AsyncValueBuilder.defaultTransitionBuilder,
    this.transitionDuration = const Duration(milliseconds: 300),
    this.transitionInCurve = Curves.easeOutCubic,
    this.transitionOutCurve = Curves.easeInCubic,
    this.applyAnimatedContainerFromChildSize = false,
    this.layoutBuilder = AnimatedSwitcherImage.defaultLayoutBuilder,
    this.alignment,
    this.clipBehaviour,
    this.addLoadingStateAsValueKeys = true,
    this.animatedSwitcherType = AnimatedSwitcherType.image,
    super.key,
  });

  @override
  ApiStateBuilderState<T> createState() => ApiStateBuilderState<T>();
}

class ApiStateBuilderState<T> extends ConsumerState<FzNotifierAsyncBuilder<T>> {
  late VoidCallback closeSubscription;

  @override
  void initState() {
    super.initState();
    // ignore: invalid_use_of_protected_member
    closeSubscription = widget.stateNotifier.listenSelf(onNotify);
  }

  @override
  void didUpdateWidget(covariant FzNotifierAsyncBuilder<T> oldWidget) {
    if (widget.stateNotifier != oldWidget.stateNotifier) {
      closeSubscription();
      // ignore: invalid_use_of_protected_member
      closeSubscription = widget.stateNotifier.listenSelf(onNotify);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    closeSubscription();
    super.dispose();
  }

  void onNotify(_, _) {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AsyncValueBuilder<T>(
      asyncValue: widget.stateNotifier.asAsyncValue(),
      dataBuilder: widget.dataBuilder,
      alignment: widget.alignment,
      loadingBuilder: (context) {
        final progress = ref.watch(widget.stateNotifier.wholeProgress);
        return widget.loadingBuilder(context, progress.progress, progress.count, progress.total);
      },
      errorBuilder: (context, error, stackTrace) {
        return widget.errorBuilder(context, error, stackTrace, () => widget.stateNotifier.retry());
      },
      transitionBuilder: widget.transitionBuilder,
      transitionDuration: widget.transitionDuration,
      transitionInCurve: widget.transitionInCurve,
      transitionOutCurve: widget.transitionOutCurve,
      applyAnimatedContainerFromChildSize: widget.applyAnimatedContainerFromChildSize,
      layoutBuilder: widget.layoutBuilder,
      clipBehaviour: widget.clipBehaviour,
      addLoadingStateAsValueKeys: widget.addLoadingStateAsValueKeys,
      animatedSwitcherType: widget.animatedSwitcherType,
    );
  }
}

class SliverApiStateBuilder<T> extends FzNotifierAsyncBuilder<T> {
  const SliverApiStateBuilder({
    required super.stateNotifier,
    required super.dataBuilder,
    super.transitionDuration = const Duration(milliseconds: 300),
    super.loadingBuilder = SliverFzProviderBuilder.defaultLoadingBuilder,
    super.errorBuilder = SliverFzProviderBuilder.defaultErrorBuilder,
    super.transitionBuilder = SliverAsyncValueBuilder.defaultTransitionBuilder,
    super.layoutBuilder = AnimatedSwitcherImage.sliverLayoutBuilder,
    super.animatedSwitcherType = AnimatedSwitcherType.normal,

    /// AnimatedSwitcherImage doesn't support slivers, because of the RepaintBoundary
    super.key,
  }) : super(
         applyAnimatedContainerFromChildSize: false,
       );
}
