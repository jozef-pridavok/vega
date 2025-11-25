import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:vega_app/strings.dart";

import "../../states/providers.dart";
import "../screen_app.dart";
import "screen_profile.dart";

class LanguageScreen extends AppScreen {
  final bool cancel;
  const LanguageScreen({super.key, this.cancel = false});

  @override
  createState() => _LanguageState();
}

class _LanguageState extends AppScreenState<LanguageScreen> {
  String selectedLanguage = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final locales = context.supportedLocales;
      final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
      final userLanguage = user.language;
      setState(() {
        selectedLanguage = locales.firstWhereOrNull((locale) => locale.languageCode == userLanguage)?.languageCode ??
            locales.first.languageCode;
      });
    });
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenLanguageTitle.tr(),
        cancel: widget.cancel,
      );

  @override
  Widget buildBody(BuildContext context) {
    final locales = context.supportedLocales;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: ListView.builder(
        physics: vegaScrollPhysic,
        itemCount: locales.length,
        itemBuilder: (context, index) => _buildRow(context, locales[index]),
      ),
    );
  }

  Widget _buildRow(BuildContext context, Locale locale) {
    return MoleculeItemBasic(
      title: "core_language_${locale.languageCode}".tr(),
      icon: "lang_${locale.languageCode}",
      applyColorFilter: false,
      actionIcon: selectedLanguage == locale.languageCode ? "check" : null,
      onAction: () async {
        ref.read(toastLogic.notifier).info(LangKeys.toastRestartUi.tr());
        setState(() => selectedLanguage = locale.languageCode);
        await context.setLocale(locale);
        await ref.read(userUpdateLogic.notifier).update(language: locale);
        if (widget.cancel)
          Future.delayed(kThemeAnimationDuration, () => context.pop());
        else
          Future.delayed(kThemeAnimationDuration, () => context.replace(const ProfileScreen()));
      },
    );
  }
}

// eof
