import 'package:flutter/material.dart';
import 'package:from_zero_ui/from_zero_ui.dart';
import 'package:from_zero_ui/util/copied_flutter_widgets/my_ensure_visible_when_focused.dart';
import 'package:intl/intl.dart';


class DateField extends Field<DateTime> {

  DateFormat formatter;
  DateFormat formatterDense;
  DateTime firstDate;
  DateTime lastDate;
  final DateTimePickerType type;

  static final defaultFormatter = DateFormat(DateFormat.YEAR_MONTH_DAY);
  static final defaultDenseFormatter = DateFormat("dd/MM/yyyy"); // TODO 3 internationalize
  static final defaultTimeFormatter = DateFormat("H:mm");
  static final defaultFirstDate = DateTime(1900);
  static final defaultLastDate = DateTime(2200);

  DateField({
    required super.uiNameGetter,
    DateTime? firstDate,
    DateTime? lastDate,
    super.value,
    super.dbValue,
    super.clearableGetter,
    super.maxWidth,
    super.minWidth,
    super.flex,
    DateFormat? formatter,
    DateFormat? formatterDense,
    super.hintGetter,
    super.tooltipGetter,
    super.tableColumnWidth,
    super.hiddenGetter,
    super.hiddenInTableGetter,
    super.hiddenInViewGetter,
    super.hiddenInFormGetter,
    super.validatorsGetter,
    super.validateOnlyOnConfirm,
    super.colModelBuilder = DateField.dateFieldDefaultGetColumn,
    super.undoValues,
    super.redoValues,
    super.fieldGlobalKey,
    super.focusNode,
    super.invalidateNonEmptyValuesIfHiddenInForm,
    super.defaultValue,
    super.backgroundColor,
    super.actionsGetter,
    super.viewWidgetBuilder,
    super.onValueChanged,
    this.type = DateTimePickerType.date,
  }) :  firstDate = firstDate ?? defaultFirstDate,
        lastDate = lastDate ?? defaultLastDate,
        formatter = formatter ?? (type==DateTimePickerType.time ? defaultTimeFormatter : defaultFormatter),
        formatterDense = formatterDense ?? formatter ?? (type==DateTimePickerType.time ? defaultTimeFormatter : defaultDenseFormatter);

  @override
  DateField copyWith({
    FieldValueGetter<String, Field>? uiNameGetter,
    DateTime? value,
    DateTime? dbValue,
    FieldValueGetter<bool, Field>? clearableGetter,
    double? maxWidth,
    double? minWidth,
    double? flex,
    DateFormat? formatter,
    DateFormat? formatterDense,
    DateTime? firstDate,
    DateTime? lastDate,
    FieldValueGetter<String?, Field>? hintGetter,
    FieldValueGetter<String?, Field>? tooltipGetter,
    double? tableColumnWidth,
    FieldValueGetter<bool, Field>? hiddenGetter,
    FieldValueGetter<bool, Field>? hiddenInTableGetter,
    FieldValueGetter<bool, Field>? hiddenInViewGetter,
    FieldValueGetter<bool, Field>? hiddenInFormGetter,
    FieldValueGetter<List<FieldValidator<DateTime>>, Field>? validatorsGetter,
    bool? validateOnlyOnConfirm,
    FieldValueGetter<SimpleColModel, Field>? colModelBuilder,
    List<DateTime?>? undoValues,
    List<DateTime?>? redoValues,
    bool? invalidateNonEmptyValuesIfHiddenInForm,
    DateTime? defaultValue,
    ContextFulFieldValueGetter<Color?, Field>? backgroundColor,
    ContextFulFieldValueGetter<List<ActionFromZero>, Field>? actionsGetter,
    ViewWidgetBuilder<DateTime>? viewWidgetBuilder,
    OnFieldValueChanged<DateTime?>? onValueChanged,
    DateTimePickerType? type,
  }) {
    return DateField(
      uiNameGetter: uiNameGetter??this.uiNameGetter,
      value: value??this.value,
      dbValue: dbValue??this.dbValue,
      clearableGetter: clearableGetter??this.clearableGetter,
      maxWidth: maxWidth??this.maxWidth,
      minWidth: minWidth??this.minWidth,
      flex: flex??this.flex,
      formatter: formatter??this.formatter,
      formatterDense: formatterDense??this.formatterDense,
      firstDate: firstDate??this.firstDate,
      lastDate: lastDate??this.lastDate,
      hintGetter: hintGetter??this.hintGetter,
      tooltipGetter: tooltipGetter??this.tooltipGetter,
      tableColumnWidth: tableColumnWidth??this.tableColumnWidth,
      hiddenInTableGetter: hiddenInTableGetter ?? hiddenGetter ?? this.hiddenInTableGetter,
      hiddenInViewGetter: hiddenInViewGetter ?? hiddenGetter ?? this.hiddenInViewGetter,
      hiddenInFormGetter: hiddenInFormGetter ?? hiddenGetter ?? this.hiddenInFormGetter,
      validatorsGetter: validatorsGetter ?? this.validatorsGetter,
      validateOnlyOnConfirm: validateOnlyOnConfirm ?? this.validateOnlyOnConfirm,
      colModelBuilder: colModelBuilder ?? this.colModelBuilder,
      undoValues: undoValues ?? List.from(this.undoValues),
      redoValues: redoValues ?? List.from(this.redoValues),
      invalidateNonEmptyValuesIfHiddenInForm: invalidateNonEmptyValuesIfHiddenInForm ?? this.invalidateNonEmptyValuesIfHiddenInForm,
      defaultValue: defaultValue ?? this.defaultValue,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      actionsGetter: actionsGetter ?? this.actionsGetter,
      viewWidgetBuilder: viewWidgetBuilder ?? this.viewWidgetBuilder,
      onValueChanged: onValueChanged ?? this.onValueChanged,
      type: type ?? this.type,
    );
  }

