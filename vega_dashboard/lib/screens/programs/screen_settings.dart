import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../screen_app.dart";
import "screen_edit.dart";

class SettingsScreen extends VegaScreen {
  final Program program;
  const SettingsScreen({required this.program, super.key});

  @override
  createState() => _SettingsState();
}

class _SettingsState extends VegaScreenState<SettingsScreen> {
  Program get program => widget.program;

  final _pluralZeroController = TextEditingController();
  final _pluralOneController = TextEditingController();
  final _pluralTwoController = TextEditingController();
  final _pluralFewController = TextEditingController();
  final _pluralManyController = TextEditingController();
  final _pluralOtherController = TextEditingController();

  final _actionAddController = TextEditingController();
  final _actionSubtractController = TextEditingController();

  final _scanningRatioController = TextEditingController();
  final _reservationsRatioController = TextEditingController();
  final _ordersRatioController = TextEditingController();

  final _precisionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _pluralZeroController.dispose();
    _pluralOneController.dispose();
    _pluralTwoController.dispose();
    _pluralFewController.dispose();
    _pluralManyController.dispose();
    _pluralOtherController.dispose();

    _actionAddController.dispose();
    _actionSubtractController.dispose();

    _scanningRatioController.dispose();
    _reservationsRatioController.dispose();
    _ordersRatioController.dispose();

    _precisionController.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _pluralZeroController.text = program.meta?["plural"]?["zero"] ?? program.plural?.zero ?? "";
      _pluralOneController.text = program.meta?["plural"]?["one"] ?? program.plural?.one ?? "";
      _pluralTwoController.text = program.meta?["plural"]?["two"] ?? program.plural?.two ?? "";
      _pluralFewController.text = program.meta?["plural"]?["few"] ?? program.plural?.few ?? "";
      _pluralManyController.text = program.meta?["plural"]?["many"] ?? program.plural?.many ?? "";
      _pluralOtherController.text = program.meta?["plural"]?["other"] ?? program.plural?.other ?? "";

      _actionAddController.text = program.meta?["actions"]?["addition"] ?? program.actions?.addition ?? "";
      _actionSubtractController.text = program.meta?["actions"]?["subtraction"] ?? program.actions?.subtraction ?? "";

      _scanningRatioController.text = program.qrCodeScanningRatio.toString();
      _reservationsRatioController.text = program.reservationsRatio.toString();
      _ordersRatioController.text = program.ordersRatio.toString();

