import "dart:typed_data";

import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../extensions/select_item.dart";
import "../../states/client_cards.dart";
import "../../states/program_editor.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../utils/image_picker.dart";
import "../../utils/validations.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/molecule_picker_date.dart";
import "../../widgets/notifications.dart";
import "../program_rewards/screen_list.dart";
import "../qr_tags/screen_qr_tags.dart";
import "../screen_app.dart";
import "screen_settings.dart";

class EditScreen extends VegaScreen {
  static final notificationsTag = "3aef0f5f-ca30-4387-ace3-b00e8ddfb74f";

  const EditScreen({super.key});

  @override
  createState() => _EditState();
}

class _EditState extends VegaScreenState<EditScreen> {
  final notificationsTag = EditScreen.notificationsTag;

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  late ProgramType _programType;
  List<Country>? _countries;
  String? _cardId;
  late IntDate _validFrom;
  IntDate? _validTo;

  String? _oldImage;
  bool _loadingImage = false;
  List<int>? _newImage;

  late List<Country> _eligibleCountries;

  @override
  void initState() {
    super.initState();

    final client = ref.read(deviceRepository).get(DeviceKey.client) as Client;
    _eligibleCountries = client.countries ?? [];

    final program = (ref.read(programEditorLogic) as ProgramEditorEditing).program;

    _validFrom = program.validFrom;
    _validTo = program.validTo;
    _cardId = program.cardId.isEmpty ? null : program.cardId;
    _programType = program.type;
    _countries = program.countries;
    _oldImage = program.image;

    Future.microtask(() {
      _nameController.text = program.name;
      _descriptionController.text = program.description ?? "";
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenProgramEditTitle.tr();

  @override
  bool onBack(WidgetRef ref) {
    dismissUnsaved(notificationsTag);
    return true;
  }

  @override
  List<Widget>? buildAppBarActions() {
    final isMobile = ref.watch(layoutLogic).isMobile;
    final editor = ref.watch(programEditorLogic) as ProgramEditorEditing;
    final program = editor.program;
    return [
      Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: NotificationsWidget(),
      ),
      if (!editor.isNew && program.type == ProgramType.reach)
        Padding(
          padding: const EdgeInsets.all(moleculeScreenPadding / 2),
          child: MoleculeSecondaryButton(
            titleText: LangKeys.buttonProgramRewards.tr(),
            onTap: () => context.popPush(ProgramRewardsScreen(program)),
          ),
        ),
      if (!isMobile) ...[
        Padding(padding: const EdgeInsets.all(moleculeScreenPadding / 2), child: _buildSaveButton()),
      ],
      VegaMenuButton(
        items: [
          if ([ProgramType.reach, ProgramType.collect].contains((_programType)))
            PopupMenuItem(
              child: MoleculeItemBasic(
                title: LangKeys.operationManageQrTags.tr(),
                onAction: () => context.popPush(QrTagsScreen(program: program)),
              ),
            ),
          PopupMenuItem(
            child: MoleculeItemBasic(
              title: LangKeys.buttonSettings.tr(),
              onAction: () => context.popPush(SettingsScreen(program: program)),
            ),
          ),
        ],
      ),
      const SizedBox(width: moleculeScreenPadding),
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

  void _listenToLogics(BuildContext context) {
    ref.listen<ProgramEditorState>(programEditorLogic, (previous, next) {
      if (next is ProgramEditorFailed) {
        final error = next.error;
        toastError(error.message);
        Future.delayed(stateRefreshDuration, () => ref.read(programEditorLogic.notifier).reedit());
      } else if (next is ProgramEditorSaved) {
        toastInfo(LangKeys.operationSuccessful.tr());
        ref.read(programEditorLogic.notifier).reedit();
        dismissUnsaved(notificationsTag);
        var key = ref.read(activeProgramsLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
        key = ref.read(preparedProgramsLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
      }
    });
  }

  Widget _mobileLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildName(),
          const MoleculeItemSpace(),
          Row(
            children: [
              Flexible(child: _buildType()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildCard()),
            ],
          ),
          const MoleculeItemSpace(),
          _buildCountries(),
          const MoleculeItemSpace(),
          Row(
            children: [
              Flexible(child: _buildValidFrom()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildValidTo()),
            ],
          ),
          const MoleculeItemSpace(),
          _buildImage(),
          const MoleculeItemSpace(),
          _buildDescription(),
          const MoleculeItemSpace(),
          _buildSaveButton(),
          const MoleculeItemSpace(),
        ],
      );

  Widget _defaultLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildName()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildType()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildCountries()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Expanded(child: _buildCard()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildValidFrom()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildValidTo()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildImage()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildDescription()),
            ],
          ),
        ],
      );

