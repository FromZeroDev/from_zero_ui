import 'package:dartx/dartx.dart';
import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:from_zero_ui/from_zero_ui.dart';
import 'package:from_zero_ui/util/comparable_list.dart';
import 'package:intl/intl.dart';





class RowAction<T> extends ActionFromZero {

  final void Function(BuildContext context, RowModel<T> row)? onRowTap;
  final String? Function(BuildContext context, RowModel<T> row)? disablingErrorGetter;
  final Map<double, ActionState>? Function(BuildContext context, RowModel<T> row)? breakpointsGetter;

  RowAction({
    required this.onRowTap,
    required super.title,
    super.icon,
    super.breakpoints,
    this.breakpointsGetter,
    super.overflowBuilder,
    super.iconBuilder,
    super.buttonBuilder,
    super.expandedBuilder,
    super.centerExpanded,
    super.key,
    this.disablingErrorGetter,
  }) :  assert(breakpointsGetter==null || breakpoints!=null, 'Please specify default breakpoints, that should be the max that a column can get'),
        super(
          onTap: (context) {},
        );

  RowAction.divider({super.key, 
    Map<double, ActionState>? breakpoints,
    super.overflowBuilder = ActionFromZero.dividerOverflowBuilder,
    super.iconBuilder = ActionFromZero.dividerIconBuilder,
    super.buttonBuilder = ActionFromZero.dividerIconBuilder,
  })  : onRowTap = null,
        disablingErrorGetter = null,
        breakpointsGetter = null,
        super(
          onTap: null,
          title: '',
          breakpoints: breakpoints ?? {
            0: ActionState.popup,
          },
        );

}



abstract class RowModel<T> {
  T get id;
  Key? get rowKey => null;
  Map get values;
  Color? get backgroundColor => null;
  TextStyle? get textStyle => null;
  double? get height => 36;
  bool? get selected => null;
  ValueChanged<RowModel<T>>? get onRowTap => null;
  ValueChanged<RowModel<T>>? get onRowDoubleTap => null;
  ValueChanged<RowModel<T>>? get onRowLongPress => null;
  OnRowHoverCallback? get onRowHover => null;
  OnCellTapCallback? get onCellTap => null;
  OnCellTapCallback? get onCellDoubleTap => null;
  OnCellTapCallback? get onCellLongPress => null;
  OnCellHoverCallback? get onCellHover => null;
  OnCheckBoxSelectedCallback? get onCheckBoxSelected => null;
  Widget? get rowAddon => null;
  bool? get rowAddonIsCoveredByGestureDetector => null;
  bool? get rowAddonIsCoveredByBackground => null;
  bool? get rowAddonIsCoveredByScrollable => null;
  bool get rowAddonIsExpandable => false;
  bool? get rowAddonIsSticky => null;
  bool? get rowAddonIsAboveRow => null;
  bool? get alwaysOnTop => null;
  List<RowModel<T>> get children;

  // these fields should only be changed by RowModel and TableFromZeroState
  bool expanded;
  int depth;
  late FocusNode focusNode = FocusNode();
  late List<RowModel<T>> filteredChildren = [];
  late bool isFilteredInBecauseOfChildren = false;
  bool? hasExpandableRows;

  RowModel({
    this.expanded = false,
    this.depth = 0,
  });
  @override
  bool operator == (dynamic other) => other is RowModel && this.id==other.id;
  @override
  int get hashCode => Object.hashAll([RowModel, id]);

  bool get isExpandable => children.isNotEmpty || (rowAddon!=null && rowAddonIsExpandable);
  List<RowModel<T>> get visibleRows => [this, if (expanded) ...children.map((e) => e.visibleRows).flatten()];
  List<RowModel<T>> get visibleFilteredRows => [this, if (expanded) ...filteredChildren.map((e) => e.visibleFilteredRows).flatten()];
  List<RowModel<T>> get visibleChildren => visibleRows..removeAt(0);
  List<RowModel<T>> get allRows => [this, ...children.map((e) => e.allRows).flatten()];
  List<RowModel<T>> get allChildren => allRows..removeAt(0);
  List<RowModel<T>> get allFilteredChildren => filteredChildren.map((e) => [e, ...e.allFilteredChildren]).flatten().toList();
  int get length => 1 + (expanded ? children.sumBy((e) => e.length) : 0);
  int get filteredLength => 1 + (expanded ? filteredChildren.sumBy((e) => e.filteredLength) : 0);
  void calculateDepth() {
    for (final e in children) {
      e.depth = depth+1;
      e.calculateDepth();
    }
  }
}

