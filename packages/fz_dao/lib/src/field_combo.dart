import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fz_actions/fz_actions.dart';
import 'package:fz_api_handling/fz_api_handling.dart';
import 'package:fz_appbar/fz_appbar.dart';
import 'package:fz_combo/fz_combo.dart';
import 'package:fz_copy_ensure_visible/fz_copy_ensure_visible.dart';
import 'package:fz_dao/fz_dao.dart';
import 'package:fz_future_handling/fz_future_handling.dart';
import 'package:fz_localizations/fz_localizations.dart';
import 'package:fz_scaffold/fz_scaffold.dart';
import 'package:fz_table/fz_table.dart';
import 'package:fz_tooltip/fz_tooltip.dart';
import 'package:fz_ui_utility/fz_ui_utility.dart';

typedef FilteredValuesGetter<T, R extends Field> =
    T Function(String value)? Function(BuildContext context, R field, DAO<dynamic> dao);

class ComboField<T extends DAO<dynamic>> extends Field<T> {
  ContextFulFieldValueGetter<List<T>?, ComboField<T>>? possibleValuesGetter;
  ContextFulFieldValueGetter<Future<List<T>>?, ComboField<T>>? possibleValuesFutureGetter;
  ContextFulFieldValueGetter<NotifierProvider<ApiState<List<T>>, AsyncValue<List<T>>>?, ComboField<T>>?
  possibleValuesProviderGetter;
  FilteredValuesGetter<List<T>, ComboField<T>>? filteredValuesGetter;
  FilteredValuesGetter<Future<List<T>>, ComboField<T>>? filteredValuesFutureGetter;
  FilteredValuesGetter<NotifierProvider<ApiState<List<T>>, AsyncValue<List<T>>>, ComboField<T>>?
  filteredValuesProviderGetter;
  bool? showSearchBox;
  ExtraWidgetBuilder<T>? extraWidget;
  FieldValueGetter<DAO<dynamic>?, ComboField<T>>? newObjectTemplateGetter;
  DAO<dynamic>? get newObjectTemplate => newObjectTemplateGetter?.call(this, dao);
  bool sort;
  bool showViewActionOnDAOs;
  bool showDropdownIcon;
  bool invalidateValuesNotInPossibleValues;
  bool showNullInSelection;
  bool showHintAsNullInSelection;
  Duration debounce;
  int minChars;

  ComboField({
    required super.uiNameGetter,
    super.value,
    super.dbValue,
    super.clearableGetter,
    super.maxWidth,
    super.minWidth,
    super.flex,
    super.hintGetter,
    super.tooltipGetter,
    this.possibleValuesGetter,
    this.possibleValuesFutureGetter,
    this.possibleValuesProviderGetter,
    this.filteredValuesGetter,
    this.filteredValuesFutureGetter,
    this.filteredValuesProviderGetter,
    this.sort = true,
    this.showSearchBox,
    this.showViewActionOnDAOs = true,
    this.showDropdownIcon = false,
    this.extraWidget,
    super.tableColumnWidth,
    super.hiddenGetter,
    super.hiddenInTableGetter,
    super.hiddenInViewGetter,
    super.hiddenInFormGetter,
    this.newObjectTemplateGetter,
    super.validatorsGetter,
    super.validateOnlyOnConfirm,
    super.colModelBuilder,
    super.undoValues,
    super.redoValues,
    this.invalidateValuesNotInPossibleValues = true,
    super.fieldGlobalKey,
    super.focusNode,
    super.invalidateNonEmptyValuesIfHiddenInForm,
    super.defaultValue,
    super.backgroundColor,
    super.actionsGetter,
    super.viewWidgetBuilder,
    super.onValueChanged,
    this.showNullInSelection = false,
    this.showHintAsNullInSelection = true,
    Duration? debounce,
    int? minChars,
  }) : debounce =
           debounce ??
           (possibleValuesGetter != null ||
                   possibleValuesFutureGetter != null ||
                   possibleValuesProviderGetter != null ||
                   filteredValuesGetter != null
               ? Duration.zero
               : const Duration(milliseconds: 300)),
       minChars =
           minChars ??
           (possibleValuesGetter != null ||
                   possibleValuesFutureGetter != null ||
                   possibleValuesProviderGetter != null ||
                   filteredValuesGetter != null
               ? 0
               : 3),
       assert(
         1 ==
             ((possibleValuesGetter == null ? 0 : 1) +
                 (possibleValuesFutureGetter == null ? 0 : 1) +
                 (possibleValuesProviderGetter == null ? 0 : 1) +
                 (filteredValuesGetter == null ? 0 : 1) +
                 (filteredValuesFutureGetter == null ? 0 : 1) +
                 (filteredValuesProviderGetter == null ? 0 : 1)),
         'You must set one and only one way of getting values.',
       );

