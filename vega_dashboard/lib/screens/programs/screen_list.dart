import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;

import "../../states/programs.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "../screen_app.dart";
import "screen_edit.dart";
import "widget_active_programs.dart";
import "widget_archived_programs.dart";
import "widget_finished_programs.dart";
import "widget_prepared_programs.dart";

class ProgramsScreen extends VegaScreen {
  const ProgramsScreen({super.showDrawer, super.key});

  @override
  createState() => _ProgramsState();
}

class _ProgramsState extends VegaScreenState<ProgramsScreen> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: 0, length: 4, vsync: this);
    Future.microtask(() => ref.read(activeClientCardsLogic.notifier).load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenProgramsTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final activePrograms = ref.watch(activeProgramsLogic);
    final preparedPrograms = ref.watch(preparedProgramsLogic);
    final finishedPrograms = ref.watch(finishedProgramsLogic);
    final archivedPrograms = ref.watch(archivedProgramsLogic);
    final isRefreshing = [activePrograms, preparedPrograms, finishedPrograms, archivedPrograms]
        .any((state) => state is ProgramsRefreshing);
    return [
      IconButton(
        icon: const VegaIcon(name: AtomIcons.add),
        onPressed: () {
          ref.read(activeClientCardsLogic.notifier).load();
          ref.read(programEditorLogic.notifier).create();
          context.push(const EditScreen());
        },
      ),
      VegaRefreshButton(
        onPressed: () {
          ref.read(activeProgramsLogic.notifier).refresh();
          ref.read(preparedProgramsLogic.notifier).refresh();
          ref.read(finishedProgramsLogic.notifier).refresh();
          ref.read(archivedProgramsLogic.notifier).refresh();
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
            Tab(text: LangKeys.tabArchived.tr()),
          ]),
          Expanded(
            child: TabBarView(
              physics: vegaScrollPhysic,
              controller: _controller,
              children: const [
                ActiveProgramsWidget(),
                PreparedProgramsWidget(),
                FinishedProgramsWidget(),
                ArchivedProgramsWidget(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// eof
