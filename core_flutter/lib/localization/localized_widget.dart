import "dart:async";

import "package:core_dart/core_logging.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";

import "asset_loader.dart";
import "localization.dart";
import "localization_controller.dart";

part "utils.dart";

class LocalizedWidget extends StatefulWidget {
  /// Place for your main page widget.
  final Widget child;

  /// List of supported locales.
  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  final List<Locale> supportedLocales;

  /// Locale when the locale is not in the list
  final Locale? fallbackLocale;

  /// Overrides device locale.
  final Locale? startLocale;

  /// Trigger for using only language code for reading localization files.
  /// @Default value false
  /// Example:
  /// ```
  /// en.json //useOnlyLangCode: true
  /// en-US.json //useOnlyLangCode: false
  /// ```
  final bool useOnlyLangCode;

  /// If a localization key is not found in the locale file, try to use the fallbackLocale file.
  /// @Default value false
  /// Example:
  /// ```
  /// useFallbackTranslations: true
  /// ```
  final bool useFallbackTranslations;

  /// Path to your folder with localization files.
  /// Example:
  /// ```dart
  /// path: 'assets/translations',
  /// path: 'assets/translations/lang.csv',
  /// ```
  final String path;

  /// Class loader for localization files.
  /// You can use custom loaders from [Easy Localization Loader](https://github.com/aissat/easy_localization_loader) or create your own class.
  /// @Default value `const RootBundleAssetLoader()`
  // ignore: prefer_typing_uninitialized_variables
  final assetLoader;

  /// Save locale in device storage.
  /// @Default value true
  final bool saveLocale;

  /// Shows a custom error widget when an error is encountered instead of the default error widget.
  /// @Default value `errorWidget = ErrorWidget()`
  final Widget Function(FlutterError? message)? errorWidget;

  LocalizedWidget({
    Key? key,
    required this.child,
    required this.supportedLocales,
    required this.path,
    this.fallbackLocale,
    this.startLocale,
    this.useOnlyLangCode = false,
    this.useFallbackTranslations = false,
    this.assetLoader = const RootBundleAssetLoader(),
    this.saveLocale = true,
    this.errorWidget,
  })  : assert(supportedLocales.isNotEmpty),
        assert(path.isNotEmpty),
        super(key: key) {
    LocalizedWidget.logger = Logger();
  }

  @override
  // ignore: library_private_types_in_public_api
  _LocalizedWidgetState createState() => _LocalizedWidgetState();

  // ignore: library_private_types_in_public_api
  static _LocalizationProvider? of(BuildContext context) => _LocalizationProvider.of(context);

  /// ensureInitialized needs to be called in main
  /// so that savedLocale is loaded and used from the
  /// start.
  static Future<void> ensureInitialized() async => await LocalizationController.initEasyLocation();

  /// Customizable logger
  static late Logger logger;
}

class _LocalizedWidgetState extends State<LocalizedWidget> {
  _LocalizationDelegate? delegate;
  LocalizationController? localizationController;
  FlutterError? translationsLoadError;

  @override
  void initState() {
    LocalizedWidget.logger.debug(() => "Init state");
    localizationController = LocalizationController(
      saveLocale: widget.saveLocale,
      fallbackLocale: widget.fallbackLocale,
      supportedLocales: widget.supportedLocales,
      startLocale: widget.startLocale,
      assetLoader: widget.assetLoader,
      useOnlyLangCode: widget.useOnlyLangCode,
      useFallbackTranslations: widget.useFallbackTranslations,
      path: widget.path,
      onLoadError: (FlutterError e) {
        setState(() {
          translationsLoadError = e;
        });
      },
    );
    // causes localization to rebuild with new language
    localizationController!.addListener(() {
      if (mounted) setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    localizationController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (translationsLoadError != null) {
      return widget.errorWidget != null
          ? widget.errorWidget!(translationsLoadError)
          : ErrorWidget(translationsLoadError!);
    }
    return _LocalizationProvider(
      widget,
      localizationController!,
      delegate: _LocalizationDelegate(
        localizationController: localizationController,
        supportedLocales: widget.supportedLocales,
      ),
    );
  }
}

class _LocalizationProvider extends InheritedWidget {
  final LocalizedWidget parent;
  final LocalizationController _localeState;
  final Locale? currentLocale;
  final _LocalizationDelegate delegate;

  List<LocalizationsDelegate> get delegates => [
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  /// Get List of supported locales
  List<Locale> get supportedLocales => parent.supportedLocales;

  // _EasyLocalizationDelegate get delegate => parent.delegate;

  _LocalizationProvider(this.parent, this._localeState, {Key? key, required this.delegate})
      : currentLocale = _localeState.locale,
        super(key: key, child: parent.child);

  /// Get current locale
  Locale get locale => _localeState.locale;

  /// Get fallback locale
  Locale? get fallbackLocale => parent.fallbackLocale;
  // Locale get startLocale => parent.startLocale;

  /// Change app locale
  Future<void> setLocale(Locale locale) async {
    // Check old locale
    if (locale != _localeState.locale) {
      assert(parent.supportedLocales.contains(locale));
      await _localeState.setLocale(locale);
    }
  }

  /// Clears a saved locale from device storage
  // Future<void> deleteSaveLocale() async {
  //   await _localeState.deleteSaveLocale();
  // }

  /// Getting device locale from platform
  Locale get deviceLocale => _localeState.deviceLocale;

  /// Reset locale to platform locale
  Future<void> resetLocale() => _localeState.resetLocale();

  @override
  bool updateShouldNotify(_LocalizationProvider oldWidget) {
    return oldWidget.currentLocale != locale;
  }

  static _LocalizationProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_LocalizationProvider>();
}

class _LocalizationDelegate extends LocalizationsDelegate<Localization> {
  final List<Locale>? supportedLocales;
  final LocalizationController? localizationController;

  ///  * use only the lang code to generate i18n file path like en.json or ar.json
  // final bool useOnlyLangCode;

  _LocalizationDelegate({this.localizationController, this.supportedLocales}) {
    LocalizedWidget.logger.debug(() => "Init Localization Delegate");
  }

  @override
  bool isSupported(Locale locale) => supportedLocales!.contains(locale);

  @override
  Future<Localization> load(Locale value) async {
    LocalizedWidget.logger.debug(() => "Load Localization Delegate");
    if (localizationController!.translations == null) {
      await localizationController!.loadTranslations();
    }

    Localization.load(value,
        translations: localizationController!.translations,
        fallbackTranslations: localizationController!.fallbackTranslations);
    return Future.value(Localization.instance);
  }

  @override
  bool shouldReload(LocalizationsDelegate<Localization> old) => false;
}

// eof
