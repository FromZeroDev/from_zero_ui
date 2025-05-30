import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:from_zero_ui/from_zero_ui.dart';
import 'package:from_zero_ui/util/copied_flutter_widgets/my_ensure_visible_when_focused.dart';


enum StringFieldType {
  short,
  long,
}

class StringField extends Field<String> {

  late final TextEditingController controller = TextEditingController(text: value);
  StringFieldType type;
  int? minLines;
  int? maxLines;
  InputDecoration? inputDecoration;
  List<TextInputFormatter>? inputFormatters;
  bool obfuscate;
  bool trimOnSave;
  bool showObfuscationToggleButton; // TODO 3 implement obfuscation toggle button
  Timer? valUpdateTimer;

  @override
  set dbValue(String? v) {
    super.dbValue = v ?? '';
  }

  @override
  set value(String? v) {  // ignore: must_call_super
                          // this is intentional :) commitValue(v) calls super
    valUpdateTimer?.cancel();
    v ??= '';
    if (v.isEmpty || v.characters.last == ' ' || v.characters.last == '\n' || !isEdited) {
      commitValue(v);
    } else if (value != controller.text) {
      addUndoEntry(value);
      valUpdateTimer = Timer(const Duration(seconds: 2), () {
        commitValue(v);
      });
    }
  }
  void commitValue(String? v) {
    super.value = v ?? '';
    syncTextEditingController();
  }

  @override
  void undo({
    bool removeEntryFromDAO = false,
    bool requestFocus = true,
  }) {
    super.commitUndo(controller.text,
      removeEntryFromDAO: removeEntryFromDAO,
      requestFocus: requestFocus,
    );
    syncTextEditingController();
  }
  @override
  void redo({
    bool removeEntryFromDAO = false,
    bool requestFocus = true,
  }) {
    super.commitRedo(controller.text,
      removeEntryFromDAO: removeEntryFromDAO,
      requestFocus: requestFocus,
    );
    syncTextEditingController();
  }
  @override
  void revertChanges() {
    super.revertChanges();
    syncTextEditingController();
  }

  void syncTextEditingController() {
    if (value != controller.text) {
      controller.text = value ?? '';
      controller.selection = TextSelection.collapsed(offset: value!.length);
    }
  }

  StringField({
    required super.uiNameGetter,
    String? value,
    String? dbValue,
    super.clearableGetter,
    super.maxWidth,
    super.minWidth,
    super.flex,
    super.hintGetter,
    super.tooltipGetter,
    this.type = StringFieldType.short,
    int? minLines,
    int? maxLines,
    this.obfuscate = false,
    bool? showObfuscationToggleButton,
    this.inputDecoration,
    this.inputFormatters,
    this.trimOnSave = true,
    super.tableColumnWidth,
    super.hiddenGetter,
    super.hiddenInTableGetter,
    super.hiddenInViewGetter,
    super.hiddenInFormGetter,
    super.validatorsGetter,
    super.validateOnlyOnConfirm,
    super.colModelBuilder,
    super.undoValues,
    super.redoValues,
    super.fieldGlobalKey,
    super.focusNode,
    super.invalidateNonEmptyValuesIfHiddenInForm,
    super.defaultValue = '',
    super.backgroundColor,
    super.actionsGetter,
    super.viewWidgetBuilder,
    super.onValueChanged,
  }) :  minLines = minLines ?? (type==StringFieldType.short ? null : 3),
        maxLines = maxLines ?? (type==StringFieldType.short ? 1 : 999999999),
        showObfuscationToggleButton = showObfuscationToggleButton ?? obfuscate,
        super(
          value: value ?? '',
          dbValue: dbValue ?? value ?? '',
        );


