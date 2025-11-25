import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/strings.dart";

import "../../main.dart";
import "../../states/account/register.dart";
import "../../states/providers.dart";
import "../cards/screen_cards.dart";
import "../screen_app.dart";

class RegisterScreen extends AppScreen {
  final bool goToHomeScreen;
  const RegisterScreen({super.key, this.goToHomeScreen = false});

  @override
  createState() => _RegisterState();
}

class _RegisterState extends AppScreenState<RegisterScreen> {
  bool get _goToHomeScreen => widget.goToHomeScreen;

  final _formKey = GlobalKey<FormState>();
  final _focusNodeLogin = FocusNode();
  final _focusNodePassword = FocusNode();
  final _focusNodeCheckPassword = FocusNode();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _checkPasswordController = TextEditingController();

  var _obscurePassword = true;
  var _obscureCheckPassword = true;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(loginLogic.notifier).reset());
    if (F().isDev) {
      _emailController.text = "u1@a.com";
      _passwordController.text = "a";
      _checkPasswordController.text = "a";
    }
  }

  @override
  void dispose() {
    _focusNodeLogin.dispose();
    _focusNodePassword.dispose();
    _focusNodeCheckPassword.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _checkPasswordController.dispose();
    super.dispose();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenRegisterTitle.tr(),
        cancel: true,
        hideButton: ref.watch(registerLogic) is RegisterInProgress,
      );

  @override
  Widget buildBody(BuildContext context) {
    _listenToRegisterState(context);
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
              LangKeys.screenRegisterDescription.tr().text,
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
                  return null;
                },
              ),
              const MoleculeItemSpace(),
              MoleculeInput(
                controller: _checkPasswordController,
                focusNode: _focusNodeCheckPassword,
                inputAction: TextInputAction.done,
                maxLines: 1,
                obscureText: _obscureCheckPassword,
                title: LangKeys.labelRepeatPassword.tr(),
                hint: LangKeys.hintRepeatPassword.tr(),
                suffixIcon: GestureDetector(
                  onTap: () => setState(() => _obscureCheckPassword = !_obscureCheckPassword),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: VegaIcon(
                      name: _obscureCheckPassword ? AtomIcons.eye : AtomIcons.eyeOff,
                      color: _obscureCheckPassword ? ref.scheme.content20 : ref.scheme.primary,
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(),
                validator: (value) {
                  if (value?.isEmpty ?? true) return LangKeys.validationPasswordRequired.tr();
                  if (value != _passwordController.text) return LangKeys.validationPasswordsDoNotMatch.tr();
                  return null;
                },
              ),
              const MoleculeItemSpace(),
              const Center(child: _AgreeWithConditionsButton()),
              const MoleculeItemSpace(),
              _RegisterButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    ref
                        .read(registerLogic.notifier)
                        .register(email: _emailController.text, password: _passwordController.text);
                  }
                },
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

  void _listenToRegisterState(BuildContext context) {
    ref.listen<RegisterState>(registerLogic, (previous, next) {
      if (next is RegisterSucceed) {
        clearHive();
        ref.read(registerLogic.notifier).reset();
        if (_goToHomeScreen) {
          _showUserCards(context);
        } else
          context.pop();
      } else if (next is RegisterFailed) {
        final error = next.error;
        final errorText =
            (error == errorUserAlreadyExists) ? LangKeys.toastAccountAlreadyRegistered.tr() : error.toString();
        toastError(errorText);
      }
    });
  }
}

class _RegisterButton extends ConsumerWidget {
  final void Function() onPressed;
  const _RegisterButton({required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<RegisterState>(registerLogic, (previous, next) {
      if (next is RegisterFailed) Future.delayed(stateRefreshDuration, () => ref.read(registerLogic.notifier).reset());
    });
    final buttonState = ref.watch(registerLogic).buttonState;
    return MoleculeActionButton(
      title: LangKeys.buttonCreate.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: buttonState,
      onPressed: onPressed,
    );
  }
}

class _AgreeWithConditionsButton extends ConsumerWidget {
  const _AgreeWithConditionsButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) => RichText(
        text: TextSpan(
          text: "${LangKeys.buttonIAgreeWith.tr()} ",
          style: AtomStyles.text.copyWith(color: ref.scheme.content),
          children: <TextSpan>[
            TextSpan(
              text: LangKeys.buttonTermsAndConditions.tr(),
              style: AtomStyles.text.copyWith(color: ref.scheme.primary),
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.push(WebViewScreen(LangKeys.menuEula.tr(), internalPage: "eula")),
            )
          ],
        ),
      );
}

// eof
