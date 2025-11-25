import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/states/providers.dart";
import "package:vega_app/strings.dart";
import "package:vega_app/widgets/leaflet_thumbnail.dart";

import "../../states/leaflet/leaflet_detail.dart";
import "../../widgets/status_error.dart";
import "../screen_app.dart";
import "screen_leaflet.dart";

class LeafletsScreen extends AppScreen {
  final LeafletOverview leafletOverview;
  const LeafletsScreen(this.leafletOverview, {super.key});

  @override
  createState() => _CouponState();
}

class _CouponState extends AppScreenState<LeafletsScreen> {
  String get _clientId => widget.leafletOverview.clientId;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(title: widget.leafletOverview.clientName);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(leafletDetailLogic(_clientId).notifier).load());
  }

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(leafletDetailLogic(_clientId));
    if (state is LeafletDetailSucceed)
      return _Leaflets(_clientId);
    else if (state is LeafletDetailFailed)
      return StatusErrorWidget(
        leafletDetailLogic(_clientId),
        onReload: () => ref.read(leafletDetailLogic(_clientId).notifier).reload(),
      );
    else
      return const AlignedWaitIndicator();
  }
}

class _Leaflets extends ConsumerWidget {
  final String clientId;

  const _Leaflets(this.clientId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(leafletDetailLogic(clientId)) as LeafletDetailSucceed;
    final count = state.leaflets.length;
    return PullToRefresh(
      onRefresh: () => ref.read(leafletDetailLogic(clientId).notifier).refresh(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: count == 0
            ? MoleculeErrorWidget(
                primaryButton: LangKeys.buttonTryAgain.tr(),
                onPrimaryAction: () => ref.read(leafletDetailLogic(clientId).notifier).reload(),
              )
            : GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.66,
                mainAxisSpacing: 24,
                crossAxisSpacing: moleculeScreenPadding,
                children: state.leaflets.map((leaflet) => _Leaflet(leaflet)).toList(),
              ),
      ),
    );
  }
}

class _Leaflet extends StatelessWidget {
  final LeafletDetail leaflet;

  const _Leaflet(this.leaflet);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.slideUp(ClientLeafletScreen(leaflet)),
      child: MoleculeCardFlyer(
        title: leaflet.name,
        label: LangKeys.validTo.tr(args: [formatDay(context.languageCode, leaflet.validTo.toDate()) ?? ""]),
        thumbnail: LeafletDetailThumbnail(leaflet),
      ),
    );
  }
}

// eof