///The widget assumes columns will be constant, so bugs may happen when changing columns
abstract class ColModel<T>{
  String get name;
  String? get compactName;
  String? get tooltip;
  Color? get backgroundColor => null;
  TextStyle? get textStyle => null;
  TextAlign? get alignment => null;
  double? get width => null;
  int? get flex => null;
  ValueChanged<int>? get onHeaderTap => null;
  ValueChanged<int>? get onHeaderDoubleTap => null;
  ValueChanged<int>? get onHeaderLongPress => null;
  OnHeaderHoverCallback? get onHeaderHover => null;
  bool? get defaultSortAscending => null;
  bool? get sortEnabled => true;
  bool? get filterEnabled => null;
  bool Function(RowModel<T> row)? get rowCountSelector;
  ShowFilterPopupCallback? get showFilterPopupCallback;
  /// exhaustive list of all possible values cells of this column can take
  /// if a row has a value not declared here, the row will be filtered out,
  /// because the valueFilter for said value will be treated as false.
  Iterable<dynamic>? get possibleValues;
  /// same as TableController.initialValueFilters, both shouldn't be specified,
  /// but if they do, the values in TableController take priority
  Map<Object?, bool>? get initialValueFilters;
  bool? get initialValueFiltersExcludeAllElse;
  bool get initiallyHidden;

  Object? getValue(RowModel row, dynamic key) {
    return row.values[key];
  }
  String getValueString(RowModel row, dynamic key) {
    final value = getValue(row, key);
    if (value is List || value is ComparableList) {
      final List list = value is List ? value
          : value is ComparableList ? value.list : [];
      return ListField.listToStringAll(list);
    } else {
      return value!=null ? value.toString() : "";
    }
  }

  String getSubtitleText(BuildContext context, List<RowModel<T>>? filtered, dynamic key, {
    bool addMetadata = true,
  }) {
    if (filtered==null) {
      return '';
    } else {
      final reFiltered = rowCountSelector==null
          ? filtered
          : filtered.where((e) => rowCountSelector!(e)).toList();
      final count = reFiltered.length;
      String result = count==0 ? FromZeroLocalizations.of(context).translate('no_elements')
          : '$count ${count>1 ? FromZeroLocalizations.of(context).translate('element_plur')
          : FromZeroLocalizations.of(context).translate('element_sing')}';
      if (addMetadata) {
        final metadata = getMetadataText(context, filtered, key, reFiltered: reFiltered);
        if (metadata.isNotBlank) {
          result += '     $name - $metadata';
        }
      }
      return result;
    }
  }
  String getMetadataText(BuildContext context, List<RowModel<T>>? filtered, dynamic key, {
    List<RowModel<T>>? reFiltered,
  }) {
    if (filtered!=null) {
      reFiltered ??= rowCountSelector==null
          ? filtered
          : filtered.where((e) => rowCountSelector!(e)).toList();
      if (reFiltered.isNotEmpty) {
        final Set<dynamic> unique = {};
        for (final row in reFiltered) {
          final value = getValue(row, key);
          addValueToSet(unique, value);
        }
        return unique.length==1 ? '1 valor único' : '${unique.length} valores únicos';
      }
    }
    return '';
  }
  static void addValueToSet(Set<dynamic> set, dynamic value) {
    if (value is ContainsValue) {
      addValueToSet(set, value.value);
    } else if (value is List) {
      for (final e in value) {
        addValueToSet(set, e);
      }
    } else {
      set.add(value);
    }
  }
  Widget? buildSortedIcon(BuildContext context, bool ascending) => null;
  List<ConditionFilter> getAvailableConditionFilters() => [
    // FilterIsEmpty(),
    // FilterTextExactly(),
    FilterTextContains(),
    FilterTextStartsWith(),
    FilterTextEndsWith(),
    // FilterNumberEqualTo(),
    // FilterNumberGreaterThan(),
    // FilterNumberLessThan(),
    // FilterDateExactDay(),
    // FilterDateAfter(),
    // FilterDateBefore(),
  ];

  static Object? getRowValue(RowModel row, dynamic key, ColModel? col) {
    return col?.getValue(row, key) ?? row.values[key];
  }
  static String getRowValueString(RowModel row, dynamic key, ColModel? col) {
    if (col!=null) {
      return col.getValueString(row, key);
    }
    final value = getRowValue(row, key, col);
    if (value is List || value is ComparableList) {
      final List list = value is List ? value
          : value is ComparableList ? value.list : [];
      return ListField.listToStringAll(list);
    } else {
      return value!=null ? value.toString() : "";
    }
  }

  List<RowModel> buildFilterPopupRowModels(List<dynamic> availableFilters, Map<dynamic, Map<Object?, bool>> valueFilters, dynamic colKey, ValueNotifier<bool> modified) {
    return availableFilters.map((e) {
      return SimpleRowModel(
        id: e,
        values: {colKey: e},
        selected: valueFilters[colKey]![e] ?? false,
        onCheckBoxSelected: (row, selected) {
          modified.value = true;
          valueFilters[colKey]![row.id] = selected!;
          (row as SimpleRowModel).selected = selected;
          return true;
        },
      );
    }).toList();
  }
}



