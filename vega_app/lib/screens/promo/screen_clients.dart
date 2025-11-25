import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../../caches.dart";
import "../../states/promo/promo.dart";
import "../../states/providers.dart";
import "../../states/user/user_cards.dart";
import "../../strings.dart";
import "../screen_app.dart";
import "screen_leaflets.dart";

class ClientsScreen extends AppScreen {
  final PromoSucceed promo;
  const ClientsScreen(this.promo, {super.key});

  @override
  createState() => _ClientsScreenState();
}

class _ClientsScreenState extends AppScreenState<ClientsScreen> {
  PromoSucceed get _promo => widget.promo;

  List<LeafletOverview> clientLeaflets = [];
  List<LeafletOverview> otherLeaflets = [];

  Future<void> _sortClients(PromoSucceed succeed) async {
    final userCards = cast<UserCardsSucceed>(ref.read(userCardsLogic));
    if (userCards == null) return;
    final clientIds = userCards.userCards.map((e) => e.clientId).whereNotNull();
    // Filter leaflets by clientIds
    clientLeaflets = succeed.leaflets.where((e) => clientIds.contains(e.clientId)).toList();
    // Filter leaflets with same clients form clientLeaflets
    otherLeaflets = succeed.leaflets.where((e) => !clientIds.contains(e.clientId)).toList();
  }

  Future<void> _listenTo() async {
    ref.listen(promoLogic, (previous, next) {
      if (next is PromoSucceed) {
        _sortClients(next);
        setState(() {});
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _sortClients(_promo);
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenClientsForLeaflet.tr(),
      );

  @override
  Widget buildBody(BuildContext context) {
    final hasClientLeaflets = clientLeaflets.isNotEmpty;
    final hasOtherLeaflets = otherLeaflets.isNotEmpty;
    _listenTo();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: PullToRefresh(
        onRefresh: () => ref.read(promoLogic.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            if (hasClientLeaflets)
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const MoleculeItemSpace(),
                    MoleculeItemTitle(header: LangKeys.screenLeafletClientsSectionForYou.tr()),
                  ],
                ),
              ),
            if (hasClientLeaflets)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final leaflet = clientLeaflets[index];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.push(LeafletsScreen(leaflet)),
                      child: MoleculusItemCard(
                        card: MoleculusItemCardLogo(
                          backgroundColor: leaflet.color?.toMaterial() ?? ref.scheme.primary,
                          imageUrl: leaflet.clientLogo,
                          imageCache: Caches.clientLogo,
                        ),
                        title: leaflet.clientName,
                        label: LangKeys.leaflets.plural(leaflet.leaflets),
                        actionIcon: AtomIcons.chevronRight,
                      ),
                    );
                  },
                  childCount: clientLeaflets.length,
                ),
              ),
            if (hasClientLeaflets && hasOtherLeaflets)
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const MoleculeItemSpace(),
                    const MoleculeItemSeparator(),
                  ],
                ),
              ),
            //
            if (hasOtherLeaflets)
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const MoleculeItemSpace(),
                    MoleculeItemTitle(header: LangKeys.screenLeafletClientsSectionOther.tr()),
                  ],
                ),
              ),
            if (hasOtherLeaflets)
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final leaflet = otherLeaflets[index];
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.push(LeafletsScreen(leaflet)),
                      child: MoleculusItemCard(
                        card: MoleculusItemCardLogo(
                          backgroundColor: leaflet.color?.toMaterial() ?? ref.scheme.primary,
                          imageUrl: leaflet.clientLogo,
                          imageCache: Caches.clientLogo,
                        ),
                        title: leaflet.clientName,
                        label: LangKeys.leaflets.plural(leaflet.leaflets),
                        actionIcon: AtomIcons.chevronRight,
                      ),
                    );
                  },
                  childCount: otherLeaflets.length,
                ),
              ),
            if (hasOtherLeaflets)
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    const MoleculeItemSpace(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// eof
