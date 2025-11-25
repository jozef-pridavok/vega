import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../screens/screen_app.dart";
import "../../states/client_card_patch.dart";
import "../../states/client_cards.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "popup_menu_items.dart";

class ActiveCardsWidget extends ConsumerStatefulWidget {
  ActiveCardsWidget({super.key});

  @override
  createState() => _ActiveCardsWidgetState();
}

class _ActiveCardsWidgetState extends ConsumerState<ActiveCardsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(activeClientCardsLogic.notifier).load());
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<ClientCardPatchState>(clientCardPatchLogic, (previous, next) async {
      bool closeDialog = next is ClientCardPatchFailed;
      if ([ClientCardPatchPhase.blocked, ClientCardPatchPhase.unblocked].contains(next.phase)) {
        closeDialog = ref.read(activeClientCardsLogic.notifier).updated(next.card);
      }
      if ([ClientCardPatchPhase.archived].contains(next.phase)) {
        ref.read(activeClientCardsLogic.notifier).removed(next.card);
        ref.read(archivedClientCardsLogic.notifier).added(next.card);
        closeDialog = true;
      }
      if (closeDialog) closeWaitDialog(context, ref);
      if (next is ClientCardPatchFailed) toastCoreError(next.error);
    });
    ref.listen(refreshLogic, (previous, next) {
      final key = ref.read(activeClientCardsLogic.notifier).hasRefreshKey(next);
      if (key == null) return;
      ref.read(refreshLogic.notifier).clear(key);
      ref.read(activeClientCardsLogic.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToLogics(context);
    final state = ref.watch(activeClientCardsLogic);
    if (state is ClientCardsSucceed)
      return const _GridWidget();
    else if (state is ClientCardsFailed)
      return StateErrorWidget(
        activeClientCardsLogic,
        onReload: () => ref.read(activeClientCardsLogic.notifier).load(),
      );
    return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  const _GridWidget();

  static const _columnName = "name";
  static const _columnPrograms = "programs";
  static const _columnCountries = "countries";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(activeClientCardsLogic) as ClientCardsSucceed;
    final isMobile = ref.watch(layoutLogic).isMobile;
    final cards = succeed.cards;
    return PullToRefresh(
      onRefresh: () => ref.read(activeClientCardsLogic.notifier).refresh(),
      child: DataGrid<Card>(
        rows: cards,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr(), width: -2),
          if (!isMobile) DataGridColumn(name: _columnPrograms, label: LangKeys.columnProgram.tr(), width: -3),
          if (!isMobile) DataGridColumn(name: _columnCountries, label: LangKeys.columnCountries.tr(), width: -3),
        ],
        onBuildCell: (column, card) => _buildCell(context, ref, column, card),
        onRowTapUp: (column, data, details) => _popupOperations(context, ref, data, details),
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) newIndex -= 1;
          ref.read(activeClientCardsLogic.notifier).reorder(oldIndex, newIndex);
        },
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, Card card) {
    final countries = card.countries;

    String? countryText;
    if (countries != null) {
      final maxCountries = 3;
      final headCountries = countries.map((category) => category.localizedName.toString()).take(maxCountries);
      final remainingCountries = countries.length - headCountries.length;
      countryText = (headCountries.join(", ") + (remainingCountries > 0 ? " +$remainingCountries" : ""));
    }
    countryText ??= LangKeys.locationEverywhere.tr();

    final columnMap = <String, ThemedText>{
      _columnName: card.name.text.color(ref.scheme.content),
      _columnPrograms: card.programNames.text.color(ref.scheme.content),
      _columnCountries: countryText.text.color(ref.scheme.content),
    };
    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return card.blocked ? cell.lineThrough : cell;
  }

  void _popupOperations(BuildContext context, WidgetRef ref, Card card, TapUpDetails details) {
    final isBlocked = card.blocked;
    showVegaPopupMenu(
      context: context,
      ref: ref,
      details: details,
      title: card.name,
      items: [
        CardMenuItems.editCard(context, ref, card),
        CardMenuItems.blockCard(context, ref, card),
        CardMenuItems.archiveCard(context, ref, card),
        if (!isBlocked) CardMenuItems.showQrCode(context, ref, card),
      ],
    );
  }
}

// eof
