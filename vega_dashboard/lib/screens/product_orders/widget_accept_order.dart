import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/molecule_picker.dart";
import "../dialog.dart";

class AcceptOrderWidget extends ConsumerStatefulWidget {
  final UserOrder userOrder;
  const AcceptOrderWidget({super.key, required this.userOrder});

  @override
  createState() => _AcceptOrderWidgetState();
}

class _AcceptOrderWidgetState extends ConsumerState<AcceptOrderWidget> {
  int? _selectedEstimate;
  int? _selectedCustomDays;
  int? _selectedCustomHours;
  int? _selectedCustomMinutes;

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
              Expanded(child: LangKeys.labelGiveOrderEstimate.tr().h3),
            ],
          ),
          const MoleculeItemSpace(),
          _buildRadioBox("15min", 15),
          _buildRadioBox("30min", 30),
          _buildRadioBox("45min", 45),
          _buildRadioBox("60min", 60),
          _buildRadioBox("1h 30min", 90),
          _buildRadioBox("2h", 120),
          _buildRadioBox("3h", 180),
          _buildCustomEstimate(),
          const MoleculeItemSpace(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: _buildCancelButton(context)),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildConfirmButton(context, ref)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return MoleculeSecondaryButton(
      titleText: LangKeys.buttonCloseWindow.tr(),
      onTap: () {
        context.pop();
      },
    );
  }

  Widget _buildConfirmButton(BuildContext context, WidgetRef ref) {
    return MoleculePrimaryButton(
      titleText: LangKeys.buttonConfirm.tr(),
      onTap: () {
        DateTime? deliveryEstimate;
        if (_selectedEstimate != null && _selectedEstimate != 999) {
          deliveryEstimate = DateTime.now().add(Duration(minutes: _selectedEstimate!));
        } else if (_selectedEstimate != null) {
          deliveryEstimate = DateTime.now().add(Duration(
            days: _selectedCustomDays!,
            hours: _selectedCustomHours!,
            minutes: _selectedCustomMinutes!,
          ));
        }
        showWaitDialog(context, ref, LangKeys.toastAcceptingOrder.tr(args: [widget.userOrder.userNickname]));
        ref.read(productOrderPatchLogic.notifier).accept(
              widget.userOrder,
              deliveryEstimate: deliveryEstimate,
            );
        context.pop();
      },
    );
  }

  Widget _buildRadioBox(
    String title,
    int minutesEstimated,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Radio<int>(
          value: minutesEstimated,
          groupValue: _selectedEstimate,
          onChanged: (int? value) {
            setState(() {
              _selectedEstimate = value!;
            });
          },
        ),
        const MoleculeItemHorizontalSpace(),
        Expanded(
          child: title.text,
        ),
      ],
    );
  }

  Widget _buildCustomEstimate() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Radio<int>(
          value: 999,
          groupValue: _selectedEstimate,
          onChanged: (int? value) {
            setState(() {
              _selectedEstimate = value!;
            });
          },
        ),
        const MoleculeItemHorizontalSpace(),
        Expanded(
          child: LangKeys.labelCustom.tr().text,
        ),
        const MoleculeItemHorizontalSpace(),
        Expanded(
          child: MoleculeSingleSelect(
            title: "dni".tr(),
            hint: "",
            items: [
              SelectItem(label: "0d", value: "0"),
              SelectItem(label: "1d", value: "1"),
              SelectItem(label: "2d", value: "2"),
              SelectItem(label: "3d", value: "3"),
              SelectItem(label: "4d", value: "4"),
              SelectItem(label: "5d", value: "5"),
              SelectItem(label: "6d", value: "6"),
              SelectItem(label: "7d", value: "7"),
            ],
            selectedItem: SelectItem(label: "0d", value: "0"),
            onChanged: (SelectItem? selectedItem) {
              _selectedCustomDays = int.parse(selectedItem!.value);
            },
          ),
        ),
        Expanded(
          child: MoleculeSingleSelect(
            title: "hodiny".tr(),
            hint: "",
            items: [
              SelectItem(label: "0h", value: "0"),
              SelectItem(label: "1h", value: "1"),
              SelectItem(label: "2h", value: "2"),
              SelectItem(label: "3h", value: "3"),
              SelectItem(label: "4h", value: "4"),
              SelectItem(label: "5h", value: "5"),
              SelectItem(label: "6h", value: "6"),
              SelectItem(label: "7h", value: "7"),
              SelectItem(label: "8h", value: "8"),
              SelectItem(label: "9h", value: "9"),
              SelectItem(label: "10h", value: "10"),
              SelectItem(label: "11h", value: "11"),
              SelectItem(label: "12h", value: "12"),
              SelectItem(label: "13h", value: "13"),
              SelectItem(label: "14h", value: "14"),
              SelectItem(label: "15h", value: "15"),
              SelectItem(label: "16h", value: "16"),
              SelectItem(label: "17h", value: "17"),
              SelectItem(label: "18h", value: "18"),
              SelectItem(label: "19h", value: "19"),
              SelectItem(label: "20h", value: "20"),
              SelectItem(label: "21h", value: "21"),
              SelectItem(label: "22h", value: "22"),
              SelectItem(label: "23h", value: "23"),
            ],
            selectedItem: SelectItem(label: "0h", value: "0"),
            onChanged: (SelectItem? selectedItem) {
              _selectedCustomHours = int.parse(selectedItem!.value);
            },
          ),
        ),
        Expanded(
          child: MoleculeSingleSelect(
            title: "minuty".tr(),
            hint: "",
            items: [
              SelectItem(label: "0min", value: "0"),
              SelectItem(label: "15min", value: "15"),
              SelectItem(label: "30min", value: "30"),
              SelectItem(label: "45min", value: "45"),
            ],
            selectedItem: SelectItem(label: "0min", value: "0"),
            onChanged: (SelectItem? selectedItem) {
              _selectedCustomMinutes = int.parse(selectedItem!.value);
            },
          ),
        ),
      ],
    );
  }
}