class SimpleRowModel<T> extends RowModel<T> {
  @override
  T id;
  @override
  Key? rowKey;
  @override
  Map values;
  @override
  Color? backgroundColor;
  @override
  TextStyle? textStyle;
  @override
  double? height;
  @override
  bool? selected;
  @override
  ValueChanged<RowModel<T>>? onRowTap;
  @override
  ValueChanged<RowModel<T>>? onRowDoubleTap;
  @override
  ValueChanged<RowModel<T>>? onRowLongPress;
  @override
  OnRowHoverCallback? onRowHover;
  @override
  OnCellTapCallback? onCellTap;
  @override
  OnCellTapCallback? onCellDoubleTap;
  @override
  OnCellTapCallback? onCellLongPress;
  @override
  OnCellHoverCallback? onCellHover;
  @override
  OnCheckBoxSelectedCallback? onCheckBoxSelected;
  @override
  Widget? rowAddon;
  @override
  bool? rowAddonIsCoveredByGestureDetector;
  @override
  bool? rowAddonIsCoveredByBackground;
  @override
  bool? rowAddonIsCoveredByScrollable;
  @override
  bool? rowAddonIsSticky;
  @override
  bool rowAddonIsExpandable;
  @override
  bool? rowAddonIsAboveRow;
  @override
  bool? alwaysOnTop;
  @override
  List<RowModel<T>> children;
  SimpleRowModel({
    required this.id,
    required this.values,
    this.rowKey,
    this.backgroundColor,
    this.textStyle,
    this.height = 36,
    this.selected,
    this.onRowTap,
    this.onRowDoubleTap,
    this.onRowLongPress,
    this.onRowHover,
    this.onCheckBoxSelected,
    this.rowAddon,
    this.rowAddonIsCoveredByGestureDetector,
    this.rowAddonIsCoveredByBackground,
    this.rowAddonIsCoveredByScrollable,
    this.rowAddonIsSticky,
    this.rowAddonIsExpandable = false,
    this.rowAddonIsAboveRow,
    this.alwaysOnTop,
    this.onCellTap,
    this.onCellDoubleTap,
    this.onCellLongPress,
    this.onCellHover,
    this.children = const [],
    super.expanded = false,
    super.depth = 0,
  });
  SimpleRowModel<T> copyWith({
    T? id,
    Key? rowKey,
    Map? values,
    Color? backgroundColor,
    TextStyle? textStyle,
    double? height,
    bool? selected,
    ValueChanged<RowModel<T>>? onRowTap,
    ValueChanged<RowModel<T>>? onRowDoubleTap,
    ValueChanged<RowModel<T>>? onRowLongPress,
    OnRowHoverCallback? onRowHover,
    OnCheckBoxSelectedCallback? onCheckBoxSelected,
    Widget? rowAddon,
    bool? rowAddonIsCoveredByGestureDetector,
    bool? rowAddonIsCoveredByBackground,
    bool? rowAddonIsCoveredByScrollable,
    bool? rowAddonIsSticky,
    bool? rowAddonIsExpandable,
    bool? rowAddonIsAboveRow,
    bool? alwaysOnTop,
    OnCellTapCallback? onCellTap,
    OnCellTapCallback? onCellDoubleTap,
    OnCellTapCallback? onCellLongPress,
    OnCellHoverCallback? onCellHover,
    List<RowModel<T>>? children,
    bool? expanded,
    int? depth,
  }) {
    return SimpleRowModel<T>(
      id: id ?? this.id,
      rowKey: rowKey ?? this.rowKey,
      values: values ?? this.values,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      height: height ?? this.height,
      selected: selected ?? this.selected,
      onRowTap: onRowTap ?? this.onRowTap,
      onRowDoubleTap: onRowDoubleTap ?? this.onRowDoubleTap,
      onRowLongPress: onRowLongPress ?? this.onRowLongPress,
      onRowHover: onRowHover ?? this.onRowHover,
      onCheckBoxSelected: onCheckBoxSelected ?? this.onCheckBoxSelected,
      rowAddon: rowAddon ?? this.rowAddon,
      rowAddonIsCoveredByGestureDetector: rowAddonIsCoveredByGestureDetector ?? this.rowAddonIsCoveredByGestureDetector,
      rowAddonIsCoveredByBackground: rowAddonIsCoveredByBackground ?? this.rowAddonIsCoveredByBackground,
      rowAddonIsCoveredByScrollable: rowAddonIsCoveredByScrollable ?? this.rowAddonIsCoveredByScrollable,
      rowAddonIsSticky: rowAddonIsSticky ?? this.rowAddonIsSticky,
      rowAddonIsAboveRow: rowAddonIsAboveRow ?? this.rowAddonIsAboveRow,
      onCellTap: onCellTap ?? this.onCellTap,
      onCellDoubleTap: onCellDoubleTap ?? this.onCellDoubleTap,
      onCellLongPress: onCellLongPress ?? this.onCellLongPress,
      onCellHover: onCellHover ?? this.onCellHover,
      alwaysOnTop: alwaysOnTop ?? this.alwaysOnTop,
      rowAddonIsExpandable: rowAddonIsExpandable ?? this.rowAddonIsExpandable,
      children: children ?? this.children,
      expanded: expanded ?? this.expanded,
      depth: depth ?? this.depth,
    );
  }
}

