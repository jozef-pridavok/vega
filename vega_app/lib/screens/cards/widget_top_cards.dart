import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../caches.dart";
import "../../states/card/top_cards.dart";
import "../../states/providers.dart";
import "screen_pick_card.dart";

class TopCardsWidget extends ConsumerWidget {
  final CardPickedCallback? onCardPicked;

  const TopCardsWidget({this.onCardPicked, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //final cardsWidget = _CardsWidget(onCardPicked: onCardPicked);
    /*
    final stateWidgetMap = <Type, Widget>{
      TopCardsFailed: const _ErrorWidget(),
      TopCardsSucceed: cardsWidget,
      TopCardsRefreshing: cardsWidget,
    };
    */
    final state = ref.watch(topCardsLogic);
    if (state is TopCardsSucceed) {
      return _CardsWidget(onCardPicked: onCardPicked);
    } else if (state is TopCardsRefreshing) {
      return _CardsWidget(onCardPicked: onCardPicked);
    } else if (state is TopCardsFailed) {
      return MoleculeErrorWidget(message: state.error.toString());
    }
    return const AlignedWaitIndicator();
    //return stateWidgetMap[topCardsState.runtimeType] ?? const AlignedWaitIndicator();
  }
}

/*
@Deprecated("Use [StatusErrorWidget] instead")
class _ErrorWidget extends ConsumerWidget {
  const _ErrorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorState = ref.watch(topCardsLogic) as TopCardsFailed;
    return StatusWidget(image: "error", message: errorState.error.toString());
  }
}
*/

class _CardsWidget extends ConsumerWidget {
  final CardPickedCallback? onCardPicked;

  const _CardsWidget({this.onCardPicked});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = cast<TopCardsSucceed>(ref.watch(topCardsLogic));
    if (state is! TopCardsSucceed) return const SizedBox.shrink();
    final cards = state.cards;
    return ListView.builder(
      //physics: vegaScrollPhysic,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, i) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onCardPicked?.call(context, ref, cards[i]),
        child: MoleculusItemCard(
          card: MoleculusCardGrid4(
            backgroundColor: cards[i].color.toMaterial(),
            imageUrl: cards[i].logo,
            imageCache: Caches.cardLogo,
          ),
          title: cards[i].name,
        ),
      ),
      itemCount: cards.length,
      shrinkWrap: true,
    );
  }
}

// eof
