import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/strings.dart";

import "../../states/providers.dart";
import "../cards/screen_cards.dart";
import "../profile/screen_login.dart";
import "../profile/screen_register.dart";

class AccountScreen extends ConsumerWidget {
  final bool hideBackButton;
  final bool closable;
  final bool allowAnonymous;

  const AccountScreen({this.closable = false, this.allowAnonymous = false, this.hideBackButton = false, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size.shortestSide;
    final imageSize = screenSize < 390 ? 128.0 : 256.0;

    return Scaffold(
      appBar: VegaAppBar(cancel: closable, hideButton: hideBackButton),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VegaImage(name: "account", width: imageSize, height: imageSize),
              const MoleculeItemDoubleSpace(),
              LangKeys.screenAccountTitle.tr().h2.color(ref.scheme.content).alignCenter,
              const MoleculeItemDoubleSpace(),
              LangKeys.screenAccountDescription.tr().text.color(ref.scheme.content).alignCenter,
              const MoleculeItemDoubleSpace(),
              const Spacer(),
              MoleculePrimaryButton(
                onTap: () => _login(context, ref),
                titleText: LangKeys.buttonIHaveAccount.tr(),
              ),
              const MoleculeItemSpace(),
              MoleculeSecondaryButton(
                onTap: () => _register(context, ref),
                titleText: LangKeys.buttonCreateAccount.tr(),
              ),
              const MoleculeItemSpace(),
              if (allowAnonymous) ...[
                MoleculeLinkButton(
                  onTap: () => _anonymous(context, ref),
                  titleText: LangKeys.buttonContinueAsAGuest.tr(),
                ),
                const MoleculeItemSpace(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _login(BuildContext context, WidgetRef ref) {
    //if (closable) context.pop();
    final device = ref.read(deviceRepository);
    device.put(DeviceKey.isWizardShowed, true);
    context.slideUp(const LoginScreen(goToHomeScreen: true));
  }

  void _register(BuildContext context, WidgetRef ref) {
    //if (closable) context.pop();
    final device = ref.read(deviceRepository);
    device.put(DeviceKey.isWizardShowed, true);
    context.slideUp(const RegisterScreen(goToHomeScreen: true));
  }

  void _anonymous(BuildContext context, WidgetRef ref) {
    //if (closable) context.pop();
    final device = ref.read(deviceRepository);
    device.put(DeviceKey.isWizardShowed, true);
    ref.read(userCardsLogic.notifier).refresh();
    context.replace(const CardsScreen(), popAll: true);
  }
}

// eof
