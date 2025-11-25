import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:flutter/material.dart";

import "widget_actions.dart";
import "statistics/widget_statistics.dart";

class DashboardDesktop extends StatelessWidget {
  const DashboardDesktop({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: ScreenFactor.tablet - 40,
          child: Padding(
            padding: const EdgeInsets.only(
              left: moleculeScreenPadding,
              top: moleculeScreenPadding,
              bottom: moleculeScreenPadding,
              right: moleculeScreenPadding / 2,
            ),
            child: const ActionsWidget(),
          ),
        ),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(
              right: moleculeScreenPadding,
              top: moleculeScreenPadding,
              bottom: moleculeScreenPadding,
              left: moleculeScreenPadding / 2,
            ),
            child: const StatisticsGridWidget(),
          ),
        ),
      ],
    );
  }
}

// eof
