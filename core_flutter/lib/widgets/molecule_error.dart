import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core_flutter.dart";

class MoleculeErrorWidget extends ConsumerStatefulWidget {
  final String? message;
  final String? messageKey;
  final String icon;
  final Color? iconColor;
  final String? primaryButton;
  final void Function()? onPrimaryAction;
  final String? secondaryButton;
  final void Function()? onSecondaryAction;

  const MoleculeErrorWidget({
    this.message,
    this.messageKey,
    this.icon = AtomIcons.xCircle,
    this.iconColor,
    this.primaryButton,
    this.onPrimaryAction,
    this.secondaryButton,
    this.onSecondaryAction,
    Key? key,
  }) : super(key: key);

  @override
  createState() => _WidgetState();
}

class _WidgetState extends ConsumerState<MoleculeErrorWidget> {
  final GlobalKey _columnKey = GlobalKey();
  double? _columnHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, viewportConstraints) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final renderBoxRed = _columnKey.currentContext!.findRenderObject() as RenderBox?;
        _columnHeight = renderBoxRed?.size.height;
        setState(() {});
      });
      return SingleChildScrollView(
        physics: (_columnHeight ?? 0) > viewportConstraints.maxHeight
            ? vegaScrollPhysic
            : const NeverScrollableScrollPhysics(),
        child: Column(
          key: _columnKey,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MoleculeItemDoubleSpace(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeItemDoublePadding),
              child: SizedBox(
                width: 128,
                height: 128,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ref.scheme.paperBold,
                  ),
                  child: Center(
                    child: VegaIcon(
                      name: widget.icon,
                      size: 85,
                      color: widget.iconColor ?? ref.scheme.negative,
                    ),
                  ),
                ),
              ),
            ),
            const MoleculeItemDoubleSpace(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeItemDoublePadding),
              child: (widget.message ?? widget.messageKey?.tr()).text.alignCenter.color(ref.scheme.content50),
            ),
            //const MoleculusItemDoubleSpace(),
            if (widget.primaryButton != null) ...[
              const MoleculeItemSpace(),
              MoleculePrimaryButton(
                titleText: widget.primaryButton,
                onTap: widget.onPrimaryAction,
              )
            ],
            if (widget.secondaryButton != null) ...[
              const MoleculeItemSpace(),
              MoleculeSecondaryButton(
                titleText: widget.secondaryButton,
                onTap: () => widget.onSecondaryAction?.call(),
              )
            ],
          ],
        ),
      );
    });
  }
}

// eof
