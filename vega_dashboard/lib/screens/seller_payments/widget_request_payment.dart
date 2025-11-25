import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../strings.dart";
import "../../widgets/molecule_picker_date.dart";
import "../screen_app.dart";

class RequestPaymentWidget extends ConsumerStatefulWidget {
  const RequestPaymentWidget({super.key});

  @override
  createState() => _RequestPaymentWidgetState();
}

class _RequestPaymentWidgetState extends ConsumerState<RequestPaymentWidget> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  var dueDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    //Future.microtask(() => ref.read(requestPaymentLogic.notifier).load());
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: isMobile ? _mobileLayout() : _defaultLayout(),
      ),
    );
  }

  Widget _mobileLayout() {
    final now = DateTime.now();
    final dueDateAvailableFrom = now.add(const Duration(days: 14));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MoleculeInput(
          title: LangKeys.labelRequestPaymentInvoiceNumber.tr(),
          hint: "20241231001",
          controller: _invoiceNumberController,
          validator: (number) {
            if (number?.isEmpty ?? true) return LangKeys.validationValueRequired.tr();
            return null;
          },
        ),
        const MoleculeItemSpace(),
        MoleculeDatePicker(
          title: LangKeys.labelRequestPaymentDueDate.tr(),
          hint: LangKeys.hintRequestPaymentDueDate.tr(),
          initialValue: dueDateAvailableFrom,
          firstDate: dueDateAvailableFrom,
          onChanged: (date) {
            if (date.isBefore(dueDateAvailableFrom)) return toastWarning(LangKeys.validationDueDateInOneMonth.tr());
            dueDate = date;
          },
        ),
        const MoleculeItemSpace(),
        Row(
          children: [
            const Spacer(),
            MoleculeSecondaryButton(onTap: () => _cancel(), titleText: LangKeys.buttonCancel.tr()),
            const MoleculeItemHorizontalSpace(),
            MoleculePrimaryButton(onTap: () => _confirm(), titleText: LangKeys.buttonConfirm.tr()),
          ],
        ),
      ],
    );
  }

  Widget _defaultLayout() {
    final now = DateTime.now();
    final dueDateAvailableFrom = now.add(const Duration(days: 14));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MoleculeInput(
          title: LangKeys.labelRequestPaymentInvoiceNumber.tr(),
          hint: "20241231001",
          controller: _invoiceNumberController,
          validator: (number) {
            if (number?.isEmpty ?? true) return LangKeys.validationValueRequired.tr();
            return null;
          },
        ),
        const MoleculeItemSpace(),
        MoleculeDatePicker(
          title: LangKeys.labelRequestPaymentDueDate.tr(),
          hint: LangKeys.hintRequestPaymentDueDate.tr(),
          initialValue: dueDateAvailableFrom,
          firstDate: dueDateAvailableFrom,
          onChanged: (date) {
            if (date.isBefore(dueDateAvailableFrom)) return toastWarning(LangKeys.validationDueDateInOneMonth.tr());
            dueDate = date;
          },
        ),
        const MoleculeItemSpace(),
        Row(
          children: [
            const Spacer(),
            MoleculeSecondaryButton(onTap: () => _cancel(), titleText: LangKeys.buttonCancel.tr()),
            const MoleculeItemHorizontalSpace(),
            MoleculePrimaryButton(onTap: () => _confirm(), titleText: LangKeys.buttonConfirm.tr()),
          ],
        ),
      ],
    );
  }

  void _confirm() {
    if (!_formKey.currentState!.validate()) return;

    final invoiceNumber = _invoiceNumberController.text;
    context.pop((invoiceNumber, IntDate.fromDate(dueDate)));
  }

  void _cancel() {
    context.pop();
  }
}

// eof
