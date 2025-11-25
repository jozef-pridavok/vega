import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/screens/client_locations/popup_menu_items.dart";

import "../../states/locations.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";

class LocationsListWidget extends ConsumerWidget {
  const LocationsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationsLogic);
    if (state is LocationsSucceed || state is LocationsRefreshing) return const _GridWidget();
    if (state is LocationsFailed)
      return StateErrorWidget(
        locationsLogic,
        onReload: () => ref.read(locationsLogic.notifier).refresh(),
      );
    return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  static const _columnName = "name";
  static const _columnType = "type";
  static const _columnAddress = "address";

  const _GridWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    final succeed = ref.watch(locationsLogic) as LocationsSucceed;
    final locations = succeed.locations;
    return PullToRefresh(
      onRefresh: () => ref.read(locationsLogic.notifier).refresh(),
      child: DataGrid<Location>(
        rows: locations,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr(), width: -1),
          if (!isMobile) DataGridColumn(name: _columnType, label: LangKeys.columnType.tr()),
          DataGridColumn(name: _columnAddress, label: LangKeys.columnAddress.tr(), width: -2),
        ],
        onBuildCell: (column, program) => _buildCell(context, ref, column, program),
        onRowTapUp: (column, data, details) => _popupOperations(context, ref, details, data),
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) newIndex -= 1;
          ref.read(locationsLogic.notifier).reorder(oldIndex, newIndex);
        },
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, Location location) {
    final columnMap = <String, ThemedText>{
      _columnName: location.name.text.color(ref.scheme.content),
      _columnType: location.type.localizedName.text.color(ref.scheme.content),
      _columnAddress:
          formatAddress(location.addressLine1, location.addressLine2, location.city).text.maxLine(2).overflowEllipsis,
    };
    return columnMap[column] ?? "?".text.color(ref.scheme.content);
  }

  void _popupOperations(BuildContext context, WidgetRef ref, TapUpDetails details, Location location) =>
      showVegaPopupMenu(
        context: context,
        ref: ref,
        details: details,
        title: location.name,
        items: [
          LocationMenuItems.edit(context, ref, location),
          LocationMenuItems.archive(context, ref, location),
        ],
      );
}

// eof
