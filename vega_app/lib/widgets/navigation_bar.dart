import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/strings.dart";

import "../screens/cards/screen_cards.dart";
import "../screens/profile/screen_profile.dart";
import "../screens/promo/screen_promo.dart";

class VegaBottomNavigationBar extends ConsumerWidget {
  final int page;
  const VegaBottomNavigationBar(this.page, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BottomNavigationBar(
      elevation: 0,
      backgroundColor: ref.scheme.paper,
      selectedItemColor: ref.scheme.primary,
      unselectedItemColor: ref.scheme.secondary,
      selectedLabelStyle: AtomStyles.labelText.copyWith(color: ref.scheme.primary),
      unselectedLabelStyle: AtomStyles.labelText.copyWith(color: ref.scheme.secondary),
      items: <BottomNavigationBarItem>[
        _buildItem(ref.scheme, page == 0, "card", LangKeys.bbCards.tr()),
        _buildItem(ref.scheme, page == 1, "tag", LangKeys.bbPromo.tr()),
        _buildItem(ref.scheme, page == 2, "user", LangKeys.bbProfile.tr()),
      ],
      currentIndex: page,
      onTap: (index) {
        if (index == page) return;
        switch (index) {
          case 0:
            context.replace(const CardsScreen(), popAll: true);
            break;
          case 1:
            context.replace(const PromoScreen(), popAll: true);
            break;
          case 2:
            context.replace(const ProfileScreen(), popAll: true);
            break;
          default:
            return;
        }
      },
    );
  }

  BottomNavigationBarItem _buildItem(MoleculeTheme theme, bool active, String icon, String title) {
    final color = active ? theme.primary : theme.secondary;
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: 24,
          height: 24,
          child: VegaIcon(name: icon, color: color),
        ),
      ),
      label: title,
    );
  }
}


// eof
