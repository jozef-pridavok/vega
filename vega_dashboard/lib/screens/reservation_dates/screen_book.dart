import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../states/reservation_dates.dart";
import "../../strings.dart";
import "../client_user_cards/widget_user_cards.dart";
import "../dialog.dart";
import "../screen_app.dart";

class BookScreen extends VegaScreen {
  final ReservationDate term;

  const BookScreen(this.term, {super.key});

  @override
  createState() => _BookState();
}

class _BookState extends VegaScreenState<BookScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(clientUserCardsLogic.notifier).loadPeriod(null));
  }

  @override
  String? getTitle() => LangKeys.screenClientUserCards.tr();

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics();
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: isMobile ? _mobileLayout() : _defaultLayout(),
    );
  }

  void _listenToLogics() {
    ref.listen<ReservationDatesState>(reservationDatesLogic, (previous, next) {
      if (next is ReservationDatesOperationSucceed) {
        closeWaitDialog(context, ref);
        toastInfo(LangKeys.operationSuccessful.tr());
        ref.read(reservationDatesLogic.notifier).afterOperation();
        final key = ref.read(reservationDatesLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
        context.pop();
      } else if (next is ReservationDatesOperationFailed) {
        toastError(LangKeys.operationFailed.tr());
        closeWaitDialog(context, ref);
        ref.read(reservationDatesLogic.notifier).afterOperation();
      }
    });
  }

  // TODO: Mobile layout
  Widget _mobileLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Filters(),
          const MoleculeItemSpace(),
          Expanded(child: UserCardsWidget(reservationDate: widget.term)),
        ],
      );

  Widget _defaultLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Filters(),
          const MoleculeItemSpace(),
          Expanded(child: UserCardsWidget(reservationDate: widget.term)),
        ],
      );
}

class _Filters extends ConsumerWidget {
  const _Filters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: const _TextFilter()),
        const MoleculeItemHorizontalSpace(),
        const Spacer(),
      ],
    );
  }
}

class _TextFilter extends ConsumerWidget {
  const _TextFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientUserCardsLogic);
    return MoleculeInput(
      title: LangKeys.clientUserCardsFilterTitle.tr(),
      hint: LangKeys.clientUserCardsFilterHint.tr(),
      initialValue: state.filter,
      onChanged: (val) => ref.read(clientUserCardsLogic.notifier).load(filter: val),
    );
  }
}

// eof
