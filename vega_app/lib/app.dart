import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/screens/startup/screen_splash.dart";

class App extends ConsumerStatefulWidget {
  final bool showBanner;

  final AppInitCallback onInit;

  const App({super.key, required this.showBanner, required this.onInit});

  @override
  createState() => _AppState();
}

class _AppState extends ConsumerState<App> with LoggerMixin {
  @override
  void initState() {
    super.initState();
    Future(
      () => widget.onInit(
        (token) {
          ref.read(deviceRepository).put(DeviceKey.deviceToken, token);
          ref.read(remoteUserRepository).updateDeviceToken(token);
        },
        (event, message) {
          debug(() => "onMessage: $event, $message");
          if (ref.read(pushNotificationLogic.notifier).push(message)) {
            Future.delayed(hapticDelay, () => hapticLight());
            final info = message.body ?? message.title;
            if (info != null) ref.read(toastLogic.notifier).info(info);
          } else {
            debug(() => "  pushNotificationLogic: not handled");
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeLogic);
    return MaterialApp(
      theme: themeState.data,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: _flavorBanner(child: const SplashScreen()),
    );
  }

  Widget _flavorBanner({required Widget child}) => widget.showBanner
      ? Banner(
          location: BannerLocation.topStart,
          message: F().name.toUpperCase(),
          color: F().bannerColor,
          child: child,
        )
      : Container(
          child: child,
        );
}

// eof
