import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/screens/card/widget_summary_reservation.dart";
import "package:vega_app/states/providers.dart";
import "package:vega_app/states/reservation/user_reservation_editor.dart";

import "../../states/reservation/user_reservations.dart";
import "../../strings.dart";
import "../../widgets/status_error.dart";
import "../screen_app.dart";
import "screen_new_reservation.dart";

class ReservationsScreen extends AppScreen {
  final UserCard userCard;
  const ReservationsScreen(this.userCard, {super.key});

  @override
  createState() => _ReservationsState();
}

class _ReservationsState extends AppScreenState<ReservationsScreen> {
  String get _clientId => widget.userCard.clientId!;
  UserCard get _userCard => widget.userCard;

  @override
  bool onPushNotification(PushNotification message) {
    final clientId = _userCard.clientId;
    if (clientId == null) return false;
    final action = message.actionType;
    final reservationChanged = action == ActionType.reservationAccepted || action == ActionType.reservationClosed;
    if (reservationChanged && message["clientId"] == clientId) {
      hapticHeavy();
      ref.read(userReservationsLogic(_clientId).notifier).refresh();
      return true;
    }
    return super.onPushNotification(message);
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenTitleReservations.tr(),
        actions: [
          IconButton(
            icon: const VegaIcon(name: AtomIcons.add),
            onPressed: () => context.slideUp(EditReservationScreen(
              clientId: widget.userCard.clientId,
              cardId: widget.userCard.cardId,
              userCardId: widget.userCard.userCardId,
            )),
          ),
        ],
      );

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(userReservationsLogic(_clientId).notifier).load());
    //final clientId = widget.userCard.clientId;
    //if (clientId == null) return;
    Future(() => ref.read(reservationsLogic(_clientId).notifier).load());
  }

  void _listenToUserReservationLogic(BuildContext context) {
    final clientId = widget.userCard.clientId;
    ref.listen<UserReservationEditorState>(reservationEditorLogic, (previous, next) {
      if (next is UserReservationConfirmed || next is UserReservationCanceled) {
        toastInfo(LangKeys.operationSuccessful.tr());
        if (clientId != null) ref.read(userReservationsLogic(clientId).notifier).refresh();
      } else if (next is UserReservationFailed) {
        toastError(next.error.toString());
      }
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToUserReservationLogic(context);
    final state = ref.watch(userReservationsLogic(_clientId));
    if (state is UserReservationsSucceed) {
      final hasReservations = state.reservations.isNotEmpty;
      if (hasReservations) return _Reservations(widget.userCard);
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: MoleculeErrorWidget(
          icon: AtomIcons.reservation,
          iconColor: ref.scheme.content20,
          message: LangKeys.screenReservationNoReservation.tr(),
          primaryButton: !hasReservations ? LangKeys.buttonMakeReservation.tr() : LangKeys.buttonTryAgain.tr(),
          onPrimaryAction: () {
            if (!hasReservations) {
              context.slideUp(EditReservationScreen(
                clientId: widget.userCard.clientId,
                cardId: widget.userCard.cardId,
                userCardId: widget.userCard.userCardId,
              ));
            } else {
              ref.read(userReservationsLogic(_clientId).notifier).refresh();
            }
          },
        ),
      );
    } else if (state is UserReservationsFailed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: StatusErrorWidget(
          userReservationsLogic(_clientId),
          onReload: () => ref.read(userReservationsLogic(_clientId).notifier).reload(),
        ),
      );
    } else
      return const CenteredWaitIndicator();
  }
}

class _Reservations extends ConsumerWidget {
  final UserCard userCard;
  String get _clientId => userCard.clientId!;

  const _Reservations(this.userCard);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(userReservationsLogic(_clientId)) as UserReservationsSucceed;
    final reservations = succeed.reservations;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: PullToRefresh(
        onRefresh: () {
          ref.read(reservationsLogic(_clientId).notifier).refresh();
          ref.read(userReservationsLogic(_clientId).notifier).refresh();
        },
        child: ListView.builder(
          itemCount: reservations.length,
          itemBuilder: (context, index) => _buildRow(context, ref, reservations[index]),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, WidgetRef ref, UserReservation res) {
    final dateTime = formatDateTimePretty(context.languageCode, res.reservationDateFrom);
    final address = formatAddress(res.locationAddressLine1, res.locationAddressLine2, res.locationCity);
    final label = "$dateTime${address != null ? "\n$address" : ""} - ${res.reservationDateStatus.localizedName}";
    return MoleculeItemBasic(
      title: res.reservationSlotName,
      label: label,
      icon: AtomIcons.reservation,
      onAction: () => _showBottomSheet(context, ref, res),
    );
  }

  void _showBottomSheet(BuildContext context, WidgetRef ref, UserReservation reservation) {
    modalBottomSheet(
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.screenReservationTitle.tr()),
          const MoleculeItemSpace(),
          UserReservationSummaryWidget(reservation: reservation),
          const MoleculeItemSpace(),
          // tlačidlo "Potrebujem poradiť"
          // const SizedBox(height: 16),
          /*
          MoleculeItemBasic(
            title: LangKeys.buttonEdit.tr(),
            onAction: () {
              error("TODO");
              context.pop();
              context.slideUp(EditReservationScreen(reservation: reservation));
            },
            icon: AtomIcons.edit,
          ),
          */
          if (reservation.reservationDateFrom > DateTime.now())
            MoleculeItemBasic(
              title: LangKeys.buttonDelete.tr(),
              onAction: () {
                context.pop();
                _askToDeleteReservation(context, ref, reservation);
              },
              icon: AtomIcons.delete,
              iconColor: ref.scheme.negative,
            ),
          const MoleculeItemSpace(),
        ],
      ),
    );
  }

  void _askToDeleteReservation(BuildContext context, WidgetRef ref, UserReservation reservation) {
    modalBottomSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.dialogDeleteReservationTitle.tr()),
          const MoleculeItemSpace(),
          LangKeys.dialogDeleteReservationMessage.tr().text.color(ref.scheme.content),
          const MoleculeItemSpace(),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MoleculePrimaryButton(
                titleText: LangKeys.buttonDelete.tr(),
                onTap: () => _deleteReservation(context, ref, reservation),
                color: ref.scheme.negative,
              ),
              const MoleculeItemSpace(),
              MoleculeSecondaryButton(titleText: LangKeys.buttonClose.tr(), onTap: () => context.pop()),
              const MoleculeItemSpace(),
            ],
          ),
        ],
      ),
    );
  }

  void _deleteReservation(BuildContext context, WidgetRef ref, UserReservation reservation) async {
    context.pop();
    ref.read(reservationEditorLogic.notifier).edit(reservation);
    await ref.read(reservationEditorLogic.notifier).cancel();
  }
}

// eof
