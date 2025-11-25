import "package:collection/collection.dart";
import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart" hide Color;
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/screens/client_cards/screen_list.dart";

import "../../data_models/dashboard.dart";
import "../../extensions/select_item.dart";
import "../../states/dashboard.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/qr_identity.dart";
import "../dialog.dart";
import "../programs/popup_menu_items.dart";
import "../programs/screen_list.dart";
import "../screen_number_input.dart";
import "action.dart";

extension ProgramTypeIcon on ProgramType {
  static final _iconMap = {
    ProgramType.credit: AtomIcons.plusSquare,
    ProgramType.collect: AtomIcons.trendingUp,
    ProgramType.reach: AtomIcons.care,
  };

  String get icon2 => _iconMap[this]!;

  String get icon => AtomIcons.program;
}

extension DashboardActions on DashboardSucceed {
  List<DashboardAction> getActionsForPos(BuildContext context, WidgetRef ref) {
    final client = ref.read(deviceRepository).get(DeviceKey.client) as Client;
    if (!client.licenseModuleLoyalty) return [];

    final lang = context.locale.languageCode;
    List<DashboardAction> actions = [];

    // Coupons actions

    actions.addAll(
      dashboard.coupons.map(
        (coupon) => DashboardAction(
          type: DashboardActionType.coupons,
          title: coupon.name,
          label: "${LangKeys.labelValidTo.tr()} ${formatIntDate(lang, coupon.validTo)}",
          icon: AtomIcons.coupon,
          actions: [
            MoleculeAction(
              title: LangKeys.buttonIssueCoupon.tr(),
              onTap: () => _issueUserCoupon(context, ref, coupon),
            ),
          ],
        ),
      ),
    );

    // Programs actions

    for (final program in dashboard.programs) {
      List<DashboardAction> programActions = [];

      final programAddOperation = program.actions?.addition ?? "+";
      final programSubtractOperation = program.actions?.subtraction ?? "-";

      final hasQrTags = [ProgramType.reach, ProgramType.collect].contains(program.type);
      final hasMenu = hasQrTags;

      programActions.add(
        DashboardAction(
          type: DashboardActionType.programs,
          title: program.name,
          label: program.description,
          icon: program.type.icon,
          primaryActionIcon: hasMenu ? AtomIcons.moreVertical : null,
          onPrimaryAction: (details) {
            final offset = details.globalPosition;
            final size = MediaQuery.of(context).size;
            showMenu(
              position: RelativeRect.fromLTRB(offset.dx, offset.dy, size.width - offset.dx, size.height - offset.dy),
              context: context,
              items: [
                ProgramMenuItems.showQrTags(context, ref, program),
              ],
            );
          },
          actions: [
            MoleculeAction.positive(
              title: programAddOperation,
              onTap: () => _programAction(
                  context, ref, program, true, programAddOperation, LangKeys.dashboardLabelPointsToAdd.tr()),
            ),
            if (program.type == ProgramType.credit)
              MoleculeAction.negative(
                title: programSubtractOperation,
                onTap: () => _programAction(context, ref, program, false, programSubtractOperation,
                    LangKeys.dashboardLabelPointsToSubtract.tr()),
              ),
          ],
        ),
      );

      actions.addAll(programActions);
    }

    if (dashboard.programs.isEmpty && dashboard.cards.isNotEmpty) {
      actions.add(
        DashboardAction(
          type: DashboardActionType.programs,
          title: LangKeys.menuClientCards.tr(),
          label: LangKeys.labelNoPrograms.tr(),
          icon: AtomIcons.card,
          actions: [
            MoleculeAction(
              title: LangKeys.operationCreateProgram.tr(),
              onTap: () => context.replace(const ProgramsScreen(showDrawer: true)),
            ),
          ],
        ),
      );
    }

    // Cards actions

    for (final card in dashboard.cards) {
      List<DashboardAction> cardActions = [];
      cardActions.add(
        DashboardAction(
          type: DashboardActionType.cards,
          title: card.name,
          label: card.programNames,
          icon: AtomIcons.card,
          actions: [
            MoleculeAction(
              title: LangKeys.operationShowQrCode.tr(),
              onTap: () {
                final qrCode = F().qrBuilder.generateCardIdentity(card.cardId);
                showIdentityForNewCard(context, ref, qrCode);
              },
            ),
            MoleculeAction.secondary(
              title: LangKeys.buttonIssueCard.tr(),
              onTap: () => _issueUserCard(context, ref, card),
            ),
          ],
        ),
      );
      actions.addAll(cardActions);
    }

    if (client.licenseModuleLoyalty && dashboard.cards.isEmpty) {
      actions.add(
        DashboardAction(
          type: DashboardActionType.cards,
          title: LangKeys.menuClientCards.tr(),
          label: LangKeys.labelNoClientCards.tr(),
          icon: AtomIcons.card,
          actions: [
            MoleculeAction(
              title: LangKeys.operationCreateCard.tr(),
              onTap: () => context.replace(const ClientCardsScreen(showDrawer: true)),
            ),
          ],
        ),
      );
    }

    return actions;
  }

