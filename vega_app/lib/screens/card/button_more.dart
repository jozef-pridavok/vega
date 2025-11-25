import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/strings.dart";

import "../../states/providers.dart";
import "screen_edit_detail.dart";

class MoreButton extends ConsumerWidget {
  final UserCard userCard;

  const MoreButton(this.userCard, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const VegaIcon(name: "more_horizontal"),
      onPressed: () => _showBottomSheet(context, ref),
    );
  }

  void _showBottomSheet(BuildContext context, WidgetRef ref) {
    final device = ref.read(deviceRepository);
    final user = device.get(DeviceKey.user) as User;
    final folders = user.folders;
    final favoriteFolder = folders.list.firstWhereOrNull((e) => e.folderId == Folder.idFavorites);
    final isFavorite = favoriteFolder?.userCardIds.contains(userCard.userCardId) ?? false;
    modalBottomSheet(
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.screenMoreCardDetailTitle.tr()),
          const MoleculeItemSpace(),
          MoleculeItemBasic(
            title: isFavorite
                ? LangKeys.cardDetailActionRemoveFromFavorites.tr()
                : LangKeys.cardDetailActionAddToFavorites.tr(),
            icon: isFavorite ? "star_off" : "star",
            onAction: () {
              _toggleFavorite(context, ref);
              context.pop();
            },
          ),
          MoleculeItemBasic(
            title: LangKeys.cardDetailActionChange.tr(),
            icon: AtomIcons.edit,
            onAction: () {
              context.pop();
              context.slideUp(EditDetailScreen(userCard, false));
            },
          ),
          MoleculeItemBasic(
            title: LangKeys.cardDetailActionDelete.tr(),
            icon: AtomIcons.delete,
            iconColor: ref.scheme.negative,
            onAction: () => _askToDeleteCard(context, ref),
          ),
          const MoleculeItemSpace(),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref) async {
    final device = ref.read(deviceRepository);
    final user = device.get(DeviceKey.user) as User;
    final folders = user.folders;
    final favoriteFolder = folders.list.firstWhereOrNull((e) => e.folderId == Folder.idFavorites);
    if (favoriteFolder == null) return;
    if (favoriteFolder.userCardIds.contains(userCard.userCardId)) {
      favoriteFolder.userCardIds.remove(userCard.userCardId);
    } else {
      favoriteFolder.userCardIds.add(userCard.userCardId);
    }
    await ref.read(userUpdateLogic.notifier).update(folders: folders);
    ref.read(userCardsLogic.notifier).updateFolders();
    if (context.mounted) context.pop();
  }

  void _askToDeleteCard(BuildContext context, WidgetRef ref) {
    context.pop();
    modalBottomSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.questionAreYouSure.tr()),
          const MoleculeItemSpace(),
          LangKeys.questionDeleteCard
              .tr(args: [userCard.name ?? userCard.number ?? "unnamed"])
              .text
              .color(ref.scheme.content),
          const MoleculeItemSpace(),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MoleculePrimaryButton(
                titleText: LangKeys.buttonDelete.tr(),
                onTap: () => _deleteCard(context, ref),
                color: ref.scheme.negative,
              ),
              const MoleculeItemSpace(),
              MoleculeSecondaryButton(
                titleText: LangKeys.buttonClose.tr(),
                onTap: () => context.pop(),
              ),
              const MoleculeItemSpace(),
            ],
          ),
        ],
      ),
    );
  }

  void _deleteCard(BuildContext context, WidgetRef ref) {
    context.pop();
    ref.read(userCardsLogic.notifier).delete(userCard.userCardId);
    context.pop();
  }
}

// eof
