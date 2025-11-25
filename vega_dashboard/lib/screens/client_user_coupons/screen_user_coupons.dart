import "dart:async";

import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../extensions/select_item.dart";
import "../../states/client_user_coupons.dart";
import "../../states/coupons.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../utils/debouncer.dart";
import "../../widgets/button_refresh.dart";
import "../../widgets/molecule_picker.dart";
import "../screen_app.dart";
import "widget_user_coupons.dart";

class ClientUserCouponsScreen extends VegaScreen {
  final Coupon? selectedCoupon;

  const ClientUserCouponsScreen({super.key, this.selectedCoupon});

  @override
  createState() => _ClientUsersScreenState();
}

class _ClientUsersScreenState extends VegaScreenState<ClientUserCouponsScreen> with SingleTickerProviderStateMixin {
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.selectedCoupon != null) {
        ref.read(clientUserCouponsLogic.notifier).loadCoupon(widget.selectedCoupon!.couponId);
      } else {
        ref.read(clientUserCouponsLogic.notifier).loadPeriod(7);
      }
    });
    Future(() {
      ref.read(activeCouponsLogic.notifier).load();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _debouncer.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenClientUserCoupons.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final userCoupons = ref.watch(clientUserCouponsLogic);
    final isRefreshing = userCoupons is ClientUserCouponsRefreshing;
    return [
      VegaRefreshButton(
        onPressed: () => ref.read(clientUserCouponsLogic.notifier).refresh(),
        isRotating: isRefreshing,
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Filters(debouncer: _debouncer, selectedCoupon: widget.selectedCoupon),
          const MoleculeItemSpace(),
          Expanded(child: const UserCouponsWidget()),
        ],
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  final Coupon? selectedCoupon;
  final Debouncer debouncer;

  const _Filters({required this.debouncer, this.selectedCoupon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return isMobile
        ? ExpansionTile(
            title: LangKeys.sectionFilter.tr().label,
            children: [
              const _PeriodFilter(),
              const MoleculeItemSpace(),
              _TextFilter(debouncer: debouncer),
              const MoleculeItemSpace(),
              const _TypeFilter(),
              const MoleculeItemSpace(),
              _CouponFilter(selectedCoupon: selectedCoupon),
              const MoleculeItemSpace(),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: const _PeriodFilter()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _TextFilter(debouncer: debouncer)),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: const _TypeFilter()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _CouponFilter(selectedCoupon: selectedCoupon)),
            ],
          );
  }
}

class _PeriodFilter extends ConsumerWidget {
  const _PeriodFilter();

  static final periods = [
    SelectItem(value: "7", label: LangKeys.periodLastSevenDays.tr()),
    SelectItem(value: "30", label: LangKeys.periodLastMonth.tr()),
    SelectItem(value: "365", label: LangKeys.periodLastYear.tr()),
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientUserCouponsLogic);
    return MoleculeSingleSelect(
      title: LangKeys.labelPeriodTitle.tr(),
      hint: LangKeys.hintPeriod.tr(),
      items: periods,
      selectedItem: periods.firstWhereOrNull((element) => element.value == state.period.toString()),
      onChanged: (val) => ref.read(clientUserCouponsLogic.notifier).load(period: int.tryParse(val.value)),
    );
  }
}

class _TextFilter extends ConsumerWidget {
  final Debouncer debouncer;

  const _TextFilter({required this.debouncer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientUserCouponsLogic);
    return MoleculeInput(
      title: LangKeys.labelFilterTitle.tr(),
      hint: LangKeys.hintClientUserCouponFilter.tr(),
      initialValue: state.filter,
      onChanged: (val) => debouncer.run(() => ref.read(clientUserCouponsLogic.notifier).load(filter: val)),
    );
  }
}

class _TypeFilter extends ConsumerWidget {
  const _TypeFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MoleculeSingleSelect(
      title: LangKeys.labelCouponType.tr(),
      hint: "hint_all_coupon_types".tr(),
      items: CouponType.values.toSelectItems(),
      onChangedOrClear: (val) => ref.read(clientUserCouponsLogic.notifier).loadType(tryParseInt(val?.value)),
    );
  }
}

class _CouponFilter extends ConsumerWidget {
  final Coupon? selectedCoupon;

  const _CouponFilter({this.selectedCoupon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupons = cast<CouponsSucceed>(ref.watch(activeCouponsLogic))?.coupons ?? [];
    final userCoupons = ref.watch(clientUserCouponsLogic);
    final coupon = coupons.firstWhereOrNull((coupon) => coupon.couponId == userCoupons.couponId);
    return MoleculeSingleSelect(
      title: LangKeys.labelCoupon.tr(),
      hint: LangKeys.hintAllCoupons.tr(),
      items: coupons.toSelectItems(),
      selectedItem: selectedCoupon?.toSelectItem() ?? coupon?.toSelectItem(),
      onChangedOrClear: (val) => ref.read(clientUserCouponsLogic.notifier).loadCoupon(val?.value),
    );
  }
}

// eof
