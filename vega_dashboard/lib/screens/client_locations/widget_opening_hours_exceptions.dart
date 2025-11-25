import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../screens/client_locations/screen_add_exception.dart";
import "../../states/location_editor.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../dialog.dart";
import "popup_menu_items.dart";
import "screen_edit.dart";

extension LocationOpeningHoursExceptions on LocationEditState {
  static const _columnDate = "date";
  static const _columnException = "exception";

  Widget buildOpeningHoursExceptionsWidget(WidgetRef ref) {
    final state = cast<LocationEditorEditing>(ref.read(locationEditorLogic));
    final location = state?.location;
    final List<({IntDate date, String exception})> exceptions = [];
    location?.openingHoursExceptions?.exceptions.forEach((key, value) {
      exceptions.add((date: key, exception: value));
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: DataGrid<({IntDate date, String exception})>(
            rows: exceptions,
            columns: [
              DataGridColumn(name: _columnDate, label: LangKeys.columnDate.tr()),
              DataGridColumn(name: _columnException, label: LangKeys.columnException.tr()),
            ],
            onBuildCell: (column, exception) => _buildCell(context, ref, column, exception),
            onRowTapUp: (column, data, details) => _popupOperations(context, ref, data, details),
          ),
        ),
        MoleculeItemSpace(),
        _buildAddButton(),
      ],
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, ({IntDate date, String exception}) exception) {
    final ex = exception.exception.isEmpty ? LangKeys.cellClosed.tr() : exception.exception;
    final columnMap = <String, Widget>{
      _columnDate: formatIntDate(context.languageCode, exception.date).text.color(ref.scheme.content),
      _columnException: ex.text.color(ref.scheme.content),
    };
    return columnMap[column] ?? "?".text.color(ref.scheme.content);
  }

  Widget _buildAddButton() {
    return MoleculeSecondaryButton(
      titleText: LangKeys.buttonAddException.tr(),
      onTap: () => context.push(AddOpeningHoursException(locationNotificationTag: notificationsTag)),
    );
  }

  void _popupOperations(
    BuildContext context,
    WidgetRef ref,
    ({IntDate date, String exception}) exception,
    TapUpDetails details,
  ) =>
      showVegaPopupMenu(
        context: context,
        ref: ref,
        details: details,
        title: exception.date.toLocalDate().toString(),
        items: [
          LocationMenuItems.addException(context, ref, notificationsTag, exception),
          LocationMenuItems.deleteException(context, ref, notificationsTag, exception.date),
        ],
      );
}

// eof
