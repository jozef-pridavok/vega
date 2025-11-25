import "package:core_dart/core_api_client.dart";
import "package:core_dart/core_errors.dart";
import "package:flutter/material.dart";

import "../core_screens.dart";
import "../localization/localized_widget.dart";
import "../themes/theme.dart";
import "../transitions/no_animation.dart";
import "../transitions/slide_up.dart";
import "../widgets/instant_indicator.dart";

// https://github.com/pedromassango/build_context/blob/master/lib/src/build_context_impl.dart

const kDefaultIndicatorDuration = Duration(milliseconds: 4000);
const kShortIndicatorDuration = Duration(milliseconds: 800);

extension VegaExtensions on BuildContext {
  //ThemeData get theme => Theme.of(this);
  String get languageCode => LocalizedWidget.of(this)!.locale.languageCode;

  NavigatorState get navigator => Navigator.of(this);

  Future<T?> push<T extends Object?>(Widget widget) => navigator.push<T>(MaterialPageRoute(builder: (_) => widget));

  void replaceInDrawer<T extends Object?>(/*LayoutState state,*/ Widget widget) {
    //if (state.isMobile) {
    //  Navigator.of(this).push<T>(MaterialPageRoute(builder: (_) => widget));
    //}
    pop();
    showGeneralDialog(
      context: this,
      pageBuilder: (_, __, ___) {
        return Align(
          alignment: Alignment.bottomLeft,
          child: SizedBox(
            width: ScreenFactor.tablet / 2, // atomDesktopDrawerWidth,
            child: widget,
          ),
        );
      },
    );
  }

  Future<T?> slideUp<T extends Object?>(Widget widget) => navigator.push<T>(SlideUpPageRoute(widget));

  //Future<T?> slideUpX<T extends Object?>(Widget widget) =>
  //    Navigator.of(this).push<T>(SlideUpPageRoute(widget));

  void pop<T extends Object?>([T? result]) {
    if (navigator.canPop()) navigator.pop<T>(result);
  }

  void popAll() {
    if (navigator.canPop()) navigator.popUntil((route) => route.isFirst);
  }

  Future<void> replace(Widget widget, {bool popAll = false}) async {
    if (popAll) this.popAll();
    await navigator.pushReplacement(NoAnimationPageRouteTransition(widget));
  }

  /// Just shortcut. Pop the current route and push a new one in its place.
  Future<T?> popPush<T extends Object?>(Widget widget) {
    pop();
    return navigator.push<T>(MaterialPageRoute(builder: (_) => widget));
  }

  void toast(
    String title, {
    Color? backgroundColor,
    Position position = Position.top,
    Duration duration = kDefaultIndicatorDuration,
    bool haptic = true,
    Widget? child,
  }) =>
      Instant(this).createIndicator(
        title: title,
        backgroundColor: backgroundColor,
        position: position,
        duration: duration,
        haptic: haptic,
        child: child,
      );

  void toastInfo(
    String title, {
    MoleculeTheme? scheme,
    Position position = Position.top,
    Duration duration = kDefaultIndicatorDuration,
    bool haptic = true,
    Widget? child,
  }) =>
      Instant(this).createIndicator(
        title: title,
        backgroundColor: scheme?.positive ?? Colors.orange.shade800,
        position: position,
        duration: duration,
        haptic: haptic,
        child: child,
      );

  void toastWarning(
    String title, {
    MoleculeTheme? scheme,
    Position position = Position.top,
    Duration duration = kDefaultIndicatorDuration,
    bool haptic = true,
    Widget? child,
  }) =>
      Instant(this).createIndicator(
        title: title,
        backgroundColor: scheme?.accent ?? Colors.orange.shade800,
        position: position,
        duration: duration,
        haptic: haptic,
        child: child,
      );

  void toastError(
    String title, {
    MoleculeTheme? scheme,
    Position position = Position.top,
    Duration duration = kDefaultIndicatorDuration,
    bool haptic = true,
    Widget? child,
  }) =>
      Instant(this).createIndicator(
        title: title,
        backgroundColor: scheme?.negative ?? Colors.red.shade800,
        position: position,
        duration: duration,
        haptic: haptic,
        child: child,
      );

  void toastCoreError(CoreError error) {
    final apiResponse = error.innerException as ApiResponse?;
    String message = error.toString();
    if (apiResponse != null) {
      message += "\n${apiResponse.json?["message"] ?? apiResponse.message ?? apiResponse.toString()}";
    } else if (error.innerException != null) {
      message += "\n${error.innerException.toString()}";
    }
    toastError(message);
  }
}

extension EasyLocalizationExtension on BuildContext {
  /// Get current locale
  Locale get locale => LocalizedWidget.of(this)!.locale;

  /// Change app locale
  Future<void> setLocale(Locale val) async => LocalizedWidget.of(this)!.setLocale(val);

  /// Old Change app locale
  @Deprecated("This is the func used in the old version of EasyLocalization. The modern func is `setLocale(val)` . "
      "This feature was deprecated after v3.0.0")
  set locale(Locale val) => LocalizedWidget.of(this)!.setLocale(val);

  /// Get List of supported locales.
  List<Locale> get supportedLocales => LocalizedWidget.of(this)!.supportedLocales;

  /// Get fallback locale
  Locale? get fallbackLocale => LocalizedWidget.of(this)!.fallbackLocale;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  /// return
  /// ```dart
  ///   delegates = [
  ///     delegate
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///     GlobalCupertinoLocalizations.delegate
  ///   ],
  /// ```
  List<LocalizationsDelegate> get localizationDelegates => LocalizedWidget.of(this)!.delegates;

  /// Clears a saved locale from device storage
  //Future<void> deleteSaveLocale() => EasyLocalization.of(this)!.deleteSaveLocale();

  /// Getting device locale from platform
  Locale get deviceLocale => LocalizedWidget.of(this)!.deviceLocale;

  /// Reset locale to platform locale
  Future<void> resetLocale() => LocalizedWidget.of(this)!.resetLocale();
}

// eof
