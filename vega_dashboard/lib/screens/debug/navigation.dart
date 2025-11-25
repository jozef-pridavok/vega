import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../screen_app.dart";

class NavScreenA extends VegaScreen {
  const NavScreenA({super.showDrawer, super.key});

  @override
  createState() => _NavScreenAState();
}

class _NavScreenAState extends VegaScreenState<NavScreenA> {
  @override
  String? getTitle() => "Screen A";

  @override
  List<Widget>? buildAppBarActions() {
    return [
      MoleculePrimaryButton(
        titleText: "Screen B",
        onTap: () => context.push(const NavScreenB()),
      ),
      const SizedBox(width: 8),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: "Screen A".text,
    );
  }
}

class NavScreenB extends VegaScreen {
  const NavScreenB({super.showDrawer, super.key});

  @override
  createState() => _NavScreenBState();
}

class _NavScreenBState extends VegaScreenState<NavScreenB> {
  @override
  String? getTitle() => "Screen B";

  @override
  List<Widget>? buildAppBarActions() {
    return [
      MoleculePrimaryButton(
        titleText: "Screen A",
        onTap: () => context.push(const NavScreenA()),
      ),
      const SizedBox(width: 8),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: "Screen B".text,
    );
  }
}

// eof
