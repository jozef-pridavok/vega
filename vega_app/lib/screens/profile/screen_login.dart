import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/extensions/theme.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../main.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../cards/screen_cards.dart";
import "../screen_app.dart";
import "../startup/screen_splash.dart";
import "screen_change_password.dart";

class LoginScreen extends AppScreen {
  final bool goToHomeScreen;
  const LoginScreen({super.key, this.goToHomeScreen = false});

  @override
  createState() => _LoginState();
}

class _LoginState extends AppScreenState<LoginScreen> {
  bool get _goToHomeScreen => widget.goToHomeScreen;

  final _formKey = GlobalKey<FormState>();
  final _focusNodeLogin = FocusNode();
  final _focusNodePassword = FocusNode();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  var _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(loginLogic.notifier).reset());
    if (F().isDev) {
      _emailController.text = "u1@a.com";
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
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenLoginTitle.tr(),
        cancel: true,
        hideButton: ref.watch(loginLogic) is LoginInProgress,
      );

  @override
  Widget buildBody(BuildContext context) {
    _listenToLoginState(context);
    final device = ref.read(deviceRepository);
    final installationId = device.get(DeviceKey.installationId);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          physics: vegaScrollPhysic,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const MoleculeItemSpace(),
              LangKeys.screenLoginDescription.tr().text,
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
                title: LangKeys.labelEmail.tr(),
                hint: LangKeys.hintEmail.tr(),
                validator: (value) {
                  if (value?.isEmpty ?? true) return LangKeys.validationEmailRequired.tr();
                  if (isNotEmail(value!)) return LangKeys.validationEmailInvalidFormat.tr();
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
                      name: _obscurePassword ? "eye" : "eye_off",
                      color: _obscurePassword ? ref.scheme.content20 : ref.scheme.primary,
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(),
                validator: (value) {
                  if (value?.isEmpty ?? true) return LangKeys.validationPasswordRequired.tr();
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
                        .login(installationId, email: _emailController.text, password: _passwordController.text);
                  }
                },
              ),
              const MoleculeItemSpace(),
              MoleculeLinkButton(
                titleText: LangKeys.buttonForgotPassword.tr(),
                onTap: () => context.slideUp(ChangePasswordScreen(email: _emailController.text)),
              ),
              const MoleculeItemSpace(),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserCards(BuildContext context) {
    ref.read(userCardsLogic.notifier).refresh();
    context.replace(const CardsScreen(), popAll: true);
  }

  void _listenToLoginState(BuildContext context) {
    return ref.listen<LoginState>(loginLogic, (previous, next) {
      if (next is LoginSucceed) {
        clearHive();
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
        _goToHomeScreen ? _showUserCards(context) : context.pop();
      } else if (next is LoginFailed) {
        final error = next.error;
        if (error == errorUserAlreadySignedIn) {
          toastError(LangKeys.toastAlreadySignedIn.tr());
          _goToHomeScreen ? _showUserCards(context) : context.pop();
        } else if (error == errorInvalidCredentials) {
          toastError(LangKeys.toastInvalidCredentials.tr());
        } else if (error == errorNoInstallation || error == errorInvalidRefreshToken) {
          toastError(error.toString());
          final device = ref.read(deviceRepository);
          // TODO: tu by som mal zachovať deviceToken a isWizardShowed
          device.clearAll();
          context.replace(const SplashScreen(), popAll: true);
        } else {
          toastError(error.toString());
        }
      }
    });
  }
}

class _LoginButton extends ConsumerWidget {
  final void Function() onPressed;
  const _LoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<LoginState>(loginLogic, (previous, next) {
      if (next is LoginFailed) Future.delayed(stateRefreshDuration, () => ref.read(loginLogic.notifier).reset());
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