  @override
  ComboField<T> copyWith({
    FieldValueGetter<String, Field>? uiNameGetter,
    T? value,
    T? dbValue,
    FieldValueGetter<bool, Field>? clearableGetter,
    double? maxWidth,
    double? minWidth,
    double? flex,
    ContextFulFieldValueGetter<List<T>?, ComboField<T>>? possibleValuesGetter,
    ContextFulFieldValueGetter<Future<List<T>>?, ComboField<T>>? possibleValuesFutureGetter,
    ContextFulFieldValueGetter<ApiProviderInstance<List<T>>?, ComboField<T>>? possibleValuesProviderGetter,
    FilteredValuesGetter<List<T>, ComboField<T>>? filteredValuesGetter,
    FilteredValuesGetter<Future<List<T>>, ComboField<T>>? filteredValuesFutureGetter,
    FilteredValuesGetter<NotifierProvider<ApiState<List<T>>, AsyncValue<List<T>>>, ComboField<T>>?
    filteredValuesProviderGetter,
    FieldValueGetter<String?, Field>? hintGetter,
    FieldValueGetter<String?, Field>? tooltipGetter,
    bool? sort,
    bool? showSearchBox,
    bool? showViewActionOnDAOs,
    bool? showDropdownIcon,
    ExtraWidgetBuilder<T>? extraWidget,
    double? tableColumnWidth,
    FieldValueGetter<bool, Field>? hiddenGetter,
    FieldValueGetter<bool, Field>? hiddenInTableGetter,
    FieldValueGetter<bool, Field>? hiddenInViewGetter,
    FieldValueGetter<bool, Field>? hiddenInFormGetter,
    FieldValueGetter<DAO<dynamic>?, ComboField<T>>? newObjectTemplateGetter,
    FieldValueGetter<List<FieldValidator<T>>, Field>? validatorsGetter,
    bool? validateOnlyOnConfirm,
    FieldValueGetter<SimpleColModel<dynamic>, Field>? colModelBuilder,
    List<T?>? undoValues,
    List<T?>? redoValues,
    bool? invalidateValuesNotInPossibleValues,
    GlobalKey? fieldGlobalKey,
    bool? invalidateNonEmptyValuesIfHiddenInForm,
    T? defaultValue,
    ContextFulFieldValueGetter<Color?, Field>? backgroundColor,
    ContextFulFieldValueGetter<List<ActionFromZero>, Field>? actionsGetter,
    ViewWidgetBuilder<T>? viewWidgetBuilder,
    OnFieldValueChanged<T?>? onValueChanged,
    bool? showNullInSelection,
    bool? showHintAsNullInSelection,
    Duration? debounce,
    int? minChars,
  }) {
    return ComboField<T>(
      uiNameGetter: uiNameGetter ?? this.uiNameGetter,
      value: value ?? this.value,
      dbValue: dbValue ?? this.dbValue,
      clearableGetter: clearableGetter ?? this.clearableGetter,
      maxWidth: maxWidth ?? this.maxWidth,
      minWidth: minWidth ?? this.minWidth,
      flex: flex ?? this.flex,
      possibleValuesGetter: possibleValuesGetter ?? this.possibleValuesGetter,
      possibleValuesFutureGetter: possibleValuesFutureGetter ?? this.possibleValuesFutureGetter,
      possibleValuesProviderGetter: possibleValuesProviderGetter ?? this.possibleValuesProviderGetter,
      filteredValuesGetter: filteredValuesGetter ?? this.filteredValuesGetter,
      filteredValuesFutureGetter: filteredValuesFutureGetter ?? this.filteredValuesFutureGetter,
      filteredValuesProviderGetter: filteredValuesProviderGetter ?? this.filteredValuesProviderGetter,
      hintGetter: hintGetter ?? this.hintGetter,
      tooltipGetter: tooltipGetter ?? this.tooltipGetter,
      sort: sort ?? this.sort,
      showSearchBox: showSearchBox ?? this.showSearchBox,
      extraWidget: extraWidget ?? this.extraWidget,
      tableColumnWidth: tableColumnWidth ?? this.tableColumnWidth,
      hiddenInTableGetter: hiddenInTableGetter ?? hiddenGetter ?? this.hiddenInTableGetter,
      hiddenInViewGetter: hiddenInViewGetter ?? hiddenGetter ?? this.hiddenInViewGetter,
      hiddenInFormGetter: hiddenInFormGetter ?? hiddenGetter ?? this.hiddenInFormGetter,
      newObjectTemplateGetter: newObjectTemplateGetter ?? this.newObjectTemplateGetter,
      validatorsGetter: validatorsGetter ?? this.validatorsGetter,
      validateOnlyOnConfirm: validateOnlyOnConfirm ?? this.validateOnlyOnConfirm,
      showViewActionOnDAOs: showViewActionOnDAOs ?? this.showViewActionOnDAOs,
      showDropdownIcon: showDropdownIcon ?? this.showDropdownIcon,
      colModelBuilder: colModelBuilder ?? this.colModelBuilder,
      undoValues: undoValues ?? List.from(this.undoValues),
      redoValues: redoValues ?? List.from(this.redoValues),
      invalidateValuesNotInPossibleValues:
          invalidateValuesNotInPossibleValues ?? this.invalidateValuesNotInPossibleValues,
      invalidateNonEmptyValuesIfHiddenInForm:
          invalidateNonEmptyValuesIfHiddenInForm ?? this.invalidateNonEmptyValuesIfHiddenInForm,
      defaultValue: defaultValue ?? this.defaultValue,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      actionsGetter: actionsGetter ?? this.actionsGetter,
      viewWidgetBuilder: viewWidgetBuilder ?? this.viewWidgetBuilder,
      onValueChanged: onValueChanged ?? this.onValueChanged,
      showNullInSelection: showNullInSelection ?? this.showNullInSelection,
      showHintAsNullInSelection: showHintAsNullInSelection ?? this.showHintAsNullInSelection,
      debounce: debounce ?? this.debounce,
      minChars: minChars ?? this.minChars,
    );
  }

