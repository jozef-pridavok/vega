import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/states/order/offer.dart";
import "package:vega_app/states/providers.dart";

import "../../caches.dart";
import "../../states/order/cart.dart";
import "../../strings.dart";
import "../../widgets/status_error.dart";
import "../../widgets/user_card_logo.dart";
import "../screen_app.dart";
import "screen_order_confirm.dart";
import "widget_product.dart";

class OfferScreen extends AppScreen {
  final UserCard userCard;
  final ProductOffer offer;
  const OfferScreen(this.userCard, this.offer, {super.key});

  @override
  createState() => _OfferState();
}

class _OfferState extends AppScreenState<OfferScreen> {
  UserCard get _userCard => widget.userCard;
  //String get _clientId => widget.offer.clientId; // _userCard.clientId!;
  String get _offerId => widget.offer.offerId;

  @override
  bool onPushNotification(PushNotification message) {
    /*
    final clientId = _userCard.clientId;
    if (clientId == null) return false;
    final action = message.actionType;
    final reservationChanged = action == ActionType.reservationAccepted || action == ActionType.reservationClosed;
    if (reservationChanged && message["clientId"] == clientId) {
      hapticHeavy();
      ref.read(ordersLogic(_clientId).notifier).refresh();
      return true;
    }
    */
    return super.onPushNotification(message);
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: _userCard.name,
        cancel: true,
        titleWidget: SizedBox(
          height: kToolbarHeight,
          child: Padding(padding: const EdgeInsets.all(8.0), child: UserCardLogo(_userCard, shadow: false)),
        ),
        /*
        actions: [
          IconButton(
            icon: const VegaIcon(name: AtomIcons.add),
            onPressed: () {
              context.slideUp(OffersScreen(
                _clientId,
                cancel: true,
                onOffer: (offer) {
                  context.pop();
                  //context.push(EditOrderScreen(userCard: widget.userCard, offerId: offer.offerId));
                },
              ));
            },
          ),
        ],
        */
      );

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(offerLogic(_offerId).notifier).load());
  }

  bool _isModal = false;

  void _listenToCartLogic() {
    ref.listen<CartState>(cartLogic, (previous, state) async {
      //if (state is CartItemOpened && (previous is! CartItemOpened || previous.productItem != state.productItem)) {
      //if (previous is! CartItemOpened && state is CartItemOpened) {
      if (state is CartItemOpened) {
        if (_isModal) return;
        _isModal = true;
        await modalBottomSheet(context, ProductItemDetail(item: state.productItem));
        _isModal = false;
      }
      //}
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToCartLogic();
    final offer = ref.watch(offerLogic(_offerId));
    if (offer is OfferReady)
      return _TabsWidget(_userCard.userCardId, _offerId);
    else if (offer is OfferLoadingFailed)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child:
            StatusErrorWidget(offerLogic(_offerId), onReload: () => ref.read(offerLogic(_offerId).notifier).reload()),
      );
    else
      return const AlignedWaitIndicator();
  }
}

class _TabsWidget extends ConsumerStatefulWidget {
  final String userCardId;
  final String offerId;
  const _TabsWidget(this.userCardId, this.offerId);

  @override
  createState() => _TabsWidgetState();
}

class _TabsWidgetState extends ConsumerState<_TabsWidget> with SingleTickerProviderStateMixin {
  String get _userCardId => widget.userCardId;
  String get _offerId => widget.offerId;
  TabController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.read(offerLogic(_offerId)) as OfferReady;
    final sections = state.offer.sections;

    if (sections == null) return _Items(_userCardId, _offerId, null);

    _controller ??= TabController(
      initialIndex: 0, //state.selectedFolderIndex,
      length: sections.length,
      vsync: this,
    );

    final tabs = <Tab>[];
    final pages = <Widget>[];

    for (final section in sections) {
      tabs.add(Tab(text: section.name));
      pages.add(_Items(_userCardId, _offerId, section.sectionId)); // folder
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MoleculeItemSpace(),
        Padding(
          padding: const EdgeInsets.only(left: moleculeScreenPadding),
          child: MoleculeTabs(controller: _controller!, tabs: tabs),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
            child: TabBarView(physics: vegaScrollPhysic, controller: _controller, children: pages),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(moleculeScreenPadding),
          child: _OrderWidget(),
        ),
      ],
      //),
    );
  }
}

class _Items extends ConsumerWidget {
  final String userCardId;
  final String offerId;
  final String? sectionId;

  const _Items(this.userCardId, this.offerId, this.sectionId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.read(offerLogic(offerId)) as OfferReady;
    final items = state.getItems(sectionId);

    if (items == null || items.isEmpty)
      return MoleculeErrorWidget(
        icon: AtomIcons.shoppingCard,
        iconColor: ref.scheme.content20,
        message: LangKeys.noData.tr(),
      );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: PullToRefresh(
        onRefresh: () => ref.read(offerLogic(offerId).notifier).refresh(),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => _buildRow(
            context,
            ref,
            items[index],
            index == items.length - 1,
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, WidgetRef ref, ProductItem item, bool isLast) {
    final currency = item.currency;
    final price = item.price ?? 0;
    final formattedPrice = currency.formatSymbol(price, context.languageCode);
    final photo = item.photo;
    final photoBh = item.photoBh;
    //ref.read(itemLogic(item.itemId).notifier).load();
    return Column(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!ref.read(cartLogic.notifier).canOpenClient(item.clientId)) {
              ref.read(toastLogic.notifier).warning("TODO: Cart is not empty!");
              // TODO: question: do you want to cancel the current order?
              ref.read(cartLogic.notifier).openClient(item.clientId, offerId, userCardId);
              return;
            }
            ref.read(cartLogic.notifier).openItem(item);
          },
          child: MoleculeProduct(
            title: item.name,
            content: item.description,
            value: formattedPrice,
            image: photo != null ? CachedImage(config: Caches.productPhoto, url: photo, blurHash: photoBh) : null,
          ),
        ),
        if (!isLast) ...[
          const MoleculeItemSpace(),
          const MoleculeItemSeparator(),
          const MoleculeItemSpace(),
        ],
      ],
    );
  }
}

class _OrderWidget extends ConsumerWidget {
  const _OrderWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartLogic);
    final order = cart.order;
    final items = order.items;
    if (items == null || items.isEmpty) return const SizedBox();
    final locale = context.languageCode;
    final price = order.totalPrice;
    final currency = order.totalPriceCurrency;
    final formattedPrice = currency?.formatSymbol(price ?? 0, locale) ?? "";
    return MoleculePrimaryButton(
      height: 56,
      title: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            VegaIcon(name: AtomIcons.shoppingCard, color: ref.scheme.light),
            const SizedBox(width: 16),
            LangKeys.orderItemCount.plural(items.length).h4.color(ref.scheme.light),
            const Spacer(),
            const SizedBox(width: 16),
            formattedPrice.label.color(ref.scheme.light),
          ],
        ),
      ),
      onTap: () {
        // if (!ref.read(cartLogic.notifier).open(clientId)) {
        //   context.toastWarning("TODO: Cart is not empty!");
        //   return;
        // }
        context.push(const OrderConfirmScreen());
      },
    );
  }
}


// eof
           
