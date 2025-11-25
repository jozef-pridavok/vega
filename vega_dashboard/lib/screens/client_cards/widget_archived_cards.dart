import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/client_cards.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";

class ArchivedCardsWidget extends ConsumerStatefulWidget {
  ArchivedCardsWidget({super.key});

  @override
  createState() => _ArchivedCardsWidgetState();
}

class _ArchivedCardsWidgetState extends ConsumerState<ArchivedCardsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(archivedClientCardsLogic.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(archivedClientCardsLogic);
    if (state is ClientCardsSucceed)
      return const _GridWidget();
    else if (state is ClientCardsFailed)
      return StateErrorWidget(
        archivedClientCardsLogic,
        onReload: () => ref.read(archivedClientCardsLogic.notifier).load(),
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
    final succeed = ref.watch(archivedClientCardsLogic) as ClientCardsSucceed;
    final isMobile = ref.watch(layoutLogic).isMobile;
    final cards = succeed.cards;
    return PullToRefresh(
      onRefresh: () => ref.read(archivedClientCardsLogic.notifier).refresh(),
      child: DataGrid<Card>(
        rows: cards,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr(), width: -2),
          if (!isMobile) DataGridColumn(name: _columnPrograms, label: LangKeys.columnProgram.tr(), width: -3),
          if (!isMobile) DataGridColumn(name: _columnCountries, label: LangKeys.columnCountries.tr(), width: -3),
        ],
        onBuildCell: (column, card) => _buildCell(context, ref, column, card),
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, Card card) {
    final countries = card.countries;

    String? countryText;
    if (column == _columnCountries) {
      if (countries != null) {
        final maxCountries = 3;
        final headCountries = countries.map((category) => category.localizedName.toString()).take(maxCountries);
        final remainingCountries = countries.length - headCountries.length;
        countryText = (headCountries.join(", ") + (remainingCountries > 0 ? " +$remainingCountries" : ""));
      } else {
        countryText ??= LangKeys.locationEverywhere.tr();
      }
    }

    final columnMap = <String, ThemedText>{
      _columnName: card.name.text.color(ref.scheme.content),
      _columnPrograms: card.programNames.text.color(ref.scheme.content),
      _columnCountries: countryText.text.color(ref.scheme.content),
    };

    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return card.blocked ? cell.lineThrough : cell;
  }
}

// eof