  @override
  Future<bool> validate(
    BuildContext context,
    DAO<dynamic> dao,
    int currentValidationId, {
    bool validateIfNotEdited = false,
    bool validateIfHidden = false,
  }) async {
    if (currentValidationId != dao.validationCallCount || !context.mounted) return false;
    final superResult = super.validate(
      context,
      dao,
      currentValidationId, // ignore: use_build_context_synchronously
      validateIfNotEdited: validateIfNotEdited,
      validateIfHidden: validateIfHidden,
    );

    if (invalidateValuesNotInPossibleValues &&
        value != null &&
        (possibleValuesGetter != null || possibleValuesProviderGetter != null || possibleValuesFutureGetter != null)) {
      List<T>? possibleValues;
      if (possibleValuesGetter != null) {
        possibleValues = possibleValuesGetter!(context, this, dao);
      }
      if (possibleValues == null && possibleValuesProviderGetter != null) {
        // ignore: use_build_context_synchronously
        final provider = possibleValuesProviderGetter!.call(context, this, dao);
        if (provider != null) {
          possibleValues = await (context as WidgetRef).readFuture(provider);
          if (currentValidationId != dao.validationCallCount || !context.mounted) return false;
        }
      }
      if (possibleValues == null && possibleValuesFutureGetter != null) {
        // ignore: use_build_context_synchronously
        final future = possibleValuesFutureGetter?.call(context, this, dao);
        if (future != null) {
          possibleValues = await future;
          if (currentValidationId != dao.validationCallCount || !context.mounted) return false;
        }
      }
      if (possibleValues != null && !possibleValues.contains(value)) {
        // ignore: use_build_context_synchronously
        final error = '$uiName: ${FromZeroLocalizations.of(context).translate("validation_combo_not_possible")}';
        if (value == dbValue) {
          validationErrors.add(
            ValidationError(
              field: this,
              error: error,
            ),
          );
        } else {
          validationErrors.add(
            InvalidatingError<T>(
              field: this,
              error: error,
              defaultValue: null,
            ),
          );
        }
      }
    }

    await superResult;
    if (currentValidationId != dao.validationCallCount || !context.mounted) return false;
    validationErrors.sort((a, b) => a.severity.weight.compareTo(b.severity.weight));
    return validationErrors.where((e) => e.isBlocking).isEmpty;
  }

