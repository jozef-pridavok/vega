import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:vega_dashboard/strings.dart";

class ScreenNumberInput extends Screen {
  final String title;
  final String label;
  final int digits;
  final Plural? plural;

  const ScreenNumberInput({super.key, required this.title, required this.label, this.digits = 0, this.plural});

  @override
  createState() => _NumberInputState();
}

class _NumberInputState extends ScreenState<ScreenNumberInput> {
  String get _title => widget.title;
  String get _label => widget.label;
  Plural? get _plural => widget.plural;

  final _formKey = GlobalKey<FormState>();
  final _focusNode = FocusNode();
  final _controller = TextEditingController();

  late FixedPoint fixedPoint = FixedPoint.digits(widget.digits);

  String suffix = "";

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: _title, //?? LangKeys.screenNumberInputTitle.tr(),
        cancel: true,
      );

  @override
  Widget buildBody(BuildContext context) {
    final lang = context.languageCode;
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: Form(
          key: _formKey,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: !isMobile ? ScreenFactor.tablet : double.infinity),
            child: AutoScrollColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const MoleculeItemSpace(),
                MoleculeInput(
                  controller: _controller,
                  focusNode: _focusNode,
                  autovalidateMode: AutovalidateMode.always,
                  inputAction: TextInputAction.done,
                  capitalization: TextCapitalization.none,
                  inputType: TextInputType.number,
                  autocorrect: false,
                  enableSuggestions: false,
                  title: _label,
                  hint: "123",
                  validator: (value) {
                    if (value?.isEmpty ?? true) return LangKeys.validationValueRequired.tr();
                    if (!((fixedPoint.parse(value) ?? 0) >= fixedPoint.expand(1)))
                      return LangKeys.validationMinimalNumber.tr(args: [fixedPoint.format(1, lang)]);
                    //if (!isInt(value!, min: 1)) return LangKeys.validationMinimalNumber.tr(args: ["1"]);
                    return null;
                  },
                  onFieldSubmitted: (value) => _tryClose(),
                  onChanged: (value) {
                    int? amount = fixedPoint.parse(value);
                    setState(() {
                      suffix = _plural != null && amount != null
                          ? formatAmount(lang, _plural, amount, digits: fixedPoint.digits) ?? ""
                          : "";
                    });
                  },
                  suffixText: suffix,
                ),
                const MoleculeItemSpace(),
                MoleculePrimaryButton(
                  titleText: LangKeys.buttonConfirm.tr(),
                  onTap: () => _tryClose(),
                ),
                const MoleculeItemSpace(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _tryClose() {
    if (_formKey.currentState!.validate()) {
      //int? points = tryParseInt(_controller.text);
      int? points = fixedPoint.parse(_controller.text);
      if (points != null) context.pop<int>(points);
      return;
    }
    _focusNode.requestFocus();
  }
}

// eof
