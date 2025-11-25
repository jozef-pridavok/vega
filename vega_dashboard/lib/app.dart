import "package:calendar_view/calendar_view.dart";
import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "screens/splash.dart";

class App extends ConsumerStatefulWidget {
  final bool showBanner;

  final AppInitCallback onInit;

  const App({super.key, required this.showBanner, required this.onInit});

  @override
  createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver, LoggerMixin {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future(() => ref.read(layoutLogic.notifier).update(context));
    Future(
      () => widget.onInit(
        (token) {
          ref.read(deviceRepository).put(DeviceKey.deviceToken, token);
          ref.read(remoteUserRepository).updateDeviceToken(token);
        },
        (event, message) {
          Future.delayed(hapticDelay, () => hapticLight());
          final info = (kDebugMode && F().isInternal ? "$event " : "") + (message.body ?? message.title ?? "");
          ref.read(toastLogic.notifier).info(info);
          ref.read(pushNotificationLogic.notifier).push(message);
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    ref.read(layoutLogic.notifier).update(context);
    //setState(() {
    //  _initScreen();
    //  //_lastSize = View.of(context).physicalSize;
    //});
  }

  @override
  Widget build(BuildContext context) {
    //final themeState = ref.watch(ThemeNotifierBase.provider);
    final themeState = ref.watch(themeLogic);
    ref.watch(layoutLogic);
    return CalendarControllerProvider(
      controller: EventController(),
      child: MaterialApp(
        theme: themeState.data,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: widget.showBanner,
        home: _flavorBanner(child: const SplashScreen()),
      ),
    );
  }

  Widget _flavorBanner({required Widget child}) => widget.showBanner
      ? Banner(
          location: BannerLocation.topStart,
          message: F().name.toUpperCase(),
          color: F().bannerColor,
          child: child,
        )
      : child;
}

// eof
