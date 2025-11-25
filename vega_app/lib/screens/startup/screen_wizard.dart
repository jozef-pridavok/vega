import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/widgets/chrome.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
import "package:vega_app/screens/profile/screen_country.dart";
import "package:vega_app/screens/startup/screen_account.dart";
import "package:vega_app/strings.dart";

import "../profile/screen_language.dart";

class WizardScreen extends ConsumerWidget {
  final int initialPage;
  const WizardScreen({super.key, this.initialPage = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Chrome(
      backgroundColor: ref.scheme.paper,
      child: Scaffold(appBar: AppBar(), body: SafeArea(child: _WizardPager(initialPage: initialPage))),
    );
  }
}

class _WizardIcon extends ConsumerWidget {
  final void Function() onTap;
  final String icon;
  final String title;
  final String description;

  const _WizardIcon({required this.onTap, required this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            VegaIcon(name: icon),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title.text.color(ref.scheme.content),
                const SizedBox(height: 4),
                description.text.color(ref.scheme.content50),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WizardPage extends ConsumerWidget {
  final int page;

  const _WizardPage(this.page);

  static const _images = {
    0: "ob_cards_f",
    1: "ob_nearby_f",
    2: "ob_shopping_f",
  };

  /* Don't remove this comment. It is necessary for keeping the localizations.

  LangKeys.wizard1Title.tr(),
  LangKeys.wizard1Description.tr(),
  LangKeys.wizard2Title.tr(),
  LangKeys.wizard2Description.tr(),
  LangKeys.wizard3Title.tr(),
  */

  static const _title = {
    0: LangKeys.wizard1Title,
    1: LangKeys.wizard2Title,
    2: LangKeys.wizard3Title,
  };

  static const _description = {
    0: LangKeys.wizard1Description,
    1: LangKeys.wizard2Description,
    2: "",
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = Localizations.localeOf(context);
    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    final screenSize = MediaQuery.of(context).size.shortestSide;
    final imageSize = screenSize < 390 ? 128.0 : 256.0;
    final country = CountryCode.fromCode(user.country);
    final languageCode = user.language ?? locale.languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: VegaImage(name: _images[page]!, width: imageSize, height: imageSize)),
        const MoleculeItemDoubleSpace(),
        _title[page]!.tr().h2.alignCenter.color(ref.scheme.content),
        const MoleculeItemDoubleSpace(),
        if (page <= 1) _description[page]!.tr().text.alignCenter.color(ref.scheme.content),
        if (page == 2)
          Row(
            children: [
              Expanded(
                child: _WizardIcon(
                  icon: AtomIcons.globe,
                  title: LangKeys.menuLanguage.tr(),
                  description: "core_language_$languageCode".tr(),
                  onTap: () => context.slideUp(const LanguageScreen(cancel: true)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _WizardIcon(
                  icon: AtomIcons.flag,
                  title: LangKeys.menuRegion.tr(),
                  description: country.localizedName,
                  onTap: () => context.slideUp(const CountryScreen(cancel: true)),
                ),
              ),
            ],
          ),
        const Spacer(),
      ],
    );
  }
}

class _WizardPager extends ConsumerStatefulWidget {
  final int initialPage;

  const _WizardPager({this.initialPage = 0});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WizardPagerState();
}

class _WizardPagerState extends ConsumerState<_WizardPager> {
  static const _pages = 3;

  late PageController _controller;

  void _showPage(int page) => _controller.animateToPage(page, duration: kThemeAnimationDuration, curve: Curves.ease);

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialPage);
    /*
    Future(() async {
      final locale = Localizations.localeOf(context);
      final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
      final userUpdate = cast<UserUpdateSucceed>(ref.read(userUpdateLogic));
      final country = userUpdate?.country ?? CountryCode.fromCode(user.country);
      final languageCode = userUpdate?.language?.languageCode ?? user.language ?? locale.languageCode;
      await ref.read(userUpdateLogic.notifier).edit(
            language: Locale.fromSubtags(languageCode: languageCode),
            country: country,
          );
    });
    */
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: PageView.builder(itemBuilder: (_, i) => _WizardPage(i), itemCount: _pages, controller: _controller),
          ),
          const MoleculeItemDoubleSpace(),
          Center(
            child: SmoothPageIndicator(
              controller: _controller,
              count: _pages,
              effect: ExpandingDotsEffect(
                expansionFactor: 2,
                radius: 4,
                spacing: 16,
                dotHeight: 4,
                dotWidth: 16,
                dotColor: ref.scheme.content10,
                activeDotColor: ref.scheme.primary,
              ),
              onDotClicked: (index) => _showPage(index),
            ),
          ),
          const MoleculeItemDoubleSpace(),
          MoleculePrimaryButton(
            onTap: () {
              int currentPage = _controller.page?.toInt() ?? 0;
              if (currentPage == _pages - 1)
                context.push(const AccountScreen(allowAnonymous: true));
              else
                _showPage(currentPage + 1);
            },
            titleText: LangKeys.buttonContinue.tr(),
          ),
          //const MoleculeItemSpace(),
        ],
      ),
    );
  }
}

// eof