  @override
  StringField copyWith({
    FieldValueGetter<String, Field>? uiNameGetter,
    String? value,
    String? dbValue,
    FieldValueGetter<String?, Field>? hintGetter,
    FieldValueGetter<String?, Field>? tooltipGetter,
    FieldValueGetter<bool, Field>? clearableGetter,
    double? maxWidth,
    double? minWidth,
    double? flex,
    StringFieldType? type,
    int? minLines,
    int? maxLines,
    bool? trimOnSave,
    InputDecoration? inputDecoration,
    List<TextInputFormatter>? inputFormatters,
    double? tableColumnWidth,
    FieldValueGetter<bool, Field>? hiddenGetter,
    FieldValueGetter<bool, Field>? hiddenInTableGetter,
    FieldValueGetter<bool, Field>? hiddenInViewGetter,
    FieldValueGetter<bool, Field>? hiddenInFormGetter,
    FieldValueGetter<List<FieldValidator<String>>, Field>? validatorsGetter,
    bool? validateOnlyOnConfirm,
    FieldValueGetter<SimpleColModel, Field>? colModelBuilder,
    List<String?>? undoValues,
    List<String?>? redoValues,
    bool? invalidateNonEmptyValuesIfHiddenInForm,
    String? defaultValue,
    ContextFulFieldValueGetter<Color?, Field>? backgroundColor,
    ContextFulFieldValueGetter<List<ActionFromZero>, Field>? actionsGetter,
    ViewWidgetBuilder<String>? viewWidgetBuilder,
    OnFieldValueChanged<String?>? onValueChanged,
    bool? obfuscate,
    bool? showObfuscationToggleButton,
  }) {
    return StringField(
      uiNameGetter: uiNameGetter??this.uiNameGetter,
      value: value??this.value,
      dbValue: dbValue??this.dbValue,
      clearableGetter: clearableGetter??this.clearableGetter,
      maxWidth: maxWidth??this.maxWidth,
      minWidth: minWidth??this.minWidth,
      flex: flex??this.flex,
      type: type??this.type,
      minLines: minLines??this.minLines,
      maxLines: maxLines??this.maxLines,
      inputDecoration: inputDecoration??this.inputDecoration,
      inputFormatters: inputFormatters??this.inputFormatters,
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
      trimOnSave: trimOnSave ?? this.trimOnSave,
      obfuscate: obfuscate ?? this.obfuscate,
      showObfuscationToggleButton: showObfuscationToggleButton ?? this.showObfuscationToggleButton,
    );
  }

