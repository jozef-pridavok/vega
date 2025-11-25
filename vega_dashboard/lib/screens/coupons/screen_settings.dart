import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../screen_app.dart";
import "screen_edit.dart";

class SettingsScreen extends VegaScreen {
  final Coupon coupon;
  const SettingsScreen({required this.coupon, super.key});

  @override
  createState() => _SettingsState();
}

class _SettingsState extends VegaScreenState<SettingsScreen> {
  Coupon get coupon => widget.coupon;

  final _userIssueLimitController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _userIssueLimitController.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _userIssueLimitController.text = coupon.meta?["userIssueLimit"]?.toString() ?? "1";
    });
  }

  @override
  String? getTitle() => LangKeys.screenCouponSettingsTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    return [
      const MoleculeItemHorizontalSpace(),
      Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: _buildConfirmButton()),
      VegaMenuButton(
        items: [
          PopupMenuItem(
            child: MoleculeItemBasic(
              title: LangKeys.buttonProgramToPoints.tr(),
              onAction: () => _resetToDefault(context),
            ),
          ),
        ],
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  void _resetToDefault(BuildContext context) {
    _userIssueLimitController.text = "1";
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: MoleculeInput(
                      title: LangKeys.labelUserIssueLimit.tr(),
                      controller: _userIssueLimitController,
                      validator: (value) => value!.isEmpty
                          ? LangKeys.couponUserIssueLimitRequired.tr()
                          : tryParseInt(value)! < 0
                              ? LangKeys.validationValueInvalid
                              : null,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    flex: 1,
                  ),
                  const MoleculeItemHorizontalSpace(),
                  Flexible(child: SizedBox(width: moleculeScreenPadding)),
                  const MoleculeItemHorizontalSpace(),
                  Flexible(child: SizedBox(width: moleculeScreenPadding)),
                ],
              ),
              const MoleculeItemSpace(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return MoleculeActionButton(
      title: LangKeys.buttonConfirm.tr(),
      onPressed: () {
        if (_formKey.currentState?.validate() != true) return;
        ref.read(couponEditorLogic.notifier).set(
              userIssueLimit: int.parse(_userIssueLimitController.text),
            );
        notifyUnsaved(ScreenCouponEdit.notificationsTag);
        context.pop();
      },
    );
  }
}

// eof
