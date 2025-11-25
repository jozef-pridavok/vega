import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../data_models/custom_card.dart";
import "../../states/providers.dart";
import "../../states/user/scan_code.dart";
import "../../strings.dart";
import "../card/screen_detail.dart";
import "../card/screen_edit_detail.dart";
import "../screen_app.dart";
import "screen_cards.dart";
import "screen_pick_card.dart";

class ProcessQrScreen extends AppScreen {
  const ProcessQrScreen({super.key});

  @override
  createState() => _ProcessQrState();
}

class _ProcessQrState extends AppScreenState<ProcessQrScreen> {
  void _goToUserCards(BuildContext context, WidgetRef ref) {
    ref.read(userCardsLogic.notifier).refresh();
    context.replace(const CardsScreen(), popAll: true);
  }

  void _goToUserCard(BuildContext context, WidgetRef ref, String userCardId) {
    ref.read(userCardLogic(userCardId).notifier).refreshOnBackground();
    final userCard = UserCard(userCardId: userCardId, clientId: "", userId: "", codeType: CodeType.ean13);
    context.popPush(DetailScreen(userCard));
  }

  Future<void> _pickCard(BuildContext context, WidgetRef ref, CodeType type, value) async {
    await context.popPush(
      PickCardScreen(onCardPicked: (context, ref, card) => _addCard(context, ref, card)),
    );
  }

  void _pickUserCard(BuildContext context, WidgetRef ref, List<String> userCardIds) {
    toastError("TODO: pick user card");
    context.replace(const CardsScreen(), popAll: true);
    //ref.read(userCardsLogic.notifier).refresh();
    //context.replace(const CardsScreen(), popAll: true);
  }

  void _addCard(BuildContext context, WidgetRef ref, Card card) {
    final userId = (ref.read(deviceRepository).get(DeviceKey.user) as User).userId;
    final userCard = UserCard(
      userCardId: uuid(),
      userId: userId,
      codeType: card.codeType,
      name: card.isCustom ? LangKeys.customLoyaltyCard.tr() : card.name,
      color: card.isCustom ? card.color : null,
      clientId: card.isCustom ? null : card.clientId,
      cardId: card.isCustom ? null : card.cardId,
    );
    context.slideUp(EditDetailScreen(userCard, true, popAllOnDone: true));
  }

  void _listenToScanQrLogic() {
    ref.listen<ScanQrCodeState>(scanCodeLogic, (previous, next) {
      if (next is ScanCodePickCard) {
        _pickCard(context, ref, next.type, next.value);
      } else if (next is ScanCodeSucceed) {
        _goToUserCards(context, ref);
      } else if (next is ScanCodeTagSucceed) {
        final userCardId = next.userCardId;
        if (userCardId != null) {
          toastInfo(LangKeys.toastQrTagHasBeenApplied.tr());
          _goToUserCard(context, ref, userCardId);
        } else {
          final userCardIds = next.userCardIds;
          if (userCardIds?.isEmpty ?? true) {
            toastWarning(LangKeys.operationFailed.tr());
            _goToUserCards(context, ref);
          } else {
            _pickUserCard(context, ref, userCardIds!);
          }
        }
      } else if (next is ScanCodeFailed) {
        toastError(LangKeys.operationFailed.tr());
      }
    });
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    final status = ref.watch(scanCodeLogic);
    return VegaAppBar(
      title: "",
      cancel: true,
      hideButton: status is! ScanCodeFailed,
      onBack: () => context.replace(const CardsScreen()),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToScanQrLogic();
    final state = ref.watch(scanCodeLogic);
    if (state is ScanCodeSucceed) {
      return MoleculeErrorWidget(icon: AtomIcons.check, message: state.userCard.name);
    } else if (state is ScanCodeFailed) {
      String message = state.error.toString();
      if (state.error == errorObjectNotFound) {
        message = LangKeys.operationFailed.tr();
      }
      return MoleculeErrorWidget(message: message);
    }
    return const CenteredWaitIndicator();
  }
}

// eof
