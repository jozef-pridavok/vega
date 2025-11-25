import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../extensions/select_item.dart";
import "../../states/programs.dart";
import "../../states/providers.dart";
import "../../states/reservation_editor.dart";
import "../../strings.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/notifications.dart";
import "../screen_app.dart";

class EditReservation extends VegaScreen {
  const EditReservation({super.key});

  @override
  createState() => _EditState();
}

class _EditState extends VegaScreenState<EditReservation> {
  final notificationsTag = "47900f40-e663-48be-89dd-b13af98a75f8";

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController();

  LoyaltyMode? _loyaltyMode;
  String? _programId;

  @override
  void initState() {
    super.initState();

    final reservation = (ref.read(reservationEditorLogic) as ReservationEditorEditing).reservation;

    _programId = reservation.programId;
    _loyaltyMode = reservation.loyaltyMode;

    Future.microtask(() {
      _nameController.text = reservation.name;
      _descriptionController.text = reservation.description ?? "";
      _discountController.text = reservation.meta?["discount"]?.toString() ?? "";
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenReservationEditTitle.tr();

  @override
  bool onBack(WidgetRef ref) {
    ref.read(activeReservationsLogic.notifier).refresh();
    ref.read(archivedReservationsLogic.notifier).refresh();
    dismissUnsaved(notificationsTag);
    return true;
  }

  @override
  List<Widget>? buildAppBarActions() {
    return [
      Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: NotificationsWidget()),
      const MoleculeItemHorizontalSpace(),
      Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: _buildSaveButton()),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: isMobile ? _mobileLayout() : _defaultLayout(),
        ),
      ),
    );
  }

  void refresh() {
    setState(() {});
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<ReservationEditorState>(reservationEditorLogic, (previous, next) {
      if (next is ReservationEditorFailed) {
        toastCoreError(next.error);
        Future.delayed(stateRefreshDuration, () => ref.read(reservationEditorLogic.notifier).reedit());
      } else if (next is ReservationEditorSucceed) {
        Future.delayed(stateRefreshDuration, () => ref.read(reservationEditorLogic.notifier).reedit());
        dismissUnsaved(notificationsTag);
        final key = ref.read(activeReservationsLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
      }
    });
  }

  // TODO: Mobile layout
  Widget _mobileLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildName()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Expanded(child: _buildLoyaltyMode()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildProgram()),
            ],
          ),
          if (_loyaltyMode == LoyaltyMode.discountForCreditPayment) ...[
            const MoleculeItemSpace(),
            Row(
              children: [
                Expanded(child: _buildDiscount()),
              ],
            ),
          ],
          const MoleculeItemSpace(),
          Row(
            children: [
              Expanded(child: _buildDescription()),
            ],
          ),
        ],
      );

  Widget _defaultLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildName()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Expanded(child: _buildLoyaltyMode()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildProgram()),
            ],
          ),
          if (_loyaltyMode == LoyaltyMode.discountForCreditPayment) ...[
            const MoleculeItemSpace(),
            Row(
              children: [
                Expanded(child: _buildDiscount()),
              ],
            ),
          ],
          const MoleculeItemSpace(),
          Row(
            children: [
              Expanded(child: _buildDescription()),
            ],
          ),
        ],
      );

  Widget _buildName() => MoleculeInput(
        title: LangKeys.labelReservationName.tr(),
        controller: _nameController,
        validator: (value) => value!.isEmpty ? LangKeys.validationNameRequired.tr() : null,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildLoyaltyMode() => MoleculeSingleSelect(
        title: LangKeys.labelReservationMode.tr(),
        hint: "",
        items: LoyaltyModes.reservations.toSelectItems(),
        selectedItem: _loyaltyMode?.toSelectItem(),
        onChanged: (selectedItem) {
          _loyaltyMode = LoyaltyModeCode.fromCode(int.tryParse(selectedItem.value));
          notifyUnsaved(notificationsTag);
          refresh();
        },
      );

  Widget _buildProgram() {
    final programs = cast<ProgramsSucceed>(ref.watch(activeProgramsLogic))?.programs ?? [];
    final editor = ref.watch(reservationEditorLogic) as ReservationEditorEditing;
    final program =
        programs.firstWhereOrNull((program) => program.programId == (_programId ?? editor.reservation.programId));
    return MoleculeSingleSelect(
      title: LangKeys.labelReservationProgram.tr(),
      hint: "",
      items: programs.toSelectItems(),
      selectedItem: program?.toSelectItem(),
      onChangedOrClear: (selectedItem) {
        _programId = selectedItem?.value;
        notifyUnsaved(notificationsTag);
      },
    );
  }

  Widget _buildDiscount() => MoleculeInput(
        title: LangKeys.labelDiscount.tr(),
        hint: LangKeys.hintDiscount.tr(),
        controller: _discountController,
        maxLines: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value?.isEmpty ?? true) return LangKeys.validationValueRequired.tr();
          if (!isInt(value!, min: 1, max: 99)) return LangKeys.validationValueInvalid.tr();
          return null;
        },
        suffixText: "%",
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildDescription() => MoleculeInput(
        title: LangKeys.labelDescription.tr(),
        controller: _descriptionController,
        maxLines: 5,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildSaveButton() {
    final state = ref.watch(reservationEditorLogic);
    return MoleculeActionButton(
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: state.buttonState,
      onPressed: () async {
        if (!_formKey.currentState!.validate()) return;
        if (_loyaltyMode == LoyaltyMode.discountForCreditPayment) {
          final programs = cast<ProgramsSucceed>(ref.watch(activeProgramsLogic))?.programs ?? [];
          final editor = ref.read(reservationEditorLogic) as ReservationEditorEditing;
          final program = programs.firstWhereOrNull((program) => program.programId == _programId);
          if (program == null || program.type != ProgramType.credit) {
            return toastError(LangKeys.validationProgramCreditRequired.tr());
          }
        }
        ref.read(reservationEditorLogic.notifier).set(
              name: _nameController.text,
              loyaltyMode: _loyaltyMode,
              programId: _programId,
              description: _descriptionController.text,
              discount: tryParseInt(_discountController.text),
            );
        await ref.read(reservationEditorLogic.notifier).save();
      },
    );
  }
}

// eof
