import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../../extensions/folder.dart";
import "../../states/providers.dart";
import "../../states/user/user_cards.dart";
import "../../strings.dart";
import "../screen_app.dart";
import "screen_folder_edit.dart";

class FoldersScreen extends AppScreen {
  const FoldersScreen({super.key});

  @override
  createState() => _FoldersState();
}

class _FoldersState extends AppScreenState {
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenFoldersTitle.tr(),
        actions: [
          IconButton(
            icon: const VegaIcon(name: AtomIcons.add),
            onPressed: () => context.slideUp(const FolderEditScreen()),
          ),
        ],
      );

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(userCardsLogic) as UserCardsSucceed;
    final folders = state.userCardsByFolder.keys;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(moleculeScreenPadding),
          child: LangKeys.screenFoldersDescription.tr().text.color(ref.scheme.content),
        ),
        Expanded(
          child: ReorderableListView(
            proxyDecorator: createMoleculeDragDecorator(ref.scheme.paperCard),
            buildDefaultDragHandles: false,
            children: folders.map(
              (folder) {
                final userCards = state.userCardsByFolder[folder] ?? [];
                return Padding(
                  padding: const EdgeInsets.all(moleculeScreenPadding),
                  key: ValueKey(folder),
                  child: MoleculeItemBasic(
                    title: folder.localizedName,
                    icon: folder.icon,
                    label: LangKeys.cards.plural(userCards.length),
                    actionIcon: AtomIcons.chevronRight,
                    onAction: () => _showBottomSheet(context, folder),
                  ),
                );
              },
            ).toList(),
            onReorder: (oldIndex, newIndex) => _reorderFolders(context, oldIndex, newIndex),
          ),
        ),
      ],
    );
  }

  void _showBottomSheet(BuildContext context, Folder folder) {
    modalBottomSheet(
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.screenFoldersTitle.tr()),
          const MoleculeItemSpace(),
          Container(
            decoration: moleculeShadowDecoration(ref.scheme.paper),
            padding: const EdgeInsets.all(moleculeScreenPadding),
            child: Column(
              children: [
                MoleculeItemTitle(header: folder.localizedName),
                const SizedBox(height: 16),
                const MoleculeItemSeparator(),
                const SizedBox(height: 16),
                MoleculeTableRow(label: LangKeys.screenFolderInfoType.tr(), value: folder.localizedType),
                const SizedBox(height: 16),
                MoleculeTableRow(label: LangKeys.screenFolderInfoLayout.tr(), value: folder.localizedLayout),
                const SizedBox(height: 16),
                MoleculeTableRow(
                  label: LangKeys.screenFolderInfoCardNumber.tr(),
                  value: LangKeys.cards.plural(folder.userCardIds.length),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const MoleculeItemSpace(),
          if (folder.type != FolderType.all)
            MoleculeItemBasic(
              title: LangKeys.buttonEdit.tr(),
              onAction: () {
                context.pop();
                context.slideUp(FolderEditScreen(folder: folder));
              },
              icon: AtomIcons.edit,
            ),
          if (folder.type == FolderType.common)
            MoleculeItemBasic(
              title: LangKeys.buttonDelete.tr(),
              onAction: () {
                context.pop();
                _askToDeleteFolder(context, folder);
              },
              icon: AtomIcons.delete,
              iconColor: ref.scheme.negative,
            ),
          const MoleculeItemSpace(),
        ],
      ),
    );
  }

  void _askToDeleteFolder(BuildContext context, Folder folder) {
    modalBottomSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.dialogDeleteFolderTitle.tr()),
          const MoleculeItemSpace(),
          LangKeys.dialogDeleteFolderMessage.tr().text.color(ref.scheme.content),
          const MoleculeItemSpace(),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MoleculePrimaryButton(
                titleText: LangKeys.buttonDelete.tr(),
                onTap: () => _deleteFolder(context, folder),
                color: ref.scheme.negative,
              ),
              const MoleculeItemSpace(),
              MoleculeSecondaryButton(titleText: LangKeys.buttonClose.tr(), onTap: () => context.pop()),
              const MoleculeItemSpace(),
            ],
          ),
        ],
      ),
    );
  }

  void _deleteFolder(BuildContext context, Folder folder) {
    context.pop();

    if (folder.type != FolderType.common) return;

    final device = ref.read(deviceRepository);
    final user = device.get(DeviceKey.user) as User;
    final folders = user.folders.list;

    int index = folders.indexWhere((e) => e.folderId == folder.folderId);
    folders.removeAt(index);

    user.folders = user.folders.copyWith(list: folders);

    ref.read(userUpdateLogic.notifier).update(folders: user.folders);
    ref.read(userCardsLogic.notifier).updateFolders();
  }

  void _reorderFolders(BuildContext context, int oldIndex, int newIndex) {
    final device = ref.read(deviceRepository);
    final user = device.get(DeviceKey.user) as User;
    final folders = user.folders.list;

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final folder = folders.removeAt(oldIndex);
    folders.insert(newIndex, folder);

    user.folders = user.folders.copyWith(list: folders);

    ref.read(userUpdateLogic.notifier).update(folders: user.folders);
    ref.read(userCardsLogic.notifier).updateFolders();
  }
}

// eof
