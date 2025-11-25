import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:flutter/material.dart";

import "../states/provider.dart";

class ErrorScreen extends Screen {
  final String? title;
  final String? titleKey;
  final String icon;
  final String? message;
  final String? messageKey;
  final String? primaryButton;
  final void Function()? primaryAction;
  final String? secondaryButton;
  final void Function()? secondaryAction;
  const ErrorScreen({
    this.title,
    this.titleKey,
    this.icon = AtomIcons.xCircle,
    this.message,
    this.messageKey,
    this.primaryButton,
    this.primaryAction,
    this.secondaryButton,
    this.secondaryAction,
    Key? key,
  }) : super(key: key);

  @override
  createState() => _StatusState();
}

class _StatusState extends ScreenState<ErrorScreen> {
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return VegaAppBar(
      hideButton: true,
      title: widget.title ?? widget.titleKey?.tr(),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: !isMobile ? ScreenFactor.tablet : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(
                child: MoleculeErrorWidget(
                  icon: widget.icon,
                  message: widget.message,
                  messageKey: widget.messageKey,
                ),
              ),
              if (widget.primaryButton != null) ...[
                const MoleculeItemSpace(),
                MoleculePrimaryButton(
                  titleText: widget.primaryButton,
                  onTap: () => widget.primaryAction?.call(),
                )
              ],
              if (widget.secondaryButton != null) ...[
                const MoleculeItemSpace(),
                MoleculeSecondaryButton(
                  titleText: widget.secondaryButton,
                  onTap: () => widget.secondaryAction?.call(),
                ),
                const MoleculeItemSpace(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// eof
