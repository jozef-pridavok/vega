import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:core_flutter/extensions/theme.dart";
import "package:core_flutter/states/provider.dart";
import "package:core_flutter/widgets/chrome.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../cards/screen_cards.dart";
import "screen_account.dart";
import "screen_wizard.dart";

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  late Locale _locale;
  int noUserErrorCounter = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _locale = Localizations.localeOf(context);
      ref.read(startupLogic.notifier).start(_locale);
    });
  }

  void _listenToStartupState() {
    ref.listen<StartupState>(startupLogic, (old, state) async {
      if (state is StartupSucceed) {
        final device = ref.read(deviceRepository);
        final user = device.get(DeviceKey.user) as User?;
        if (user != null) {
          final language = user.language;
          if (language != null && language.isNotEmpty) await context.setLocale(Locale(language));
          final theme = user.theme;
          ref.read(themeLogic.notifier).changeTheme(theme.material);
        }
        state.isWizardShowed ? _showHomeScreen(ref) : _showWizardScreen();
      } else if (state is StartupFailed) {
        /*
        if (state.error == errorNoUser) {
          if (noUserErrorCounter < 5) {
            await Future.delayed(stateRefreshDuration);
            await ref.read(startupLogic.notifier).start(_locale);
            noUserErrorCounter++;
            return;
          }
        }
        */
        _failed(context, state);
      }
    });
  }

  void _failed(BuildContext context, StartupFailed state) {
    final reuseOfRefreshToken = state.error.code == errorRefreshTokenReuseDetected.code;
    final invalidRefreshToken = state.error.code == errorInvalidRefreshToken.code;
    final noUser = state.error.code == errorNoUser.code;

    String message = LangKeys.errorServiceUnavailable.tr(); // state.error.toString();
    String primaryButton = LangKeys.buttonTryAgain.tr();
    Function() primaryAction = () {
      final locale = Localizations.localeOf(context);
      context.pop();
      ref.read(startupLogic.notifier).start(locale);
    };
    String? secondaryButton;
    Function()? secondaryAction;
    if (noUser) {
      message = LangKeys.errorNoUser.tr();
      primaryButton = LangKeys.buttonOpenAppSettings.tr();
      primaryAction = () => Environment.openAppSettings();
      secondaryButton = LangKeys.buttonTryAgain.tr();
      secondaryAction = () {
        context.pop();
        ref.read(deviceRepository).put(DeviceKey.user, null);
        ref.read(startupLogic.notifier).start(_locale);
      };
    }
    if (invalidRefreshToken || reuseOfRefreshToken) {
      message = LangKeys.errorInvalidRefreshToken.tr();
      primaryButton = LangKeys.buttonContinue.tr();
      primaryAction = () => context.replace(const AccountScreen(allowAnonymous: true, hideBackButton: true));
    }
    final fatal = ErrorScreen(
      icon: state.isOnline ? AtomIcons.xCircle : AtomIcons.offline,
      //image: state.isOnline ? "error" : "offline",
      message: message,
      primaryButton: primaryButton,
      primaryAction: primaryAction,
      secondaryButton: secondaryButton,
      secondaryAction: secondaryAction,
      /*
      primaryButton: invalidRefreshToken ? LangKeys.buttonContinue.tr() : LangKeys.buttonTryAgain.tr(),
      primaryAction: () {
        if (invalidRefreshToken) {
          context.replace(const AccountScreen(allowAnonymous: true, hideBackButton: true));
          return;
        }
        final locale = Localizations.localeOf(context);
        context.pop();
        ref.read(startupLogic.notifier).start(locale);
      },
      */
    );
    final route = NoAnimationPageRouteTransition(fatal);
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(route);
  }

  void _showHomeScreen(WidgetRef ref) {
    Future.microtask(() => ref.read(userCardsLogic.notifier).load());
    context.replace(const CardsScreen(), popAll: true);
  }

  void _showWizardScreen() {
    context.replace(const WizardScreen(), popAll: true);
  }

  @override
  Widget build(BuildContext context) {
    _listenToStartupState();
    final backgroundColor = ref.scheme.primary;
    return Chrome(
      backgroundColor: backgroundColor,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: const CenteredWaitIndicator(color: Colors.white),
      ),
    );
  }
}

// eof
