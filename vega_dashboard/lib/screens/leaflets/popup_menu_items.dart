import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../dialog.dart";
import "screen_leaflet_edit.dart";
import "screen_leaflet_pages.dart";

class LeafletMenuItems {
  static PopupMenuItem showPages(BuildContext context, WidgetRef ref, Leaflet leaflet) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationShowPages.tr(),
        icon: AtomIcons.eye,
        onAction: () => context.popPush(ScreenLeafletPages(leaflet: leaflet)),
      ),
    );
  }

  static PopupMenuItem block(BuildContext context, WidgetRef ref, Leaflet leaflet) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: leaflet.blocked ? LangKeys.operationUnblock.tr() : LangKeys.operationBlock.tr(),
        icon: leaflet.blocked ? AtomIcons.shield : AtomIcons.shieldOff,
        onAction: () {
          context.pop();
          if (leaflet.blocked) {
            showWaitDialog(context, ref, LangKeys.toastUnblocking.tr());
            ref.read(leafletPatchLogic.notifier).unblock(leaflet);
          } else {
            showWaitDialog(context, ref, LangKeys.toastBlocking.tr());
            ref.read(leafletPatchLogic.notifier).block(leaflet);
          }
        },
      ),
    );
  }

  static PopupMenuItem finish(BuildContext context, WidgetRef ref, Leaflet leaflet) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationFinish.tr(),
        icon: AtomIcons.stop,
        onAction: () {
          context.pop();
          showWaitDialog(context, ref, LangKeys.toastFinishing.tr());
          ref.read(leafletPatchLogic.notifier).finish(leaflet);
        },
      ),
    );
  }

  static PopupMenuItem archive(BuildContext context, WidgetRef ref, Leaflet leaflet) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationArchive.tr(),
        icon: AtomIcons.delete,
        onAction: () async {
          context.pop();
          _askToArchive(context, ref, leaflet);
        },
      ),
    );
  }

  static Future<void> _askToArchive(BuildContext context, WidgetRef ref, Leaflet leaflet) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogArchiveTitle.tr().h3,
        content: LangKeys.dialogArchiveContent.tr(args: [leaflet.name]).text,
        actions: [
          MoleculePrimaryButton(
            onTap: () => context.pop(false),
            titleText: LangKeys.buttonCancel.tr(),
          ),
          MoleculePrimaryButton(
            onTap: () => context.pop(true),
            titleText: LangKeys.buttonArchive.tr(),
            color: ref.scheme.negative,
          ),
        ],
      ),
    );
    if (result == true) {
      showWaitDialog(context, ref, LangKeys.toastArchiving.tr());
      ref.read(leafletPatchLogic.notifier).archive(leaflet);
    }
  }

  static PopupMenuItem start(BuildContext context, WidgetRef ref, Leaflet leaflet) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationStart.tr(),
        icon: AtomIcons.start,
        onAction: () {
          // TODO: tu dať varovanie, či skutočne spustiť leták teraz... nastaví valid_from na `now`
          context.pop();
          showWaitDialog(context, ref, LangKeys.toastStarting.tr());
          ref.read(leafletPatchLogic.notifier).start(leaflet);
        },
      ),
    );
  }

  static PopupMenuItem edit(BuildContext context, WidgetRef ref, Leaflet leaflet) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEdit.tr(),
        icon: AtomIcons.edit,
        onAction: () async {
          ref.read(leafletEditorLogic.notifier).edit(leaflet);
          context.popPush(ScreenLeafletEdit());
        },
      ),
    );
  }
}

// eof
