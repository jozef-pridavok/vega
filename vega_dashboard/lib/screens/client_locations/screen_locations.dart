import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../../states/location_editor.dart";
import "../../states/location_patch.dart";
import "../../states/locations.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "../dialog.dart";
import "../screen_app.dart";
import "screen_edit.dart";
import "widget_locations.dart";
import "widget_map.dart";

class ClientLocationsScreen extends VegaScreen {
  const ClientLocationsScreen({super.showDrawer, super.key});

  @override
  createState() => _LocationsState();
}

class _LocationsState extends VegaScreenState<ClientLocationsScreen> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: 0, length: 2, vsync: this);
    Future.microtask(() => ref.read(locationsLogic.notifier).load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenLocationsTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final locations = ref.watch(locationsLogic);
    final isRefreshing = locations.runtimeType == LocationsRefreshing;
    return [
      IconButton(
        icon: const VegaIcon(name: AtomIcons.add),
        onPressed: () {
          ref.read(locationEditorLogic.notifier).create();
          context.push(LocationEditScreen());
        },
      ),
      VegaRefreshButton(
        onPressed: () => ref.read(locationsLogic.notifier).refresh(),
        isRotating: isRefreshing,
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoleculeTabs(controller: _controller, tabs: [
            Tab(text: LangKeys.tabList.tr()),
            Tab(text: LangKeys.tabMap.tr()),
          ]),
          Expanded(
            child: TabBarView(
              physics: vegaScrollPhysic,
              controller: _controller,
              children: [const LocationsListWidget(), const LocationsMapWidget()],
            ),
          ),
        ],
      ),
    );
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<LocationPatchState>(locationPatchLogic, (previous, next) async {
      bool failed = next is LocationPatchFailed;
      if (next.phase.isSuccessful || failed) {
        closeWaitDialog(context, ref);
        await ref.read(locationPatchLogic.notifier).reset();
        await ref.read(locationsLogic.notifier).refresh();
      }
      if (failed) toastCoreError(next.error);
    });
    ref.listen<LocationEditorState>(locationEditorLogic, (previous, next) async {
      if (next is LocationEditorSaved) {
        await ref.read(locationsLogic.notifier).refresh();
      }
    });
  }
}

// eof
