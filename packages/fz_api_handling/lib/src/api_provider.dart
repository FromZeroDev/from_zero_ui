import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:fz_animated_switcher_image/fz_animated_switcher_image.dart';
import 'package:fz_api_handling/src/riverpod_caching.dart';
import 'package:fz_dialog/fz_dialog.dart';
import 'package:fz_future_handling/fz_future_handling.dart';
import 'package:fz_localizations/fz_localizations.dart';
import 'package:fz_log/fz_log.dart';
import 'package:fz_snackbar/fz_snackbar.dart';
// ignore: depend_on_referenced_packages, implementation_imports
import 'package:riverpod/src/builder.dart';

typedef ApiProviderInstance<T> = NotifierProvider<ApiState<T>, AsyncValue<T>>;

typedef ApiProviderFamilyInstance<T, P> = NotifierProviderFamily<ApiState<T>, AsyncValue<T>, P>;

// ignore: non_constant_identifier_names
ApiProviderInstance<T> ApiProvider<T>(
  ApiState<T> Function() create, {
  String? name,
  Iterable<ProviderOrFamily>? dependencies,
  Retry? retry,
}) {
  return const AutoDisposeNotifierProviderBuilder()<ApiState<T>, AsyncValue<T>>(
    create,
    name: name,
    dependencies: dependencies,
    retry: retry,
  );
}

// ignore: non_constant_identifier_names
ApiProviderFamilyInstance<T, P> ApiProviderFamily<T, P>(
  ApiState<T> Function(P param) create, {
  String? name,
  Iterable<ProviderOrFamily>? dependencies,
  Retry? retry,
}) {
  return const AutoDisposeNotifierProviderFamilyBuilder()<ApiState<T>, AsyncValue<T>, P>(
    create,
    name: name,
    dependencies: dependencies,
    retry: retry,
  );
}

class ApiStateNoProvider<T> extends ApiState<T> {
  ApiStateNoProvider(super._create) : super._noProvider();

  @override
  AsyncValue<T> get state => _state;

  @override
  set state(AsyncValue<T> state) {
    if (state == _state) return;
    _state = state;
    notifyListeners();
  }
}

class ApiState<T> extends Notifier<AsyncValue<T>> with ChangeNotifier {
  final bool isNoProvider;

  final Future<T> Function(ApiState<T>) _create;
  final Duration? disposeDelay;
  final Duration? maxTimeToLive;
  late Future<T> future;

  // TODO: 2 these should probably be part of the LoadingState?
  late final selfTotalNotifier = ValueNotifier<double?>(null)..addListener(_computeTotal);
  late final selfProgressNotifier = ValueNotifier<double?>(null)..addListener(_computeProgress);
  late final wholeTotalNotifier = ValueNotifier<double?>(null)..addListener(_computePercentage);
  late final wholeProgressNotifier = ValueNotifier<double?>(null)..addListener(_computePercentage);
  late final wholePercentageNotifier = ValueNotifier<double?>(null);

  final List<ApiProviderInstance<dynamic>> _watching = [];
  final List<ApiState<dynamic>> _watchingNotifiers = [];
  final List<CancelToken> _cancelTokens = [];
  void addCancelToken(CancelToken ct) {
    _cancelTokens.add(ct);
  }

  ApiState(
    this._create, {
    this.disposeDelay,
    this.maxTimeToLive,
  }) : isNoProvider = false,
       super();

  ApiState._noProvider(
    this._create,
  ) : isNoProvider = true,
      disposeDelay = null,
      maxTimeToLive = null,
      super() {
    _state = AsyncValue.loading();
    _runFuture();
  }

  @override
  AsyncValue<T> build() {
    _isRefreshed = false;
    _runFuture();
    _state = AsyncValue.loading();
    return AsyncValue.loading();
  }

  // remove protected warning
  @override
  AsyncValue<T> get state => super.state;

