import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";

import "../../caches.dart";
import "../../extensions/folder.dart";
import "../../states/providers.dart";
import "../../states/user/user_cards.dart";
import "../../strings.dart";
import "../screen_app.dart";
import "screen_folder_cards.dart";

class FolderEditScreen extends AppScreen {
  final Folder? folder;
  const FolderEditScreen({this.folder, super.key});

  @override
  createState() => _FolderEditState();
}

class _FolderEditState extends AppScreenState<FolderEditScreen> {
  late Folder _folder; // => widget.folder;

  final _nameController = TextEditingController();
  final _layoutController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _folder = widget.folder ?? Folder.createNew();
    _nameController.text = _folder.name;
    _layoutController.text = _folder.localizedLayout;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _layoutController.dispose();
    super.dispose();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenEditFolderTitle.tr(),
        cancel: true,
      );

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(userCardsLogic) as UserCardsSucceed;
    final userCards = state.userCards;
    final userCardsIds = _folder.userCardIds.where((e) => userCards.any((x) => x.userCardId == e)).toList();
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeInput(
                title: LangKeys.screenEditYourCardNameLabel.tr(),
                hint: LangKeys.screenEditYourFolderNameHint.tr(),
                controller: _nameController,
                inputAction: TextInputAction.next,
                capitalization: TextCapitalization.sentences,
                readOnly: _folder.type != FolderType.common,
                validator: (val) => val?.isEmpty ?? true ? LangKeys.validationNameRequired.tr() : null,
              ),
            ),
            const MoleculeItemSpace(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeInput(
                title: LangKeys.screenEditFolderLayoutLabel.tr(),
                controller: _layoutController,
                suffixIcon: const VegaIcon(name: "chevron_down"),
                inputAction: TextInputAction.done,
                enableSuggestions: false,
                readOnly: true,
                maxLines: 1,
                enableInteractiveSelection: false,
                onTap: () => _showLayoutBottomSheet(context),
              ),
            ),
            const MoleculeItemSpace(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeSecondaryButton(
                titleText: LangKeys.screenEditFolderPickCardsLabel.tr(),
                onTap: () => context.push(FolderCardsScreen(_folder)),
              ),
            ),
            const MoleculeItemSpace(),
            //
            if (userCardsIds.isNotEmpty) ...[
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                proxyDecorator: createMoleculeDragDecorator(ref.scheme.paperCard),
                buildDefaultDragHandles: false,
                children: userCardsIds.map(
                  (userCardId) {
                    final userCard = userCards.firstWhereOrNull((element) => element.userCardId == userCardId);
                    return Material(
                      key: ValueKey(userCardId),
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
                        child: MoleculusItemCard(
                          card: MoleculusCardGrid4(
                            backgroundColor: userCard?.color?.toMaterial() ?? ref.scheme.paperCard,
                            imageUrl: userCard?.logo,
                            imageCache: Caches.cardLogo,
                          ),
                          title: userCard?.name ?? userCard?.cardName ?? LangKeys.loyaltyCard.tr(),
                          actionIcon: AtomIcons.delete,
                          actionIconColor: ref.scheme.negative,
                        ),
                      ),
                    );
                  },
                ).toList(),
                onReorder: (oldIndex, newIndex) => _reorderUserCards(oldIndex, newIndex),
              ),
              const MoleculeItemSpace(),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculePrimaryButton(
                onTap: () {
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    ref.read(toastLogic.notifier).warning(LangKeys.operationFailed.tr());
                    return;
                  }
                  _folder = _folder.copyWith(
                    name: _nameController.text,
                  );
                  _folder.isNew ? _createFolder(context) : _updateFolder(context);
                  context.pop();
                },
                titleText: LangKeys.buttonConfirm.tr(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLayoutBottomSheet(BuildContext context) {
    const layouts = FolderLayout.values; //.map((e) => e.code).toList().sorted((a, b) => a.compareTo(b));
    modalBottomSheet(
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.screenEditFolderLayoutLabel.tr()),
          const MoleculeItemSpace(),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: layouts
                .map(
                  (e) => MoleculeItemBasic(
                    title: "columns".plural(e.code),
                    actionIcon: _folder.layout == e ? "check" : null,
                    //showDetail: false,
                    onAction: () {
                      _folder = _folder.copyWith(layout: e);
                      _layoutController.text = _folder.localizedLayout;
                      context.pop();
                      //_updateFolder(context);
                    },
                  ),
                )
                .toList(),
          )
        ],
      ),
    );
  }

  void _createFolder(BuildContext context) {
    final device = ref.read(deviceRepository);
    final user = device.get(DeviceKey.user) as User;
    final folders = user.folders;
    _folder = _folder.copyWith(folderId: uuid());
    folders.list.add(_folder);

    user.folders = folders;

    ref.read(userUpdateLogic.notifier).update(folders: folders);
    ref.read(userCardsLogic.notifier).updateFolders();
    context.pop();
  }

  void _updateFolder(BuildContext context) {
    final device = ref.read(deviceRepository);
    final user = device.get(DeviceKey.user) as User;
    final folders = user.folders;

    final index = folders.list.indexWhere((e) => e.folderId == _folder.folderId);
    folders.list[index] = _folder;

    user.folders = folders;

    ref.read(userUpdateLogic.notifier).update(folders: folders);
    ref.read(userCardsLogic.notifier).updateFolders();
    context.pop();
  }

  void _reorderUserCards(int oldIndex, int newIndex) {
    final userCardId = _folder.userCardIds.removeAt(oldIndex);
    _folder.userCardIds.insert(newIndex, userCardId);

    final device = ref.read(deviceRepository);
    final user = device.get(DeviceKey.user) as User;
    final folders = user.folders;
    final index = folders.list.indexWhere((e) => e.folderId == _folder.folderId);
    folders.list[index] = _folder.copyWith(userCardIds: _folder.userCardIds);
    ref.read(userUpdateLogic.notifier).update(folders: folders);
    ref.read(userCardsLogic.notifier).updateFolders();
  }
}

// eof