class SimpleColModel<T> extends ColModel<T>{
  @override
  String name;
  @override
  String? compactName;
  @override
  String? tooltip;
  @override
  Color? backgroundColor;
  @override
  TextStyle? textStyle;
  @override
  TextAlign? alignment;
  @override
  int? flex;
  @override
  double? width;
  @override
  ValueChanged<int>? onHeaderTap;
  @override
  ValueChanged<int>? onHeaderDoubleTap;
  @override
  ValueChanged<int>? onHeaderLongPress;
  @override
  OnHeaderHoverCallback? onHeaderHover;
  @override
  bool? defaultSortAscending;
  @override
  bool? sortEnabled;
  @override
  bool? filterEnabled;
  @override
  bool Function(RowModel<T> row)? rowCountSelector;
  @override
  ShowFilterPopupCallback? showFilterPopupCallback;
  @override
  Iterable<dynamic>? possibleValues;
  @override
  Map<Object?, bool>? initialValueFilters;
  @override
  bool? initialValueFiltersExcludeAllElse;
  @override
  bool initiallyHidden;
  SimpleColModel({
    required this.name,
    this.compactName,
    this.tooltip,
    this.backgroundColor,
    this.textStyle,
    this.alignment,
    this.flex,
    this.width,
    this.onHeaderTap,
    this.onHeaderDoubleTap,
    this.onHeaderLongPress,
    this.onHeaderHover,
    this.defaultSortAscending,
    this.sortEnabled = true,
    this.filterEnabled,
    this.rowCountSelector,
    this.showFilterPopupCallback,
    this.possibleValues,
    this.initialValueFilters,
    this.initialValueFiltersExcludeAllElse,
    this.initiallyHidden = false,
  });
  SimpleColModel<T> copyWith({
    String? name,
    String? tooltip,
    Color? backgroundColor,
    TextStyle? textStyle,
    TextAlign? alignment,
    int? flex,
    double? width,
    ValueChanged<int>? onHeaderTap,
    ValueChanged<int>? onHeaderDoubleTap,
    ValueChanged<int>? onHeaderLongPress,
    OnHeaderHoverCallback? onHeaderHover,
    bool? defaultSortAscending,
    bool? sortEnabled,
    bool? filterEnabled,
    bool Function(RowModel<T> row)? rowCountSelector,
    ShowFilterPopupCallback? showFilterPopupCallback,
    String? compactName,
    Iterable<dynamic>? possibleValues,
    Map<Object?, bool>? initialValueFilters,
    bool? initialValueFiltersExcludeAllElse,
    bool? initiallyHidden,
  }){
    return SimpleColModel<T>(
      name: name ?? this.name,
      tooltip: tooltip ?? this.tooltip,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      alignment: alignment ?? this.alignment,
      flex: flex ?? this.flex,
      width: width ?? this.width,
      onHeaderTap: onHeaderTap ?? this.onHeaderTap,
      onHeaderDoubleTap: onHeaderDoubleTap ?? this.onHeaderDoubleTap,
      onHeaderLongPress: onHeaderLongPress ?? this.onHeaderLongPress,
      onHeaderHover: onHeaderHover ?? this.onHeaderHover,
      defaultSortAscending: defaultSortAscending ?? this.defaultSortAscending,
      sortEnabled: sortEnabled ?? this.sortEnabled,
      filterEnabled: filterEnabled ?? this.filterEnabled,
      rowCountSelector: rowCountSelector ?? this.rowCountSelector,
      showFilterPopupCallback: showFilterPopupCallback ?? this.showFilterPopupCallback,
      compactName: compactName ?? this.compactName,
      possibleValues: possibleValues ?? this.possibleValues,
      initiallyHidden: initiallyHidden ?? this.initiallyHidden,
      initialValueFilters: initialValueFilters ?? this.initialValueFilters,
      initialValueFiltersExcludeAllElse: initialValueFiltersExcludeAllElse ?? this.initialValueFiltersExcludeAllElse,
    );
  }
}



