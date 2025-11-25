import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;

import "../../states/client_cards.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "../screen_app.dart";
import "screen_edit.dart";
import "widget_active_cards.dart";
import "widget_archived_cards.dart";

class ClientCardsScreen extends VegaScreen {
  const ClientCardsScreen({super.showDrawer, super.key});

  @override
  createState() => _ClientCardsState();
}

class _ClientCardsState extends VegaScreenState<ClientCardsScreen> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenClientCardsTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final activeCards = ref.watch(activeClientCardsLogic);
    final archivedCards = ref.watch(archivedClientCardsLogic);
    final isRefreshing = [activeCards, archivedCards].any((state) => state is ClientCardsRefreshing);
    return [
      IconButton(
        icon: const VegaIcon(name: AtomIcons.add),
        onPressed: () {
          ref.read(clientCardEditorLogic.notifier).create();
          context.push(const EditClientCard());
        },
      ),
      VegaRefreshButton(
        onPressed: () {
          ref.read(activeClientCardsLogic.notifier).refresh();
          ref.read(archivedClientCardsLogic.notifier).refresh();
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
            Tab(text: LangKeys.tabArchived.tr()),
          ]),
          Expanded(
            child: TabBarView(
              physics: vegaScrollPhysic,
              controller: _controller,
              children: [ActiveCardsWidget(), ArchivedCardsWidget()],
            ),
          ),
        ],
      ),
    );
  }
}

// eof
