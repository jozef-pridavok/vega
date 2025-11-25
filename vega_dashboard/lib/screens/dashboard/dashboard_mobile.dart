import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "widget_actions.dart";

class DashboardMobile extends StatelessWidget {
  const DashboardMobile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: const ActionsWidget(),
    );
  }
}

// eof