class NumColModel<T> extends SimpleColModel<T> {
  NumberFormat? formatter;
  bool metadataShowSum;
  bool metadataShowAverage;
  NumColModel({
    required super.name,
    super.compactName,
    super.tooltip,
    super.backgroundColor,
    super.textStyle,
    super.flex,
    super.width,
    super.onHeaderTap,
    super.onHeaderDoubleTap,
    super.onHeaderLongPress,
    super.onHeaderHover,
    super.sortEnabled = true,
    super.filterEnabled,
    super.rowCountSelector,
    super.showFilterPopupCallback,
    this.formatter,
    super.defaultSortAscending = false,
    super.alignment = TextAlign.right,
    super.possibleValues,
    super.initiallyHidden,
    super.initialValueFilters,
    super.initialValueFiltersExcludeAllElse,
    this.metadataShowSum = true,
    this.metadataShowAverage = true,
  });
  @override
  NumColModel<T> copyWith({
    String? name,
    String? tooltip,
    Color? backgroundColor,
    TextStyle? textStyle,
    TextAlign? alignment,
    int? flex,
    double? width,
    ValueChanged<int>? onHeaderTap,
    ValueChanged<int>? onHeaderDoubleTap,
    ValueChanged<int>? onHeaderLongPress,
    OnHeaderHoverCallback? onHeaderHover,
    bool? defaultSortAscending,
    bool? sortEnabled,
    bool? filterEnabled,
    bool Function(RowModel<T> row)? rowCountSelector,
    ShowFilterPopupCallback? showFilterPopupCallback,
    NumberFormat? formatter,
    String? compactName,
    Iterable<dynamic>? possibleValues,
    Map<Object?, bool>? initialValueFilters,
    bool? initialValueFiltersExcludeAllElse,
    bool? initiallyHidden,
    bool? metadataShowSum,
    bool? metadataShowAverage,
  }){
    return NumColModel<T>(
      name: name ?? this.name,
      tooltip: tooltip ?? this.tooltip,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      alignment: alignment ?? this.alignment,
      flex: flex ?? this.flex,
      width: width ?? this.width,
      onHeaderTap: onHeaderTap ?? this.onHeaderTap,
      onHeaderDoubleTap: onHeaderDoubleTap ?? this.onHeaderDoubleTap,
      onHeaderLongPress: onHeaderLongPress ?? this.onHeaderLongPress,
      onHeaderHover: onHeaderHover ?? this.onHeaderHover,
      defaultSortAscending: defaultSortAscending ?? this.defaultSortAscending,
      sortEnabled: sortEnabled ?? this.sortEnabled,
      filterEnabled: filterEnabled ?? this.filterEnabled,
      rowCountSelector: rowCountSelector ?? this.rowCountSelector,
      showFilterPopupCallback: showFilterPopupCallback ?? this.showFilterPopupCallback,
      formatter: formatter ?? this.formatter,
      compactName: compactName ?? this.compactName,
      possibleValues: possibleValues ?? this.possibleValues,
      initiallyHidden: initiallyHidden ?? this.initiallyHidden,
      initialValueFilters: initialValueFilters ?? this.initialValueFilters,
      initialValueFiltersExcludeAllElse: initialValueFiltersExcludeAllElse ?? this.initialValueFiltersExcludeAllElse,
      metadataShowSum: metadataShowSum ?? this.metadataShowSum,
      metadataShowAverage: metadataShowAverage ?? this.metadataShowAverage,
    );
  }
  @override
  String getValueString(RowModel row, dynamic key) {
    final value = getValue(row, key);
    if (value is List || value is ComparableList) {
      final List list = value is List ? value
          : value is ComparableList ? value.list : [];
      return ListField.listToStringAll(list,
        converter: _format,
      );
    } else {
      return _format(value);
    }
  }
  String _format(dynamic value) {
    return value==null ? ''
        : (formatter!=null && value is num) ? formatter!.format(value)
        : value.toString();
  }
  @override
  String getMetadataText(BuildContext context, List<RowModel<T>>? filtered, dynamic key, {
    List<RowModel<T>>? reFiltered,
  }) {
    if (filtered!=null) {
      reFiltered ??= rowCountSelector==null
          ? filtered
          : filtered.where((e) => rowCountSelector!(e)).toList();
      if (reFiltered.isNotEmpty) {
        var result = '';
        num? sum;
        if (metadataShowSum) {
          sum = _sumList(reFiltered.map((e) => getValue(e, key)));
          result += 'suma: ${_format(sum)}';
        }
        if (metadataShowAverage) {
          sum ??= _sumList(reFiltered.map((e) => getValue(e, key)));
          final avg = sum / reFiltered.length;
          if (result.isNotEmpty) result += '  ';
          result += 'promedio: ${_format(avg)}';
        }
        return result;
      }
    }
    return '';
  }
  num _sumList(Iterable list) {
    return list.sumBy((value) {
      if (value is num) {
        return value;
      }
      if (value is ContainsValue<num>) {
        return value.value ?? 0;
      }
      if (value is List) {
        return _sumList(value);
      }
      if (value is ComparableList) {
        return _sumList(value.list);
      }
      return 0;
    });
  }
  @override
  Widget? buildSortedIcon(BuildContext context, bool ascending) {
    return Icon(
      ascending
          ? MaterialCommunityIcons.sort_numeric_ascending
          : MaterialCommunityIcons.sort_numeric_descending,
      key: ValueKey(ascending),
      size: 20,
      color: Theme.of(context).brightness==Brightness.light ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.secondary,
    );
  }
  @override
  List<ConditionFilter> getAvailableConditionFilters() => [
    // FilterIsEmpty(),
    FilterNumberEqualTo(),
    FilterNumberGreaterThan(),
    FilterNumberLessThan(),
  ];
}



