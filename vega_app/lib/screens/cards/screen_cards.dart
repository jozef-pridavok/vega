import "dart:ui";

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:reorderable_grid/reorderable_grid.dart";

import "../../caches.dart";
import "../../states/providers.dart";
import "../../states/user/user_cards.dart";
import "../../strings.dart";
import "../../widgets/status_error.dart";
import "../card/screen_detail.dart";
import "../screen_tab.dart";
import "button_add.dart";
import "button_settings.dart";

class CardsScreen extends TabScreen {
  const CardsScreen({Key? key}) : super(0, LangKeys.screenMyCardsTitle, key: key);

  @override
  createState() => _CardsScreenState();
}

class _CardsScreenState extends TabScreenState<CardsScreen> {
  //@override
  //void onGainedVisibility() {
  //  Future.microtask(() => ref.read(userCardsLogic.notifier).refreshOnBackground());
  //  super.onGainedVisibility();
  //}

  @override
  bool onPushNotification(PushNotification message) {
    final action = message.actionType;
    if (action == null || !action.isUserCard) return super.onPushNotification(message);
    ref.read(userCardsLogic.notifier).refreshOnBackground();
    return true;
  }

  @override
  Widget? buildPrimaryAppBar(BuildContext context) => VegaPrimaryAppBar(
        LangKeys.screenMyCardsTitle.tr(),
        actions: const [SettingsButton(), AddButton()],
      );

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(userCardsLogic);
    //if (state is UserCardsRefreshing && state.folders.list.isEmpty)
    //  return const AlignedWaitIndicator();
    //else
    if (state is UserCardsSucceed) // UserCardsRefreshing is derived from UserCardsSucceed
      return const _TabsWidget();
    else if (state is UserCardsFailed) {
      final icons = {
        errorNoData: AtomIcons.card,
        errorSynchronization: AtomIcons.refresh,
      };
      final messages = {
        errorNoData: LangKeys.errorNoUserCard,
      };
      final buttonTexts = {
        errorNoData: LangKeys.buttonAddCard,
        errorServiceUnavailable: LangKeys.buttonContinue,
      };
      final buttonActions = {
        errorNoData: universalAdd,
        errorSynchronization: _repairSynchronization,
        errorServiceUnavailable: _loadInOffline,
      };
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: StatusErrorWidget(
          userCardsLogic,
          getIcon: (error) => icons[error],
          getMessage: (error) => messages[error]?.tr(),
          getButtonText: (error) => buttonTexts[error]?.tr(),
          getButtonAction: (error, context, ref) {
            if (buttonActions[error] == null) return true;
            buttonActions[error]!.call(context, ref);
            return false;
          },
          onReload: () => ref.read(userCardsLogic.notifier).refresh(),
        ),
      );
    } else
      return const AlignedWaitIndicator();
  }

  Future<void> _repairSynchronization(BuildContext context, WidgetRef ref) async {
    await ref.read(userCardsLogic.notifier).repair();
  }

  Future<void> _loadInOffline(BuildContext context, WidgetRef ref) async {
    await ref.read(userCardsLogic.notifier).load();
  }
}

class _TabsWidget extends ConsumerStatefulWidget {
  const _TabsWidget();

  @override
  createState() => _TabsWidgetState();
}

class _TabsWidgetState extends ConsumerState<_TabsWidget> with TickerProviderStateMixin {
  TabController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final succeed = ref.watch(userCardsLogic) as UserCardsSucceed;
    final userCardsByFolder = succeed.userCardsByFolder;
    _controller?.dispose();
    _controller = TabController(
      initialIndex: succeed.selectedFolderIndex,
      length: userCardsByFolder.length,
      vsync: this,
    );
    _controller!.addListener(_onTabIndexChanged);
    final tabs = userCardsByFolder.keys.map((folder) => Tab(text: folder.name)).toList();
    final pages = userCardsByFolder.keys.map((folder) => _GridWidget(folder)).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MoleculeItemSpace(),
          MoleculeTabs(controller: _controller!, tabs: tabs),
          Expanded(child: TabBarView(physics: vegaScrollPhysic, controller: _controller, children: pages)),
        ],
        //),
      ),
    );
  }

  void _onTabIndexChanged() {
    final index = _controller!.index;
    final state = ref.read(userCardsLogic) as UserCardsSucceed;
    var folders = state.folders;
    final folder = folders.list[index];
    folders = folders.copyWith(selectedFolder: folder.folderId);
    ref.read(userUpdateLogic.notifier).update(folders: folders);
  }
}

