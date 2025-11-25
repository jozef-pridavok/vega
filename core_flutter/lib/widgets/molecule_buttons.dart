import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "button_progress.dart";

class MoleculePrimaryButton extends ConsumerWidget {
  final String? titleText;
  final Widget? title;
  final void Function()? onTap;
  final Color? color;
  final double height;

  const MoleculePrimaryButton({
    Key? key,
    this.titleText,
    this.title,
    required this.onTap,
    this.color,
    this.height = moleculeButtonHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      constraints: BoxConstraints.tightFor(height: height),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(moleculeButtonRadius),
          ),
          //textStyle: AtomStyles.textBold.copyWith(overflow: TextOverflow.ellipsis),
          backgroundColor: color ?? ref.scheme.primary,
          disabledBackgroundColor: ref.scheme.secondary,
        ),
        onPressed: onTap,
        child: title ?? (titleText ?? "").textBold.color(ref.scheme.light),
      ),
    );
  }
}

class MoleculeSecondaryButton extends ConsumerWidget {
  final String? titleText;
  final Widget? title;
  final void Function() onTap;
  final bool circle;
  final Color? color;

  const MoleculeSecondaryButton({
    Key? key,
    this.titleText,
    this.title,
    required this.onTap,
    this.circle = false,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      constraints: const BoxConstraints.tightFor(height: moleculeButtonHeight),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          side: BorderSide(width: 1, color: color ?? ref.scheme.primary),
          shape: circle
              ? const CircleBorder()
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(moleculeButtonRadius),
                ),
        ),
        child: title ?? (titleText ?? "").textBold.alignCenter.color(color ?? ref.scheme.primary),
        onPressed: () => onTap(),
      ),
    );
  }
}

class MoleculeLinkButton extends ConsumerWidget {
  final String titleText;
  final Function()? onTap;
  final Color? color;

  const MoleculeLinkButton({
    Key? key,
    required this.titleText,
    required this.onTap,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MouseRegion(
        cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: titleText.text.color(color ?? ref.scheme.primary),
      ),
    );
    /*
    return MaterialButton(
      height: 32,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
      child: titleText.text.color(color ?? ref.scheme.primary),
      color: backgroundColor,
      onPressed: () => onTap?.call(),
    );
    */
  }
}

enum MoleculeActionButtonState { idle, loading, success, fail }

class MoleculeActionButton extends ConsumerWidget {
  final bool primaryButton;
  final String title;
  final String loadingTitle;
  final String failTitle;
  final String successTitle;
  final MoleculeActionButtonState buttonState;
  final void Function()? onPressed;
  final Widget? titleWidget;
  final double minWidth;
  final double maxWidth;
  final Color? color;

  const MoleculeActionButton({
    Key? key,
    this.primaryButton = true,
    this.title = "",
    this.loadingTitle = "",
    this.failTitle = "",
    this.successTitle = "",
    this.onPressed,
    this.buttonState = MoleculeActionButtonState.idle,
    this.titleWidget,
    this.minWidth = 200,
    this.maxWidth = 400,
    this.color,
  }) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = this.color ?? ref.scheme.primary;
    final bg = primaryButton ? color : ref.scheme.paperCard;
    final fg = primaryButton ? ref.scheme.light : ref.scheme.primary;
    return ProgressButton(
      minWidth: minWidth,
      maxWidth: maxWidth,
      radius: moleculeButtonRadius,
      height: moleculeButtonHeight,
      progressIndicator: CircularProgressIndicator(
        backgroundColor: Colors.transparent,
        strokeWidth: 0.5,
        valueColor: AlwaysStoppedAnimation<Color>(ref.scheme.light),
      ),
      progressIndicatorAlignment: MainAxisAlignment.center,
      progressIndicatorSize: moleculeButtonHeight / 3.0 * 2,
      stateWidgets: {
        ButtonState.idle: titleWidget ?? title.textBold.color(fg),
        ButtonState.loading: loadingTitle.textBold.color(fg),
        ButtonState.fail: failTitle.textBold.color(fg),
        ButtonState.success: successTitle.textBold.color(fg),
      },
      stateColors: {
        ButtonState.idle: bg,
        ButtonState.loading: bg,
        ButtonState.fail: ref.scheme.negative,
        ButtonState.success: ref.scheme.positive,
      },
      disabledColor: ref.scheme.secondary,
      onPressed: onPressed,
      state: _mapButtonState(buttonState),
    );
  }

  ButtonState _mapButtonState(MoleculeActionButtonState buttonState) {
    switch (buttonState) {
      case MoleculeActionButtonState.idle:
        return ButtonState.idle;
      case MoleculeActionButtonState.loading:
        return ButtonState.loading;
      case MoleculeActionButtonState.success:
        return ButtonState.success;
      case MoleculeActionButtonState.fail:
        return ButtonState.fail;
    }
  }
}

// eof
