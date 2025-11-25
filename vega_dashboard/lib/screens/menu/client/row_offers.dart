import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../strings.dart";
import "../../product_offers/screen_product_offers.dart";

class OffersRow extends ConsumerStatefulWidget {
  const OffersRow({super.key});

  @override
  createState() => _OffersRowState();
}

class _OffersRowState extends ConsumerState<OffersRow> {
  @override
  Widget build(BuildContext context) {
    return MoleculeItemBasic(
      icon: AtomIcons.offer,
      title: LangKeys.menuClientOffers.tr(),
      label: LangKeys.menuClientOffersDescription.tr(),
      onAction: () => context.replace(const ProductOffersScreen(showDrawer: true)),
    );
  }
}

// eof
