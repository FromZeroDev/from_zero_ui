import 'dart:async';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:fz_table/fz_table.dart';
import 'package:fz_localizations/fz_localizations.dart';
import 'package:fz_copy_tooltip/fz_copy_tooltip.dart';
import 'package:fz_dao/fz_dao.dart';
import 'package:fz_value_string/fz_value_string.dart';
import 'package:fz_comparable_list/fz_comparable_list.dart';
import 'package:fz_future_handling/fz_future_handling.dart';
import 'package:fz_api_handling/fz_api_handling.dart';
import 'package:fz_popup/fz_popup.dart';
import 'package:fz_scrollbar/fz_scrollbar.dart';
import 'package:fz_simple_shadow/fz_simple_shadow.dart';
import 'package:fz_ui_utility/fz_ui_utility.dart';
import 'package:fz_platform/fz_platform.dart';
import 'package:fz_export/fz_export.dart';
import 'package:fz_animations/fz_animations.dart';
import 'package:fz_actions/fz_actions.dart';
import 'package:fz_scaffold/fz_scaffold.dart';
import 'package:fz_selectable_icon/fz_selectable_icon.dart';
import 'package:fz_appbar/fz_appbar.dart';
import 'package:fz_notification_relayer/fz_notification_relayer.dart';
import 'package:fz_log/fz_log.dart';
import 'package:fz_dialog/fz_dialog.dart';

class TableEmptyWidget<T> extends StatelessWidget {
  final TableController<T>? tableController;
  final String? title;
  final String? subtitle;
  final List<ActionFromZero>? actions;
  final FutureOr<String>? exportPathForExcel;
  final VoidCallback? onShowMenu;
  final Widget? retryButton;

  const TableEmptyWidget({
    this.tableController,
    this.title,
    this.subtitle,
    this.actions,
    this.exportPathForExcel,
    this.onShowMenu,
    this.retryButton,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final state = tableController?.currentState;
    List<ActionFromZero> actions = this.actions ?? [];
    if (tableController != null &&
        (tableController!.currentState?.widget.allowCustomization ?? false)) {
      actions = TableFromZeroState.addManageActions(
        context,
        actions: actions,
        controller: tableController!,
      );
    }
    final exportPathForExcel =
        this.exportPathForExcel ??
        tableController?.currentState?.widget.exportPathForExcel;
    if (tableController != null && exportPathForExcel != null) {
      actions = TableFromZeroState.addExportExcelAction(
        context,
        actions: actions,
        tableController: tableController!,
        exportPathForExcel: exportPathForExcel,
      );
    }
    final filtersApplied =
        state != null &&
        state.filtersApplied.values.firstOrNullWhere((e) => e == true) != null;
    return ContextMenuFromZero(
      actions: actions.whereType<ActionFromZero>().toList(),
      onShowMenu: onShowMenu,
      child: Stack(
        children: [
          Positioned.fill(
            child: OverflowBox(
              maxHeight: double.infinity,
              child: Center(
                child: Icon(
                  MaterialCommunityIcons.clipboard_alert_outline,
                  size: 88,
                  color: Theme.of(
                    context,
                  ).disabledColor.withValues(alpha: 0.04),
                ),
              ),
            ),
          ),
          ErrorSign(
            title:
                title ?? FromZeroLocalizations.of(context).translate('no_data'),
            subtitle:
                subtitle ??
                (state != null &&
                        (filtersApplied || state.widget.rows.isNotEmpty)
                    ? FromZeroLocalizations.of(
                        context,
                      ).translate('no_data_filters')
                    : FromZeroLocalizations.of(
                        context,
                      ).translate('no_data_desc')),
            retryButton:
                retryButton ??
                (tableController == null || (state != null && !filtersApplied)
                    ? null
                    : TextButton(
                        onPressed: () {
                          state?.clearAllFilters();
                        },
                        child: const IntrinsicWidth(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 8),
                              Icon(Icons.filter_alt_off),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Limpiar todos los Filtros', // TODO: 3 internationalize
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                            ],
                          ),
                        ),
                      )),
          ),
        ],
      ),
    );
  }
}