class BoolColModel<T> extends SimpleColModel<T> {
  String trueValue;
  String falseValue;
  BoolColModel({
    required super.name,
    super.tooltip,
    super.compactName,
    super.backgroundColor,
    super.textStyle,
    super.flex,
    super.width,
    super.onHeaderTap,
    super.onHeaderDoubleTap,
    super.onHeaderLongPress,
    super.onHeaderHover,
    super.sortEnabled = true,
    super.filterEnabled,
    super.rowCountSelector,
    super.showFilterPopupCallback,
    this.trueValue = 'SÍ', // TODO 3 internationalize
    this.falseValue = 'NO', // TODO 3 internationalize
    super.defaultSortAscending = false,
    super.alignment = TextAlign.center,
    super.possibleValues,
    super.initiallyHidden,
    super.initialValueFilters,
    super.initialValueFiltersExcludeAllElse,
  });
  @override
  BoolColModel<T> copyWith({
    String? name,
    String? tooltip,
    Color? backgroundColor,
    TextStyle? textStyle,
    TextAlign? alignment,
    int? flex,
    double? width,
    ValueChanged<int>? onHeaderTap,
    ValueChanged<int>? onHeaderDoubleTap,
    ValueChanged<int>? onHeaderLongPress,
    OnHeaderHoverCallback? onHeaderHover,
    bool? defaultSortAscending,
    bool? sortEnabled,
    bool? filterEnabled,
    bool Function(RowModel<T> row)? rowCountSelector,
    ShowFilterPopupCallback? showFilterPopupCallback,
    String? trueValue,
    String? falseValue,
    String? compactName,
    Iterable<dynamic>? possibleValues,
    Map<Object?, bool>? initialValueFilters,
    bool? initialValueFiltersExcludeAllElse,
    bool? initiallyHidden,
  }){
    return BoolColModel<T>(
      name: name ?? this.name,
      tooltip: tooltip ?? this.tooltip,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      alignment: alignment ?? this.alignment,
      flex: flex ?? this.flex,
      width: width ?? this.width,
      onHeaderTap: onHeaderTap ?? this.onHeaderTap,
      onHeaderDoubleTap: onHeaderDoubleTap ?? this.onHeaderDoubleTap,
      onHeaderLongPress: onHeaderLongPress ?? this.onHeaderLongPress,
      onHeaderHover: onHeaderHover ?? this.onHeaderHover,
      defaultSortAscending: defaultSortAscending ?? this.defaultSortAscending,
      sortEnabled: sortEnabled ?? this.sortEnabled,
      filterEnabled: filterEnabled ?? this.filterEnabled,
      rowCountSelector: rowCountSelector ?? this.rowCountSelector,
      showFilterPopupCallback: showFilterPopupCallback ?? this.showFilterPopupCallback,
      trueValue: trueValue ?? this.trueValue,
      falseValue: falseValue ?? this.falseValue,
      compactName: compactName ?? this.compactName,
      possibleValues: possibleValues ?? this.possibleValues,
      initiallyHidden: initiallyHidden ?? this.initiallyHidden,
      initialValueFilters: initialValueFilters ?? this.initialValueFilters,
      initialValueFiltersExcludeAllElse: initialValueFiltersExcludeAllElse ?? this.initialValueFiltersExcludeAllElse,
    );
  }
  @override
  String getValueString(RowModel row, dynamic key) {
    final value = getValue(row, key);
    if (value is bool) {
      return value ? trueValue : falseValue;
    } else {
      return value==null ? '' : value.toString();
    }
  }
  @override
  String getMetadataText(BuildContext context, List<RowModel<T>>? filtered, dynamic key, {
    List<RowModel<T>>? reFiltered,
  }) {
    return '';
  }
  @override
  List<ConditionFilter> getAvailableConditionFilters() => [];
}



