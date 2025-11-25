import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../screens/login.dart";
import "../strings.dart";

class SimpleErrorWidget extends ConsumerWidget {
  final String icon;
  final String message;
  final String? buttonText;
  final void Function()? buttonAction;

  const SimpleErrorWidget({
    this.icon = AtomIcons.xCircle,
    required this.message,
    this.buttonText,
    this.buttonAction,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: !isMobile ? ScreenFactor.tablet : double.infinity),
        child: MoleculeErrorWidget(
          icon: icon,
          message: message,
          primaryButton: buttonText,
          onPrimaryAction: buttonAction,
        ),
      ),
    );
  }
}

class StateErrorWidget extends ConsumerWidget {
  final StateNotifierProvider provider;
  final Function? onReload;
  final String? Function(CoreError error)? getIcon;
  final String? Function(CoreError error)? getMessage;
  final String? Function(CoreError error)? getButtonText;
  final void Function(CoreError error, BuildContext context, WidgetRef ref)? getButtonAction;

  const StateErrorWidget(
    this.provider, {
    this.onReload,
    super.key,
    this.getIcon,
    this.getMessage,
    this.getButtonText,
    this.getButtonAction,
  });

  void _showLoginScreen(BuildContext context, WidgetRef ref) {
    context.replace(const LoginScreen(), popAll: true);
  }

  String _getIcon(CoreError error) {
    String? icon = getIcon?.call(error);
    if (icon != null) return icon;
    if (error == errorInvalidLicense) return AtomIcons.blocked;
    if (error == errorConnectionTimeout) return AtomIcons.cloudOff;
    if (error == errorServiceUnavailable) return AtomIcons.cloudLightning;
    if (error == errorInvalidRefreshToken) return AtomIcons.shieldOff;
    if (error == errorNoData) return AtomIcons.slash;
    return AtomIcons.xCircle;
  }

  String? _getMessage(CoreError error) {
    if (error == errorInvalidLicense) return LangKeys.errorConnectionTimeout.tr();
    if (error == errorConnectionTimeout) return LangKeys.errorConnectionTimeout.tr();
    if (error == errorServiceUnavailable) return LangKeys.errorServiceUnavailable.tr();
    if (error == errorInvalidRefreshToken) return LangKeys.errorInvalidRefreshToken.tr();
    if (error == errorNoData) return LangKeys.errorNoData.tr();
    if (error.code == 900) return error.message;
    return getMessage?.call(error) ?? error.message;
  }

  String? _getButtonText(CoreError error) {
    if (error == errorInvalidRefreshToken) return LangKeys.buttonContinue.tr();
    if (error == errorNoData) return null;
    return getButtonText?.call(error) ?? LangKeys.buttonTryAgain.tr();
  }

  void _getButtonAction(CoreError error, BuildContext context, WidgetRef ref) {
    if (error == errorInvalidRefreshToken) return _showLoginScreen(context, ref);
    (getButtonAction != null ? getButtonAction!(error, context, ref) : onReload?.call());
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    print("isMobile: $isMobile, ${!isMobile ? ScreenFactor.tablet : double.infinity}");
    final errorState = ref.watch(provider) as FailedState;
    final error = errorState.error;
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: !isMobile ? ScreenFactor.tablet : double.infinity),
        child: MoleculeErrorWidget(
          icon: _getIcon(error),
          message: _getMessage(error),
          primaryButton: _getButtonText(error),
          onPrimaryAction:
              (getButtonAction != null || onReload != null) ? () => _getButtonAction(error, context, ref) : null,
        ),
      ),
    );
  }
}

// eof
