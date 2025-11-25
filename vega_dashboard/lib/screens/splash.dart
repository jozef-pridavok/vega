import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:core_flutter/extensions/theme.dart";
import "package:core_flutter/states/provider.dart";
import "package:core_flutter/widgets/chrome.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../states/providers.dart";
import "../strings.dart";
import "dashboard/dashboard.dart";
import "login.dart";
import "seller_clients/screen_list.dart";

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with LoggerMixin {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final locale = Localizations.localeOf(context);
      ref.read(startupLogic.notifier).start(locale);
    });
  }

  void _listenToStartupState() {
    ref.listen<StartupState>(startupLogic, (old, state) {
      if (state is StartupSucceed) {
        final device = ref.read(deviceRepository);
        final user = device.get(DeviceKey.user) as User?;
        if (user != null) {
          final language = user.language;
          if (language != null && language.isNotEmpty) {
            context.setLocale(Locale(language));
          }
          final theme = user.theme;
          ref.read(themeLogic.notifier).changeTheme(theme.material);
        }
        _showHomeScreen(ref);
      }
      if (state is StartupFailed) _failed(context, state);
    });
  }

  void _listenToLogoutState() {
    ref.listen<LogoutState>(logoutLogic, (previous, next) {
      if (next is LogoutSucceed) {
        ref.read(logoutLogic.notifier).reset();
        context.replace(const LoginScreen());
      } else if (next is LogoutFailed) {
        //ref.read(logoutLogic.notifier).reset();
        //context.replace(const LoginScreen());
        ref.read(logoutLogic.notifier).reset();
        final device = ref.read(deviceRepository);
        // TODO: tu by som mal zachovať deviceToken a isWizardShowed
        device.clearAll();
        context.replace(const SplashScreen(), popAll: true);
      }
    });
  }

  void _failed(BuildContext context, StartupFailed state) {
    final error = state.error;

    String icon = AtomIcons.xCircle;
    if (error == errorInvalidApiKey) icon = "settings";
    if (error == errorConnectionTimeout) icon = AtomIcons.cloudOff;
    if (error == errorServiceUnavailable) icon = AtomIcons.cloudLightning;
    if (error == errorInvalidRefreshToken) icon = AtomIcons.shieldOff;

    String message = LangKeys.errorUnexpectedError.tr(args: [error.code.toString()]); // state.error.toString();
    if (error == errorConnectionTimeout) message = LangKeys.errorConnectionTimeout.tr();
    if (error == errorServiceUnavailable) message = LangKeys.errorServiceUnavailable.tr();
    if (error == errorInvalidRefreshToken) message = LangKeys.errorInvalidRefreshToken.tr();
    if (error.code == 900) message = error.message;

    final invalidRefreshToken = error == errorInvalidRefreshToken;

    final canLogout =
        (error != errorInvalidRefreshToken && error != errorServiceUnavailable && error != errorConnectionTimeout);

    final fatal = ErrorScreen(
      icon: icon,
      message: message,
      primaryButton: invalidRefreshToken ? LangKeys.buttonContinue.tr() : LangKeys.buttonTryAgain.tr(),
      primaryAction: () {
        if (invalidRefreshToken) {
          ref.read(loginLogic.notifier).reset();
          final device = ref.read(deviceRepository);
          // TODO: tu by som mal zachovať deviceToken a isWizardShowed
          device.clearAll();
          context.replace(const SplashScreen(), popAll: true);
          //context.replace(const LoginScreen());
          return;
        }
        context.pop();
        final locale = Localizations.localeOf(context);
        //if (kDebugMode) ref.read(deviceRepository).clear();
        ref.read(startupLogic.notifier).start(locale);
      },
      secondaryButton: canLogout ? LangKeys.buttonLogout.tr() : null,
      secondaryAction: canLogout ? () => ref.read(logoutLogic.notifier).logout() : null,
    );

    final route = NoAnimationPageRouteTransition(fatal);
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(route);
  }

  void _invalidRole(WidgetRef ref, String? message) {
    final error = ErrorScreen(
      message: LangKeys.errorNoRoles.tr() + (message != null ? "\n$message" : ""),
      primaryButton: LangKeys.buttonIHaveAccount.tr(),
      primaryAction: () {
        context.pop();
        final locale = Localizations.localeOf(context);
        //if (kDebugMode) ref.read(deviceRepository).clearAll();
        ref.read(startupLogic.notifier).start(locale);
      },
    );
    final route = NoAnimationPageRouteTransition(error);
    Navigator.of(context).popUntil((route) => route.isFirst);
    Navigator.of(context).push(route);
  }

  Future<void> _showHomeScreen(WidgetRef ref) async {
    final device = ref.read(deviceRepository);
    var user = device.get(DeviceKey.user) as User?;
    if (user?.isAnonymous ?? true) {
      context.replace(const LoginScreen());
      return;
    }
    final roles = user?.roles;
    if (roles == null || roles.isEmpty) {
      verbose(() => "UserId: ${user?.userId}");
      warning("Roles: ${roles?.join(",") ?? "No roles"}");
      _invalidRole(
        ref,
        F().isInternal ? "Roles: ${roles?.join(",") ?? "No roles"}" : null,
      );
      return;
    }
    if (user?.isSeller ?? false) return context.replace(const SellerClientsScreen(showDrawer: true));
    //if (user?.isDevelopment ?? false) return context.replace(const TranslationsScreen(showDrawer: true));

    context.replace(const DashboardScreen(showDrawer: true));
  }

  @override
  Widget build(BuildContext context) {
    _listenToStartupState();
    _listenToLogoutState();
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
