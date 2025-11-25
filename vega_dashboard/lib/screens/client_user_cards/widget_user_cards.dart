import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/client_user_cards.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "popup_menu_items.dart";

class UserCardsWidget extends ConsumerStatefulWidget {
  final ReservationDate? reservationDate;
  const UserCardsWidget({this.reservationDate, super.key});

  @override
  createState() => _UsersWidgetState();
}

class _UsersWidgetState extends ConsumerState<UserCardsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(clientUserCardsLogic.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientUserCardsLogic);
    if (state is ClientUserCardsSucceed) {
      return _GridWidget(widget.reservationDate);
    } else if (state is ClientUserCardsFailed) {
      return StateErrorWidget(
        clientUserCardsLogic,
        getIcon: (error) => error == errorNoData ? AtomIcons.user : null,
        onReload: () => ref.read(clientUserCardsLogic.notifier).refresh(),
      );
    } else
      return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  final ReservationDate? reservationDate;

  const _GridWidget(this.reservationDate);

  static const _columnCardName = "cardName";
  static const _columnNumber = "number";
  static const _columnUserName = "userName";
  static const _columnLastActivity = "lastActivity";
  //static const _columnBalance = "points";
  static const _columnProgram = "program";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    final succeed = ref.watch(clientUserCardsLogic) as ClientUserCardsSucceed;
    final userCards = succeed.userCards;
    return PullToRefresh(
      onRefresh: () => ref.read(clientUserCardsLogic.notifier).refresh(),
      child: DataGrid<UserCard>(
        rows: userCards,
        columns: [
          DataGridColumn(name: _columnCardName, label: LangKeys.columnName.tr(), width: 150),
          DataGridColumn(name: _columnNumber, label: LangKeys.columnCardNumber.tr(), width: 150),
          DataGridColumn(name: _columnUserName, label: LangKeys.columnUserNick.tr(), width: 150),
          DataGridColumn(
            name: _columnLastActivity,
            label: LangKeys.columnLastActivity.tr(),
            width: isMobile ? double.nan : 200,
          ),
          if (!isMobile) DataGridColumn(name: _columnProgram, label: LangKeys.columnProgram.tr()),
        ],
        onBuildCell: (column, userCard) => _buildCell(context, ref, column, userCard),
        onRowTapUp: (column, userCard, details) => _popupOperations(context, ref, succeed, userCard, details),
      ),
    );
  }

  Widget _buildProgram(BuildContext context, WidgetRef ref, UserCard userCard) {
    final programs = (userCard.programs ?? []);
    if (programs.isEmpty) return "".text.color(ref.scheme.content);
    programs.sort((a, b) => b.userPoints.compareTo(a.userPoints));

    return ListView.builder(
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemCount: programs.length,
      itemBuilder: (context, index) {
        final program = programs[index];
        final points =
            formatAmount(context.locale.languageCode, program.plural, program.userPoints, digits: program.digits);
        String summary = "${program.name}: $points";
        if (program.lastLocationName != null) summary += ", ${program.lastLocationName}";
        if (program.lastTransactionDate != null)
          summary += ", ${formatDate(context.locale.languageCode, program.lastTransactionDate)}";
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: MoleculeChip(
              label: summary,
              //active: program.userPoints > 0,
              backgroundColor: (program.userPoints > 0
                  ? ref.scheme.positive
                  : (program.userPoints == 0 ? ref.scheme.paperBold : ref.scheme.negative)),
              //backgroundColor: Colors.amber,
            ),
          ),
        );
      },
    );

    /* Wrap

    final maxPrograms = 3;
    final headPrograms = programs.take(maxPrograms);
    final remainingPrograms = programs.length - headPrograms.length;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: headPrograms.map((program) {
            final points = formatAmount(context.locale.languageCode, program.plural, program.userPoints, digits: program.digits);
            String summary = "${program.name}: $points";
            if (program.lastLocationName != null) summary += ", ${program.lastLocationName}";
            if (program.lastTransactionDate != null)
              summary += ", ${formatDate(context.locale.languageCode, program.lastTransactionDate)}";
            return MoleculeChip(
              label: summary,
              active: program.userPoints > 0,
              //backgroundColor: Colors.amber,
            );
          }).toList() +
          (remainingPrograms > 0 ? [MoleculeChip(label: "+$remainingPrograms")] : []),
    );

    */
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, UserCard userCard) {
    final locale = context.locale.languageCode;
    final columnMap = <String, Widget>{
      _columnCardName: userCard.name.text.color(ref.scheme.content),
      _columnNumber: userCard.number.text.color(ref.scheme.content),
      _columnUserName: userCard.userName.text.color(ref.scheme.content),
      _columnLastActivity: formatDate(locale, userCard.lastActivity).text.color(ref.scheme.content),
      _columnProgram: _buildProgram(context, ref, userCard),
    };
    //userCard.de
    return columnMap[column] ?? "?".text.color(ref.scheme.content);
  }

  void _popupOperations(BuildContext context, WidgetRef ref, ClientUserCardsSucceed succeed, UserCard userCard,
          TapUpDetails details) =>
      showVegaPopupMenu(
        context: context,
        ref: ref,
        details: details,
        title: userCard.name ?? userCard.number ?? "?",
        items: [
          if (reservationDate != null) UserCardMenuItems.book(context, ref, userCard, reservationDate!),
          UserCardMenuItems.showTransactions(context, ref, userCard),
          UserCardMenuItems.sendMessage(context, ref, userCard),
          UserCardMenuItems.openUserData(context, ref, userCard),
        ],
      );
}

// eof
