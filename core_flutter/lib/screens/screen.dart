import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:focus_detector/focus_detector.dart";

import "../states/provider.dart";
import "../states/toast.dart";
import "../widgets/chrome.dart";

abstract class ScreenBase extends ConsumerStatefulWidget {
  const ScreenBase({Key? key}) : super(key: key);
}

abstract class ScreenBaseState<S extends ScreenBase> extends ConsumerState<S> {}

abstract class Screen extends ScreenBase {
  final bool useSafeArea;
  const Screen({this.useSafeArea = true, Key? key}) : super(key: key);
}

abstract class ScreenState<S extends Screen> extends ScreenBaseState<S> {
  @protected
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  void _listenToToastLogic(BuildContext context) {
    ref.listen(toastLogic, (previous, next) {
      if (!mounted) return;
      final toast = ref.read(toastLogic.notifier).pop();
      if (toast == null) return;
      Widget? child;
      switch (toast.type) {
        case ToastType.info:
          context.toastInfo(toast.message, scheme: ref.scheme, child: child);
          break;
        case ToastType.warning:
          context.toastWarning(toast.message, scheme: ref.scheme, child: child);
          break;
        case ToastType.error:
          context.toastError(toast.message, scheme: ref.scheme, child: child);
          break;
        case ToastType.errorCore:
          context.toastCoreError(toast.error!);
          break;
      }
    });
  }

  void _listenToPushNotificationLogic(BuildContext context) {
    ref.listen(pushNotificationLogic, (previous, next) {
      final message = ref.read(pushNotificationLogic.notifier).peek();
      if (message == null) return;
      if (onPushNotification(message)) {
        ref.read(pushNotificationLogic.notifier).pop();
      }
    });
  }

  bool onPushNotification(PushNotification message) => false;

  @protected
  void listenToLogics(BuildContext context) {
    _listenToToastLogic(context);
    _listenToPushNotificationLogic(context);
  }

  @protected
  @override
  Widget build(BuildContext context) {
    listenToLogics(context);
    final scheme = ref.watch(themeLogic).scheme;
    return Chrome(
      backgroundColor: scheme.paper,
      child: Scaffold(
        key: scaffoldKey,
        appBar: buildAppBar(context),
        drawer: buildDrawer(context),
        body: FocusDetector(
          child: widget.useSafeArea ? SafeArea(child: buildBody(context)) : buildBody(context),
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
        //floatingActionButton: buildFloatingActionButton(context),
        //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget buildBody(BuildContext context);

  Widget? buildDrawer(BuildContext context) => null;

  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  //Widget? buildFloatingActionButton(BuildContext context) => null;

  void onGainedVisibility() {}
}

// eof
