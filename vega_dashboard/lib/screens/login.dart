import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:core_flutter/extensions/theme.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../states/providers.dart";
import "../strings.dart";
import "dashboard/dashboard.dart";
import "screen_app.dart";
import "splash.dart";

class LoginScreen extends VegaScreen {
  const LoginScreen({super.key});

  @override
  createState() => _LoginState();
}

class _LoginState extends VegaScreenState {
  final _formKey = GlobalKey<FormState>();
  final _focusNodeLogin = FocusNode();
  final _focusNodePassword = FocusNode();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  var _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    Future(() => ref.read(loginLogic.notifier).reset());
    if (F().isDev) {
      _emailController.text = "c1.admin1"; // pos1
      _passwordController.text = "a";
    }
  }

  @override
  void dispose() {
    _focusNodeLogin.dispose();
    _focusNodePassword.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenLoginTitle.tr();

  @override
  bool get hideBackButton => true;

  @override
  Widget buildBody(BuildContext context) {
    _listenToLoginLogic(context);
    final device = ref.read(deviceRepository);
    final installationId = device.get(DeviceKey.installationId) as String;
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: !isMobile ? ScreenFactor.tablet : double.infinity),
            child: AutoScrollColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const MoleculeItemSpace(),
                MoleculeInput(
                  controller: _emailController,
                  focusNode: _focusNodeLogin,
                  onFieldSubmitted: (value) => _focusNodePassword.requestFocus(),
                  inputAction: TextInputAction.next,
                  capitalization: TextCapitalization.none,
                  inputType: TextInputType.emailAddress,
                  autocorrect: false,
                  enableSuggestions: false,
                  title: LangKeys.labelLogin.tr(),
                  hint: LangKeys.hintLogin.tr(),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return LangKeys.validationLoginRequired.tr();
                    }
                    return null;
                  },
                ),
                const MoleculeItemSpace(),
                MoleculeInput(
                  controller: _passwordController,
                  focusNode: _focusNodePassword,
                  inputAction: TextInputAction.done,
                  maxLines: 1,
                  obscureText: _obscurePassword,
                  title: LangKeys.labelPassword.tr(),
                  hint: LangKeys.hintPassword.tr(),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: VegaIcon(
                        name: _obscurePassword ? AtomIcons.eye : AtomIcons.eyeOff,
                        color: _obscurePassword ? ref.scheme.content20 : ref.scheme.primary,
                      ),
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return LangKeys.validationPasswordRequired.tr();
                    }
                    //_password = value!;
                    return null;
                  },
                ),
                const MoleculeItemSpace(),
                _LoginButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      ref
                          .read(loginLogic.notifier)
                          .login(installationId, login: _emailController.text, password: _passwordController.text);
                    }
                  },
                ),
                const MoleculeItemSpace(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _listenToLoginLogic(BuildContext context) {
    ref.listen<LoginState>(loginLogic, (previous, next) {
      if (next is LoginSucceed) {
        ref.read(loginLogic.notifier).reset();

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
        context.replace(const DashboardScreen(showDrawer: true));
      } else if (next is LoginFailed) {
        final code = next.error.code;
        if (code == errorUserAlreadySignedIn.code) {
          toastError(LangKeys.toastAlreadySignedIn.tr());
          context.replace(const DashboardScreen(showDrawer: true));
        } else if (code == errorInvalidCredentials.code) {
          toastError(LangKeys.toastInvalidCredentials.tr());
        } else if ([errorNoInstallation.code, errorInvalidRefreshToken.code, errorNoAccessToken.code].contains(code)) {
          toastCoreError(next.error);
          ref.read(loginLogic.notifier).reset();
          final device = ref.read(deviceRepository);
          // TODO: tu by som mal zachovať deviceToken a isWizardShowed
          device.clearAll();
          context.replace(const SplashScreen(), popAll: true);
        } else {
          toastCoreError(next.error);
        }
        //ref.read(toastLogic.notifier).error(next.error.toString());
      }
    });
  }
}

class _LoginButton extends ConsumerWidget {
  final void Function() onPressed;
  const _LoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(loginLogic, (previous, next) {
      if (next is LoginFailed) {
        Future.delayed(stateRefreshDuration, () {
          if (!context.mounted) return;
          ref.read(loginLogic.notifier).reset();
        });
      }
    });
    final buttonState = ref.watch(loginLogic).buttonState;
    return MoleculeActionButton(
      title: LangKeys.buttonLogin.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: buttonState,
      onPressed: onPressed,
    );
  }
}

// eof
