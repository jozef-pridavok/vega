import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/leaflet_patch.dart";
import "../../states/leaflets.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "../screen_app.dart";
import "popup_menu_items.dart";

class PreparedLeaflets extends ConsumerStatefulWidget {
  PreparedLeaflets({super.key});

  @override
  createState() => _LeafletsState();
}

class _LeafletsState extends ConsumerState<PreparedLeaflets> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(preparedLeafletsLogic.notifier).load());
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<LeafletPatchState>(leafletPatchLogic, (previous, next) {
      bool closeDialog = next is LeafletPatchFailed;
      if ([LeafletPatchPhase.blocked, LeafletPatchPhase.unblocked].contains(next.phase)) {
        var key = ref.read(activeLeafletsLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
        closeDialog = true;
      }
      if (next.phase == LeafletPatchPhase.archived) {
        var key = ref.read(preparedLeafletsLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
        closeDialog = true;
      }
      if (next.phase == LeafletPatchPhase.started) {
        var key = ref.read(preparedLeafletsLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
        key = ref.read(activeLeafletsLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
        closeDialog = true;
      }
      if (closeDialog) closeWaitDialog(context, ref);
      if (next is LeafletPatchFailed) toastCoreError(next.error);
    });
    ref.listen(refreshLogic, (previous, next) {
      final key = ref.read(preparedLeafletsLogic.notifier).hasRefreshKey(next);
      if (key == null) return;
      ref.read(refreshLogic.notifier).clear(key);
      ref.read(preparedLeafletsLogic.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToLogics(context);
    final state = ref.watch(preparedLeafletsLogic);
    if (state is LeafletsSucceed)
      return const _GridWidget();
    else if (state is LeafletsFailed)
      return StateErrorWidget(
        preparedLeafletsLogic,
        getIcon: (error) => error == errorNoData ? AtomIcons.leaflet : null,
        onReload: () => ref.read(preparedLeafletsLogic.notifier).load(),
      );
    else
      return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  const _GridWidget();

  static const _columnName = "name";
  static const _columnLocation = "location";
  static const _columnValidFrom = "validFrom";
  static const _columnValidTo = "validTo";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    final succeed = ref.watch(preparedLeafletsLogic) as LeafletsSucceed;
    final leaflets = succeed.leaflets;
    return PullToRefresh(
      onRefresh: () async => await ref.read(preparedLeafletsLogic.notifier).refresh(),
      child: DataGrid<Leaflet>(
        rows: leaflets,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
          DataGridColumn(name: _columnLocation, label: LangKeys.columnLocation.tr()),
          DataGridColumn(name: _columnValidFrom, label: LangKeys.columnValidFrom.tr()),
          if (!isMobile) DataGridColumn(name: _columnValidTo, label: LangKeys.columnValidTo.tr()),
        ],
        onBuildCell: (column, leaflet) => _buildCell(context, ref, column, leaflet),
        onRowTapUp: (column, leaflets, details) => _popupOperations(context, ref, leaflets, details),
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) newIndex -= 1;
          ref.read(preparedLeafletsLogic.notifier).reorder(oldIndex, newIndex);
        },
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, Leaflet leaflet) {
    final locale = context.languageCode;
    final columnMap = <String, Widget>{
      _columnName: leaflet.name.text.color(ref.scheme.content),
      _columnLocation: (leaflet.locationName ?? LangKeys.locationEverywhere.tr()).text.color(ref.scheme.content),
      _columnValidFrom: formatIntDate(locale, leaflet.validFrom).text.color(ref.scheme.content),
      _columnValidTo: formatIntDate(locale, leaflet.validTo, fallback: LangKeys.cellAlwaysValid.tr())
          .text
          .color(ref.scheme.content),
    };

    return columnMap[column] ?? "?".text.color(ref.scheme.content);
  }

  void _popupOperations(BuildContext context, WidgetRef ref, Leaflet leaflet, TapUpDetails details) =>
      showVegaPopupMenu(
        context: context,
        ref: ref,
        details: details,
        title: leaflet.name,
        items: [
          LeafletMenuItems.showPages(context, ref, leaflet),
          LeafletMenuItems.start(context, ref, leaflet),
          LeafletMenuItems.edit(context, ref, leaflet),
          LeafletMenuItems.archive(context, ref, leaflet),
        ],
      );
}

// eof
