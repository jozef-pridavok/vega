import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/strings.dart";

import "../../states/providers.dart";

class SettingsButton extends ConsumerWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const VegaIcon(name: "change_layout"),
      onPressed: () => _showBottomSheet(context, ref),
    );
  }

  void _showBottomSheet(BuildContext context, WidgetRef ref) {
    final device = ref.read(deviceRepository);
    final user = device.get(DeviceKey.user) as User;
    final selected = user.folders.selectedFolder;
    Folder? folder = user.folders.list.firstWhereOrNull((e) => e.folderId == selected);
    folder ??= user.folders.list.first;
    const layouts = FolderLayout.values; //.map((e) => e.code).toList().sorted((a, b) => a.compareTo(b));
    modalBottomSheet(
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.screenEditFolderTitle.tr()),
          const MoleculeItemSpace(),
          ...layouts.map(
            (e) => MoleculeItemBasic(
              title: LangKeys.columns.plural(e.code),
              actionIcon: folder?.layout == e ? AtomIcons.check : null,
              onAction: () {
                _setLayout(ref, folder!, e);
                context.pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _setLayout(WidgetRef ref, Folder folder, FolderLayout layout) {
    final device = ref.read(deviceRepository);
    final user = device.get(DeviceKey.user) as User;
    final folders = user.folders;
    final index = folders.list.indexWhere((e) => e.folderId == folder.folderId);
    folders.list[index] = folder.copyWith(layout: layout);
    ref.read(userUpdateLogic.notifier).update(folders: folders);
    ref.read(userCardsLogic.notifier).updateFolders();
  }
}

// eof