  @override
  List<Widget> buildFieldEditorWidgets(
    BuildContext context, {
    bool addCard = false,
    bool asSliver = true,
    expandToFillContainer = true,
    bool dense = false,
    bool ignoreHidden = false,
    FocusNode? focusNode,
    ScrollController? mainScrollController,
    bool useGlobalKeys = true,
  }) {
    focusNode ??= this.focusNode;
    Widget result;
    if (hiddenInForm && !ignoreHidden) {
      result = const SizedBox.shrink();
      if (asSliver) {
        result = SliverToBoxAdapter(
          child: result,
        );
      }
      return [result];
    }
    if (expandToFillContainer) {
      result = LayoutBuilder(
        builder: (context, constraints) {
          return _buildFieldEditorWidget(
            context,
            addCard: addCard,
            asSliver: asSliver,
            expandToFillContainer: expandToFillContainer,
            largeHorizontally: constraints.maxWidth >= ScaffoldFromZero.screenSizeMedium,
            dense: dense,
            focusNode: focusNode!,
            constraints: constraints,
            useGlobalKeys: useGlobalKeys,
          );
        },
      );
    } else {
      result = _buildFieldEditorWidget(
        context,
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

  Widget _buildFieldEditorWidget(
    BuildContext context, {
    required FocusNode focusNode,
    bool addCard = false,
    bool asSliver = true,
    bool expandToFillContainer = true,
    bool largeHorizontally = false,
    bool dense = false,
    BoxConstraints? constraints,
    bool useGlobalKeys = true,
  }) {
    ExtraWidgetBuilder<T>? extraWidget;
    final newObjectTemplate = this.newObjectTemplate;
    if (newObjectTemplate?.canSave ?? false) {
      extraWidget = (context, onSelected) {
        final navigator = Navigator.of(context);
        final emptyDAO = newObjectTemplate!.copyWith();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (this.extraWidget != null) this.extraWidget!(context, onSelected),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                child: TextButton(
                  onPressed: () async {
                    final res = await emptyDAO.maybeEdit(dao.contextForValidation ?? context);
                    if (res != null) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        onSelected?.call(emptyDAO as T);
                        navigator.pop(emptyDAO as T);
                      });
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(width: 6),
                        const Icon(Icons.add),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          '${FromZeroLocalizations.of(context).translate("add")} ${emptyDAO.classUiName}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      };
    }
    final provider = possibleValuesProviderGetter?.call(context, this, dao);
    Widget result = AnimatedBuilder(
      animation: this,
      builder: (context, child) {
        final enabled = this.enabled;
        final visibleValidationErrors = passedFirstEdit
            ? validationErrors
            : validationErrors.where((e) => e.isBeforeEditing);
        Widget result = ComboFromZero<T>(
          focusNode: focusNode,
          enabled: enabled,
          clearable: false,
          title: uiName,
          hint: hint,
          value: value,
          showNullInSelection: showNullInSelection,
          showHintAsNullInSelection: showHintAsNullInSelection,
          possibleValues: possibleValuesGetter?.call(context, this, dao),
          possibleValuesFuture: possibleValuesFutureGetter?.call(context, this, dao),
          possibleValuesProvider: provider,
          filteredValues: filteredValuesGetter?.call(context, this, dao),
          filteredValuesFuture: filteredValuesFutureGetter?.call(context, this, dao),
          filteredValuesProvider: filteredValuesProviderGetter?.call(context, this, dao),
          sort: sort,
          showSearchBox: showSearchBox,
          onSelected: (v) => _onSelected(v, focusNode),
          // popupWidth: maxWidth,
          buttonStyle: addCard || dense ? null : TextButton.styleFrom(padding: EdgeInsets.zero),
          buttonChildBuilder:
              (
                context, {
                required title,
                required hint,
                required value,
                required enabled,
                required clearable,
                showDropdownIcon = false,
                dense = false,
              }) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: dense ? 0 : context.findAncestorStateOfType<AppbarFromZeroState>()!.actions.length * 40,
                  ),
                  child: buttonContentBuilder(
                    context,
                    title: title,
                    hint: hint,
                    value: (dense ? value?.uiNameDense : value),
                    enabled: enabled,
                    clearable: false,
                    showDropdownIcon: showDropdownIcon,
                    dense: dense,
                  ),
                );
              },
          extraWidget: extraWidget ?? this.extraWidget,
          showViewActionOnDAOs: showViewActionOnDAOs,
          showDropdownIcon: showDropdownIcon,
          debounce: debounce,
          minChars: minChars,
        );
        // TODO: 3 implement the loading sign for possibleValuesFuture as well
        if (provider != null) {
          result = Stack(
            children: [
              result,
              Positioned(
                left: 3,
                top: 3,
                child: ApiProviderBuilder(
                  provider: provider,
                  animatedSwitcherType: AnimatedSwitcherType.normal,
                  dataBuilder: (context, data) {
                    return const SizedBox.shrink();
                  },
                  loadingBuilder: (context, progress) {
                    return SizedBox(
                      height: 10,
                      width: 10,
                      child: LoadingSign(
                        value: null,
                        padding: EdgeInsets.zero,
                        size: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace, onRetry) {
                    return const SizedBox(
                      height: 10,
                      width: 10,
                      child: Icon(
                        Icons.error_outlined,
                        color: Colors.red,
                        size: 12,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
        result = AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          color: dense && visibleValidationErrors.isNotEmpty
              ? ValidationMessage
                    .severityColors[Theme.of(context).brightness.inverse]![visibleValidationErrors.first.severity]!
                    .withValues(alpha: 0.2)
              : backgroundColor?.call(context, this, dao),
          curve: Curves.easeOut,
          child: result,
        );
        result = TooltipFromZero(
          message:
              (dense
                      ? visibleValidationErrors
                      : visibleValidationErrors.where((e) => e.severity == ValidationErrorSeverity.disabling))
                  .fold('', (a, b) {
                    return a.toString().trim().isEmpty
                        ? b.toString()
                        : b.toString().trim().isEmpty
                        ? a.toString()
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
            allActions = allActions
                .map(
                  (e) => e.copyWith(
                    disablingError: '',
                  ),
                )
                .toList();
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
          isEmpty: enabled && value == null,
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
                ValidationMessage(
                  errors: validationErrors,
                  passedFirstEdit: passedFirstEdit,
                ),
            ],
          ),
        ),
      ),
    );
    return result;
  }

  bool? _onSelected(T? v, FocusNode focusNode) {
    userInteracted = true;
    value = v;
    focusNode.requestFocus();
  }

  // TODO: 2 this should probably be a StatelessWidget
  static Widget buttonContentBuilder(
    BuildContext context, {
    required String? title,
    required String? hint,
    required dynamic value,
    required bool enabled,
    required bool clearable,
    bool showDropdownIcon = false,
    bool dense = false,
  }) {
    final showHintOrTitleInsteadOfValue = value == null || value.toString().isEmpty;
    final showHintInsteadOfValue = showHintOrTitleInsteadOfValue && hint != null;
    return Padding(
      padding: EdgeInsets.only(right: enabled && clearable ? 40 : 0, bottom: dense ? 4 : 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: dense ? 0 : 15,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dense
                    ? Text(
                        showHintOrTitleInsteadOfValue ? (hint ?? title ?? '') : value.toString(),
                        maxLines: 2,
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          height: 1,
                          fontWeight: showHintOrTitleInsteadOfValue ? FontWeight.normal : null,
                          // color: Theme.of(context).textTheme.dis,
                        ),
                      )
                    : value == null && hint == null && title != null
                    ? Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          title,
                          maxLines: 2,
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w400,
                            height: 1.1,
                            color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: enabled ? 1 : 0.75),
                          ),
                        ),
                      )
                    : MaterialKeyValuePair(
                        padding: 4,
                        title: title,
                        titleMaxLines: 1,
                        titleStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                          height: 1,
                          color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(alpha: enabled ? 1 : 0.75),
                        ),
                        value: showHintOrTitleInsteadOfValue ? (hint ?? '') : value.toString(),
                        valueMaxLines: 2,
                        valueStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                          height: 1,
                          color: Theme.of(context).textTheme.bodyLarge!.color!.withValues(
                            alpha: enabled && !showHintInsteadOfValue ? 1 : 0.75,
                          ),
                        ),
                      ),
                const SizedBox(
                  height: 4,
                ),
              ],
            ),
          ),
          SizedBox(
            width: dense ? 0 : 6,
          ),
          if (!dense && showDropdownIcon && enabled && !clearable)
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).textTheme.bodyLarge!.color,
            ),
          SizedBox(
            width: dense ? 0 : 6,
          ),
        ],
      ),
    );
  }

  @override
  List<ActionFromZero> buildDefaultActions(BuildContext context, {FocusNode? focusNode}) {
    return [
      ...super.buildDefaultActions(
        context,
        focusNode: focusNode,
      ),
      if (possibleValuesProviderGetter != null) ActionFromZero.divider(breakpoints: {0: ActionState.popup}),
      if (possibleValuesProviderGetter != null)
        ActionFromZero(
          title: 'Refrescar Datos', // TODO: 3 internationalize
          icon: const Icon(
            Icons.refresh,
          ),
          breakpoints: {0: ActionState.popup},
          onTap: (context) {
            userInteracted = true;
            focusNode?.requestFocus();
            final ref = dao.contextForValidation! as WidgetRef;
            final provider = possibleValuesProviderGetter!(context, this, dao);
            final stateNotifier = ref.read(provider!.notifier);
            stateNotifier.refresh(ref);
          },
        ),
    ];
  }
}
