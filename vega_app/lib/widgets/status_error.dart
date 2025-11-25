import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/strings.dart";

import "../screens/startup/screen_account.dart";

class StatusErrorWidget extends ConsumerWidget {
  final StateNotifierProvider provider;
  final Function? onReload;
  final String? Function(CoreError error)? getIcon;
  final String? Function(CoreError error)? getMessage;
  final String? Function(CoreError error)? getButtonText;

  /// Should return true to call onReload
  final bool Function(CoreError error, BuildContext context, WidgetRef ref)? getButtonAction;

  const StatusErrorWidget(
    this.provider, {
    this.onReload,
    super.key,
    this.getIcon,
    this.getMessage,
    this.getButtonText,
    this.getButtonAction,
  });

  void _showAccountScreen(BuildContext context, WidgetRef ref) {
    //ref.read(deviceRepository).put(DeviceKey.user, null);
    //ref.read(deviceRepository).put(DeviceKey.refreshToken, null);
    //ref.read(deviceRepository).put(DeviceKey.accessToken, null);
    context.replace(const AccountScreen(allowAnonymous: true, hideBackButton: true));
  }

  String _getIcon(CoreError error) {
    String? icon = getIcon?.call(error);
    if (icon != null) return icon;
    if (error == errorConnectionTimeout) return AtomIcons.cloudOff;
    if (error == errorServiceUnavailable) return AtomIcons.cloudLightning;
    if (error == errorInvalidRefreshToken) return AtomIcons.shieldOff;
    if (error == errorNoData) return AtomIcons.slash;
    return AtomIcons.xCircle;
  }

  String? _getMessage(CoreError error) {
    String? message = getMessage?.call(error);
    if (message != null) return message;
    if (error == errorConnectionTimeout) return LangKeys.errorConnectionTimeout.tr();
    if (error == errorServiceUnavailable) return LangKeys.errorServiceUnavailable.tr();
    if (error == errorInvalidRefreshToken) return LangKeys.errorInvalidRefreshToken.tr();
    if (error == errorNoData) return LangKeys.errorNoData.tr();
    if (error.code == 900) return error.message;
    return error.message;
  }

  String? _getButtonText(CoreError error) {
    String? buttonText = getButtonText?.call(error);
    if (buttonText != null) return buttonText;
    if (error == errorInvalidRefreshToken) return LangKeys.buttonContinue.tr();
    if (error == errorNoData) return null;
    return LangKeys.buttonTryAgain.tr();
  }

  void _getButtonAction(CoreError error, BuildContext context, WidgetRef ref) {
    if (error == errorInvalidRefreshToken) return _showAccountScreen(context, ref);
    if ((getButtonAction?.call(error, context, ref) ?? true)) onReload?.call();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errorState = ref.watch(provider) as FailedState;
    final error = errorState.error;
    return MoleculeErrorWidget(
      icon: _getIcon(error),
      message: _getMessage(error),
      primaryButton: _getButtonText(error),
      onPrimaryAction: () => _getButtonAction(error, context, ref),
    );
  }
  /*
  Widget build(BuildContext context, WidgetRef ref) {
    //final isDarkMode = ref.scheme.mode == ThemeMode.dark;
    final errorState = ref.watch(provider) as FailedState;
    final invalidRefreshToken = errorState.error.code == errorInvalidRefreshToken.code;
    return MoleculeErrorWidget(
      //image: "error${isDarkMode ? '_d' : ''}",
      message: invalidRefreshToken ? LangKeys.errorInvalidRefreshToken.tr() : errorState.error.message,
      primaryButton: invalidRefreshToken ? LangKeys.buttonContinue.tr() : LangKeys.buttonTryAgain.tr(),
      onPrimaryAction: () => invalidRefreshToken ? _showAccountScreen(context, ref) : onReload?.call(),
    );
  }
  */
}

// eof
