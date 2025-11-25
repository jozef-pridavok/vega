import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/strings.dart";

import "../../utils/validations.dart";
import "screen_edit.dart";

extension LocationOpeningHours on LocationEditState {
  Widget buildOpeningHoursWidget(WidgetRef ref) {
    return Form(
      key: formKeys[1],
      autovalidateMode: AutovalidateMode.always,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Day.monday.localizedName.label),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildMonday(), flex: 3),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Day.tuesday.localizedName.label),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildTuesday(), flex: 3),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Day.wednesday.localizedName.label),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildWednesday(), flex: 3),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Day.thursday.localizedName.label),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildThursday(), flex: 3),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Day.friday.localizedName.label),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildFriday(), flex: 3),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Day.saturday.localizedName.label),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildSaturday(), flex: 3),
              ],
            ),
            const MoleculeItemSpace(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: Day.sunday.localizedName.label),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildSunday(), flex: 3),
              ],
            ),
            const MoleculeItemSpace(),
            LangKeys.labelOpeningHoursGeneral.tr().text,
            const MoleculeItemSpace(),
            LangKeys.labelOpeningHoursRanges.tr().text,
            const MoleculeItemSpace(),
            LangKeys.labelOpeningHoursClosed.tr().text,
          ],
        ),
      ),
    );
  }

  Widget _buildMonday() => MoleculeInput(
        controller: mondayController,
        maxLines: 1,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) => !isOpeningHours(val) ? LangKeys.validationValueInvalid.tr() : null,
        onChanged: (val) => notifyUnsaved(notificationsTag),
      );
  Widget _buildTuesday() => MoleculeInput(
        controller: tuesdayController,
        maxLines: 1,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) => !isOpeningHours(val) ? LangKeys.validationValueInvalid.tr() : null,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildWednesday() => MoleculeInput(
        controller: wednesdayController,
        maxLines: 1,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) => !isOpeningHours(val) ? LangKeys.validationValueInvalid.tr() : null,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildThursday() => MoleculeInput(
        controller: thursdayController,
        maxLines: 1,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) => !isOpeningHours(val) ? LangKeys.validationValueInvalid.tr() : null,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildFriday() => MoleculeInput(
        controller: fridayController,
        maxLines: 1,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) => !isOpeningHours(val) ? LangKeys.validationValueInvalid.tr() : null,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildSaturday() => MoleculeInput(
        controller: saturdayController,
        maxLines: 1,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) => !isOpeningHours(val) ? LangKeys.validationValueInvalid.tr() : null,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildSunday() => MoleculeInput(
        controller: sundayController,
        maxLines: 1,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) => !isOpeningHours(val) ? LangKeys.validationValueInvalid.tr() : null,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );
}

// eof
