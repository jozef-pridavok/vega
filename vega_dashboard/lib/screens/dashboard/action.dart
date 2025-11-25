import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../../strings.dart";

enum DashboardActionType { system, reservations, orders, coupons, programs, cards, other }

enum DashboardActionLayout { tile, info }

extension DashboardActionTypeLocalized on DashboardActionType {
  static final _keyMap = {
    DashboardActionType.system: LangKeys.menuSystem,
    DashboardActionType.reservations: LangKeys.menuReservations,
    DashboardActionType.orders: LangKeys.menuClientOrders,
    DashboardActionType.coupons: LangKeys.menuClientCoupons,
    DashboardActionType.programs: LangKeys.menuClientPrograms,
    DashboardActionType.cards: LangKeys.menuClientCards,
    DashboardActionType.other: "dashboard_action_other",
  };

  String get localizedName => _keyMap[this]!.tr();
}

class DashboardAction {
  final DashboardActionType type;
  final DashboardActionLayout layout;
  final String? title;
  final String? label;
  final String? icon;
  final List<MoleculeAction>? actions;

  final String? primaryActionIcon;
  final void Function(TapUpDetails)? onPrimaryAction;

  const DashboardAction({
    required this.type,
    required this.title,
    this.label,
    this.icon,
    this.actions,
    this.primaryActionIcon,
    this.onPrimaryAction,
    this.layout = DashboardActionLayout.tile,
  });
}

// eod
