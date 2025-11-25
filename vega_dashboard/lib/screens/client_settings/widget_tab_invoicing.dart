import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../../strings.dart";
import "screen_settings.dart";

extension InvoicingClientSettings on ClientSettingsScreenState {
  Widget buildInvoicingMobileLayout() {
    return SingleChildScrollView(
      child: Form(
        key: formKeys[2],
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MoleculeItemSpace(),
            LangKeys.billingInformationInfo.tr().text.alignCenter,
            const MoleculeItemSpace(),
            _buildName(),
            const MoleculeItemSpace(),
            _buildCompanyNumber(),
            const MoleculeItemSpace(),
            _buildCompanyVat(),
            const MoleculeItemSpace(),
            _buildAddress1(),
            const MoleculeItemSpace(),
            _buildAddress2(),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: _buildZip()),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: _buildCity(), flex: 3),
              ],
            ),
            const MoleculeItemSpace(),
            _buildCountry(),
            const MoleculeItemSpace(),
            _buildPhone(),
            const MoleculeItemSpace(),
            _buildEmail(),
            const MoleculeItemSpace(),
          ],
        ),
      ),
    );
  }

  Widget buildInvoicingDefaultLayout() {
    return SingleChildScrollView(
      child: Form(
        key: formKeys[2],
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              LangKeys.billingInformationInfo.tr(),
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: _buildName()),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: _buildCompanyNumber()),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: _buildCompanyVat()),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: _buildAddress1()),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: _buildAddress2()),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: _buildZip()),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: _buildCity()),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: _buildCountry()),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(child: _buildPhone()),
                const MoleculeItemHorizontalSpace(),
                Flexible(child: _buildEmail()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildName() => MoleculeInput(
        title: LangKeys.labelCompanyName.tr(),
        controller: invoicingNameController,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationTag),
      );

  Widget _buildCompanyNumber() => MoleculeInput(
        title: LangKeys.labelClientCompanyNumberId.tr(),
        controller: invoicingCompanyNumberIdController,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationTag),
      );

  Widget _buildCompanyVat() => MoleculeInput(
        title: LangKeys.labelClientCompanyVatId.tr(),
        controller: invoicingCompanyVatIdController,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationTag),
      );

  Widget _buildAddress1() => MoleculeInput(
        title: LangKeys.labelAddressLine1.tr(),
        controller: invoicingAddress1Controller,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationTag),
      );

  Widget _buildAddress2() => MoleculeInput(
        title: LangKeys.labelAddressLine2.tr(),
        controller: invoicingAddress2Controller,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationTag),
      );

  Widget _buildZip() => MoleculeInput(
        title: LangKeys.labelZip.tr(),
        controller: invoicingZipController,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationTag),
      );

  Widget _buildCity() => MoleculeInput(
        title: LangKeys.labelCity.tr(),
        controller: invoicingCityController,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationTag),
      );

  Widget _buildCountry() => MoleculeInput(
        title: LangKeys.labelCountry.tr(),
        controller: invoicingCountryController,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationTag),
      );

  Widget _buildPhone() => MoleculeInput(
        title: LangKeys.labelPhone.tr(),
        controller: invoicingPhoneController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) =>
            ((val?.isEmpty ?? true) || isPhoneNumber(val ?? "")) ? null : LangKeys.validationPhoneInvalidFormat.tr(),
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationTag),
      );

  Widget _buildEmail() => MoleculeInput(
        title: LangKeys.labelEmail.tr(),
        controller: invoicingEmailController,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) =>
            ((val?.isEmpty ?? true) || isEmail(val ?? "")) ? null : LangKeys.validationEmailInvalidFormat.tr(),
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationTag),
      );
}

// eof
