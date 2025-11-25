import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:flutter/material.dart";
import "package:rate_my_app/rate_my_app.dart";

import "../../strings.dart";
import "../screen_app.dart";

class AboutScreen extends AppScreen {
  const AboutScreen({super.key});

  @override
  createState() => _AboutState();
}

class _AboutState extends AppScreenState<AboutScreen> {
  static const infoEmail = "info@vega.com";

  final _rateMyApp = RateMyApp();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _rateMyApp.init();
      if (mounted && _rateMyApp.shouldOpenDialog) {
        await _rateMyApp.showRateDialog(context);
      }
    });
    super.initState();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) =>
      VegaAppBar(title: LangKeys.screenAboutTitle.tr());

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MoleculeItemSpace(),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: const SvgAsset(
                  "assets/icons/ic_app.svg",
                  fit: BoxFit.contain,
                  width: 96,
                  height: 96,
                ),
              ),
            ),
            const MoleculeItemSpace(),
            const MoleculeItemSpace(),
            LangKeys.screenAboutHeader.tr().h3.alignCenter.color(
              ref.scheme.content,
            ),
            const MoleculeItemSpace(),
            LangKeys.screenAboutDescription.tr().text.alignLeft.color(
              ref.scheme.content,
            ),
            const MoleculeItemSpace(),
            MoleculePrimaryButton(
              titleText: LangKeys.screenAboutRateApp.tr(),
              onTap: () => _rateMyApp.showRateDialog(context),
            ),
            const MoleculeItemSpace(),
            MoleculeItemBasic(
              title: LangKeys.screenAboutContactUs.tr(),
              label: infoEmail,
              actionIcon: AtomIcons.mail,
              onAction: () =>
                  Environment.openEmail(infoEmail), //_openEmail(infoEmail),
            ),
            //
            const MoleculeItemSpace(),
            const MoleculeItemSeparator(),
            const MoleculeItemSpace(),
            MoleculeItemTitle(header: LangKeys.screenAboutDocuments.tr()),
            const MoleculeItemSpace(),
            MoleculeItemBasic(
              icon: AtomIcons.fileText,
              title: LangKeys.screenAboutTerms.tr(),
              actionIcon: AtomIcons.chevronRight,
              onAction: () => context.push(
                WebViewScreen(
                  LangKeys.menuPrivacy.tr(),
                  internalPage: "privacy",
                ),
              ),
            ),
            MoleculeItemBasic(
              icon: AtomIcons.fileText,
              title: LangKeys.screenAboutEula.tr(),
              actionIcon: AtomIcons.chevronRight,
              onAction: () => context.push(
                WebViewScreen(LangKeys.menuEula.tr(), internalPage: "eula"),
              ),
            ),
            //
            const MoleculeItemSpace(),
            const MoleculeItemSeparator(),
            const MoleculeItemSpace(),
            MoleculeItemTitle(
              header: LangKeys.screenAboutSystemInformation.tr(),
            ),
            const MoleculeItemSpace(),
            MoleculeTableRow(
              label: LangKeys.screenAboutVersion.tr(),
              value: F().version,
            ),
            const SizedBox(height: 16),
            MoleculeTableRow(
              label: LangKeys.screenAboutBuild.tr(),
              value: F().buildNumber,
            ),
            const SizedBox(height: 16),
            MoleculeTableRow(
              label: LangKeys.screenAboutTranslation.tr(),
              value: LangKeys.translationVersion.tr(),
            ),
            //
            if (F().isInternal) ...[
              const MoleculeItemSpace(),
              MoleculeTableRow(
                label: LangKeys.screenAboutAppName.tr(),
                value: F().appName,
              ),
              const MoleculeItemSpace(),
              MoleculeTableRow(
                label: LangKeys.screenAboutPackageName.tr(),
                value: F().packageName,
              ),
              const MoleculeItemSpace(),
              MoleculeTableRow(
                label: LangKeys.screenAboutInstallerStore.tr(),
                value: F().installerStore,
              ),
            ],
            //
          ],
        ),
      ),
    );
  }

  /*
  import "package:url_launcher/url_launcher.dart";

  void _openEmail(String email) async {
    Environment.openEmail(email);
    final url = Uri(
      scheme: "mailto",
      path: email,
      queryParameters: {"subject": "Feedback"},
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      warning("Could not launch $url");
    }
  }
  */
}

// eof
