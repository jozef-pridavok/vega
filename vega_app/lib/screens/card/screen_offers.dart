import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/states/providers.dart";

import "../../states/order/offers.dart";
import "../../strings.dart";
import "../../widgets/status_error.dart";
import "../screen_app.dart";

class OffersScreen extends AppScreen {
  final String clientId;
  final bool cancel;
  final void Function(ProductOffer offer)? onOffer;
  const OffersScreen(this.clientId, {this.cancel = false, this.onOffer, super.key});

  @override
  createState() => _OffersState();
}

class _OffersState extends AppScreenState<OffersScreen> {
  String get _clientId => widget.clientId;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenTitleOffers.tr(),
        cancel: widget.cancel,
      );

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(offersLogic(_clientId).notifier).load());
  }

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(offersLogic(_clientId));
    if (state is OffersSucceed) {
      if (state.offers.isNotEmpty) return _Offers(_clientId, widget.onOffer);
      return MoleculeErrorWidget(
        icon: AtomIcons.shoppingCard,
        iconColor: ref.scheme.content20,
        message: LangKeys.noData.tr(),
      );
    } else if (state is OffersFailed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: StatusErrorWidget(
          offersLogic(_clientId),
          onReload: () => ref.read(offersLogic(_clientId).notifier).reload(),
        ),
      );
    } else
      return const CenteredWaitIndicator();
  }
}

class _Offers extends ConsumerWidget {
  final String clientId;
  final void Function(ProductOffer offer)? onOffer;

  const _Offers(this.clientId, this.onOffer);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(offersLogic(clientId)) as OffersSucceed;
    final offers = succeed.offers;
    //final reservations = succeed.reservations;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: PullToRefresh(
        onRefresh: () => ref.read(offersLogic(clientId).notifier).refresh(),
        child: ListView.builder(
          itemCount: offers.length,
          itemBuilder: (context, index) => _buildRow(context, ref, offers[index]),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, WidgetRef ref, ProductOffer offer) {
    return MoleculeItemBasic(
      title: offer.name,
      label: offer.description,
      icon: AtomIcons.shoppingCard,
      actionIcon: AtomIcons.itemDetail,
      onAction: () => onOffer?.call(offer),
    );
  }
}

// eof