  @override
  List<Widget> buildFieldEditorWidgets(BuildContext context, {
    bool addCard=false,
    bool asSliver = true,
    bool expandToFillContainer = true,
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
            largeVertically: maxLines!=1,
            largeHorizontally: constraints.maxWidth>=ScaffoldFromZero.screenSizeMedium,
            focusNode: focusNode!,
            dense: dense,
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
        focusNode: focusNode,
        largeVertically: maxLines!=1,
        dense: dense,
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
    bool largeVertically = true,
    bool largeHorizontally = false,
    bool dense = false,
    BoxConstraints? constraints,
    bool useGlobalKeys = true,
  }) {
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        valUpdateTimer?.cancel();
        if (controller.text != value) {
          super.value = controller.text;
        }
        if (!passedFirstEdit) {
          if (dao.contextForValidation!=null) {
            passedFirstEdit = true;
            validate(dao.contextForValidation!, dao, dao.validationCallCount);
            notifyListeners();
          }
        }
      }
    });
    Widget result = NotificationListener(
      onNotification: (notification) => true,
      child: AnimatedBuilder(
        animation: this,
        builder: (context, child) {
          final enabled = this.enabled;
          final visibleValidationErrors = passedFirstEdit
              ? validationErrors
              : validationErrors.where((e) => e.isBeforeEditing);
          final actions = buildActions(context, focusNode);
          final defaultActions = buildDefaultActions(context, focusNode: focusNode);
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
          Widget result = Stack(
            fit: largeVertically ? StackFit.loose : StackFit.expand,
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: focusNode,
                  builder: (context, child) {
                    final backgroundColor = this.backgroundColor?.call(context, this, dao);
                    final focusColor = Theme.of(context).focusColor.withOpacity(Theme.of(context).focusColor.opacity*0.6);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      color: dense && visibleValidationErrors.isNotEmpty
                          ? ValidationMessage.severityColors[Theme.of(context).brightness.inverse]![visibleValidationErrors.first.severity]!.withOpacity(0.2)
                          : focusNode.hasFocus  ? backgroundColor!=null ? Color.alphaBlend(focusColor, backgroundColor)
                                                                        : focusColor
                                                : focusColor.withOpacity(0),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ),
              KeyboardListener(
                includeSemantics: false,
                focusNode: FocusNode(skipTraversal: true),
                onKeyEvent: (value) => defaultOnKeyEvent(value, controller, focusNode, maxLines!=null&&maxLines!<=1),
                child: RawGestureDetector(
                  behavior: HitTestBehavior.translucent,
                  gestures: {
                    TransparentTapGestureRecognizer: GestureRecognizerFactoryWithHandlers<TransparentTapGestureRecognizer>(
                          () => TransparentTapGestureRecognizer(debugOwner: this),
                          (TapGestureRecognizer instance) {
                            instance // hack to fix textField breaking when window loses focus on desktop
                              .onTapDown = (details) => controller.notifyListeners();
                          },
                    ),
                  },
                  child: Builder(
                    builder: (context) {
                      return buildDaoTextFormField(context,
                        uiName: uiName,
                        value: value,
                        dense: dense,
                        controller: controller,
                        enabled: enabled,
                        focusNode: focusNode,
                        hint: hint,
                        inputDecoration: inputDecoration,
                        inputFormatters: inputFormatters,
                        minLines: minLines,
                        maxLines: maxLines,
                        largeVertically: largeVertically,
                        obfuscate: obfuscate,
                        onChanged: (v) {
                          userInteracted = true;
                          value = v;
                        },
                        onEditingComplete: () {
                          focusNode.nextFocus();
                        },
                        actions: allActions,
                      );
                    },
                  ),
                ),
              ),
            ],
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
            result = AppbarFromZero(
              addContextMenu: false, // shown in TextField contextMenuBuilder instead
              backgroundColor: Colors.transparent,
              elevation: 0,
              useFlutterAppbar: false,
              extendTitleBehindActions: true,
              toolbarHeight: largeVertically ? null : 56,
              paddingRight: 6,
              actionPadding: 0,
              skipTraversalForActions: true,
              constraints: const BoxConstraints(),
              actions: allActions,
              title: SizedBox(height: largeVertically ? null : 56, child: result),
            );
          }
          result = ValidationRequiredOverlay(
            isRequired: isRequired,
            isEmpty: enabled && value.isNullOrBlank,
            errors: validationErrors,
            dense: dense,
            child: result,
          );
          return result;
        },
      ),
    );
    if (addCard) {
      result = Card(
        clipBehavior: Clip.hardEdge,
        color: enabled ? null : Theme.of(context).canvasColor,
        child: result,
      );
    }
    return EnsureVisibleWhenFocused(
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
                height: largeVertically ? null : 64,
                child: result,
              ),
              if (!dense)
                ValidationMessage(errors: validationErrors, passedFirstEdit: passedFirstEdit,),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildDaoTextFormField(BuildContext context, {
    required String uiName,
    String? value,
    TextEditingController? controller,
    bool enabled = true,
    FocusNode? focusNode,
    VoidCallback? onEditingComplete,
    int? minLines,
    int? maxLines,
    bool obfuscate = false,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? inputFormatters,
    InputDecoration? inputDecoration,
    String? hint,
    bool largeVertically = false,
    bool dense = false,
    TextAlign textAlign = TextAlign.start,
    TextInputType? keyboardType,
    List<ActionFromZero> actions = const [],
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      focusNode: focusNode,
      onEditingComplete: onEditingComplete,
      obscureText: obfuscate,
      onChanged: onChanged,
      inputFormatters: [
        if (maxLines!=null)
          LineLimitTextFormatter(maxLines),
        if (inputFormatters!=null)
          ...inputFormatters,
      ],
      minLines: minLines,
      textAlign: textAlign,
      keyboardType: keyboardType,
      maxLines: minLines==null||minLines<=(maxLines??0) ? maxLines : minLines,
      textInputAction: largeVertically ? null : TextInputAction.next,
      style: Theme.of(context).textTheme.titleMedium!.copyWith(
        height: largeVertically ? 1.2 : 1.05,
        color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(enabled ? 1 : 0.75),
        fontWeight: largeVertically ? FontWeight.w500 : FontWeight.w600,
      ),
      decoration: inputDecoration??InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        alignLabelWithHint: dense,
        hintStyle: TextStyle(color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.75)),
        labelStyle: TextStyle(
          height: dense ? 0 : largeVertically ? 0.2 : 0.6,
          color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(enabled ? 1 : 0.75),
        ),
        label: largeVertically
            ? Padding(
                padding: EdgeInsets.only(
                  top: !dense&&hint!=null ? 12 : largeVertically ? 0 : 8,
                  bottom: !dense&&hint!=null ? 12 : largeVertically ? 6 : 0,
                ),
                child: Text(uiName,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              )
            : ClipPath(
                clipper: SideClipper.horizontal(),
                child: OpacityGradient(
                  direction: OpacityGradient.right,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                      top: !dense&&hint!=null ? 12 : largeVertically ? 0 : 8,
                      bottom: !dense&&hint!=null ? 12 : largeVertically ? 6 : 0,
                    ),
                    child: Text(uiName,
                      softWrap: false,
                      overflow: TextOverflow.visible, // anything but visible applies a Clip for some reason :(((
                    ),
                  ),
                ),
              ),
        floatingLabelBehavior: dense ? FloatingLabelBehavior.never
            : !enabled ? (value==null||value.isEmpty) ? FloatingLabelBehavior.never : FloatingLabelBehavior.always
            : hint!=null ? FloatingLabelBehavior.always : FloatingLabelBehavior.auto,
        contentPadding: EdgeInsets.only(
          // left: dense ? textAlign==TextAlign.right ? 8 : 0 : 16, // TODO 1 test in next flutter version if there is an assert thrown here when left=0
          left: dense ? 0 : 16,
          right: dense ? 0 : (16 + (context.findAncestorStateOfType<AppbarFromZeroState>()!.actions.length*40)),
          bottom: largeVertically ? 16 : dense ? 10 : 0,
          top: largeVertically ? 16 : dense ? 8 : 6,
        ),
      ),
      contextMenuBuilder: (context, editableTextState) {
        focusNode?.requestFocus();
        return AdaptiveTextSelectionToolbar.buttonItems(
          buttonItems: [
            ...editableTextState.contextMenuButtonItems,
            ...actions.where((e) => e.getStateForMaxWidth(0)!=ActionState.none).map((e) {
              return ContextMenuButtonItem(
                label: e.title,
                onPressed: e.onTap==null ? null : () => e.onTap?.call(context),
                type: ContextMenuButtonType.custom,
              );
            }),
          ],
          anchors: editableTextState.contextMenuAnchors,
        );
      },
    );
  }

  static void defaultOnKeyEvent(KeyEvent value, TextEditingController controller, FocusNode focusNode, bool isSingleLine) {
    if (value is KeyDownEvent) {
      final selectionStart = controller.selection.start;
      if (selectionStart!=controller.selection.end) {
        return;
      }
      if (value.logicalKey==LogicalKeyboardKey.arrowDown) {
        if (isSingleLine || selectionStart==controller.text.length) {
          focusNode.focusInDirection(TraversalDirection.down);
          // focusNode.nextFocus(); // because directional focus is REALLY buggy
        }
      } else if (value.logicalKey==LogicalKeyboardKey.arrowUp) {
        if (isSingleLine || selectionStart==0) {
          focusNode.focusInDirection(TraversalDirection.up);
          // focusNode.previousFocus(); // because directional focus is REALLY buggy
        }
      } else if (value.logicalKey==LogicalKeyboardKey.arrowLeft) {
        if (selectionStart==0) {
          focusNode.focusInDirection(TraversalDirection.left);
          // focusNode.previousFocus(); // because directional focus is REALLY buggy
        }
      } else if (value.logicalKey==LogicalKeyboardKey.arrowRight) {
        if (selectionStart==controller.text.length) {
          focusNode.focusInDirection(TraversalDirection.right);
          // focusNode.nextFocus(); // because directional focus is REALLY buggy
        }
      }
    }
  }

}


