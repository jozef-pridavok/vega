import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;

import "../../states/providers.dart";
import "../../states/qr_tags.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "../screen_app.dart";
import "widget_print_tags.dart";
import "widget_unused_tags.dart";
import "widget_used_tags.dart";

class QrTagsScreen extends VegaScreen {
  final Program program;

  const QrTagsScreen({super.key, required this.program});

  @override
  createState() => _QrTagsState();
}

class _QrTagsState extends VegaScreenState<QrTagsScreen> with SingleTickerProviderStateMixin {
  late TabController _controller;
  Program get program => widget.program;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: 0, length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenQrTagsTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final unusedQrTags = ref.watch(unusedQrTagsLogic);
    final isRefreshing = [unusedQrTags].any((state) => state is QrTagsRefreshing);
    return [
      VegaRefreshButton(
        onPressed: () {
          ref.read(unusedQrTagsLogic.notifier).refresh(program.programId);
        },
        isRotating: isRefreshing,
      ),
      const MoleculeItemHorizontalSpace(),
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
            Tab(text: LangKeys.tabUnusedTags.tr()),
            Tab(text: LangKeys.tabPrintNewTags.tr()),
            Tab(text: LangKeys.tabUsedTags.tr()),
          ]),
          Expanded(
            child: TabBarView(
              physics: vegaScrollPhysic,
              controller: _controller,
              children: [
                UnusedTagsWidget(programId: program.programId),
                PrintTagsWidget(program: program),
                UsedTagsWidget(programId: program.programId),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// eof
