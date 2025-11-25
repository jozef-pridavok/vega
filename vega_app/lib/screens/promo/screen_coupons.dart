import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/states/providers.dart";
import "package:vega_app/strings.dart";

import "../../states/promo/category_coupons.dart";
import "../../widgets/coupon.dart";
import "../../widgets/status_error.dart";
import "../screen_app.dart";
import "screen_coupon.dart";

class CouponsScreen extends AppScreen {
  final ClientCategory category;
  const CouponsScreen({required this.category, super.key});

  @override
  createState() => _CouponsState();
}

class _CouponsState extends AppScreenState<CouponsScreen> {
  ClientCategory get _category => widget.category;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(title: _category.localizedName);

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(couponsByCategoryLogic(_category).notifier).load());
  }

  @override
  Widget buildBody(BuildContext context) {
    final state = ref.watch(couponsByCategoryLogic(_category));
    if (state is CategoryCouponsSucceed)
      return _Coupons(_category);
    else if (state is CategoryCouponsFailed)
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: StatusErrorWidget(
          couponsByCategoryLogic(_category),
          onReload: () => ref.read(couponsByCategoryLogic(_category).notifier).reload(),
        ),
      );
    else
      return const AlignedWaitIndicator();
  }
}

class _Coupons extends ConsumerWidget {
  final ClientCategory category;

  const _Coupons(this.category);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(couponsByCategoryLogic(category)) as CategoryCouponsSucceed;
    final coupons = state.coupons;
    final hasCoupons = coupons.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: PullToRefresh(
        onRefresh: () => ref.read(couponsByCategoryLogic(category).notifier).refresh(),
        child: ListView(
          children: hasCoupons
              ? coupons
                  .map(
                    (coupon) => GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => context.push(CouponDetail(coupon)),
                      child: CouponWidget(coupon),
                    ),
                  )
                  .toList()
              : [
                  MoleculeErrorWidget(
                    icon: AtomIcons.coupon,
                    message: LangKeys.noData.tr(),
                  ),
                ],
        ),
      ),
    );
  }
}


// eof