class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final upperCased = newValue.text.toUpperCase();
    if (upperCased!=newValue.text) {
      return TextEditingValue(
        text: upperCased,
        selection: newValue.selection,
      );
    }
    return newValue;
  }
}
class LowerCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final lowerCased = newValue.text.toLowerCase();
    if (lowerCased!=newValue.text) {
      return TextEditingValue(
        text: lowerCased,
        selection: newValue.selection,
      );
    }
    return newValue;
  }
}
class LineLimitTextFormatter extends TextInputFormatter {
  int? lineLimit;
  LineLimitTextFormatter(this.lineLimit);
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (lineLimit==null || lineLimit!<1) return newValue;
    int lineCount = 0;
    final characters = newValue.text.characters.toList();
    for (int i=0; i<characters.length; i++) {
      if (characters[i]=='\n' || characters[i]=='\r') {
        lineCount++;
        if (lineCount >= lineLimit!) {
          final newText = newValue.text.substring(0, i)
              + newValue.text.substring(i).replaceAll(RegExp(r'\r\n|\r|\n|/'), ' ');
          return TextEditingValue(
            text: newText,
            selection: newValue.selection,
          );
        }
        if (characters[i]=='\r' && characters.length>i+1 && characters[i+1]=='\n') {
          i++; // count \r\n as a single line break
        }
      }
    }
    return newValue;
  }
}


