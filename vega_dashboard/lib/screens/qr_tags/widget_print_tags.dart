import "package:core_flutter/app/flavors.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pw;
import "package:printing/printing.dart";

import "../../extensions/print_size.dart";
import "../../extensions/select_item.dart";
import "../../states/providers.dart";
import "../../states/qr_tags_editor.dart";
import "../../strings.dart";
import "../../widgets/molecule_picker.dart";
import "../dialog.dart";
import "../screen_app.dart";

class PrintTagsWidget extends ConsumerStatefulWidget {
  final Program program;
  PrintTagsWidget({super.key, required this.program});

  @override
  createState() => _PrintTagsWidgetState();
}

class _PrintTagsWidgetState extends ConsumerState<PrintTagsWidget> {
  Program get program => widget.program;

  static const tagMargin = 10;
  static final double qrTagPadding = tagMargin.toDouble() / 3;
  static const double qrSizedBoxHeight = 2;

  final _numberOfPointsController = TextEditingController();
  final _numberOfTagsController = TextEditingController();
  final _sizeOfTagsController = TextEditingController();

  PrintSize _format = PrintSize.a4;
  PrintOrientation _orientation = PrintOrientation.portrait;

  final _qrBuilder = F().qrBuilder;
  late pw.Document _doc;
  final List<String> _generatedTags = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _numberOfPointsController.text = "10";
      _numberOfTagsController.text = "20";
      _sizeOfTagsController.text = "30";
      createQrTags();
    });
  }

  void createQrTags() {
    _doc = pw.Document();

    _generatedTags.clear();

    final lang = context.languageCode;

    final programName = program.name;

    int tagCount = int.parse(_numberOfTagsController.text);
    final tagSize = int.parse(_sizeOfTagsController.text);
    final pageFormat = _format.toPdfPageFormat();

    final qrFontSize = tagSize / 7.5;

    final page = pw.MultiPage(
      pageFormat: pageFormat,
      orientation: _orientation.toPageOrientation(),
      build: (pw.Context context) {
        return [
          pw.Wrap(
            children: List.generate(
              tagCount,
              (index) {
                final qrTagId = uuid();
                _generatedTags.add(qrTagId);
                final fixedPoint = FixedPoint.digits(program.digits);
                final points = fixedPoint.parse(_numberOfPointsController.text) ?? 0;
                final valueText = formatAmount(lang, program.plural, points, digits: program.digits) ?? "";
                // split valueText by space
                final valueTextParts = valueText.split(" ");
                return pw.Padding(
                  padding: pw.EdgeInsets.only(right: tagMargin.toDouble(), bottom: tagMargin.toDouble()),
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 1.0, style: pw.BorderStyle.dashed),
                    ),
                    child: pw.Padding(
                      padding: pw.EdgeInsets.all(qrTagPadding),
                      child: pw.Column(
                        mainAxisSize: pw.MainAxisSize.min,
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.BarcodeWidget(
                            data: _qrBuilder.generateQrTagWithPoints(qrTagId),
                            barcode: pw.Barcode.qrCode(),
                            width: tagSize.toDouble(),
                            height: tagSize.toDouble(),
                          ),
                          pw.SizedBox(height: tagMargin / 4),
                          pw.SizedBox(
                            width: tagSize.toDouble(),
                            child: pw.RichText(
                              textAlign: pw.TextAlign.center,
                              text: pw.TextSpan(
                                style: pw.TextStyle(fontSize: qrFontSize),
                                children: [
                                  pw.TextSpan(
                                    text: "$programName\n",
                                  ),
                                  if (valueTextParts.isNotEmpty)
                                    pw.TextSpan(
                                      text: valueTextParts[0],
                                      style: pw.TextStyle(fontSize: qrFontSize * 2, fontWeight: pw.FontWeight.bold),
                                    ),
                                  if (valueTextParts.length > 1)
                                    pw.TextSpan(
                                      text: " ${valueTextParts.skip(1).join(" ")}",
                                      style: pw.TextStyle(fontSize: qrFontSize),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ];
      },
    );
    _doc.addPage(page);
  }

  @override
  void dispose() {
    super.dispose();
    _numberOfPointsController.dispose();
    _numberOfTagsController.dispose();
    _sizeOfTagsController.dispose();
  }

  void refresh() {
    setState(() {});
  }

  void _listenToLogic(BuildContext context) {
    ref.listen(printQrTagsLogic, (previous, next) {
      bool failed = next is QrTagsEditorCreateFailed;
      bool operationCompleted = failed || next is QrTagsEditorCreateSucceed;
      if (operationCompleted) {
        closeWaitDialog(context, ref);
        ref.read(printQrTagsLogic.notifier).reset();
        toastInfo(LangKeys.toastQrTagsGenerated.tr());
      }
      if (failed) toastCoreError(next.error);
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToLogic(context);
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return isMobile ? _mobileLayout() : _defaultLayout();
  }

  Widget _mobileLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildNumberOfPoints()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildNumberOfTags()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildSizeOfTags()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildFormat()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildOrientation()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildPrintButton()),
            ],
          ),
          const MoleculeItemSpace(),
          Expanded(child: _buildPrintPreview()),
        ],
      );

  Widget _defaultLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildNumberOfPoints()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildNumberOfTags()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildSizeOfTags()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildFormat()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildOrientation()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildPrintButton()),
            ],
          ),
          const MoleculeItemSpace(),
          Expanded(child: _buildPrintPreview()),
        ],
      );

  Widget _buildNumberOfPoints() => MoleculeInput(
        title: LangKeys.labelNumberOfPoints.tr(),
        controller: _numberOfPointsController,
        maxLines: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value?.isEmpty ?? true) return LangKeys.validationValueRequired.tr();
          if (!isInt(value!, min: 1)) return LangKeys.validationValueInvalid.tr();
          return null;
        },
        onChanged: (value) {
          if (value.isEmpty || !isInt(value, min: 1)) return;
          createQrTags();
          refresh();
        },
      );

  Widget _buildNumberOfTags() => MoleculeInput(
        title: LangKeys.labelNumberOfTags.tr(),
        controller: _numberOfTagsController,
        maxLines: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value?.isEmpty ?? true) return LangKeys.validationValueRequired.tr();
          if (!isInt(value!, min: 1)) return LangKeys.validationValueInvalid.tr();
          return null;
        },
        onChanged: (value) {
          if (value.isEmpty || !isInt(value, min: 1)) return;
          createQrTags();
          refresh();
        },
      );

  Widget _buildSizeOfTags() => MoleculeInput(
        title: LangKeys.labelSizeOfTags.tr(),
        controller: _sizeOfTagsController,
        maxLines: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value?.isEmpty ?? true) return LangKeys.validationValueRequired.tr();
          if (!isInt(value!, min: 5)) return LangKeys.validationValueInvalid.tr();
          return null;
        },
        onChanged: (value) {
          if (value.isEmpty || !isInt(value, min: 5)) return;
          createQrTags();
          refresh();
        },
      );

  Widget _buildFormat() {
    return MoleculeSingleSelect(
        title: LangKeys.labelFormat.tr(),
        hint: "",
        items: PrintSize.values.toSelectItems(),
        selectedItem: PrintSize.a4.toSelectItem(),
        onChanged: (selectedItem) {
          _format = PrintSizeCode.fromCode(int.tryParse(selectedItem.value));
          createQrTags();
          refresh();
        });
  }

  Widget _buildOrientation() {
    return MoleculeSingleSelect(
        title: LangKeys.labelOrientation.tr(),
        hint: "",
        items: PrintOrientation.values.toSelectItems(),
        selectedItem: PrintOrientation.portrait.toSelectItem(),
        onChanged: (selectedItem) {
          _orientation = PrintOrientationCode.fromCode(int.tryParse(selectedItem.value));
          //final data = PdfPreviewController.listen(context);
          createQrTags();
          refresh();
        });
  }

  Widget _buildPrintButton() => Padding(
        padding: const EdgeInsets.only(top: moleculeScreenPadding),
        child: MoleculePrimaryButton(
          titleText: LangKeys.buttonPrint.tr(),
          onTap: () async {
            showWaitDialog(context, ref, LangKeys.toastCreatingTags.tr());
            ref
                .read(printQrTagsLogic.notifier)
                .createMany(_generatedTags, program.programId, int.parse(_numberOfPointsController.text));
            await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => _doc.save());
          },
        ),
      );

  Widget _buildPrintPreview() {
    return PdfPreview(
      build: (format) => _doc.save(),
      useActions: false,
      canChangePageFormat: false,
      canChangeOrientation: true,
      enableScrollToPage: true,
    );
  }
}

// eof
