import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/coupon_code.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../utils/input_formatters.dart";
import "../../widgets/data_grid.dart";
import "../screen_app.dart";

class EditCouponCodesScreen extends VegaScreen {
  final List<String> codes;
  const EditCouponCodesScreen(this.codes, {super.key});

  @override
  createState() => _EditState();
}

class _EditState extends VegaScreenState<EditCouponCodesScreen> {
  List<String> get _codes => widget.codes;
  final _formKey = GlobalKey<FormState>();

  final _countController = TextEditingController();
  final _maskShapeController = TextEditingController();
  final _maskTypeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _countController.text = "25";
      _maskShapeController.text = "***-***";
      _maskTypeController.text = CouponCodeMaskType.onlyUpperCase.name;
      ref.read(couponCodesGeneratorLogic.notifier).beginEdit(_codes);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _countController.dispose();
    _maskShapeController.dispose();
    _maskTypeController.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenEditCouponCodeTitle.tr();

  @override
  List<Widget>? buildAppBarActions() => [
        Padding(
          padding: const EdgeInsets.all(moleculeScreenPadding / 2),
          child: _buildGenerateButton(),
        ),
      ];

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: isMobile ? _mobileLayout() : _defaultLayout(),
    );
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<CouponCodesGeneratorState>(couponCodesGeneratorLogic, (previous, next) async {
      if (next is CouponCodesEditing) {
        ref.read(couponEditorLogic.notifier).set(codes: next.codes.map((generatedCode) => generatedCode.code).toList());
      }
    });
  }

  // TODO: Mobile layout
  Widget _mobileLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(child: _buildCount()),
                      const MoleculeItemHorizontalSpace(),
                      Flexible(child: _buildShape()),
                      const MoleculeItemHorizontalSpace(),
                      Flexible(child: _buildMaskType()),
                    ],
                  ),
                  const MoleculeItemSpace()
                ],
              ),
            ),
          ),
          Expanded(
            child: _GridWidget(),
          ),
        ],
      );

  Widget _defaultLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(child: _buildCount()),
                      const MoleculeItemHorizontalSpace(),
                      Flexible(child: _buildShape()),
                      const MoleculeItemHorizontalSpace(),
                      Flexible(child: _buildMaskType()),
                    ],
                  ),
                  const MoleculeItemSpace()
                ],
              ),
            ),
          ),
          Expanded(
            child: _GridWidget(),
          ),
        ],
      );

  Widget _buildCount() => MoleculeInput(
        title: LangKeys.couponCodeCountLabel.tr(),
        controller: _countController,
        validator: (value) => value!.isEmpty ? LangKeys.couponCodeCountRequired.tr() : null,
        maxLines: 1,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          MaxValueInputFormatter(2000),
        ],
      );

  Widget _buildShape() => MoleculeInput(
        title: LangKeys.couponMaskShapeLabel.tr(),
        controller: _maskShapeController,
        validator: (value) => value!.isEmpty ? LangKeys.couponCodeMaskShapeRequired.tr() : null,
        maxLines: 1,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r"[*\- ]"))],
      );

  Widget _buildMaskType() {
    return MoleculeInput(
      title: LangKeys.couponCodeMaskTypeLabel.tr(),
      controller: _maskTypeController,
      suffixIcon: const VegaIcon(name: AtomIcons.chevronDown),
      inputAction: TextInputAction.done,
      enableSuggestions: false,
      readOnly: true,
      maxLines: 1,
      enableInteractiveSelection: false,
      onTap: () => _pickMaskType(context),
    );
  }

  void _pickMaskType(BuildContext context) {
    // TODO: layout
    final isMobile = kDebugMode && ref.watch(layoutLogic).isMobile;
    isMobile
        ? showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: moleculeBottomSheetBorder,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) => DraggableScrollableSheet(
                  expand: false,
                  initialChildSize: 0.66,
                  minChildSize: 0.66,
                  maxChildSize: 0.90,
                  builder: (context, scrollController) => _buildMaskTypePicker(context),
                ),
              );
            },
          )
        : showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: LangKeys.pickCodeMaskTypeLabel.tr().text,
              content: _buildMaskTypePicker(context),
            ),
          );
  }

  Widget _buildMaskTypePicker(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...CouponCodeMaskType.values.map(
            (type) => MoleculeItemBasic(
              title: type.localizedName,
              onAction: () {
                _maskTypeController.text = type.name;
                ref.read(couponCodesGeneratorLogic.notifier).set(codeMaskType: type);
                context.pop();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    return MoleculeActionButton(
      title: LangKeys.generateButton.tr(),
      onPressed: () {
        final codeCount = tryParseInt(_countController.text);
        if (codeCount == null || codeCount < 1) return;
        ref.read(couponCodesGeneratorLogic.notifier).generateCodes(codeCount, _maskShapeController.text);
      },
    );
  }
}

class _GridWidget extends ConsumerWidget {
  const _GridWidget();

  static const _columnOrder = "order";
  static const _columnCode = "code";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(couponCodesGeneratorLogic) as CouponCodesEditing;
    final codes = state.codes;
    return PullToRefresh(
      onRefresh: () async {},
      child: DataGrid<GeneratedCouponCodes>(
        rows: codes,
        columns: [
          DataGridColumn(name: _columnOrder, label: LangKeys.columnOrder.tr()),
          DataGridColumn(name: _columnCode, label: LangKeys.columnCode.tr()),
        ],
        onBuildCell: (column, code) => _buildCell(context, ref, column, code),
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, GeneratedCouponCodes generatedCode) {
    final columnMap = <String, Widget>{
      _columnOrder: generatedCode.order.toString().text.color(ref.scheme.content),
      _columnCode: generatedCode.code.text.color(ref.scheme.content),
    };
    return columnMap[column] ?? "?".text.color(ref.scheme.content);
  }
}

// eof
