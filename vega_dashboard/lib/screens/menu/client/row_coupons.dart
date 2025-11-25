import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../strings.dart";
import "../../coupons/screen_list.dart";

class CouponsRow extends ConsumerStatefulWidget {
  const CouponsRow({super.key});

  @override
  createState() => _CouponsRowState();
}

class _CouponsRowState extends ConsumerState<CouponsRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: AtomIcons.coupon,
      title: LangKeys.menuClientCoupons.tr(),
      label: LangKeys.menuClientCouponsDescription.tr(),
      onAction: () => context.replace(const CouponsScreen(showDrawer: true)),
    );
  }
}

// eof
