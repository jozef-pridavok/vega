import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:core_flutter/states/provider.dart";

/// This class is used to create a screen in the app.
abstract class AppScreen extends Screen {
  const AppScreen({super.useSafeArea, super.key});
}

abstract class AppScreenState<S extends AppScreen> extends ScreenState<S> {
  void toastInfo(String message) => ref.read(toastLogic.notifier).info(message);
  void toastWarning(String message) => ref.read(toastLogic.notifier).warning(message);
  void toastError(String message) => ref.read(toastLogic.notifier).error(message);

  void toastCoreError(CoreError error) => ref.read(toastLogic.notifier).error(error.toString());

  void delayedStateRefresh(Function() action) => mounted ? Future.delayed(stateRefreshDuration, action) : null;
}

// eof
