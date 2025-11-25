import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/strings.dart";

import "../../states/account/change_password.dart";
import "../../states/account/register.dart";
import "../../states/providers.dart";
import "../screen_app.dart";

class ChangePasswordScreen extends AppScreen {
  final String? email;
  const ChangePasswordScreen({super.key, this.email});

  @override
  createState() => _ChangePasswordState();
}

class _ChangePasswordState extends AppScreenState<ChangePasswordScreen> {
  String? get _email => widget.email;

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
    Future.microtask(() => ref.read(changePasswordLogic.notifier).reset());
    _emailController.text = _email ?? "";
    _passwordController.text = "";
    _checkPasswordController.text = "";
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
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return VegaAppBar(
      // localize to slovak, english, spanish
      title: LangKeys.screenChangePasswordTitle.tr(),
      cancel: true,
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    ref.listen<ChangePasswordState>(changePasswordLogic, (previous, next) {
      if (next is ChangePasswordFailed) {
        final error = next.error;
        String errorText = error.toString();
        ref.read(toastLogic.notifier).error(errorText);
        Future.delayed(stateRefreshDuration, () => ref.read(changePasswordLogic.notifier).reset());
      } else if (next is ChangePasswordRequested) {
        toastInfo(LangKeys.toastChangePasswordRequested.tr());
        ref.read(changePasswordLogic.notifier).reset();
        context.pop();
      }
    });
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
              LangKeys.screenChangePasswordDescription.tr().text,
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
                      name: _obscureCheckPassword ? "eye" : "eye_off",
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
              _ChangePasswordButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  ref
                      .read(changePasswordLogic.notifier)
                      .changePassword(_emailController.text, _passwordController.text);
                },
              ),
              const MoleculeItemSpace(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChangePasswordButton extends ConsumerWidget {
  final void Function() onPressed;
  const _ChangePasswordButton({required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(changePasswordLogic, (previous, next) {
      if (next is RegisterFailed)
        Future.delayed(stateRefreshDuration, () => ref.read(changePasswordLogic.notifier).reset());
    });
    final buttonState = ref.watch(changePasswordLogic).buttonState;
    return MoleculeActionButton(
      title: LangKeys.buttonChangePassword.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: buttonState,
      onPressed: onPressed,
    );
  }
}

// eof
