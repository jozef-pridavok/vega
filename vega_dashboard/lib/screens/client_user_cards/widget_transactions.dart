import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/client_user_card_transactions.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";

class ClientUserCardTransactionsWidget extends ConsumerStatefulWidget {
  final UserCard userCard;
  final List<LoyaltyTransaction>? transactions;

  const ClientUserCardTransactionsWidget(
    this.userCard, {
    super.key,
    this.transactions,
  });

  @override
  createState() => _ClientUsersWidgetWidgetState();
}

class _ClientUsersWidgetWidgetState extends ConsumerState<ClientUserCardTransactionsWidget> {
  UserCard get _userCard => widget.userCard;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(clientUserCardTransactionsLogic.notifier).load(userCardId: _userCard.userCardId));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clientUserCardTransactionsLogic);
    if (state is ClientUserCardTransactionsSucceed)
      return _GridWidget(
        transactions: widget.transactions,
      );
    else if (state is ClientUserCardTransactionsFailed)
      return StateErrorWidget(
        clientUserCardTransactionsLogic,
        onReload: () => ref.read(clientUserCardTransactionsLogic.notifier).refresh(),
      );
    else
      return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  final List<LoyaltyTransaction>? transactions;

  const _GridWidget({
    this.transactions,
  });

  static const _columnDate = "date";
  static const _columnProgram = "program";
  static const _columnPoints = "points";
  static const _columnObject = "object";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(clientUserCardTransactionsLogic) as ClientUserCardTransactionsSucceed;
    final transactions = this.transactions ?? succeed.transactions;
    return PullToRefresh(
      onRefresh: () => ref.read(clientUserCardTransactionsLogic.notifier).refresh(),
      child: DataGrid<LoyaltyTransaction>(
        rows: transactions,
        columns: [
          DataGridColumn(name: _columnDate, label: LangKeys.columnDate.tr()),
          DataGridColumn(name: _columnProgram, label: LangKeys.columnProgram.tr()),
          DataGridColumn(name: _columnPoints, label: LangKeys.columnPoints.tr()),
          DataGridColumn(name: _columnObject, label: LangKeys.columnTransactionObject.tr()),
        ],
        onBuildCell: (column, transaction) => _buildCell(context, ref, column, transaction),
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, LoyaltyTransaction transaction) {
    final locale = context.locale.languageCode;
    final points = transaction.points;
    final columnMap = <String, Widget>{
      _columnDate: formatDate(locale, transaction.date).text.color(ref.scheme.content),
      _columnProgram: transaction.programName.text.color(ref.scheme.content),
      // TODO: format points
      _columnPoints: MoleculeChip(
        //
        //label: formatAmount(locale, null, points, digits: transaction.digits) ?? "?",
        // formatAmount(locale, null, points, digits: transaction.digits) ?? "?",
        label: FixedPoint.digits(transaction.digits).format(transaction.points, locale),
        backgroundColor: points > 0 ? ref.scheme.positive : ref.scheme.negative,
      ),
      //points.toString().text.color(ref.scheme.content),
      _columnObject: transaction.objectType.localizedName.text.color(ref.scheme.content),
    };
    return columnMap[column] ?? "?".text.color(ref.scheme.content);
  }
}

// eof
