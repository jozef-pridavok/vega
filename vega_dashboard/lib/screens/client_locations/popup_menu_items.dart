import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../dialog.dart";
import "screen_add_exception.dart";
import "screen_edit.dart";

class LocationMenuItems {
  static PopupMenuItem edit(BuildContext context, WidgetRef ref, Location location) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEdit.tr(),
        icon: AtomIcons.edit,
        onAction: () {
          context.pop();
          ref.read(locationEditorLogic.notifier).edit(location);
          context.push(LocationEditScreen());
        },
      ),
    );
  }

  static PopupMenuItem archive(BuildContext context, WidgetRef ref, Location location) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationArchive.tr(),
        icon: AtomIcons.delete,
        onAction: () {
          context.pop();
          Future.delayed(fastRefreshDuration, () => _askToArchiveLocation(context, ref, location));
        },
      ),
    );
  }

  static Future<void> _askToArchiveLocation(BuildContext context, WidgetRef ref, Location location) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogArchiveTitle.tr().h3,
        content: LangKeys.dialogArchiveContent.tr(args: [location.name]).text,
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
      ref.read(locationPatchLogic.notifier).archive(location);
    }
  }

  static PopupMenuItem addException(
    BuildContext context,
    WidgetRef ref,
    String notificationsTag,
    ({IntDate date, String exception}) exception,
  ) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEdit.tr(),
        icon: AtomIcons.edit,
        onAction: () {
          context.pop();
          context.push(AddOpeningHoursException(
            locationNotificationTag: notificationsTag,
            exception: exception,
          ));
        },
      ),
    );
  }

  static PopupMenuItem deleteException(
    BuildContext context,
    WidgetRef ref,
    String notificationsTag,
    IntDate exception,
  ) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationDelete.tr(args: [exception.toLocalDate().toString()]),
        icon: AtomIcons.delete,
        onAction: () {
          context.pop();
          Future.delayed(fastRefreshDuration, () => _askToDeleteException(context, ref, notificationsTag, exception));
        },
      ),
    );
  }

  static Future<void> _askToDeleteException(
    BuildContext context,
    WidgetRef ref,
    String notificationsTag,
    IntDate exception,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogDeleteTitle.tr().text,
        content: LangKeys.dialogDeleteContent.tr(args: [exception.toLocalDate().toString()]).text,
        actions: [
          MoleculePrimaryButton(
            titleText: LangKeys.buttonCancel.tr(),
            onTap: () => context.pop(false),
          ),
          MoleculePrimaryButton(
            titleText: LangKeys.buttonDelete.tr(),
            onTap: () => context.pop(true),
            color: ref.scheme.negative,
          ),
        ],
      ),
    );
    if (result == true) {
      final unsavedWarningText = LangKeys.notificationUnsavedData.tr();
      ref.read(notificationsLogic.notifier).warning(unsavedWarningText, tag: notificationsTag);
      ref.read(locationEditorLogic.notifier).deleteException(exception);
      ref.read(locationEditorLogic.notifier).refresh();
    }
  }
}

// eof
