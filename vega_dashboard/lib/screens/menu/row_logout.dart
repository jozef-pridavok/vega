import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../dialog.dart";
import "../screen_app.dart";

class LogoutRow extends ConsumerStatefulWidget {
  const LogoutRow({super.key});

  @override
  createState() => _LogoutRowState();
}

class _LogoutRowState extends ConsumerState<LogoutRow> {
  void _listenToLogoutLogic() {
    ref.listen<LogoutState>(logoutLogic, (previous, next) async {
      if (next is LogoutFailed) {
        closeWaitDialog(context, ref);
        toastError(LangKeys.operationFailed.tr());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToLogoutLogic();
    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    // format: nick (login), if nick is empty, then login only
    final title = (user.nick?.isNotEmpty ?? false) ? "${user.nick} (${user.login})" : user.login;
    return MoleculeItemBasic(
      icon: AtomIcons.logout,
      title: LangKeys.menuLogout.tr(),
      label: title,
      actionIcon: AtomIcons.chevronRight,
      onAction: () {
        context.pop();
        showWaitDialog(context, ref, LangKeys.toastLoggingOut.tr());
        ref.read(logoutLogic.notifier).logout();
      },
    );
  }
}

// eof
