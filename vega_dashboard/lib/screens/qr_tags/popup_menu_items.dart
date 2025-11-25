import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../strings.dart";
import "../client_user_cards/screen_send_message.dart";
import "../client_users/screen_edit_info.dart";

class QrTagsMenuItems {
  static PopupMenuItem sendMessage(BuildContext context, WidgetRef ref, QrTag qrTag) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationSendMessage.tr(),
        icon: AtomIcons.send,
        onAction: () => context.popPush(SendMessageScreen(qrTag.usedByUserId!, qrTag.usedByUserNick ?? "")),
      ),
    );
  }

  static PopupMenuItem openUserData(BuildContext context, WidgetRef ref, QrTag qrTag) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEditUserData.tr(),
        icon: AtomIcons.edit,
        onAction: () => context.popPush(EditClientUserInfoScreen(userId: qrTag.usedByUserId!)),
      ),
    );
  }
}

// eof
