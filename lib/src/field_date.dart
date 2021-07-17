import 'package:flutter/material.dart';
import 'package:from_zero_ui/from_zero_ui.dart';
import 'package:from_zero_ui/src/dao.dart';
import 'package:intl/intl.dart';


class DateField extends Field<DateTime> {

  DateFormat formatter;
  DateTime firstDate;
  DateTime lastDate;

  DateField({
    required String uiName,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? value,
    DateTime? dbValue,
    bool clearable = true,
    bool enabled = true,
    bool hidden = false,
    double maxWidth = 512,
    DateFormat? formatter,
    String? hint,
    double? tableColumnWidth,
  }) :  this.firstDate = firstDate ?? DateTime(1900),
        this.lastDate = lastDate ?? DateTime(2200),
        this.formatter = formatter ?? DateFormat(DateFormat.YEAR_MONTH_DAY),
        super(
          uiName: uiName,
          value: value,
          dbValue: dbValue,
          clearable: clearable,
          enabled: enabled,
          hidden: hidden,
          maxWidth: maxWidth,
          hint: hint,
          tableColumnWidth: tableColumnWidth,
        );

  @override
  DateField copyWith({
    String? uiName,
    DateTime? value,
    DateTime? dbValue,
    bool? clearable,
    bool? enabled,
    bool? hidden,
    double? maxWidth,
    DateTime? firstDate,
    DateTime? lastDate,
    String? hint,
    double? tableColumnWidth,
  }) {
    return DateField(
      uiName: uiName??this.uiName,
      value: value??this.value,
      dbValue: dbValue??this.dbValue,
      clearable: clearable??this.clearable,
      enabled: enabled??this.enabled,
      hidden: hidden??this.hidden,
      maxWidth: maxWidth??this.maxWidth,
      firstDate: firstDate??this.firstDate,
      lastDate: lastDate??this.lastDate,
      hint: hint??this.hint,
      tableColumnWidth: tableColumnWidth??this.tableColumnWidth,
    );
  }

  @override
  String toString() => value==null ? '' : formatter.format(value!);

  @override
  List<Widget> buildFieldEditorWidgets(BuildContext context, {
    bool addCard=false,
    bool asSliver = true,
    expandToFillContainer: true,
    bool autofocus = false,
  }) {
    Widget result;
    if (hidden) {
      result = SizedBox.shrink();
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
          );
        },
      );
    } else {
      result = _buildFieldEditorWidget(context,
        addCard: addCard,
        asSliver: asSliver,
        expandToFillContainer: expandToFillContainer,
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
    bool addCard=false,
    bool asSliver = true,
    bool expandToFillContainer = true,
    bool largeHorizontally = false,
  }) {
    Widget result = ChangeNotifierBuilder(
      changeNotifier: this,
      builder: (context, v, child) {
        return Stack(
          children: [
            DatePickerFromZero(
              enabled: enabled,
              clearable: clearable,
              title: uiName,
              firstDate: firstDate,
              lastDate: lastDate,
              hint: hint,
              value: value,
              onSelected: (v) {value=v;},
              popupWidth: maxWidth,
              buttonChildBuilder: _buttonContentBuilder,
            ),
          ],
        );
      },
    );
    if (addCard) {
      result = Card(
        clipBehavior: Clip.hardEdge,
        child: result,
      );
    }
    result = Padding(
      padding: EdgeInsets.symmetric(horizontal: largeHorizontally ? 12 : 0),
      child: Center(
        child: SizedBox(
          width: maxWidth,
          height: 64,
          child: result,
        ),
      ),
    );
    return result;
  }

  Widget _buttonContentBuilder(BuildContext context, String? title, String? hint, DateTime? value, formatter, bool enabled, bool clearable) {
    return Padding(
      padding: EdgeInsets.only(right: enabled&&clearable ? 40 : 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 8,),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MaterialKeyValuePair(
                  title: title,
                  padding: 6,
                  value: value==null ? (hint ?? '') : formatter.format(value),
                  valueStyle: Theme.of(context).textTheme.subtitle1!.copyWith(
                    height: 1,
                    color: value==null ? Theme.of(context).textTheme.caption!.color!
                        : Theme.of(context).textTheme.bodyText1!.color!,
                  ),
                ),
                SizedBox(height: 4,),
              ],
            ),
          ),
          SizedBox(width: 4,),
          if (enabled && !clearable)
            Icon(Icons.arrow_drop_down),
          SizedBox(width: !(enabled && clearable) ? 36 : 4,),
        ],
      ),
    );
  }

}