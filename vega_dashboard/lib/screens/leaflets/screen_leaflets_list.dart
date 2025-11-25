import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../../screens/leaflets/screen_leaflet_edit.dart";
import "../../states/leaflets.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "../screen_app.dart";
import "./widget_leaflets_active.dart";
import "./widget_leaflets_finished.dart";
import "./widget_leaflets_prepared.dart";

class LeafletScreenList extends VegaScreen {
  const LeafletScreenList({super.showDrawer, super.key});

  @override
  createState() => _LeafletsState();
}

class _LeafletsState extends VegaScreenState<LeafletScreenList> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: 0, length: 3, vsync: this);
    Future.microtask(() => ref.read(locationsLogic.notifier).load());
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenLeafletTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final activeLeaflets = ref.watch(activeLeafletsLogic);
    final preparedLeaflets = ref.watch(preparedLeafletsLogic);
    final finishedLeaflets = ref.watch(finishedLeafletsLogic);
    final isRefreshing =
        [activeLeaflets, preparedLeaflets, finishedLeaflets].any((state) => state is LeafletsRefreshing);
    return [
      IconButton(
        icon: const VegaIcon(name: AtomIcons.add),
        onPressed: () {
          ref.read(leafletEditorLogic.notifier).create();
          context.push(ScreenLeafletEdit());
        },
      ),
      VegaRefreshButton(
        onPressed: () {
          ref.read(activeLeafletsLogic.notifier).refresh();
          ref.read(preparedLeafletsLogic.notifier).refresh();
          ref.read(finishedLeafletsLogic.notifier).refresh();
        },
        isRotating: isRefreshing,
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoleculeTabs(controller: _controller, tabs: [
            Tab(text: LangKeys.tabActive.tr()),
            Tab(text: LangKeys.tabPrepared.tr()),
            Tab(text: LangKeys.tabFinished.tr()),
          ]),
          Expanded(
            child: TabBarView(
              physics: vegaScrollPhysic,
              controller: _controller,
              children: [ActiveLeaflets(), PreparedLeaflets(), FinishedLeaflets()],
            ),
          ),
        ],
      ),
    );
  }
}

// eof
