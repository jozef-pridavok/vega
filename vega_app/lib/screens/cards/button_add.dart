import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../data_models/custom_card.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/user_identity.dart";
import "../card/screen_edit_detail.dart";
import "screen_pick_card.dart";
import "screen_process_qr.dart";

Future<void> universalAdd(BuildContext context, WidgetRef ref) async {
  final screen = CodeCameraScreen(
    title: LangKeys.screenAddTitle.tr(),
    cancel: true,
    onFinish: (type, value) {
      ref.read(scanCodeLogic.notifier).parse(type ?? CodeType.qr, value);
      context.push(const ProcessQrScreen());
    },
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AddManuallyButton(),
        MoleculeItemSpace(),
        _ShowUserIdentityButton(),
      ],
    ),
  );
  await context.slideUp(screen);
}

class AddButton extends ConsumerWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
        icon: const VegaIcon(name: AtomIcons.add),
        onPressed: () => universalAdd(context, ref),
      );
}

class _AddManuallyButton extends ConsumerWidget {
  const _AddManuallyButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: "${LangKeys.labelScanCode.tr()} ",
        style: AtomStyles.text.copyWith(color: ref.scheme.content),
        children: <TextSpan>[
          TextSpan(
            text: LangKeys.labelAddManually.tr(),
            style: AtomStyles.text.copyWith(color: ref.scheme.primary),
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.popPush(
                    PickCardScreen(onCardPicked: (context, ref, card) => _addCard(context, ref, card)),
                  ),
          ),
          TextSpan(
            text: ".",
            style: AtomStyles.text.copyWith(color: ref.scheme.content),
          ),
        ],
      ),
    );
  }

  void _addCard(BuildContext context, WidgetRef ref, Card card) {
    final userId = (ref.read(deviceRepository).get(DeviceKey.user) as User).userId;
    final userCard = UserCard(
      userCardId: uuid(),
      userId: userId,
      name: card.isCustom ? LangKeys.customLoyaltyCard.tr() : card.name,
      color: card.color,
      codeType: card.codeType,
      clientId: card.isCustom ? null : card.clientId,
      cardId: card.cardId,
    );
    context.slideUp(EditDetailScreen(userCard, true, popAllOnDone: true));
  }
}

class _ShowUserIdentityButton extends ConsumerWidget {
  const _ShowUserIdentityButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: "${LangKeys.labelShowToOperator.tr()} ",
        style: AtomStyles.text.copyWith(color: ref.scheme.content),
        children: <TextSpan>[
          TextSpan(
            text: LangKeys.labelYourIdentity.tr(),
            style: AtomStyles.text.copyWith(color: ref.scheme.primary),
            recognizer: TapGestureRecognizer()..onTap = () => _showUserIdentity(context, ref),
          ),
          TextSpan(
            text: ".",
            style: AtomStyles.text.copyWith(color: ref.scheme.content),
          ),
        ],
      ),
    );
  }

  Future<void> _showUserIdentity(BuildContext context, WidgetRef ref) async {
    context.pop();
    await showUserIdentity(context, ref);
    //await ref.read(userCardsLogic.notifier).refreshOnBackground();
  }
}

// eof
