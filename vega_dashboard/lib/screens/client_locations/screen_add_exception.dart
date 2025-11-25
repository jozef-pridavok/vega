import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/src/consumer.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../../utils/validations.dart";
import "../../widgets/molecule_picker_date.dart";
import "../../widgets/notifications.dart";
import "../screen_app.dart";

class AddOpeningHoursException extends VegaScreen {
  final ({IntDate date, String exception})? exception;
  final String locationNotificationTag;

  const AddOpeningHoursException({super.key, required this.locationNotificationTag, this.exception});

  @override
  createState() => _AddExceptionState();
}

class _AddExceptionState extends VegaScreenState<AddOpeningHoursException> {
  final notificationsTag = "96f6efd7-4d17-41a2-a061-fca5545de6ad";

  final unsavedWarningText = LangKeys.notificationUnsavedData.tr();

  final _formKey = GlobalKey<FormState>();

  final _exceptionController = TextEditingController();

  DateTime? _pickedDate;

  @override
  void initState() {
    super.initState();
    _exceptionController.text = widget.exception?.exception ?? "";
    _pickedDate = widget.exception?.date.toLocalDate() ?? DateTime.now();
  }

  @override
  void dispose() {
    super.dispose();
    _exceptionController.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenLocationDetailsTitle.tr();

  @override
  bool onBack(WidgetRef ref) {
    dismissUnsaved(notificationsTag);
    return super.onBack(ref);
  }

  @override
  List<Widget>? buildAppBarActions() {
    bool isMobile = ref.watch(layoutLogic).isMobile;
    return [
      Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: NotificationsWidget(),
      ),
      if (!isMobile) ...[
        const MoleculeItemHorizontalSpace(),
        Padding(
          padding: const EdgeInsets.all(moleculeScreenPadding / 2),
          child: _buildConfirmButton(),
        ),
      ]
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    bool isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: PullToRefresh(
        onRefresh: () async {},
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isMobile) ...[
                  _buildDate(),
                  const MoleculeItemSpace(),
                  _buildException(),
                ],
                if (!isMobile)
                  Row(
                    children: [
                      Expanded(child: _buildDate()),
                      const MoleculeItemHorizontalSpace(),
                      Expanded(child: _buildException()),
                    ],
                  ),
                const MoleculeItemSpace(),
                LangKeys.labelOpeningHoursGeneral.tr().text,
                const MoleculeItemSpace(),
                LangKeys.labelOpeningHoursRanges.tr().text,
                const MoleculeItemSpace(),
                LangKeys.labelOpeningHoursClosed.tr().text,
                if (isMobile) ...[
                  const MoleculeItemSpace(),
                  _buildConfirmButton(),
                  const MoleculeItemSpace(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDate() => MoleculeDatePicker(
        title: LangKeys.labelDate.tr(),
        hint: "",
        initialValue: widget.exception?.date.toLocalDate() ?? DateTime.now(),
        onChanged: (selectedDate) {
          notifyUnsaved(notificationsTag);
          _pickedDate = selectedDate;
        },
        enabled: widget.exception == null,
      );

  Widget _buildException() => MoleculeInput(
        title: LangKeys.labelException.tr(),
        controller: _exceptionController,
        maxLines: 1,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (val) => !isOpeningHours(val) ? LangKeys.validationValueInvalid.tr() : null,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildConfirmButton() {
    return MoleculePrimaryButton(
      titleText: LangKeys.buttonConfirm.tr(),
      onTap: () async {
        ref.read(locationEditorLogic.notifier).addException(
              IntDate.fromDate(_pickedDate!),
              _exceptionController.text,
            );
        dismissUnsaved(notificationsTag);
        notifyUnsaved(widget.locationNotificationTag);
        ref.read(locationEditorLogic.notifier).refresh();
        context.pop();
      },
    );
  }
}

// eof