class _GridWidget extends ConsumerStatefulWidget {
  final Folder folder;
  const _GridWidget(this.folder);

  @override
  createState() => _GridWidgetState();
}

class _GridWidgetState extends ConsumerState<_GridWidget> {
  Folder get _folder => widget.folder;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userCardsLogic) as UserCardsSucceed;
    final folders = state.userCardsByFolder;
    final userCards = folders[_folder] ?? [];
    if (state is UserCardsRefreshing && state.userCards.isEmpty) return const AlignedWaitIndicator();
    return PullToRefresh(
      onRefresh: () => ref.read(userCardsLogic.notifier).refresh(),
      child: ReorderableGridView.builder(
        primary: true,
        proxyDecorator: createMoleculeDragDecorator(Colors.transparent),
        //physics: vegaScrollPhysic,
        padding: const EdgeInsets.only(top: 4, left: 4, right: 6, bottom: 16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _folder.layout.code,
          childAspectRatio: 4 / 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
        ),
        itemBuilder: (context, index) => _buildGridItem(_folder.layout, userCards[index]),
        itemCount: userCards.length,
        onReorder: (oldIndex, newIndex) {
          final userCardId = userCards.removeAt(oldIndex);
          userCards.insert(newIndex, userCardId);

          final device = ref.read(deviceRepository);
          final user = device.get(DeviceKey.user) as User;
          final folders = user.folders;

          final index = folders.list.indexWhere((e) => e.folderId == _folder.folderId);
          folders.list[index] = _folder.copyWith(userCardIds: userCards.map((e) => e.userCardId).toList());
          ref.read(userUpdateLogic.notifier).update(folders: folders);
          ref.read(userCardsLogic.notifier).updateFolders();
        },
      ),
    );
  }

  Widget _buildGridItem(FolderLayout layout, UserCard userCard) {
    //final detailState = ref.watch(userCardLogic(userCardI.userCardId));
    //final detailSucceed = cast<UserCardLoaded>(detailState);
    //final userCard = detailSucceed?.userCard ?? userCardI;
    late Widget widget;
    if (layout == FolderLayout.twoColumns) {
      widget = MoleculusCardGrid4(
        backgroundColor: userCard.color?.toMaterial() ?? ref.scheme.paperCard,
        imageUrl: userCard.logo,
        imageCache: Caches.cardLogo,
        imagePlaceholder: SvgAsset.logo(),
        detailText: userCard.name,
        //detailIcon: "add",
      );
    } else if (layout == FolderLayout.threeColumns) {
      widget = MoleculusCardGrid3(
        backgroundColor: userCard.color?.toMaterial() ?? ref.scheme.paperCard,
        imageUrl: userCard.logo,
        imageCache: Caches.cardLogo,
        imagePlaceholder: SvgAsset.logo(),
        text: userCard.name,
      );
    } else if (layout == FolderLayout.fourColumns) {
      widget = MoleculusCardGrid2(
        backgroundColor: userCard.color?.toMaterial() ?? ref.scheme.paperCard,
        imageUrl: userCard.logo,
        imageCache: Caches.cardLogo,
        imagePlaceholder: SvgAsset.logo(),
        text: userCard.name,
      );
    } else if (layout == FolderLayout.fiveColumns) {
      widget = MoleculusCardGrid1(
        backgroundColor: userCard.color?.toMaterial() ?? ref.scheme.paperCard,
        imageUrl: userCard.logo,
        imageCache: Caches.cardLogo,
        imagePlaceholder: SvgAsset.logo(),
      );
    }
    if (!userCard.syncIsActive)
      return ImageFiltered(
        key: ValueKey(userCard.userCardId),
        imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: widget,
      );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      key: ValueKey(userCard.userCardId),
      onTap: () => context.push(DetailScreen(userCard)),
      child: widget,
    );
  }
}

// eof
