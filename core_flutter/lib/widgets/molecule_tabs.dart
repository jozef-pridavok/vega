import "package:buttons_tabbar/buttons_tabbar.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../extensions/widget_ref.dart";
import "../themes/theme.dart";

///
class MoleculeTabs extends ConsumerWidget implements PreferredSizeWidget {
  final List<Widget> tabs;
  final TabController controller;
  final void Function(int)? onTap;

  const MoleculeTabs({
    Key? key,
    required this.tabs,
    required this.controller,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: moleculeScreenPadding),
      child: ButtonsTabBar(
        controller: controller,
        backgroundColor: ref.scheme.primary,
        unselectedBackgroundColor: ref.scheme.paperBold,
        unselectedLabelStyle: AtomStyles.labelText.copyWith(color: ref.scheme.primary),
        labelSpacing: 0,
        labelStyle: AtomStyles.labelText.copyWith(color: ref.scheme.light),
        contentPadding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        height: 24,
        buttonMargin: const EdgeInsets.only(right: moleculeScreenPadding),
        radius: 12,
        tabs: tabs,
        onTap: onTap,
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50);
}

// eof