  void posUniversalCamera(BuildContext context, WidgetRef ref) async {
    final screen = CodeCameraScreen(
      title: LangKeys.screenScanUserCard.tr(),
      cancel: true,
      onFinish: (type, value) {
        context.pop();

        final qrBuilder = F().qrBuilder;
        final userCouponId = qrBuilder.parseUserCouponIdentity(value);
        final reachRequestReward = qrBuilder.parseReachRequestReward(value);
        final userIdentity = qrBuilder.parseUserIdentity(value);
        if (userCouponId != null) {
          showWaitDialog(context, ref, LangKeys.toastRedeemingCoupon.tr());
          ref.read(redeemCouponLogic.notifier).redeem(type ?? CodeType.qr, value);
        } else if (reachRequestReward != null) {
          final (userCardId, rewardId) = reachRequestReward;
          final programs = dashboard.programs;
          final program = programs.firstWhereOrNull(
            (p) => p.rewards?.any((r) => r.programRewardId == rewardId) ?? false,
          );
          if (program == null) return ref.read(toastLogic.notifier).error(LangKeys.toastProgramWithRewardNotFound.tr());
          final reward = program.rewards?.firstWhereOrNull((reward) => reward.programRewardId == rewardId);
          if (reward == null) return ref.read(toastLogic.notifier).error(LangKeys.toastRewardNotFound.tr());
          showWaitDialog(context, ref, LangKeys.toastIssuingReward.tr());
          ref.read(issueRewardLogic.notifier).issue(reward.programRewardId, userCardId);
        } else if (userIdentity != null) {
          final state = cast<DashboardSucceed>(ref.read(dashboardLogic));
          if (state == null) return ref.read(toastLogic.notifier).error(LangKeys.toastUnexpectedError.tr());
          if (dashboard.cards.isEmpty) return;
          if (dashboard.cards.length == 1) {
            final card = dashboard.cards.first;
            showWaitDialog(context, ref, LangKeys.toastIssuingUserCard.tr());
            ref.read(issueUserCardLogic.notifier).issue(card, type ?? CodeType.qr, value);
          } else {
            final isMobile = ref.read(layoutLogic).isMobile;
            isMobile
                ? showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: moleculeBottomSheetBorder,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setState) => DraggableScrollableSheet(
                          expand: false,
                          initialChildSize: 0.66,
                          minChildSize: 0.66,
                          maxChildSize: 0.90,
                          builder: (context, scrollController) =>
                              _buildCardPicker(context, ref, state.dashboard, type ?? CodeType.qr, value),
                        ),
                      );
                    },
                  )
                : showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: LangKeys.pickCardLabel.tr().text,
                      content: _buildCardPicker(context, ref, state.dashboard, type ?? CodeType.qr, value),
                    ),
                  );
          }
        } else {
          ref.read(toastLogic.notifier).warning("type: $type, value: $value");
          //ref.read(toastLogic.notifier).warning(LangKeys.toastUnexpectedError.tr());
          // Try to find a card by code (value argument). If found, show programs that can be used with this card.
          // Then show a list of program actions that can be used with this card.
        }

        //ref.read(scanQrCodeLogic.notifier).parse(type, value),
      },
    );
    await context.slideUp(screen);
  }

  Widget _buildCardPicker(BuildContext context, WidgetRef ref, Dashboard dashboard, CodeType type, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MoleculeSingleSelect(
          hint: LangKeys.hintAllCards,
          items: dashboard.cards.toSelectItems(),
          onChanged: (selected) {
            final card = dashboard.cards.firstWhere((c) => c.cardId == selected.value);
            showWaitDialog(context, ref, LangKeys.toastIssuingUserCard.tr());
            ref.read(issueUserCardLogic.notifier).issue(card, type, value);
            context.pop();
          },
        ),
      ],
    );
  }

  void _issueUserCoupon(BuildContext context, WidgetRef ref, Coupon coupon) async {
    final screen = CodeCameraScreen(
      title: LangKeys.screenScanUserCard.tr(),
      cancel: true,
      onFinish: (type, value) {
        context.pop();
        showWaitDialog(context, ref, LangKeys.toastIssuingCoupon.tr());
        ref.read(issueCouponLogic.notifier).issue(coupon, type ?? CodeType.qr, value);
      },
    );
    await context.slideUp(screen);
  }

  void _issueUserCard(BuildContext context, WidgetRef ref, Card card) async {
    final screen = CodeCameraScreen(
      title: LangKeys.screenScanUserCard.tr(),
      cancel: true,
      onFinish: (type, value) {
        context.pop();
        showWaitDialog(context, ref, LangKeys.toastIssuingUserCard.tr());
        ref.read(issueUserCardLogic.notifier).issue(card, type ?? CodeType.qr, value);
      },
    );
    await context.slideUp(screen);
  }

  void _programAction(
    BuildContext context,
    WidgetRef ref,
    Program program,
    bool add,
    String numberInputTitle,
    String numberInputLabel,
  ) async {
    final screen = CodeCameraScreen(
      title: LangKeys.screenScanUserCard.tr(),
      cancel: true,
      onFinish: (type, value) async {
        context.pop();
        final input = ScreenNumberInput(
          title: numberInputTitle,
          label: numberInputLabel,
          digits: program.digits,
          plural: program.plural,
        );
        final points = await context.slideUp<int>(input);
        if (points == null) return;

        final message = formatAmount(context.locale.languageCode, program.plural, points, digits: program.digits);
        showWaitDialog(context, ref, "$numberInputTitle: $message");

        String? userCardId;
        String? number;
        final qrUserCardId = F().qrBuilder.parseUserCardIdentity(value);
        if (qrUserCardId != null)
          userCardId = qrUserCardId;
        else
          number = value;

        add
            ? ref.read(programActionLogic.notifier).add(program, points, userCardId: userCardId, number: number)
            : ref.read(programActionLogic.notifier).subtract(program, points, userCardId: userCardId, number: number);
      },
    );
    await context.slideUp(screen);
  }
}

// eof