      _precisionController.text = program.digits.toString();
    });
  }

  @override
  String? getTitle() => LangKeys.screenProgramSettingsTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    return [
      const MoleculeItemHorizontalSpace(),
      Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: _buildConfirmButton(),
      ),
      if (F().isInternal && kDebugMode) ...[
        const MoleculeItemHorizontalSpace(),
        Padding(
          padding: const EdgeInsets.all(moleculeScreenPadding / 2),
          child: _buildTestButton(),
        ),
      ],
      VegaMenuButton(
        items: [
          PopupMenuItem(
            child: MoleculeItemBasic(
              title: LangKeys.buttonProgramToPoints.tr(),
              onAction: () {
                context.pop();
                _resetAsPointProgram(context);
              },
            ),
          ),
          PopupMenuItem(
            child: MoleculeItemBasic(
              title: LangKeys.buttonProgramToCredit.tr(),
              onAction: () {
                context.pop();
                _resetAsCreditProgram(context);
              },
            ),
          ),
        ],
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  String _pluralHint(String key) {
    String translated = key.tr();
    if (translated.isEmpty) {
      return LangKeys.labelPluralDoNotFill.tr();
    }
    return translated;
  }

  String? _validatePluralFormat(String? val) {
    if (val == null || val.isEmpty) return null;
    if (!val.contains("{}")) return LangKeys.validationPluralInvalidFormat.tr();
    return null;
  }

  void _resetAsPointProgram(BuildContext context) {
    _pluralZeroController.text = LangKeys.defaultProgramPointsZero.tr();
    _pluralOneController.text = LangKeys.defaultProgramPointsOne.tr();
    _pluralTwoController.text = LangKeys.defaultProgramPointsTwo.tr();
    _pluralFewController.text = LangKeys.defaultProgramPointsFew.tr();
    _pluralManyController.text = LangKeys.defaultProgramPointsMany.tr();
    _pluralOtherController.text = LangKeys.defaultProgramPointsOther.tr();

    _actionAddController.text = LangKeys.defaultProgramActionAdd.tr();
    _actionSubtractController.text = LangKeys.defaultProgramActionSubtract.tr();

    _scanningRatioController.text = "1";
    _reservationsRatioController.text = "1";
    _ordersRatioController.text = "1";
  }

  void _resetAsCreditProgram(BuildContext context) {
    final lang = context.languageCode;
    final currency = (ref.read(deviceRepository).get(DeviceKey.client) as Client?)?.currency ?? Currency.usd;

    _pluralZeroController.text = currency.formatCode(currency.collapse(0), lang);
    _pluralOneController.text = currency.formatCode(currency.collapse(1), lang);
    _pluralTwoController.text = currency.formatCode(currency.collapse(2), lang);
    _pluralFewController.text = "{} ${currency.code}";
    _pluralManyController.text = "{} ${currency.code}";
    _pluralOtherController.text = "{} ${currency.code}";

    _actionAddController.text = LangKeys.defaultProgramCreditAdd.tr();
    _actionSubtractController.text = LangKeys.defaultProgramCreditSubtract.tr();

    _scanningRatioController.text = "1";
    _reservationsRatioController.text = "1";
    _ordersRatioController.text = "1";
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
              MoleculeItemTitle(header: LangKeys.sectionPrecision.tr()),
              const MoleculeItemSpace(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Flexible(
                    flex: 3,
                    child: MoleculeInput(
                      title: LangKeys.labelDecimalPlaces.tr(),
                      hint: LangKeys.hintProgramDecimalPlaces.tr(),
                      controller: _precisionController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) => (val?.isNotEmpty ?? false) && isInt(val!, min: 0, max: 12)
                          ? null
                          : LangKeys.validationProgramDecimalPlaces.tr(args: [0.toString(), 12.toString()]),
                    ),
                  ),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(
                    child: MoleculeSecondaryButton(
                      titleText: LangKeys.buttonWholeNumber.tr(),
                      onTap: () {
                        _precisionController.text = "0";
                      },
                    ),
                  ),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(
                    child: MoleculeSecondaryButton(
                      titleText: LangKeys.buttonCurrency.tr(),
                      onTap: () {
                        _precisionController.text = "2";
                      },
                    ),
                  ),
                ],
              ),
              const MoleculeItemSpace(),
              const MoleculeItemSeparator(),
              const MoleculeItemSpace(),
              const MoleculeItemSpace(),
              MoleculeItemTitle(header: LangKeys.sectionPlural.tr()),
              const MoleculeItemSpace(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: MoleculeInput(
                      title: LangKeys.labelPluralZero.tr(),
                      hint: _pluralHint(LangKeys.labelPluralZeroHint),
                      controller: _pluralZeroController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) => val?.isEmpty == true ? LangKeys.validationValueRequired.tr() : null,
                    ),
                  ),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(
                    child: MoleculeInput(
                      title: LangKeys.labelPluralOne.tr(),
                      hint: _pluralHint(LangKeys.labelPluralOneHint),
                      controller: _pluralOneController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) => val?.isEmpty == true ? LangKeys.validationValueRequired.tr() : null,
                    ),
                  ),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(
                    child: MoleculeInput(
                      title: LangKeys.labelPluralTwo.tr(),
                      hint: _pluralHint(LangKeys.labelPluralTwoHint),
                      controller: _pluralTwoController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) => val?.isEmpty == true ? LangKeys.validationValueRequired.tr() : null,
                    ),
                  ),
                ],
              ),
              const MoleculeItemSpace(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: MoleculeInput(
                      title: LangKeys.labelPluralFew.tr(),
                      hint: _pluralHint(LangKeys.labelPluralFewHint),
                      controller: _pluralFewController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) => _validatePluralFormat(val),
                    ),
                  ),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(
                    child: MoleculeInput(
                      title: LangKeys.labelPluralMany.tr(),
                      hint: _pluralHint(LangKeys.labelPluralManyHint),
                      controller: _pluralManyController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) => _validatePluralFormat(val),
                    ),
                  ),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(
                    child: MoleculeInput(
                      title: "label_plural_other".tr(),
                      hint: _pluralHint(LangKeys.labelPluralOtherHint),
                      controller: _pluralOtherController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) => _validatePluralFormat(val),
                    ),
                  ),
                ],
              ),
              const MoleculeItemSpace(),
              const MoleculeItemSeparator(),
              const MoleculeItemSpace(),
              const MoleculeItemSpace(),
              MoleculeItemTitle(header: LangKeys.sectionActionButtons.tr()),
              const MoleculeItemSpace(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: MoleculeInput(
                      title: LangKeys.labelActionAdd.tr(),
                      hint: LangKeys.labelActionAddHint.tr(),
                      controller: _actionAddController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) => val?.isEmpty == true ? LangKeys.validationValueRequired.tr() : null,
                    ),
                  ),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(
                    child: MoleculeInput(
                      title: LangKeys.labelActionSubtract.tr(),
                      hint: LangKeys.labelActionSubtractHint.tr(),
                      controller: _actionSubtractController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) => val?.isEmpty == true ? LangKeys.validationValueRequired.tr() : null,
                    ),
                  ),
                ],
              ),
              const MoleculeItemSpace(),
              const MoleculeItemSeparator(),
              const MoleculeItemSpace(),
              const MoleculeItemSpace(),
              MoleculeItemTitle(header: LangKeys.sectionConversion.tr()),
              const MoleculeItemSpace(),
              Row(
                children: [
                  Expanded(
                    child: MoleculeInput(
                      title: LangKeys.labelScanningRatio.tr(),
                      controller: _scanningRatioController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) =>
                          double.tryParse(val ?? "") == null ? LangKeys.validationValueInvalid.tr() : null,
                    ),
                  ),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(
                    child: MoleculeInput(
                      title: LangKeys.labelReservationsRatio.tr(),
                      controller: _reservationsRatioController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) =>
                          double.tryParse(val ?? "") == null ? LangKeys.validationValueInvalid.tr() : null,
                    ),
                  ),
                  const MoleculeItemHorizontalSpace(),
                  Expanded(
                    child: MoleculeInput(
                      title: LangKeys.labelOrdersRatio.tr(),
                      controller: _ordersRatioController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (val) =>
                          double.tryParse(val ?? "") == null ? LangKeys.validationValueInvalid.tr() : null,
                    ),
                  ),
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

        String? zero = _pluralZeroController.text.isNotEmpty ? _pluralZeroController.text : null;
        String? one = _pluralOneController.text.isNotEmpty ? _pluralOneController.text : null;
        String? two = _pluralTwoController.text.isNotEmpty ? _pluralTwoController.text : null;
        String? few = _pluralFewController.text.isNotEmpty ? _pluralFewController.text : null;
        String? many = _pluralManyController.text.isNotEmpty ? _pluralManyController.text : null;
        String other = _pluralOtherController.text;

        final plural = Plural(
          zero: zero,
          one: one,
          two: two,
          few: few,
          many: many,
          other: other,
        );

        final actions = ProgramActions(
          addition: _actionAddController.text,
          subtraction: _actionSubtractController.text,
        );

        ref.read(programEditorLogic.notifier).set(
              plural: plural,
              actions: actions,
              qrCodeScanningRatio: double.tryParse(_scanningRatioController.text) ?? 1,
              reservationsRatio: double.tryParse(_reservationsRatioController.text) ?? 1,
              ordersRatio: double.tryParse(_ordersRatioController.text) ?? 1,
              digits: int.tryParse(_precisionController.text) ?? 0,
            );

        notifyUnsaved(EditScreen.notificationsTag);
        context.pop();
      },
    );
  }

  Widget _buildTestButton() {
    final locale = context.languageCode;
    return MoleculeSecondaryButton(
      titleText: "Test",
      onTap: () {
        if (_formKey.currentState?.validate() != true) return;

        String? zero = _pluralZeroController.text.isNotEmpty ? _pluralZeroController.text : null;
        String? one = _pluralOneController.text.isNotEmpty ? _pluralOneController.text : null;
        String? two = _pluralTwoController.text.isNotEmpty ? _pluralTwoController.text : null;
        String? few = _pluralFewController.text.isNotEmpty ? _pluralFewController.text : null;
        String? many = _pluralManyController.text.isNotEmpty ? _pluralManyController.text : null;
        String other = _pluralOtherController.text;

        final plural = Plural(
          zero: zero,
          one: one,
          two: two,
          few: few,
          many: many,
          other: other,
        );

        print(formatAmount(locale, plural, 0));
        print(formatAmount(locale, plural, 1));
        print(formatAmount(locale, plural, 2));
        print(formatAmount(locale, plural, 3));
        print(formatAmount(locale, plural, 4));
        print(formatAmount(locale, plural, 6.5));
        print(formatAmount(locale, plural, 100));
      },
    );
  }
}

// eof
