import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/screens/promo/screen_categories.dart";
import "package:vega_app/screens/promo/screen_coupons.dart";
import "package:vega_app/states/promo/category_coupons.dart";
import "package:vega_app/strings.dart";
import "package:vega_app/widgets/coupon.dart";

import "../../states/promo/promo.dart";
import "../../states/providers.dart";
import "../../widgets/leaflet_thumbnail.dart";
import "../../widgets/status_error.dart";
import "../profile/screen_location.dart";
import "../screen_tab.dart";
import "screen_clients.dart";
import "screen_coupon.dart";
import "screen_coupons_on_map.dart";
import "screen_leaflets.dart";

class PromoScreen extends TabScreen {
  const PromoScreen({Key? key}) : super(1, LangKeys.screenPromoTitle, key: key);

  @override
  createState() => _PromoScreenState();
}

class _PromoScreenState extends TabScreenState<PromoScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(promoLogic.notifier).load());
  }

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(promoLogic);
    if (state is PromoSucceed)
      return const _Body();
    else if (state is PromoFailed)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: StatusErrorWidget(
          promoLogic,
          onReload: () => ref.read(promoLogic.notifier).refresh(),
        ),
      );
    else
      return const AlignedWaitIndicator();
  }
}

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(promoLogic) as PromoSucceed;

    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    bool withoutLocation = user.metaLocationPoint == null;

    const fraction = 0.85;
    final newestCoupons = succeed.newestCoupons.length;
    final nearestCoupons = succeed.nearestCoupons.length;
    final leaflets = succeed.leaflets.length;

    return PullToRefresh(
      onRefresh: () => ref.read(promoLogic.notifier).refresh(),
      child: ListView(
        children: [
          //
          // Newest
          if (newestCoupons > 0) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeItemTitle(
                header: LangKeys.promoSectionNewest.tr(),
                action: LangKeys.promoSectionActionAll.tr(),
                onAction: () => context.push(
                  CategoriesScreen(
                    onCategoryPicked: (category) => context.push(CouponsScreen(category: category)),
                    onCategoryDetail: (category) async {
                      await ref.read(couponsByCategoryLogic(category).notifier).load();
                      final succeed = cast<CategoryCouponsSucceed>(ref.read(couponsByCategoryLogic(category)));
                      if (succeed != null) return succeed.coupons.length;
                      return -1;
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            PageViewEx(
              physics: vegaScrollPhysic,
              padEnds: newestCoupons == 1,
              //itemCount: newestCoupons,
              //itemBuilder: (context, index) {
              //  final coupon = succeed.newestCoupons[index];
              //  return GestureDetector(
              //    behavior: HitTestBehavior.opaque,
              //    onTap: () => context.push(CouponDetail(coupon)),
              //    child: CouponWidget(coupon),
              //  );
              //},
              controller: PageController(viewportFraction: fraction),
              children: [
                for (final coupon in succeed.newestCoupons)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push(CouponDetail(coupon)),
                    child: CouponWidget(coupon),
                  ),
              ],
            ),
          ],
          //
          // Nearest
          if (withoutLocation) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: LangKeys.promoSectionNearestDisabled.tr().text.color(ref.scheme.content).alignCenter,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeLinkButton(
                titleText: LangKeys.buttonOpenAppLocationSettings.tr(),
                onTap: () async {
                  await context.push(const LocationScreen());
                  await ref.read(promoLogic.notifier).refresh();
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (nearestCoupons > 0) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeItemTitle(
                header: LangKeys.promoSectionNearest.tr(),
                action: LangKeys.promoSectionActionMap.tr(),
                onAction: () => context.push(const CouponsOnMapScreen()),
              ),
            ),
            const SizedBox(height: 16),
            PageViewEx(
              physics: vegaScrollPhysic,
              padEnds: newestCoupons == 1,
              //itemCount: nearestCoupons,
              //itemBuilder: (context, index) {
              //  final coupon = succeed.nearestCoupons[index];
              //  return GestureDetector(
              //    behavior: HitTestBehavior.opaque,
              //    onTap: () => context.push(CouponDetail(coupon)),
              //    child: CouponWidget(coupon),
              //  );
              //},
              controller: PageController(viewportFraction: fraction),
              children: [
                for (final coupon in succeed.nearestCoupons)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => context.push(CouponDetail(coupon)),
                    child: CouponWidget(coupon),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          //
          // Leaflets
          if (leaflets > 0) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: MoleculeItemTitle(
                header: LangKeys.promoSectionLeaflets.tr(),
                action: LangKeys.promoSectionLeafletsActionShowAll.tr(),
                onAction: () => context.push(ClientsScreen(succeed)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 222,
              child: ListView.builder(
                physics: vegaScrollPhysic,
                scrollDirection: Axis.horizontal,
                itemCount: leaflets,
                itemBuilder: (context, index) => _Leaflet(succeed.leaflets[index]),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _Leaflet extends StatelessWidget {
  final LeafletOverview leaflet;

  const _Leaflet(this.leaflet);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(LeafletsScreen(leaflet)),
      child: Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: SizedBox(
          width: 96,
          child: MoleculeCardFlyer(
            title: leaflet.clientName,
            label: "leaflets".plural(leaflet.leaflets),
            thumbnail: LeafletOverviewThumbnail(leaflet),
          ),
        ),
      ),
    );
  }
}

// eof
