import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";

import "../../strings.dart";
import "../system/screen_logs.dart";

class SystemScreen extends Screen {
  const SystemScreen({super.key});

  @override
  createState() => _SystemState();
}

class _SystemState extends ScreenState {
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(title: LangKeys.screenSystemTitle.tr());

  @override
  Widget buildBody(BuildContext context) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: !isMobile ? ScreenFactor.tablet : double.infinity),
          child: ListView(physics: vegaScrollPhysic, children: [
            MoleculeItemBasic(
              title: LangKeys.menuLogs.tr(),
              label: LangKeys.menuLogsDescription.tr(),
              icon: AtomIcons.list,
              onAction: () async {
                context.replace(const LogsScreen());
                //context.pop();
              },
            ),
          ]),
        ),
      ),
    );
  }
}

// eof
