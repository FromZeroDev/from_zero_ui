import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fz_dao/fz_dao.dart';
import 'package:fz_flutter_riverpod/fz_flutter_riverpod.dart';
import 'package:fz_future_handling/fz_future_handling.dart';
import 'package:fz_localizations/fz_localizations.dart';
import 'package:fz_popup/fz_popup.dart';
import 'package:fz_riverpod/fz_riverpod.dart' hide FzNotifierBuilder;
import 'package:fz_scrollbar/fz_scrollbar.dart';
import 'package:fz_table/fz_table.dart';
import 'package:fz_tooltip/fz_tooltip.dart';
import 'package:fz_ui_utility/fz_ui_utility.dart';

typedef ButtonChildBuilder<T> =
    Widget Function(
      BuildContext context, {
      required String? title,
      required String? hint,
      required T? value,
      required bool enabled,
      required bool clearable,
      bool showDropdownIcon,
    });

/// returns true if navigator should pop after (default true)
typedef OnPopupItemSelected<T> = bool? Function(T? value);
typedef ExtraWidgetBuilder<T> =
    Widget Function(
      BuildContext context,
      OnPopupItemSelected<T>? onSelected,
    );

class ComboFromZero<T> extends StatefulWidget {
  final T? value;
  final List<T>? possibleValues;
  final AsyncValue<List<T>>? possibleValuesAsync;
  final Future<List<T>>? possibleValuesFuture;
  final FzProviderInstance<List<T>>? possibleValuesProvider;
  final List<T> Function(String query)? filteredValues;
  final AsyncValue<List<T>> Function(String query)? filteredValuesAsync;
  final Future<List<T>> Function(String query)? filteredValuesFuture;
  final FzProviderInstance<List<T>> Function(String query)? filteredValuesProvider;
  final VoidCallback? onCanceled;
  final OnPopupItemSelected<T>? onSelected;
  final bool? showSearchBox;
  final String? title;
  final String? hint;
  final bool enabled;
  final bool clearable;
  final bool sort;
  final bool showViewActionOnDAOs;
  final bool showDropdownIcon;
  final bool blockComboWhilePossibleValuesLoad;
  final ButtonChildBuilder<T>? buttonChildBuilder;
  final double? popupWidth;
  final ExtraWidgetBuilder<T>? extraWidget;
  final FocusNode? focusNode;
  final Widget Function(T value)? popupWidgetBuilder;
  final ButtonStyle? buttonStyle;
  final Duration debounce;
  final int minChars;

  /// if null, an InkWell will be used instead
  final double popupRowHeight;
  final bool useFixedPopupRowHeight;
  final bool showNullInSelection;
  final bool showHintAsNullInSelection;

  const ComboFromZero({
    super.key,
    this.value,
    this.possibleValues,
    this.possibleValuesAsync,
    this.possibleValuesFuture,
    this.possibleValuesProvider,
    this.filteredValues,
    this.filteredValuesAsync,
    this.filteredValuesFuture,
    this.filteredValuesProvider,
    this.onSelected,
    this.onCanceled,
    this.showSearchBox,
    this.title,
    this.hint,
    this.buttonChildBuilder,
    this.enabled = true,
    this.clearable = true,
    this.sort = true,
    this.showViewActionOnDAOs = true,
    this.showDropdownIcon = false,
    this.popupWidth,
    this.extraWidget,
    this.focusNode,
    this.popupWidgetBuilder,
    this.buttonStyle = const ButtonStyle(
      padding: WidgetStatePropertyAll(EdgeInsets.zero),
    ),
    this.popupRowHeight = 38,
    this.useFixedPopupRowHeight = true,
    this.blockComboWhilePossibleValuesLoad = false,
    this.showNullInSelection = false,
    this.showHintAsNullInSelection = true,
    Duration? debounce,
    int? minChars,
  }) : debounce =
           debounce ??
           (possibleValues != null ||
                   possibleValuesAsync != null ||
                   possibleValuesFuture != null ||
                   possibleValuesProvider != null ||
                   filteredValues != null
               ? Duration.zero
               : const Duration(milliseconds: 300)),
       minChars =
           minChars ??
           (possibleValues != null ||
                   possibleValuesAsync != null ||
                   possibleValuesFuture != null ||
                   possibleValuesProvider != null ||
                   filteredValues != null
               ? 0
               : 3),
       assert(
         1 ==
             ((possibleValues == null ? 0 : 1) +
                 (possibleValuesAsync == null ? 0 : 1) +
                 (possibleValuesFuture == null ? 0 : 1) +
                 (possibleValuesProvider == null ? 0 : 1) +
                 (filteredValues == null ? 0 : 1) +
                 (filteredValuesAsync == null ? 0 : 1) +
                 (filteredValuesFuture == null ? 0 : 1) +
                 (filteredValuesProvider == null ? 0 : 1)),
         'You must set one and only one way of getting values.',
       );

