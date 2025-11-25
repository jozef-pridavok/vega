import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:core_flutter/widgets/chrome.dart";
import "package:flutter/material.dart";
import "package:focus_detector/focus_detector.dart";

import "../widgets/navigation_bar.dart";
import "screen_app.dart";

/// This class is used for the primary screen (the one with the tab) in the app.
///
abstract class TabScreen extends AppScreen {
  final int index;
  final String titleKey;
  const TabScreen(this.index, this.titleKey, {super.key});
}

abstract class TabScreenState<S extends TabScreen> extends AppScreenState<S> {
  Widget? buildPrimaryAppBar(BuildContext context) {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    listenToLogics(context);
    final scheme = ref.watch(themeLogic).scheme;
    return Chrome(
      backgroundColor: scheme.paper,
      child: Scaffold(
        bottomNavigationBar: VegaBottomNavigationBar(widget.index),
        body: FocusDetector(
          child: SafeArea(
            child: NestedScrollView(
              physics: vegaScrollPhysic,
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                buildPrimaryAppBar(context) ?? VegaPrimaryAppBar(widget.titleKey.tr()),
              ],
              body: buildBody(context),
            ),
          ),
          onVisibilityGained: () {
            if (!mounted) return;
            ref.watch(themeLogic.notifier).checkSystem();
            onGainedVisibility();
          },
          onForegroundGained: () {
            if (!mounted) return;
            ref.watch(themeLogic.notifier).checkSystem();
            onGainedVisibility();
          },
        ),
      ),
    );
  }
}

// eof
