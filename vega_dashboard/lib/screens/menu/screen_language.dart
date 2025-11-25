import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";

import "../../states/providers.dart";
import "../../strings.dart";

class LanguageScreen extends Screen {
  const LanguageScreen({super.key});

  @override
  createState() => _LanguageState();
}

class _LanguageState extends ScreenState<LanguageScreen> {
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(title: LangKeys.screenLanguageTitle.tr());

  @override
  Widget buildBody(BuildContext context) {
    final locales = context.supportedLocales;
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: !isMobile ? ScreenFactor.tablet : double.infinity),
          child: ListView.builder(
            physics: vegaScrollPhysic,
            itemCount: locales.length,
            itemBuilder: (context, index) => _buildRow(context, locales[index]),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(BuildContext context, Locale locale) {
    return MoleculeItemBasic(
      title: "core_language_${locale.languageCode}".tr(),
      icon: "lang_${locale.languageCode}",
      applyColorFilter: false,
      actionIcon: context.locale == locale ? "check" : null,
      onAction: () async {
        await context.setLocale(locale);
        context.pop();
        await ref.read(userUpdateLogic.notifier).update(language: locale);
      },
    );
  }
}

// eof