  @override
  String toString() => value==null ? ''
      : type==DateTimePickerType.time && dao.contextForValidation!=null
          ? TimeOfDay.fromDateTime(value!).format(dao.contextForValidation!)
          : formatter.format(value!);

  @override
  List<Widget> buildFieldEditorWidgets(BuildContext context, {
    bool addCard=false,
    bool asSliver = true,
    expandToFillContainer = true,
    bool dense = false,
    FocusNode? focusNode,
    bool ignoreHidden = false,
    ScrollController? mainScrollController,
    bool useGlobalKeys = true,
  }) {
    focusNode ??= this.focusNode;
    Widget result;
    if (hiddenInForm && !ignoreHidden) {
      result = const SizedBox.shrink();
      if (asSliver) {
        result = SliverToBoxAdapter(child: result,);
      }
      return [result];
    }
    if (expandToFillContainer) {
      result = LayoutBuilder(
        builder: (context, constraints) {
          return _buildFieldEditorWidget(context,
            addCard: addCard,
            asSliver: asSliver,
            expandToFillContainer: expandToFillContainer,
            largeHorizontally: constraints.maxWidth>=ScaffoldFromZero.screenSizeMedium,
            dense: dense,
            focusNode: focusNode!,
            constraints: constraints,
            useGlobalKeys: useGlobalKeys,
          );
        },
      );
    } else {
      result = _buildFieldEditorWidget(context,
        addCard: addCard,
        asSliver: asSliver,
        expandToFillContainer: expandToFillContainer,
        dense: dense,
        focusNode: focusNode,
        useGlobalKeys: useGlobalKeys,
      );
    }
    if (asSliver) {
      result = SliverToBoxAdapter(
        child: result,
      );
    }
    return [result];
  }
  Widget _buildFieldEditorWidget(BuildContext context, {
    required FocusNode focusNode,
    bool addCard=false,
    bool asSliver = true,
    bool expandToFillContainer = true,
    bool largeHorizontally = false,
    bool dense = false,
    BoxConstraints? constraints,
    bool useGlobalKeys = true,
  }) {
    Widget result = AnimatedBuilder(
      animation: this,
      builder: (context, child) {
        final enabled = this.enabled;
        final visibleValidationErrors = passedFirstEdit
            ? validationErrors
            : validationErrors.where((e) => e.isBeforeEditing);
        Widget result = DatePickerFromZero(
          focusNode: focusNode,
          enabled: enabled,
          clearable: clearable,
          showClearButton: false,
          title: uiName,
          firstDate: firstDate,
          lastDate: lastDate,
          hint: hint,
          value: value,
          type: type,
          onSelected: (v) {
            userInteracted = true;
            value = v;
            focusNode.requestFocus();
            return true;
          },
          popupWidth: maxWidth,
          buttonStyle: addCard||dense ? null : TextButton.styleFrom(padding: EdgeInsets.zero),
          formatter: dense ? formatterDense : formatter,
          buttonChildBuilder: (context, title, hint, value, formatter, enabled, clearable) {
            return Padding(
              padding: EdgeInsets.only(right: dense ? 0 : context.findAncestorStateOfType<AppbarFromZeroState>()!.actions.length*40),
              child: _buttonContentBuilder(context, title, hint, value, type, formatter, enabled, false,
                dense: dense,
              ),
            );
          },
        );
        result = AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: dense && visibleValidationErrors.isNotEmpty
              ? ValidationMessage.severityColors[Theme.of(context).brightness.inverse]![visibleValidationErrors.first.severity]!.withOpacity(0.2)
              : backgroundColor?.call(context, this, dao),
          curve: Curves.easeOut,
          child: result,
        );
        result = TooltipFromZero(
          message: (dense ? visibleValidationErrors : visibleValidationErrors.where((e) => e.severity==ValidationErrorSeverity.disabling)).fold('', (a, b) {
            return a.toString().trim().isEmpty ? b.toString()
                : b.toString().trim().isEmpty ? a.toString()
                : '$a\n$b';
          }),
          waitDuration: enabled ? const Duration(seconds: 1) : Duration.zero,
          child: result,
        );
        if (!dense) {
          final actions = buildActions(context, focusNode);
          final defaultActions = buildDefaultActions(context);
          var allActions = [
            ...actions,
            if (actions.isNotEmpty && defaultActions.isNotEmpty)
              ActionFromZero.divider(breakpoints: {0: ActionState.popup}),
            ...defaultActions,
          ];
          if (!enabled) {
            allActions = allActions.map((e) => e.copyWith(
              disablingError: '',
            ),).toList();
          }
          result = AppbarFromZero(
            contextMenuEnabled: enabled,
            onShowContextMenu: () => focusNode.requestFocus(),
            backgroundColor: Colors.transparent,
            elevation: 0,
            useFlutterAppbar: false,
            extendTitleBehindActions: true,
            toolbarHeight: 56,
            paddingRight: 6,
            actionPadding: 0,
            skipTraversalForActions: true,
            constraints: const BoxConstraints(),
            actions: allActions,
            title: SizedBox(height: 56, child: result),
          );
        }
        result = ValidationRequiredOverlay(
          isRequired: isRequired,
          isEmpty: enabled && value==null,
          errors: validationErrors,
          dense: dense,
          child: result,
        );
        return result;
      },
    );
    if (addCard) {
      result = Card(
        clipBehavior: Clip.hardEdge,
        color: enabled ? null : Theme.of(context).canvasColor,
        child: result,
      );
    }
    result = EnsureVisibleWhenFocused(
      focusNode: focusNode,
      child: Padding(
        key: useGlobalKeys ? fieldGlobalKey : null,
        padding: EdgeInsets.symmetric(horizontal: !dense && largeHorizontally ? 12 : 0),
        child: SizedBox(
          width: maxWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 64,
                child: result,
              ),
              if (!dense)
                ValidationMessage(errors: validationErrors, passedFirstEdit: passedFirstEdit,),
            ],
          ),
        ),
      ),
    );
    return result;
  }

  Widget _buttonContentBuilder(BuildContext context, String? title, String? hint, DateTime? value, DateTimePickerType type, DateFormat formatter, bool enabled, bool clearable, {
    bool dense = false,
  }) {
    final formattedValue = value==null ? null : type==DateTimePickerType.time
        ? TimeOfDay.fromDateTime(value).format(context)
        : formatter.format(value);
    return ComboField.buttonContentBuilder(context, title, hint, formattedValue, enabled, clearable,
      dense: dense,
    );
  }

  static SimpleColModel dateFieldDefaultGetColumn(Field field, DAO dao) {
    if (field is! DateField || field.type==DateTimePickerType.date) {
      return DateColModel(
        name: field.uiName,
        filterEnabled: true,
        flex: field.tableColumnWidth?.round() ?? 192,
        formatter: field is DateField
            ? field.formatterDense
            : defaultDenseFormatter,
      );
    } else {
      return SimpleColModel(
        name: field.uiName,
        filterEnabled: true,
        flex: field.tableColumnWidth?.round() ?? 192,
      );
    }
  }
}

