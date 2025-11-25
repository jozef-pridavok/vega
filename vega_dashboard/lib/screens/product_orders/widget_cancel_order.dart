import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../dialog.dart";

class CancelOrderWidget extends ConsumerStatefulWidget {
  final UserOrder userOrder;
  const CancelOrderWidget({super.key, required this.userOrder});

  @override
  createState() => _CancelOrderWidgetState();
}

class _CancelOrderWidgetState extends ConsumerState<CancelOrderWidget> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _reasonController.dispose();
  }

  void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.labelCancelOrder.tr().text,
        content: build(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: LangKeys.labelCancelOrderReason.tr().h3),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _buildReason()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _buildCloseButton(context)),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildCancelButton(context, ref)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return MoleculeSecondaryButton(
      titleText: LangKeys.buttonCloseWindow.tr(),
      onTap: () {
        context.pop();
      },
    );
  }

  Widget _buildCancelButton(BuildContext context, WidgetRef ref) {
    return MoleculePrimaryButton(
      titleText: LangKeys.buttonCancelOrder.tr(),
      color: ref.scheme.negative,
      onTap: () {
        showWaitDialog(context, ref, LangKeys.toastCancellingOrder.tr(args: [widget.userOrder.userNickname]));
        ref.read(productOrderPatchLogic.notifier).cancel(
              widget.userOrder,
              cancelledReason: _reasonController.text,
            );
      },
    );
  }

  Widget _buildReason() => MoleculeInput(
        controller: _reasonController,
        maxLines: 5,
        onChanged: (value) => (),
      );
}