  Widget _buildName() => MoleculeInput(
        title: LangKeys.labelName.tr(),
        controller: _nameController,
        maxLines: 1,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => (value?.length ?? 0) < 1 ? LangKeys.validationNameRequired.tr() : null,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildType() => MoleculeSingleSelect(
        title: LangKeys.labelProgramType.tr(),
        hint: "",
        items: ProgramType.values.toSelectItems(),
        selectedItem: _programType.toSelectItem(),
        onChanged: (selectedItem) {
          _programType = ProgramTypeCode.fromCode(int.tryParse(selectedItem.value));
          notifyUnsaved(notificationsTag);
        },
      );

  Widget _buildCountries() {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return MoleculeMultiSelect(
      title: LangKeys.labelCountries.tr(),
      hint: LangKeys.locationEverywhere.tr(),
      items: _eligibleCountries.toSelectItems(),
      maxSelectedItems: isMobile ? 2 : 10,
      selectedItems: _countries?.toSelectItems() ?? [],
      clearable: true,
      onChanged: (selectedItems) {
        _countries = selectedItems.map((e) => CountryCode.fromCode(e.value)).toList();
        notifyUnsaved(notificationsTag);
      },
    );
  }

  Widget _buildCard() {
    final cards = cast<ClientCardsSucceed>(ref.watch(activeClientCardsLogic))?.cards ?? [];
    final editor = ref.watch(programEditorLogic) as ProgramEditorEditing;
    final card = cards.firstWhereOrNull((card) => card.cardId == (_cardId ?? editor.program.cardId));
    return MoleculeSingleSelect(
      title: LangKeys.labelCard.tr(),
      hint: LangKeys.hintCard.tr(),
      items: cards.toSelectItems(),
      selectedItem: card?.toSelectItem(),
      onChanged: (selectedItem) {
        _cardId = cards.firstWhere((card) => card.cardId == selectedItem.value).cardId;
        notifyUnsaved(notificationsTag);
      },
    );
  }

  Widget _buildValidFrom() => MoleculeDatePicker(
        title: LangKeys.labelValidFrom.tr(),
        hint: LangKeys.hintValidFrom.tr(),
        initialValue: _validFrom.toDate(),
        onChanged: (selectedDate) {
          _validFrom = selectedDate.toIntDate();
          notifyUnsaved(notificationsTag);
        },
      );

  Widget _buildValidTo() => MoleculeDatePicker(
        title: LangKeys.labelValidTo.tr(),
        hint: LangKeys.hintValidTo.tr(),
        initialValue: _validTo?.toDate(),
        onChangedOrNull: (selectedDate) {
          _validTo = selectedDate?.toIntDate();
          notifyUnsaved(notificationsTag);
        },
      );

  Widget _buildDescription() => MoleculeInput(
        title: LangKeys.labelDescription.tr(),
        controller: _descriptionController,
        maxLines: 5,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildImage() {
    return GestureDetector(
      onTap: _pickFile,
      behavior: HitTestBehavior.opaque,
      child: MoleculeCardLoyaltyMedium(
        label: _nameController.text,
        image: IndexedStack(
          index: _loadingImage ? 0 : 1,
          alignment: Alignment.center,
          children: [
            const CenteredWaitIndicator(),
            _newImage != null
                ? Image.memory(Uint8List.fromList(_newImage!), fit: BoxFit.cover)
                : _oldImage != null
                    ? Image.network(_oldImage!, fit: BoxFit.cover)
                    : Center(child: LangKeys.hintClickToSetImage.tr().text.alignCenter),
          ],
        ),
        // TODO: tu dať logo clienta
      ),
    );
  }

  void _pickFile() async {
    setState(() => _loadingImage = true);
    final image = await ImagePicker().pickImage();
    if (image == null) return setState(() => _loadingImage = false);
    _newImage = image.toList();
    notifyUnsaved(notificationsTag);
    setState(() => _loadingImage = false);
  }

  Widget _buildSaveButton() {
    final state = ref.watch(programEditorLogic);
    return MoleculeActionButton(
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: state.buttonState,
      onPressed: () {
        final editing = cast<ProgramEditorEditing>(state);
        if (editing == null || !_formKey.currentState!.validate()) return;
        if (!isValidFromTo(ref, _validFrom, _validTo, validFromInFuture: false)) return;
        if (_cardId == null) return toastError(LangKeys.toastValidationCardRequired.tr());
        if (editing.isNew && _newImage == null) return toastError(LangKeys.toastValidationImageRequired.tr());
        ref.read(programEditorLogic.notifier).set(
              name: _nameController.text,
              type: _programType,
              countries: _countries,
              cardId: _cardId,
              validFrom: _validFrom,
              validTo: _validTo,
              description: _descriptionController.text,
            );
        ref.read(programEditorLogic.notifier).save(_newImage);
      },
    );
  }
}

// eof
