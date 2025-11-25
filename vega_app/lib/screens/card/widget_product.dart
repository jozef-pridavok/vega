import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/states/order/cart.dart";

import "../../caches.dart";
import "../../states/order/item.dart";
import "../../states/providers.dart";

class ProductItemDetail extends ConsumerStatefulWidget {
  final ProductItem item;

  const ProductItemDetail({required this.item, super.key});

  @override
  createState() => _ProductItemDetailState();
}

class _ProductItemDetailState extends ConsumerState<ProductItemDetail> {
  ProductItem get _item => widget.item;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(itemLogic(_item.itemId).notifier).load());
    Future.microtask(() => ref.read(cartLogic.notifier).openItem(_item));
  }

  void _listenToCartNotifier() {
    ref.listen<CartState>(cartLogic, (previous, state) {
      if (state is CartOpened) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.languageCode;
    final photo = widget.item.photo;
    final photoBh = widget.item.photoBh;
    ref.watch(itemLogic(widget.item.itemId));
    _listenToCartNotifier();
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9, //_item.modifications.isNotEmpty ? 0.90 : 0.618,
      minChildSize: 0.618,
      maxChildSize: 0.90,
      builder: (BuildContext context, ScrollController scrollController) => Stack(
        children: [
          SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                const MoleculeItemSpace(),
                MoleculeItemTitle(header: _item.name),
                const MoleculeItemSpace(),
                if (true) ...[
                  AspectRatio(
                    aspectRatio: 1,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      child: photo != null
                          ? CachedImage(
                              url: photo,
                              config: Caches.productPhoto,
                              blurHash: photoBh,
                              errorBuilder: (context, error, stackTrace) => SvgAsset.logo(),
                            )
                          : Container(color: ref.scheme.paper),
                    ),
                  ),
                  const MoleculeItemSpace(),
                ],
                if (kDebugMode) ...[
                  MoleculeCardLoyaltyBig(
                    title: "Debug",
                    child: Column(
                      children: [
                        MoleculeTableRow(label: "Id", value: _item.itemId),
                        const SizedBox(height: 16),
                        MoleculeTableRow(label: "Photo", value: _item.photo),
                      ],
                    ),
                  ),
                  const MoleculeItemSpace(),
                ],
                MoleculeCardLoyaltyBig(
                  title: widget.item.name,
                  showSeparator: true,
                  label: widget.item.description,
                  child: MoleculeTableRow(
                    label: "TODO: Cena",
                    value: _item.currency.formatSymbol(_item.price ?? 0, lang),
                  ),
                ),
                const MoleculeItemSpace(),
                _ModificationWidget(widget.item),
                const SizedBox(height: _BuyWidget._height + (_BuyWidget._padding * 2)),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _BuyWidget(_item),
          ),
        ],
      ),
    );
  }
}

class _BuyWidget extends ConsumerWidget {
  static const double _padding = 12;
  static const double _height = 48;
  final ProductItem item;

  const _BuyWidget(this.item);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = context.languageCode;
    final cart = ref.watch(cartLogic);
    if (cart is! CartItemOpened) return const SizedBox();
    final itemState = ref.watch(itemLogic(item.itemId));
    if (itemState is! ItemSucceed) return const SizedBox();
    final modifications = itemState.getModifications(item.itemId);
    final totalPrice = cart.getPrice(item, modifications);
    return Container(
      color: ref.scheme.paper,
      child: Container(
        height: _height,
        margin: const EdgeInsets.symmetric(vertical: _padding),
        child: Row(
          children: [
            IconButton(
              onPressed: () => ref.read(cartLogic.notifier).decQty(),
              icon: const VegaIcon(name: AtomIcons.minusCircle, size: 24),
            ),
            cart.orderItem.qty.toString().h3.color(ref.scheme.content),
            IconButton(
              onPressed: () => ref.read(cartLogic.notifier).incQty(),
              icon: const VegaIcon(name: AtomIcons.plusCircle, size: 24),
            ),
            const Spacer(),
            const SizedBox(width: 12),
            totalPrice.format(locale).h3.color(ref.scheme.content),
            const SizedBox(width: 12),
            totalPrice.currency.name.label.color(ref.scheme.content50),
            const SizedBox(width: 12),
            MoleculePrimaryButton(
              onTap: () => ref.read(cartLogic.notifier).confirmItem(),
              title: VegaIcon(name: AtomIcons.shoppingCardAdd, size: 24, color: ref.scheme.light),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModificationWidget extends ConsumerWidget {
  final ProductItem item;

  const _ModificationWidget(this.item);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(itemLogic(item.itemId));
    if (state is ItemSucceed) {
      final modifications = state.getModifications(item.itemId);
      return Column(
        children: [
          for (final modification in modifications) ...[
            MoleculeCardLoyaltyBig(
              title: modification.name,
              child: Column(
                children: state
                    .getOptions(modification.modificationId)
                    .expand((option) => [_OptionWidget(item, modification, option), const SizedBox(height: 16)])
                    .toList(),
              ),
            ),
            const MoleculeItemSpace(),
          ],
        ],
      );
    } else if (state is ItemFailed)
      return state.error.message.text.color(ref.scheme.negative);
    else
      return const CenteredWaitIndicator();
  }
}

class _OptionWidget extends ConsumerWidget {
  final ProductItem item;
  final ProductItemModification modification;
  final ProductItemOption option;

  const _OptionWidget(this.item, this.modification, this.option);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = cast<CartItemOpened>(ref.watch(cartLogic));
    final name = option.unit.isNotEmpty ? "${option.unit} ${option.name}" : option.name;
    String price = item.currency.formatSymbol(option.price);
    final pricing = option.pricing.symbol;
    price = "$pricing $price";
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        final notifier = ref.read(cartLogic.notifier);
        if (modification.type == ProductItemModificationType.singleSelection)
          notifier.toggleSingleOption(modification, option);
        if (modification.type == ProductItemModificationType.multipleSelection)
          notifier.toggleMultipleOption(modification, option);
      },
      child: Row(
        children: [
          if (modification.type == ProductItemModificationType.singleSelection)
            MoleculeCheckBox(value: (cart?.countOption(option) ?? 0) > 0),
          if (modification.type == ProductItemModificationType.multipleSelection)
            MoleculeCheckBox(value: (cart?.countOption(option) ?? 0) > 0),
          const SizedBox(width: 8),
          Expanded(child: MoleculeTableRow(label: name, value: price)),
        ],
      ),
    );
  }
}

// eof