class DateColModel<T> extends SimpleColModel<T> {
  DateFormat? formatter;
  DateColModel({
    required super.name,
    super.compactName,
    super.tooltip,
    super.backgroundColor,
    super.textStyle,
    super.flex,
    super.width,
    super.alignment,
    super.onHeaderTap,
    super.onHeaderDoubleTap,
    super.onHeaderLongPress,
    super.onHeaderHover,
    super.sortEnabled = true,
    super.filterEnabled,
    super.rowCountSelector,
    super.showFilterPopupCallback,
    this.formatter,
    super.defaultSortAscending = false,
    super.possibleValues,
    super.initiallyHidden,
    super.initialValueFilters,
    super.initialValueFiltersExcludeAllElse,
  });
  @override
  DateColModel<T> copyWith({
    String? name,
    String? tooltip,
    Color? backgroundColor,
    TextStyle? textStyle,
    TextAlign? alignment,
    int? flex,
    double? width,
    ValueChanged<int>? onHeaderTap,
    ValueChanged<int>? onHeaderDoubleTap,
    ValueChanged<int>? onHeaderLongPress,
    OnHeaderHoverCallback? onHeaderHover,
    bool? defaultSortAscending,
    bool? sortEnabled,
    bool? filterEnabled,
    bool Function(RowModel<T> row)? rowCountSelector,
    ShowFilterPopupCallback? showFilterPopupCallback,
    DateFormat? formatter,
    String? compactName,
    Iterable<dynamic>? possibleValues,
    Map<Object?, bool>? initialValueFilters,
    bool? initialValueFiltersExcludeAllElse,
    bool? initiallyHidden,
  }){
    return DateColModel<T>(
      name: name ?? this.name,
      tooltip: tooltip ?? this.tooltip,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textStyle: textStyle ?? this.textStyle,
      alignment: alignment ?? this.alignment,
      flex: flex ?? this.flex,
      width: width ?? this.width,
      onHeaderTap: onHeaderTap ?? this.onHeaderTap,
      onHeaderDoubleTap: onHeaderDoubleTap ?? this.onHeaderDoubleTap,
      onHeaderLongPress: onHeaderLongPress ?? this.onHeaderLongPress,
      onHeaderHover: onHeaderHover ?? this.onHeaderHover,
      defaultSortAscending: defaultSortAscending ?? this.defaultSortAscending,
      sortEnabled: sortEnabled ?? this.sortEnabled,
      filterEnabled: filterEnabled ?? this.filterEnabled,
      rowCountSelector: rowCountSelector ?? this.rowCountSelector,
      showFilterPopupCallback: showFilterPopupCallback ?? this.showFilterPopupCallback,
      formatter: formatter ?? this.formatter,
      compactName: compactName ?? this.compactName,
      possibleValues: possibleValues ?? this.possibleValues,
      initiallyHidden: initiallyHidden ?? this.initiallyHidden,
      initialValueFilters: initialValueFilters ?? this.initialValueFilters,
      initialValueFiltersExcludeAllElse: initialValueFiltersExcludeAllElse ?? this.initialValueFiltersExcludeAllElse,
    );
  }
  @override
  String getMetadataText(BuildContext context, List<RowModel<T>>? filtered, dynamic key, {
    List<RowModel<T>>? reFiltered,
  }) => '';
  @override
  String getValueString(RowModel row, dynamic key) {
    final value = getValue(row, key);
    if (value is List || value is ComparableList) {
      final List list = value is List ? value
          : value is ComparableList ? value.list : [];
      return ListField.listToStringAll(list,
        converter: _format,
      );
    } else {
      return _format(value);
    }
  }
  String _format(dynamic value) {
    return value==null ? ''
        : (formatter!=null && value is DateTime) ? formatter!.format(value)
        : (formatter!=null && value is Date) ? formatter!.format(value.toDateTime())
        : value is DateField && value.value!=null ? value.formatterDense.format(value.value!)
        : value.toString();
  }
  @override
  List<ConditionFilter> getAvailableConditionFilters() => [
    // FilterDateExactDay(),
    FilterDateAfter(),
    FilterDateBefore(),
  ];
  @override
  List<RowModel> buildFilterPopupRowModels(List<dynamic> availableFilters, Map<dynamic, Map<Object?, bool>> valueFilters, dynamic colKey, ValueNotifier<bool> modified) {
    final Map<int, Map<int, List<Object>>> grouped = {};
    final List<dynamic> other = [];
    for (final e in availableFilters) {
      DateTime? value;
      if (e is DateTime) {
        value = e;
      } else if (e is Date) {
        value = e.toDateTime();
      } else if (e is ContainsValue<DateTime>) {
        value = e.value;
      }
      if (value!=null) {
        if (!grouped.containsKey(value.year)) grouped[value.year] = {};
        if (!grouped[value.year]!.containsKey(value.month)) grouped[value.year]![value.month] = [];
        grouped[value.year]![value.month]!.add(e);
      } else {
        other.add(e);
      }
    }
    final List<RowModel> result = [];
    for (final e in other) {
      result.add(SimpleRowModel(
        id: e,
        values: {colKey: e},
        selected: valueFilters[colKey]![e] ?? false,
        alwaysOnTop: true,
        onCheckBoxSelected: (row, selected) {
          modified.value = true;
          valueFilters[colKey]![row.id] = selected!;
          (row as SimpleRowModel).selected = selected;
          return true;
        },
      ),);
    }
    for (final year in grouped.keys) {
      result.add(SimpleRowModel(
        id: year,
        values: {colKey: year},
        expanded: grouped.length==1,
        children: [
          for (final month in grouped[year]!.keys)
            SimpleRowModel(
              id: month,
              values: {colKey: ValueString(month, DateFormat("MMMM", "es").format(DateTime(year, month)))}, // TODO 3 internationalize
              expanded: grouped[year]!.length==1,
              children: [
                for (final date in grouped[year]![month]!)
                  SimpleRowModel(
                    id: date,
                    values: {colKey: date},
                    selected: valueFilters[colKey]![date] ?? false,
                    onCheckBoxSelected: (row, selected) {
                      modified.value = true;
                      valueFilters[colKey]![row.id] = selected!;
                      (row as SimpleRowModel).selected = selected;
                      return true;
                    },
                  ),
              ],
            ),
        ],
      ),);
    }
    return result;
  }
}