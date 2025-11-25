import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/states/providers.dart";
import "package:vega_app/strings.dart";

import "../../data_models/custom_card.dart";
import "../screen_app.dart";
import "widget_top_cards.dart";

typedef CardPickedCallback = void Function(BuildContext context, WidgetRef ref, Card card);

class PickCardScreen extends AppScreen {
  final CardPickedCallback onCardPicked;
  const PickCardScreen({required this.onCardPicked, super.key});

  @override
  createState() => _PickCardScreenState();
}

class _PickCardScreenState extends AppScreenState<PickCardScreen> {
  CardPickedCallback get _onCardPicked => widget.onCardPicked;

  @override
  void initState() {
    super.initState();
    Future(() => ref.read(topCardsLogic.notifier).load());
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        hideButton: true,
        titleWidget: MoleculeInput(
          prefixIcon: GestureDetector(
            onTap: () => context.pop(),
            child: const Padding(padding: EdgeInsets.all(6.0), child: VegaIcon(name: "arrow_left")),
          ),
          hint: LangKeys.screenCardPickerSearchHint.tr(),
          maxLines: 1,
          onChanged: (value) => ref.read(topCardsLogic.notifier).search(value),
        ),
      );

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: PullToRefresh(
        onRefresh: () => ref.watch(topCardsLogic.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const MoleculeItemSpace(),
                  MoleculeItemTitle(header: LangKeys.screenCardPickerSectionCustomCards.tr()),
                  GestureDetector(
                    onTap: () => _onCardPicked(context, ref, CustomCard.get()),
                    child: MoleculusItemCard(
                      // TODO: toto je asi zlá klasa, treba vytvoriť novú
                      card: MoleculusCardGrid4(
                        backgroundColor: ref.scheme.primary,
                        image: Container(),
                      ),
                      title: LangKeys.customLoyaltyCard.tr(),
                    ),
                  ),
                  const MoleculeItemSpace(),
                  const MoleculeItemSeparator(),
                  const MoleculeItemSpace(),
                  MoleculeItemTitle(header: LangKeys.screenCardPickerSectionTopCards.tr()),
                  const MoleculeItemSpace(),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([TopCardsWidget(onCardPicked: _onCardPicked)]),
            ),
          ],
        ),
      ),
    );
  }
}

// eof