  // keep compatibility with code that used this as a StateNotifier
  late AsyncValue<T> _state;
  @override
  set state(AsyncValue<T> state) {
    if (state == _state) return;
    _state = state;
    notifyListeners();
    super.state = state;
  }

  bool get mounted => isNoProvider || ref.mounted;

  // remove protected warning
  @override
  Ref get ref => super.ref;

  Future<WatchedT> watch<WatchedT>(ApiProviderInstance<WatchedT> watchProvider) async {
    final notifier = ref.read(watchProvider.notifier);
    if (!_watching.contains(watchProvider)) {
      _watching.add(watchProvider);
      _watchingNotifiers.add(notifier);
      final newApiState = ref.read(watchProvider.notifier);
      _computeTotal();
      _computeProgress();
      _computePercentage();
      newApiState.wholeTotalNotifier.addListener(_computeTotal);
      newApiState.wholeProgressNotifier.addListener(_computeProgress);
      newApiState.wholePercentageNotifier.addListener(_computePercentage);
    }
    ref.watch(watchProvider);
    return notifier.future;
  }

  bool _isRefreshed = false;
  bool retry() {
    bool refreshed = false;
    if (!isNoProvider) {
      for (final e in _watchingNotifiers) {
        refreshed = refreshed || e.retry();
      }
    }
    if (!refreshed && state is AsyncError) {
      if (!_isRefreshed) {
        _isRefreshed = true;
        if (isNoProvider) {
          _runFuture();
        } else {
          ref.invalidateSelfWhenUnpaused();
        }
      }
      return true;
    }
    return refreshed;
  }

  void refresh() {
    bool refreshed = false;
    if (!isNoProvider) {
      for (final e in _watchingNotifiers) {
        e.refresh();
        refreshed = true;
      }
    }
    if (!refreshed) {
      if (!_isRefreshed) {
        _isRefreshed = true;
        if (isNoProvider) {
          _runFuture();
        } else {
          ref.invalidateSelfWhenUnpaused();
        }
      }
    }
  }

