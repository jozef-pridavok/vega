import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/strings.dart";

import "../../repositories/local.dart";
import "../../states/providers.dart";

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<LogoutState>(logoutLogic, (previous, next) {
      if (next is LogoutSucceed) {
        clearLocalData();
        ref.read(logoutLogic.notifier).reset();
        ref.read(userCardsLogic.notifier).refresh();
        context.pop();
      } else if (next is LogoutFailed) {
        ref.read(toastLogic.notifier).error(next.error.message);
        Future.delayed(stateRefreshDuration, () => ref.read(logoutLogic.notifier).reset());
      }
    });
    return IconButton(icon: const VegaIcon(name: AtomIcons.logout), onPressed: () => _askToLogout(context, ref));
  }

  void _askToLogout(BuildContext context, WidgetRef ref) => modalBottomSheet(
        context,
        Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final logoutState = ref.watch(logoutLogic);
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MoleculeItemSpace(),
                MoleculeItemTitle(header: LangKeys.screenProfileLogoutTitle.tr()),
                const MoleculeItemSpace(),
                LangKeys.screenProfileLogoutDescription.tr().text.color(ref.scheme.content),
                const MoleculeItemSpace(),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    MoleculeActionButton(
                      title: LangKeys.buttonLogout.tr(),
                      successTitle: LangKeys.operationSuccessful.tr(),
                      failTitle: LangKeys.operationFailed.tr(),
                      buttonState: logoutState.buttonState,
                      onPressed: () => ref.watch(logoutLogic.notifier).logout(),
                      color: ref.scheme.negative,
                    ),
                    const MoleculeItemSpace(),
                    MoleculeSecondaryButton(titleText: LangKeys.buttonClose.tr(), onTap: () => context.pop()),
                    const MoleculeItemSpace(),
                  ],
                ),
              ],
            );
          },
        ),
      );
}

// eof
