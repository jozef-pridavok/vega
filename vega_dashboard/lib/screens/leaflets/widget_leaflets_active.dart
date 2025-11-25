import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../screens/screen_app.dart";
import "../../states/leaflet_patch.dart";
import "../../states/leaflets.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "popup_menu_items.dart";

class ActiveLeaflets extends ConsumerStatefulWidget {
  ActiveLeaflets({super.key});

  @override
  createState() => _LeafletsState();
}

class _LeafletsState extends ConsumerState<ActiveLeaflets> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(activeLeafletsLogic.notifier).load());
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<LeafletPatchState>(leafletPatchLogic, (previous, next) {
      bool closeDialog = next is LeafletPatchFailed;
      if ([LeafletPatchPhase.blocked, LeafletPatchPhase.unblocked].contains(next.phase)) {
        closeDialog = ref.read(activeLeafletsLogic.notifier).updated(next.leaflet);
      }
      if (next.phase == LeafletPatchPhase.finished) {
        ref.read(activeLeafletsLogic.notifier).removed(next.leaflet);
        ref.read(finishedLeafletsLogic.notifier).added(next.leaflet);
        closeDialog = true;
      }
      if (closeDialog) closeWaitDialog(context, ref);
      if (next is LeafletPatchFailed) toastCoreError(next.error);
    });
    ref.listen(refreshLogic, (previous, next) {
      final key = ref.read(activeLeafletsLogic.notifier).hasRefreshKey(next);
      if (key == null) return;
      ref.read(refreshLogic.notifier).clear(key);
      ref.read(activeLeafletsLogic.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToLogics(context);
    final state = ref.watch(activeLeafletsLogic);
    if (state is LeafletsSucceed)
      return const _GridWidget();
    else if (state is LeafletsFailed)
      return StateErrorWidget(
        activeLeafletsLogic,
        getIcon: (error) => error == errorNoData ? AtomIcons.leaflet : null,
        onReload: () => ref.read(activeLeafletsLogic.notifier).load(),
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
    final succeed = ref.watch(activeLeafletsLogic) as LeafletsSucceed;
    final leaflets = succeed.leaflets;
    return PullToRefresh(
      onRefresh: () async => await ref.read(activeLeafletsLogic.notifier).refresh(),
      child: DataGrid<Leaflet>(
        rows: leaflets,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
          DataGridColumn(name: _columnLocation, label: LangKeys.columnLocation.tr()),
          if (!isMobile) DataGridColumn(name: _columnValidFrom, label: LangKeys.columnValidFrom.tr()),
          DataGridColumn(name: _columnValidTo, label: LangKeys.columnValidTo.tr()),
        ],
        onBuildCell: (column, leaflet) => _buildCell(context, ref, column, leaflet),
        onRowTapUp: (column, leaflets, details) => _popupOperations(context, ref, leaflets, details),
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) newIndex -= 1;
          ref.read(activeLeafletsLogic.notifier).reorder(oldIndex, newIndex);
        },
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, Leaflet leaflet) {
    final locale = context.languageCode;
    final isBlocked = leaflet.blocked;
    final columnMap = <String, ThemedText>{
      _columnName: leaflet.name.text.color(ref.scheme.content),
      _columnLocation: (leaflet.locationName ?? LangKeys.locationEverywhere.tr()).text.color(ref.scheme.content),
      _columnValidFrom: formatIntDate(locale, leaflet.validFrom).text.color(ref.scheme.content),
      _columnValidTo: formatIntDate(locale, leaflet.validTo, fallback: LangKeys.cellAlwaysValid.tr())
          .text
          .color(ref.scheme.content),
    };
    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return isBlocked ? cell.lineThrough : cell;
  }

  void _popupOperations(BuildContext context, WidgetRef ref, Leaflet leaflet, TapUpDetails details) =>
      showVegaPopupMenu(
        context: context,
        ref: ref,
        details: details,
        title: leaflet.name,
        items: [
          LeafletMenuItems.showPages(context, ref, leaflet),
          LeafletMenuItems.block(context, ref, leaflet),
          LeafletMenuItems.finish(context, ref, leaflet),
        ],
      );
}

// eof