  Future<void> _runFuture() async {
    cancel();
    if (!isNoProvider) {
      ref.onDispose(cancel);
    }
    selfTotalNotifier.value = null;
    selfProgressNotifier.value = null;
    wholePercentageNotifier.value = null;
    // this doesn't seem to be necessary, because we only call _runFuture() from build(), which already sets loading state
    if (!isNoProvider && !ref.isFirstBuild) {
      state = AsyncValue.loading();
    }
    // // this doesn't seem to be necessary, I don't thing this is ever called with isPaused=true
    // if (ref.isPaused) {
    //   ref.onResume(_runFuture);
    //   return;
    // }
    try {
      future = _create(this);
      try {
        final data = await future;
        if (!mounted) return;
        state = AsyncValue<T>.data(data);
        if (!isNoProvider) {
          if (disposeDelay case final disposeDelay?) {
            ref.addDisposeDelay(disposeDelay);
          }
          if (maxTimeToLive case final maxTimeToLive?) {
            ref.addMaxTimeToLive(maxTimeToLive);
          }
        }
      } catch (e, st) {
        if (e is DioException) {
          // // this logging should be done in DIO interceptors. That is the only way to ensure it is logged only once for each call.
          // if (err.response==null) {
          //   log (LgLvl.info, 'Dio Connection Error caught in ApiState<$State>',
          //     e: err,
          //     type: FzLgType.network,
          //   );
          // } else {
          //   log (LgLvl.warning, 'Dio Error with response caught in ApiState<$State> future',
          //     e: err,
          //     type: FzLgType.network,
          //   );
          // }
          if (e.type == DioExceptionType.cancel && e.error.toString() == 'PROVIDER CANCELLED') {
            // hack to prevent provider being stuck in error state while loading after refreshing
            return;
          }
        } else {
          log(
            LgLvl.error,
            'Error caught in ApiState<$T> future',
            e: e,
            st: st,
          );
        }
        cancel();
        if (!mounted) return;
        state = AsyncValue<T>.error(e, st);
      }
    } catch (e, st) {
      log(
        LgLvl.error,
        'Error caught before running ApiState<$T> future. This should never happen',
        e: e,
        st: st,
      );
      if (!mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  void cancel() {
    for (final c in _cancelTokens) {
      try {
        c.cancel('PROVIDER CANCELLED');
      } catch (_) {}
    }
    _cancelTokens.clear();
  }

  void _computeTotal() {
    if (!mounted) return;
    double? result = selfTotalNotifier.value;
    if (result != null && !isNoProvider) {
      for (final e in _watchingNotifiers) {
        final partial =
            e.wholeTotalNotifier.value ??
            e._state.maybeWhen<double?>(
              data: (_) => 0,
              orElse: () => null,
            );
        if (partial != null) {
          result = (result ?? 0) + partial;
        } else {
          result = null;
          break;
        }
      }
    }
    wholeTotalNotifier.value = result;
  }

  void _computeProgress() {
    if (!mounted) return;
    double? result = selfProgressNotifier.value;
    if (result != null && !isNoProvider) {
      for (final e in _watchingNotifiers) {
        final partial =
            e.wholeProgressNotifier.value ??
            e._state.maybeWhen<double?>(
              data: (_) => 0,
              orElse: () => null,
            );
        if (partial != null) {
          result = (result ?? 0) + partial;
        } else {
          result = null;
          break;
        }
      }
    }
    wholeProgressNotifier.value = result;
  }

  void _computePercentage() {
    if (!mounted) return;
    // Percentage calculated only from wholeNotifiers
    double? total = wholeTotalNotifier.value;
    double? progress = wholeProgressNotifier.value;
    double? result = total == null || total == 0 ? null : (progress ?? 0) / total;
    if (result == null && !isNoProvider) {
      // Percentage of all dependencies are used, asuming their totals are equal
      total = selfTotalNotifier.value;
      progress = selfProgressNotifier.value;
      result = total == null
          ? null
          : progress == null || total == 0
          ? 0
          : progress / total;
      final allWatching = List<ApiState<dynamic>>.from(_watchingNotifiers);
      for (int i = 0; i < allWatching.length; i++) {
        for (final e in allWatching[i]._watchingNotifiers) {
          if (!allWatching.contains(e)) {
            allWatching.add(e);
          }
        }
      }
      bool allNull = result == null;
      for (final notifier in allWatching) {
        double? partialProgress = notifier.selfProgressNotifier.value;
        double? partialTotal = notifier.selfTotalNotifier.value;
        double? partial = partialTotal == null
            ? null
            : partialTotal == 0 || partialProgress == null
            ? 0
            : partialProgress / partialTotal;
        allNull = allNull && partial == null;
        if (notifier.mounted && !notifier.ref.isFirstBuild) {
          partial ??= notifier._state.maybeWhen<double>(
            data: (_) => 1,
            orElse: () => 0,
          );
        }
        result = (result ?? 0) + (partial ?? 0);
      }
      result = result == null || allNull ? null : (result / (allWatching.length + 1));
    }
    wholePercentageNotifier.value = result;
  }

  /// utility to use with dio request onReceiveProgress callback
  void onReceiveProgress(int count, int total) {
    if (!mounted) return;
    selfTotalNotifier.value = total.toDouble();
    selfProgressNotifier.value = count.toDouble();
  }
}

typedef ApiLoadingBuilder = Widget Function(BuildContext context, ValueListenable<double?>? progress);
typedef ApiErrorBuilder =
    Widget Function(BuildContext context, Object error, StackTrace? stackTrace, VoidCallback? onRetry);

class ApiProviderBuilder<T> extends ConsumerWidget {
  final ApiProviderInstance<T> provider;
  final DataBuilder<T> dataBuilder;
  final ApiLoadingBuilder loadingBuilder;
  final ApiErrorBuilder errorBuilder;
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

  const ApiProviderBuilder({
    required this.provider,
    required this.dataBuilder,
    this.loadingBuilder = ApiProviderBuilder.defaultLoadingBuilder,
    this.errorBuilder = ApiProviderBuilder.defaultErrorBuilder,
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
    // final routeBase = context.findAncestorStateOfType<OnlyOnActiveBuilderState>();
    // if (routeBase!=null) {
    //   log ('$routeBase -- ${routeBase.isActiveRoute(context)}'); // should be isActive && !ref.isCalled(provider)
    //   if (!routeBase.isActiveRoute(context)) {
    //     return SizedBox.shrink();
    //   }
    // }
    ApiState<T> stateNotifier = ref.watch(provider.notifier);
    // ignore: unused_local_variable
    AsyncValue<T> value = ref.watch(provider);
    return AsyncValueBuilder<T>(
      // using stateNotifier.state instead of value because value is kept when reloading, so loading state is never shown
      // ignore: invalid_use_of_protected_member
      asyncValue: stateNotifier.state,
      dataBuilder: dataBuilder,
      alignment: alignment,
      loadingBuilder: (context) {
        return loadingBuilder(context, stateNotifier.wholePercentageNotifier);
      },
      errorBuilder: (context, error, stackTrace) {
        return errorBuilder(context, error, stackTrace, () => stateNotifier.retry());
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
    ValueListenable<double?>? progress, {
    double? size,
  }) {
    if (progress == null) {
      return LoadingSign(
        size: size ?? 48,
      );
    } else {
      return ValueListenableBuilder<double?>(
        valueListenable: progress,
        builder: (context, progress, child) {
          return LoadingSign(
            value: progress,
            size: size ?? 48,
          );
        },
      );
    }
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
      onRetry: isRetryable ? onRetry : null,
      retryButton: shouldShowErrorDetails(error, stackTrace)
          ? buildErrorDetailsButton(context, error, stackTrace, isRetryable ? onRetry : null)
          : null,
    );
  }

  static Widget Function(BuildContext context, Object? error, StackTrace? stackTrace) getErrorIcon =
      defaultGetErrorIcon;
  static Widget defaultGetErrorIcon(BuildContext context, Object? error, StackTrace? stackTrace) {
    if (error is DioException) {
      if (error.response != null) {
        if (error.response!.statusCode == 403) {
          return const Icon(Icons.do_disturb_on_outlined);
        }
        if (error.response!.statusCode == 404) {
          return const Icon(Icons.error_outline);
        }
        if (error.response!.statusCode! < 500) {
          return const Icon(Icons.do_disturb_on_outlined);
        }
        return const Icon(Icons.report_problem_outlined);
      }
      return const Icon(MaterialCommunityIcons.wifi_off);
    }
    if (error is PartialSuccessError) {
      return Icon(Icons.warning);
    }
    return const Icon(Icons.report_problem_outlined);
  }

  static String Function(BuildContext context, Object? error, StackTrace? stackTrace) getErrorTitle =
      defaultGetErrorTitle;
  static String defaultGetErrorTitle(BuildContext context, Object? error, StackTrace? stackTrace) {
    // TODO: 3 internationalize
    if (error is DioException) {
      if (error.response != null) {
        if (error.response!.statusCode == 403) {
          return 'Error de Autorización';
        }
        if (error.response!.statusCode == 404) {
          return 'Recurso no Encontrado';
        }
        if (error.response!.statusCode! < 500) {
          return 'Petición Rechazada por el servidor';
        }
        return 'Error Interno del Servidor';
      }
      return FromZeroLocalizations.of(context).translate("error_connection");
    }
    if (error is PartialSuccessError) {
      return error.titleOverride;
    }
    return "Error Inesperado";
  }

  static String? Function(BuildContext context, Object? error, StackTrace? stackTrace) getErrorSubtitle =
      defaultGetErrorSubtitle;
  static String? defaultGetErrorSubtitle(BuildContext context, Object? error, StackTrace? stackTrace) {
    // TODO: 3 internationalize
    if (error is DioException) {
      if (error.response != null) {
        if (error.response!.statusCode == 403) {
          return 'Usted no tiene permiso para acceder al recurso solicitado';
        }
        if (error.response!.statusCode == 404) {
          return 'Por favor, notifique a su administrador de sistema';
        }
        if (error.response!.statusCode! < 500) {
          return null;
        }
        return 'Por favor, notifique a su administrador de sistema';
      }
      return FromZeroLocalizations.of(context).translate("error_connection_details");
    }
    if (error is PartialSuccessError) {
      return error.messageOverride;
    }
    return "Por favor, notifique a su administrador de sistema";
  }

  static bool Function(Object? error, StackTrace? stackTrace) isErrorRetryable = defaultIsErrorRetryable;
  static bool defaultIsErrorRetryable(Object? error, StackTrace? stackTrace) {
    if (error is DioException) {
      if (error.response != null) {
        if (error.response!.statusCode == 403) {
          return false;
        }
        if (error.response!.statusCode == 404) {
          return false;
        }
        if (error.response!.statusCode! < 500) {
          return false;
        }
        return false;
      }
      return true;
    }
    if (error is PartialSuccessError) {
      return false;
    }
    return false;
  }

  static bool Function(Object? error, StackTrace? stackTrace) shouldShowErrorDetails = defaultShouldShowErrorDetails;
  static bool defaultShouldShowErrorDetails(Object? error, StackTrace? stackTrace) {
    if (error is DioException) {
      if (error.response != null) {
        if (error.response!.statusCode == 403) {
          return false;
        }
        if (error.response!.statusCode == 404) {
          return false;
        }
        if (error.response!.statusCode! < 500) {
          return false;
        }
        return false;
      }
      return true;
    }
    if (error is PartialSuccessError) {
      return false;
    }
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
          const SizedBox(
            height: 8,
          ),
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

class SliverApiProviderBuilder<T> extends ApiProviderBuilder<T> {
  const SliverApiProviderBuilder({
    required super.provider,
    required super.dataBuilder,
    super.transitionDuration = const Duration(milliseconds: 300),
    super.loadingBuilder = SliverApiProviderBuilder.defaultLoadingBuilder,
    super.errorBuilder = SliverApiProviderBuilder.defaultErrorBuilder,
    super.transitionBuilder = SliverAsyncValueBuilder.defaultTransitionBuilder,
    super.layoutBuilder = AnimatedSwitcherImage.sliverLayoutBuilder,
    super.animatedSwitcherType = AnimatedSwitcherType.normal,

    /// AnimatedSwitcherImage doesn't support slivers, because of the RepaintBoundary
    super.key,
  }) : super(
         applyAnimatedContainerFromChildSize: false,
       );

  static Widget defaultLoadingBuilder(BuildContext context, ValueListenable<double?>? progress) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 256,
        child: ApiProviderBuilder.defaultLoadingBuilder(context, progress),
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
        child: ApiProviderBuilder.defaultErrorBuilder(context, error, stackTrace, onRetry),
      ),
    );
  }
}

class ApiProviderMultiBuilder<T> extends ConsumerWidget {
  final List<ApiProviderInstance<T>> providers;
  final DataMultiBuilder<T> dataBuilder;
  final ApiLoadingBuilder loadingBuilder;
  final ApiErrorBuilder errorBuilder;
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

  const ApiProviderMultiBuilder({
    required this.providers,
    required this.dataBuilder,
    this.loadingBuilder = ApiProviderBuilder.defaultLoadingBuilder,
    this.errorBuilder = ApiProviderBuilder.defaultErrorBuilder,
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
    List<ApiState<T>> stateNotifiers = [];
    List<AsyncValue<T>> values = [];
    for (final e in providers) {
      final stateNotifier = ref.watch(e.notifier);
      ref.watch(e);
      stateNotifiers.add(stateNotifier);
      // using stateNotifier.state instead of value because value is kept when realoading, so loading state is never shown
      // ignore: invalid_use_of_protected_member
      values.add(stateNotifier.state);
    }
    final listenables = stateNotifiers.map((e) => e.wholePercentageNotifier);
    final unifiedListenable = UnitedValueListenable(listenables, (values) {
      double? percentage;
      try {
        final meaningfulValues = values.whereType<double>().toList();
        percentage = meaningfulValues.isEmpty
            ? null
            : meaningfulValues.reduce((v, e) => v + e) / meaningfulValues.length;
      } catch (_) {}
      return percentage;
    });
    return AsyncValueMultiBuilder<T>(
      asyncValues: values,
      dataBuilder: dataBuilder,
      alignment: alignment,
      loadingBuilder: (context) {
        return loadingBuilder(context, unifiedListenable);
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

class SliverApiProviderMultiBuilder<T> extends ApiProviderMultiBuilder<T> {
  const SliverApiProviderMultiBuilder({
    required super.providers,
    required super.dataBuilder,
    super.transitionDuration = const Duration(milliseconds: 300),
    super.loadingBuilder = SliverApiProviderBuilder.defaultLoadingBuilder,
    super.errorBuilder = SliverApiProviderBuilder.defaultErrorBuilder,
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

class ApiStateBuilder<T> extends ConsumerStatefulWidget {
  final ApiState<T> stateNotifier;
  final DataBuilder<T> dataBuilder;
  final ApiLoadingBuilder loadingBuilder;
  final ApiErrorBuilder errorBuilder;
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

  const ApiStateBuilder({
    required this.stateNotifier,
    required this.dataBuilder,
    this.loadingBuilder = ApiProviderBuilder.defaultLoadingBuilder,
    this.errorBuilder = ApiProviderBuilder.defaultErrorBuilder,
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

class ApiStateBuilderState<T> extends ConsumerState<ApiStateBuilder<T>> {
  late AsyncValue<T> value;

  @override
  void initState() {
    super.initState();
    value = widget.stateNotifier.state;
    widget.stateNotifier.addListener(onNotify);
  }

  void onNotify() {
    if (!mounted) return;
    setState(() {
      value = widget.stateNotifier.state;
    });
  }

  @override
  void didUpdateWidget(covariant ApiStateBuilder<T> oldWidget) {
    if (widget.stateNotifier != oldWidget.stateNotifier) {
      oldWidget.stateNotifier.removeListener(onNotify);
      widget.stateNotifier.addListener(onNotify);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    widget.stateNotifier.removeListener(onNotify);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AsyncValueBuilder<T>(
      asyncValue: value,
      dataBuilder: widget.dataBuilder,
      alignment: widget.alignment,
      loadingBuilder: (context) {
        return widget.loadingBuilder(context, widget.stateNotifier.wholePercentageNotifier);
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

class SliverApiStateBuilder<T> extends ApiStateBuilder<T> {
  const SliverApiStateBuilder({
    required super.stateNotifier,
    required super.dataBuilder,
    super.transitionDuration = const Duration(milliseconds: 300),
    super.loadingBuilder = SliverApiProviderBuilder.defaultLoadingBuilder,
    super.errorBuilder = SliverApiProviderBuilder.defaultErrorBuilder,
    super.transitionBuilder = SliverAsyncValueBuilder.defaultTransitionBuilder,
    super.layoutBuilder = AnimatedSwitcherImage.sliverLayoutBuilder,
    super.animatedSwitcherType = AnimatedSwitcherType.normal,

    /// AnimatedSwitcherImage doesn't support slivers, because of the RepaintBoundary
    super.key,
  }) : super(
         applyAnimatedContainerFromChildSize: false,
       );
}

class PartialSuccessError<T> {
  final T? result;
  final int snackbarTypeOverride;
  final String titleOverride;
  final String messageOverride;
  const PartialSuccessError({
    required this.result,
    this.snackbarTypeOverride = SnackBarFromZero.warning,
    this.titleOverride = 'Éxito Parcial',
    this.messageOverride = '',
  });
}

// copied from riverpod because they don't expose it
typedef Retry = Duration? Function(int retryCount, Object error);
