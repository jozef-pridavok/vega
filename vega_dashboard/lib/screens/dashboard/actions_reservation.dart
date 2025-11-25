import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/dashboard.dart";
import "../../states/providers.dart";
import "../../states/reservations.dart";
import "../../strings.dart";
import "../dialog.dart";
import "../reservation_dates/screen_dates.dart";
import "../reservations/screen_reservations.dart";
import "action.dart";

extension DashboardActions on DashboardSucceed {
  List<DashboardAction> getActionsForReservation(BuildContext context, WidgetRef ref) {
    final client = ref.read(deviceRepository).get(DeviceKey.client) as Client;
    if (!client.licenseModuleReservations) return [];

    final locale = Localizations.localeOf(context).toString();

    List<DashboardAction> actions = [];

    final reservationsStatus = ref.watch(activeReservationsLogic);
    final reservations = cast<ReservationsSucceed>(reservationsStatus);
    if (reservations?.reservations.isEmpty ?? false) {
      final action = DashboardAction(
        type: DashboardActionType.reservations,
        title: LangKeys.menuReservations.tr(),
        icon: AtomIcons.reservation,
        label: LangKeys.labelNoReservations.tr(),
        actions: [
          MoleculeAction.secondary(
            title: LangKeys.operationDefineReservations.tr(),
            onTap: () => context.push(const ReservationsScreen()),
          ),
        ],
      );
      actions.add(action);
    } else if (reservationsStatus is ReservationsSucceed) {
      final action = DashboardAction(
        type: DashboardActionType.reservations,
        title: LangKeys.menuClientReservationCalendar.tr(),
        icon: AtomIcons.reservation,
        label: LangKeys.menuClientReservationCalendarDescription.tr(),
        actions: [
          MoleculeAction.secondary(
            title: LangKeys.buttonView.tr(),
            onTap: () => context.push(const ReservationDatesScreen()),
          ),
        ],
      );
      actions.add(action);
    }

    //

    final max = 3;

    final List<ReservationForDashboard> reservationsForConfirmation =
        dashboard.reservationsForConfirmation.take(max).toList();

    if (reservationsForConfirmation.isNotEmpty) {
      for (final reservation in reservationsForConfirmation) {
        final action = DashboardAction(
          type: DashboardActionType.reservations,
          title: "${reservation.reservationName} - ${reservation.slotName}, ${reservation.userNick}",
          icon: AtomIcons.reservation,
          label: formatDateTimeRangePretty(locale, reservation.dateTimeFrom, reservation.dateTimeTo),
          actions: [
            MoleculeAction.positive(
              title: LangKeys.buttonConfirm.tr(),
              onTap: () {
                showWaitDialog(context, ref, LangKeys.toastConfirmingBooking.tr());
                ref.read(reservationForDashboardLogic.notifier).confirm(reservation);
              },
            ),
            MoleculeAction.negative(
              title: LangKeys.buttonCancel.tr(),
              onTap: () {
                showWaitDialog(context, ref, LangKeys.toastCancelingBooking.tr());
                ref.read(reservationForDashboardLogic.notifier).cancel(reservation);
              },
            ),
          ],
        );
        actions.add(action);
      }
    }

    if (dashboard.reservationsForConfirmation.length > max) {
      int restLength = dashboard.reservationsForConfirmation.length - max;
      actions.add(
        DashboardAction(
          type: DashboardActionType.reservations,
          layout: DashboardActionLayout.info,
          title: LangKeys.labelUnconfirmedReservationsCount.tr(args: [restLength.toString()]),
          icon: AtomIcons.plusCircle,
        ),
      );
    }

    //

    final List<ReservationForDashboard> reservationsForFinalization =
        dashboard.reservationsForFinalization.take(max).toList();

    if (reservationsForFinalization.isNotEmpty) {
      for (final reservation in reservationsForFinalization) {
        final action = DashboardAction(
          type: DashboardActionType.reservations,
          title: "${reservation.reservationName} - ${reservation.slotName}, ${reservation.userNick}",
          icon: AtomIcons.reservation,
          label: formatDateTimeRangePretty(locale, reservation.dateTimeFrom, reservation.dateTimeTo),
          actions: [
            MoleculeAction.positive(
              title: LangKeys.buttonCompleteBooking.tr(),
              onTap: () {
                showWaitDialog(context, ref, LangKeys.toastCompletingBooking.tr());
                ref.read(reservationForDashboardLogic.notifier).complete(reservation);
              },
            ),
            MoleculeAction.negative(
              title: LangKeys.buttonForfeitBooking.tr(),
              onTap: () {
                showWaitDialog(context, ref, LangKeys.toastForfeitingBooking.tr());
                ref.read(reservationForDashboardLogic.notifier).forfeit(reservation);
              },
            ),
          ],
        );
        actions.add(action);
      }
    }

    if (dashboard.reservationsForFinalization.length > max) {
      int restLength = dashboard.reservationsForFinalization.length - max;
      actions.add(
        DashboardAction(
          type: DashboardActionType.reservations,
          layout: DashboardActionLayout.info,
          title: LangKeys.labelUnfinishedReservationsCount.tr(args: [restLength.toString()]),
          icon: AtomIcons.plusCircle,
        ),
      );
    }

    return actions;
  }
}