  @override
  ComboFromZeroState<T> createState() => ComboFromZeroState<T>();

  // TODO: 2 this should probably be a statless widget
  static Widget defaultButtonChildBuilder(
    BuildContext context, {
    required String? title,
    required String? hint,
    required dynamic value,
    required bool enabled,
    required bool clearable,
    bool showDropdownIcon = true,
  }) {
    final theme = Theme.of(context);
    return IntrinsicWidth(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 38,
          minWidth: 192,
        ),
        child: Padding(
          padding: EdgeInsets.only(right: enabled && clearable ? 32 : 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: value == null && hint == null && title != null
                    ? Text(
                        title,
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: enabled ? theme.textTheme.bodyLarge!.color : theme.disabledColor,
                        ),
                      )
                    : MaterialKeyValuePair(
                        title: title,
                        value: value == null ? (hint ?? '') : value.toString(),
                        valueStyle: theme.textTheme.titleMedium!.copyWith(
                          height: 1,
                          color: enabled && value != null ? theme.textTheme.bodyLarge!.color : theme.disabledColor,
                        ),
                      ),
              ),
              const SizedBox(
                width: 4,
              ),
              if (showDropdownIcon && enabled && !clearable)
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.textTheme.bodyLarge!.color,
                ),
              const SizedBox(
                width: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ComboFromZeroState<T> extends State<ComboFromZero<T>> {
  final buttonKey = GlobalKey();
  late FocusNode buttonFocusNode = widget.focusNode ?? FocusNode();
  bool _isPushedPopup = false;

  @override
  void didUpdateWidget(ComboFromZero<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    buttonFocusNode = widget.focusNode ?? buttonFocusNode;
    if (!widget.enabled && _isPushedPopup) {
      final thisRoute = ModalRoute.of(context);
      if (thisRoute != null) {
        Navigator.of(context).popUntil((route) {
          return route == thisRoute;
        });
      } else {
        Navigator.of(context).pop();
      }
      // _popPopup();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget result;
    if (widget.blockComboWhilePossibleValuesLoad) {
      if (widget.possibleValuesProvider != null) {
        result = FzProviderBuilder<List<T>>(
          provider: widget.possibleValuesProvider!,
          dataBuilder: _buildCombo,
          loadingBuilder: _buildComboLoading,
          errorBuilder: _buildComboError,
        );
      } else if (widget.possibleValuesFuture != null) {
        result = FutureBuilderFromZero<List<T>>(
          future: widget.possibleValuesFuture!,
          successBuilder: _buildCombo,
          loadingBuilder: _buildComboLoading,
          errorBuilder: (context, error, stackTrace) =>
              _buildComboError(context, error, stackTrace is StackTrace ? stackTrace : null),
        );
      } else if (widget.possibleValuesAsync != null) {
        result = AsyncValueBuilder<List<T>>(
          asyncValue: widget.possibleValuesAsync!,
          dataBuilder: _buildCombo,
          loadingBuilder: _buildComboLoading,
          errorBuilder: _buildComboError,
        );
      } else {
        result = _buildCombo(context, widget.possibleValues);
      }
    } else {
      result = _buildCombo(context, null);
    }
    return result;
  }

  Widget _buildComboError(BuildContext context, Object? error, StackTrace? stackTrace, [VoidCallback? onRetry]) {
    return LimitedBox(
      maxWidth: 256,
      maxHeight: 64,
      child: FzProviderBuilder.defaultErrorBuilder(context, error, stackTrace, onRetry),
    );
  }

  Widget _buildComboLoading(BuildContext context, [double? progress, double? count, double? total]) {
    Widget result;
    if (widget.buttonChildBuilder == null) {
      result = ComboFromZero.defaultButtonChildBuilder(
        context,
        title: widget.title,
        hint: widget.hint,
        value: widget.value,
        enabled: widget.enabled,
        clearable: widget.clearable,
        showDropdownIcon: widget.showDropdownIcon,
      );
    } else {
      result = widget.buttonChildBuilder!(
        context,
        title: widget.title,
        hint: widget.hint,
        value: widget.value,
        enabled: widget.enabled,
        clearable: widget.clearable,
        showDropdownIcon: widget.showDropdownIcon,
      );
    }
    return LimitedBox(
      maxWidth: 256,
      maxHeight: 64,
      child: Stack(
        children: [
          result,
          Positioned.fill(
            child: Container(
              alignment: Alignment.center,
              color: Theme.of(context).disabledColor,
              child: FzProviderBuilder.defaultLoadingBuilder(context, progress, count, total),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombo(
    BuildContext context,
    List<T>? possibleValues,
  ) {
    Widget result;
    if (widget.buttonChildBuilder == null) {
      result = ComboFromZero.defaultButtonChildBuilder(
        context,
        title: widget.title,
        hint: widget.hint,
        value: widget.value,
        enabled: widget.enabled,
        clearable: widget.clearable,
        showDropdownIcon: widget.showDropdownIcon,
      );
    } else {
      result = widget.buttonChildBuilder!(
        context,
        title: widget.title,
        hint: widget.hint,
        value: widget.value,
        enabled: widget.enabled,
        clearable: widget.clearable,
        showDropdownIcon: widget.showDropdownIcon,
      );
    }
    final onPressed = widget.enabled
        ? () async {
            buttonFocusNode.requestFocus();
            _isPushedPopup = true;
            T? selected = await showPopupFromZero<T>(
              context: context,
              anchorKey: buttonKey,
              width: widget.popupWidth,
              builder: (context) {
                final Widget result;
                if (possibleValues != null) {
                  result = _buildPopup(context, possibleValues);
                } else {
                  if (widget.possibleValuesProvider != null) {
                    result = FzProviderBuilder<List<T>>(
                      provider: widget.possibleValuesProvider!,
                      dataBuilder: _buildPopup,
                      loadingBuilder: _buildPopupLoading,
                      errorBuilder: _buildPopupError,
                    );
                  } else if (widget.possibleValuesFuture != null) {
                    result = FutureBuilderFromZero<List<T>>(
                      future: widget.possibleValuesFuture!,
                      successBuilder: _buildPopup,
                      loadingBuilder: _buildPopupLoading,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPopupError(context, error, stackTrace is StackTrace ? stackTrace : null),
                    );
                  } else if (widget.possibleValuesAsync != null) {
                    result = AsyncValueBuilder<List<T>>(
                      asyncValue: widget.possibleValuesAsync!,
                      dataBuilder: _buildPopup,
                      loadingBuilder: _buildPopupLoading,
                      errorBuilder: _buildPopupError,
                    );
                  } else {
                    result = _buildPopup(context, widget.possibleValues);
                  }
                }
                return result;
              },
            );
            _isPushedPopup = false;
            if (selected == null) {
              widget.onCanceled?.call();
            }
          }
        : null;
    if (widget.buttonStyle != null) {
      result = TextButton(
        key: buttonKey,
        style: widget.buttonStyle,
        focusNode: buttonFocusNode,
        onPressed: onPressed,
        child: Center(
          child: OverflowScroll(
            scrollDirection: Axis.vertical,
            autoscrollSpeed: null,
            child: result,
          ),
        ),
      );
    } else {
      result = InkWell(
        key: buttonKey,
        focusNode: buttonFocusNode,
        onTap: onPressed,
        child: Center(
          child: OverflowScroll(
            scrollDirection: Axis.vertical,
            autoscrollSpeed: null,
            child: result,
          ),
        ),
      );
    }
    result = Stack(
      children: [
        result,
        if (widget.enabled && widget.clearable)
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: ExcludeFocus(
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, animation) {
                    return SizeTransition(
                      sizeFactor: animation,
                      child: FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                    );
                  },
                  child: widget.value != null
                      ? TooltipFromZero(
                          message: FromZeroLocalizations.of(context).translate('clear'),
                          child: IconButton(
                            icon: const Icon(Icons.close),
                            splashRadius: 20,
                            onPressed: () {
                              if (widget.enabled) {
                                widget.onSelected?.call(null);
                              }
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
      ],
    );
    return result;
  }

  Widget _buildPopup(
    BuildContext context,
    List<T>? possibleValues,
  ) {
    return ComboFromZeroPopup<T>(
      possibleValues: possibleValues,
      filteredValues: widget.filteredValues,
      filteredValuesAsync: widget.filteredValuesAsync,
      filteredValuesFuture: widget.filteredValuesFuture,
      filteredValuesProvider: widget.filteredValuesProvider,
      onSelected: (value) {
        if (widget.enabled) {
          widget.onSelected?.call(value);
        }
      },
      onCanceled: widget.onCanceled,
      value: widget.value,
      sort: widget.sort,
      showSearchBox: widget.showSearchBox,
      showViewActionOnDAOs: widget.showViewActionOnDAOs,
      title: widget.title,
      extraWidget: widget.extraWidget,
      popupWidgetBuilder: widget.popupWidgetBuilder,
      rowHeight: widget.popupRowHeight,
      useFixedRowHeight: widget.useFixedPopupRowHeight,
      showNullInSelection: widget.showNullInSelection,
      showHintAsNullInSelection: widget.showHintAsNullInSelection,
      hint: widget.hint,
      debounce: widget.debounce,
      minChars: widget.minChars,
    );
  }

  Widget _buildPopupError(BuildContext context, Object? error, StackTrace? stackTrace, [VoidCallback? onRetry]) {
    return IntrinsicHeight(
      child: FzProviderBuilder.defaultErrorBuilder(context, error, stackTrace, onRetry),
    );
  }

  Widget _buildPopupLoading(BuildContext context, [double? progress, double? count, double? total]) {
    return SizedBox(
      height: 128,
      child: FzProviderBuilder.defaultLoadingBuilder(context, progress, count, total),
    );
  }
}

class ComboFromZeroPopup<T> extends StatefulWidget {
  final T? value;
  final List<T>? possibleValues;
  final List<T> Function(String query)? filteredValues;
  final AsyncValue<List<T>> Function(String query)? filteredValuesAsync;
  final Future<List<T>> Function(String query)? filteredValuesFuture;
  final FzProviderInstance<List<T>> Function(String query)? filteredValuesProvider;
  final VoidCallback? onCanceled;
  final OnPopupItemSelected<T>? onSelected;
  final bool? showSearchBox;
  final bool showViewActionOnDAOs;
  final bool sort;
  final String? title;
  final ExtraWidgetBuilder<T>? extraWidget;
  final Widget Function(T value)? popupWidgetBuilder;
  final double rowHeight;
  final bool useFixedRowHeight;
  final bool showNullInSelection;
  final bool showHintAsNullInSelection;
  final String? hint;
  final Duration debounce;
  final int minChars;

  const ComboFromZeroPopup({
    this.possibleValues,
    this.filteredValues,
    this.filteredValuesAsync,
    this.filteredValuesFuture,
    this.filteredValuesProvider,
    this.value,
    this.onSelected,
    this.onCanceled,
    this.showSearchBox,
    this.showViewActionOnDAOs = true,
    this.sort = true,
    this.title,
    this.extraWidget,
    this.popupWidgetBuilder,
    this.rowHeight = 38,
    this.useFixedRowHeight = true,
    this.showNullInSelection = false,
    this.showHintAsNullInSelection = true,
    this.hint,
    Duration? debounce,
    int? minChars,
    super.key,
  }) : debounce =
           debounce ??
           (possibleValues != null || filteredValues != null ? Duration.zero : const Duration(milliseconds: 500)),
       minChars = minChars ?? (possibleValues != null || filteredValues != null ? 0 : 3),
       assert(
         1 ==
             ((possibleValues == null ? 0 : 1) +
                 (filteredValues == null ? 0 : 1) +
                 (filteredValuesAsync == null ? 0 : 1) +
                 (filteredValuesFuture == null ? 0 : 1) +
                 (filteredValuesProvider == null ? 0 : 1)),
         'You must set one and only one way of getting values.',
       );

  @override
  ComboFromZeroPopupState<T> createState() => ComboFromZeroPopupState<T>();
}

class ComboFromZeroPopupState<T> extends State<ComboFromZeroPopup<T>> {
  final ScrollController popupScrollController = ScrollController();
  final TextEditingController queryController = TextEditingController();
  String? searchQuery;
  TableController<T?> tableController = TableController();
  FocusNode initialFocus = FocusNode();

  final GlobalKey addonKey = GlobalKey();

  bool get showSearchBox =>
      widget.showSearchBox ?? (widget.possibleValues == null || widget.possibleValues!.length > 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (showSearchBox) {
        initialFocus.requestFocus();
      } else {
        // FocusScope.of(context).nextFocus();
      }
    });
    lastUpdate = DateTime.timestamp();
  }

  @override
  Widget build(BuildContext context) {
    Widget? table;
    if (showSearchBox && (searchQuery?.length ?? 0) < widget.minChars) {
      table = buildTable(context, [], queryTooSmall: true);
    } else if (widget.possibleValues case final values?) {
      table = buildTable(context, values);
    } else if (widget.filteredValues case final filter?) {
      table = buildTable(context, filter(searchQuery ?? ''));
    } else if (widget.filteredValuesProvider case final filter?) {
      table = FzProviderBuilder<List<T>>(
        provider: filter(searchQuery ?? ''),
        dataBuilder: buildTable,
        loadingBuilder: (context, _, _, _) => buildTable(context, [], showLoading: true),
        errorBuilder: _buildError,
        transitionBuilder: (context, child, animation) => FadeTransition(opacity: animation, child: child),
      );
    } else if (widget.filteredValuesAsync case final filter?) {
      table = AsyncValueBuilder<List<T>>(
        asyncValue: filter(searchQuery ?? ''),
        dataBuilder: buildTable,
        loadingBuilder: (context) => buildTable(context, [], showLoading: true),
        errorBuilder: _buildError,
        transitionBuilder: (context, child, animation) => FadeTransition(opacity: animation, child: child),
      );
    } else if (widget.filteredValuesFuture case final filter?) {
      table = FutureBuilderFromZero<List<T>>(
        future: filter(searchQuery ?? ''),
        successBuilder: buildTable,
        loadingBuilder: (context) => buildTable(context, [], showLoading: true),
        errorBuilder: (context, error, stackTrace) =>
            _buildError(context, error, stackTrace is StackTrace ? stackTrace : null),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      );
    }
    return ScrollbarFromZero(
      controller: popupScrollController,
      child: table!,
    );
  }

  Widget _buildError(BuildContext context, Object? error, StackTrace? stackTrace, [VoidCallback? onRetry]) {
    return IntrinsicHeight(
      child: FzProviderBuilder.defaultErrorBuilder(context, error, stackTrace, onRetry),
    );
  }

  Widget buildTable(
    BuildContext context,
    List<T> values, {
    bool showLoading = false,
    bool queryTooSmall = false,
  }) {
    final defaultTextStyle = Theme.of(context).textTheme.titleMedium!.copyWith(
      fontWeight: FontWeight.w500,
    );
    final rows = values.map((e) {
      return SimpleRowModel<T?>(
        id: e,
        values: {0: e.toString()},
        height: widget.useFixedRowHeight ? widget.rowHeight : null,
        textStyle: defaultTextStyle,
        onRowTap: (value) {
          _select(e);
        },
      );
    }).toList();
    if (widget.showNullInSelection) {
      rows.add(
        SimpleRowModel<T?>(
          id: null,
          values: {
            0: (widget.showHintAsNullInSelection ? widget.hint : null) ?? '< Vacío >',
          }, // TODO: 3 internationalize
          height: widget.useFixedRowHeight ? widget.rowHeight : null,
          alwaysOnTop: true,
          textStyle: defaultTextStyle,
          onRowTap: (value) {
            _select(null);
          },
        ),
      );
    }
    return CustomScrollView(
      controller: popupScrollController,
      shrinkWrap: true,
      slivers: [
        if (!showSearchBox) const SliverToBoxAdapter(child: SizedBox(height: 12)),
        TableFromZero<T?>(
          tableController: tableController,
          tableHorizontalPadding: 8,
          initialSortedColumn: widget.sort ? 0 : -1,
          enableFixedHeightForListRows: widget.useFixedRowHeight,
          cellBuilder: widget.popupWidgetBuilder == null
              ? null
              : (context, row, colKey, col) => widget.popupWidgetBuilder!(row.id as T),
          rows: rows,
          onFilter: widget.possibleValues == null
              ? null
              : (filtered) {
                  List<RowModel<T?>> starts = [];
                  List<RowModel<T?>> contains = [];
                  if (searchQuery == null || searchQuery!.isEmpty) {
                    contains = filtered;
                  } else {
                    final q = searchQuery!.trim().toUpperCase();
                    for (final e in filtered) {
                      final value = (e.id is DAO)
                          ? (e.id! as DAO).searchName.toUpperCase()
                          : e.id == null
                          ? e.values[0].toString()
                          : e.id.toString().toUpperCase();
                      if (value.contains(q)) {
                        if (value.startsWith(q)) {
                          starts.add(e);
                        } else {
                          contains.add(e);
                        }
                      }
                    }
                  }
                  return [...starts, ...contains];
                },
          rowActions: widget.showViewActionOnDAOs && T is DAO
              ? [
                  RowAction<T>(
                    title: FromZeroLocalizations.of(context).translate('view'),
                    icon: const Icon(Icons.info_outline),
                    onRowTap: (context, row) {
                      (row.id as DAO).pushViewDialog(context);
                    },
                  ),
                ]
              : [],
          emptyWidget: !queryTooSmall
              ? null
              : TableEmptyWidget(
                  tableController: tableController,
                  title: 'Buscar...',
                  subtitle: 'Escriba al menos ${widget.minChars} caracteres para buscar',
                ),
          headerWidgetAddon: ColoredBox(
            key: addonKey,
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                if (widget.title != null)
                  Container(
                    padding: EdgeInsets.only(
                      top: showSearchBox ? 8.0 : 0,
                      bottom: widget.extraWidget != null
                          ? 4
                          : !showSearchBox
                          ? 12
                          : 0,
                      left: 8,
                      right: 8,
                    ),
                    alignment: Alignment.center,
                    child: Transform.translate(
                      offset: Offset(0, widget.extraWidget == null && showSearchBox ? 4 : 0),
                      child: Text(
                        widget.title!,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (widget.extraWidget != null)
                  widget.extraWidget!(
                    context,
                    widget.onSelected,
                  ),
                if (showSearchBox)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 8.0,
                      left: 12,
                      right: 12,
                    ),
                    child: KeyboardListener(
                      includeSemantics: false,
                      focusNode: FocusNode(),
                      onKeyEvent: (value) {
                        if (value is KeyDownEvent) {
                          if (value.logicalKey == LogicalKeyboardKey.arrowDown) {
                            FocusScope.of(context).focusInDirection(TraversalDirection.down);
                          } else if (value.logicalKey == LogicalKeyboardKey.arrowUp) {
                            FocusScope.of(context).focusInDirection(TraversalDirection.up);
                          }
                        }
                      },
                      child: TextFormField(
                        controller: queryController,
                        focusNode: initialFocus,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.only(
                            left: 8,
                            right: 80,
                            bottom: 4,
                            top: 8,
                          ),
                          labelText: FromZeroLocalizations.of(context).translate('search...'),
                          labelStyle: const TextStyle(height: 1.5),
                          suffixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                        onChanged: _onChanged,
                        onFieldSubmitted: (value) {
                          final filtered = tableController.filtered;
                          if (filtered.length == 1) {
                            _select(filtered.first.id);
                          }
                        },
                      ),
                    ),
                  ),
                if (showLoading) LinearProgressIndicator(),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
      ],
    );
  }

  late DateTime lastUpdate;
  bool updateQueued = false;
  void _onChanged(_) {
    final diff = DateTime.timestamp().difference(lastUpdate);
    lastUpdate = DateTime.timestamp();
    if (updateQueued) return;
    if (diff > widget.debounce) {
      _executeOnChanged(queryController.text);
    } else {
      updateQueued = true;
      _queueChangeExecution(diff);
    }
  }

  void _queueChangeExecution(Duration diff) {
    diff = DateTime.timestamp().difference(lastUpdate);
    Future<void>.delayed(widget.debounce - diff).then((_) {
      if (!context.mounted) return;
      diff = DateTime.timestamp().difference(lastUpdate);
      if (diff < widget.debounce) {
        _queueChangeExecution(diff);
        return;
      }
      _executeOnChanged(queryController.text);
      lastUpdate = DateTime.timestamp();
      updateQueued = false;
    });
  }

  void _executeOnChanged(String value) {
    searchQuery = value;
    if (widget.possibleValues != null) {
      tableController.filter();
    } else {
      tableController.reInit();
      setState(() {});
    }
  }

  void _select(T? e) {
    bool? pop = widget.onSelected?.call(e);
    if (pop ?? true) {
      Navigator.of(context).pop(e);
    }
  }
}
