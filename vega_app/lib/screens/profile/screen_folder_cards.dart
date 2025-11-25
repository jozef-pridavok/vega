import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../../caches.dart";
import "../../states/providers.dart";
import "../../states/user/user_cards.dart";
import "../../strings.dart";
import "../screen_app.dart";

class FolderCardsScreen extends AppScreen {
  final Folder folder;

  const FolderCardsScreen(this.folder, {super.key});

  @override
  createState() => _FolderCardsState();
}

class _FolderCardsState extends AppScreenState<FolderCardsScreen> {
  String get _folderId => widget.folder.folderId;

  @override
  PreferredSizeWidget? buildAppBar(context) => VegaAppBar(title: LangKeys.screenFoldersTitle.tr());
  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(userCardsLogic) as UserCardsSucceed;
    final folder = state.userCardsByFolder.keys.firstWhereOrNull((folder) => folder.folderId == _folderId);
    final cards = state.userCards;
    final folderCards = state.userCardsByFolder[folder]?.map((e) => e.userCardId).toList() ?? widget.folder.userCardIds;

    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: ListView(
        children: cards
            .map(
              (userCard) => GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _toggleCard(context, userCard),
                child: MoleculusItemCard(
                  icon: folderCards.firstWhereOrNull((x) => x == userCard.userCardId) != null
                      ? AtomIcons.checkboxOn
                      : AtomIcons.checkboxOff,
                  card: MoleculusCardGrid4(
                    backgroundColor: userCard.color?.toMaterial() ?? ref.scheme.paper,
                    imageUrl: userCard.logo,
                    imageCache: Caches.cardLogo,
                  ),
                  title: userCard.name ?? userCard.cardName ?? LangKeys.loyaltyCard.tr(),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  void _toggleCard(BuildContext context, UserCard userCard) {
    final device = ref.read(deviceRepository);
    final user = device.get(DeviceKey.user) as User;
    final folders = user.folders;
    final folder = folders.list.firstWhereOrNull((e) => e.folderId == _folderId);
    if (folder == null) {
      if (widget.folder.isNew) {
        if (widget.folder.userCardIds.contains(userCard.userCardId)) {
          widget.folder.userCardIds.remove(userCard.userCardId);
        } else {
          widget.folder.userCardIds.add(userCard.userCardId);
        }
        // invoke buildBody, newly created folder has been updated
        ref.read(userCardsLogic.notifier).updateFolders();
      }
      return;
    }
    if (folder.userCardIds.contains(userCard.userCardId)) {
      folder.userCardIds.remove(userCard.userCardId);
    } else {
      folder.userCardIds.add(userCard.userCardId);
    }
    ref.read(userUpdateLogic.notifier).update(folders: folders);
    ref.read(userCardsLogic.notifier).updateFolders();
  }
}

// eof
