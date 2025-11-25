import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;

import "../../repositories/product_offer.dart";
import "../../states/product_offer_editor.dart";
import "../../states/product_offer_patch.dart";
import "../../states/product_offers.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "../dialog.dart";
import "../screen_app.dart";
import "screen_product_offer_edit.dart";
import "widget_product_offers.dart";

class ProductOffersScreen extends VegaScreen {
  const ProductOffersScreen({super.showDrawer, super.key});

  @override
  createState() => _ProductOffersState();
}

class _ProductOffersState extends VegaScreenState<ProductOffersScreen> with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: 0, length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenProductOffersTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final activeProductOffers = ref.watch(activeProductOffersLogic);
    final archivedProductOffers = ref.watch(archivedProductOffersLogic);
    final isRefreshing = [activeProductOffers, archivedProductOffers].any((state) => state is ProductOffersRefreshing);
    return [
      IconButton(
        icon: const VegaIcon(name: AtomIcons.add),
        onPressed: () {
          final client = ref.read(deviceRepository).get(DeviceKey.client) as Client;
          final productOffer = ProductOffer(
            offerId: uuid(),
            name: "",
            loyaltyMode: LoyaltyMode.none,
            type: ProductOfferType.regular,
            clientId: client.clientId,
            date: IntDate.now(),
            rank: 0,
          );
          ref.read(productOfferEditorLogic.notifier).edit(productOffer, isNew: true);
          context.push(const EditProductOffer());
        },
      ),
      VegaRefreshButton(
        onPressed: () {
          ref.read(activeProductOffersLogic.notifier).refresh();
          ref.read(archivedProductOffersLogic.notifier).refresh();
        },
        isRotating: isRefreshing,
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogic();
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MoleculeTabs(controller: _controller, tabs: [
            Tab(text: LangKeys.tabActive.tr()),
            Tab(text: LangKeys.tabArchived.tr()),
          ]),
          Expanded(
            child: TabBarView(
              physics: vegaScrollPhysic,
              controller: _controller,
              children: [
                ProductOffersWidget(ProductOfferRepositoryFilter.active),
                ProductOffersWidget(ProductOfferRepositoryFilter.archived),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _listenToLogic() {
    ref.listen<ProductOfferEditorState>(productOfferEditorLogic, (previous, next) async {
      if (previous is ProductOfferEditorSaving && next is ProductOfferEditorSucceed) {
        await ref.read(activeProductOffersLogic.notifier).refresh();
        await ref.read(archivedProductOffersLogic.notifier).refresh();
      }
    });
    //
    ref.listen<ProductOfferPatchState>(productOfferPatchLogic, (previous, next) async {
      bool failed = next is ProductOfferPatchFailed;
      if (next.phase.isSuccessful || failed) {
        closeWaitDialog(context, ref);
        await ref.read(productOfferPatchLogic.notifier).reset();
        await ref.read(activeProductOffersLogic.notifier).refresh();
        await ref.read(archivedProductOffersLogic.notifier).refresh();
      }
      if (failed) {
        toastError(next.error.toString());
      }
    });
  }
}

// eof
