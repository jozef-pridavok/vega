import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/program_reward_editor.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../utils/image_picker.dart";
import "../../utils/validations.dart";
import "../../widgets/molecule_picker_date.dart";
import "../../widgets/notifications.dart";
import "../screen_app.dart";

class EditProgramReward extends VegaScreen {
  const EditProgramReward({super.key});

  @override
  createState() => _EditState();
}

class _EditState extends VegaScreenState<EditProgramReward> {
  final notificationsTag = "e695aaf8-ecb7-4967-b9e3-8a433a6345b9";
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController();
  final _countController = TextEditingController();

  late IntDate _validFrom;
  IntDate? _validTo;
  late String? _image;

  bool _limitedCount = false;
  late ProgramDigits _digits;

  bool _loadingImage = false;
  List<int>? _newImage;

  @override
  void initState() {
    super.initState();
    final editing = (ref.read(rewardEditorLogic) as RewardEditorEditing);
    final reward = editing.reward;

    _digits = ProgramDigits(editing.program.digits);

    _image = reward.image;
    _validFrom = reward.validFrom;
    _validTo = reward.validTo;
    _limitedCount = reward.count != null;
    Future.microtask(() {
      _nameController.text = reward.name;
      _descriptionController.text = reward.description ?? "";
      _pointsController.text = reward.points.toString();
      _countController.text = reward.count?.toString() ?? "";
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    _countController.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenProgramRewardEditTitle.tr();

  @override
  bool onBack(WidgetRef ref) {
    dismissUnsaved(notificationsTag);
    return true;
  }

  @override
  List<Widget>? buildAppBarActions() {
    return [
      Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: NotificationsWidget(),
      ),
      const MoleculeItemHorizontalSpace(),
      Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: _buildSaveButton(),
      ),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToEditorState(context);
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: isMobile ? _mobileLayout() : _desktopLayout(),
        ),
      ),
    );
  }

  void _listenToEditorState(BuildContext context) {
    ref.listen<RewardEditorState>(rewardEditorLogic, (previous, next) {
      if (next is RewardEditorFailed) {
        toastCoreError(next.error);
        delayedStateRefresh(() => ref.read(rewardEditorLogic.notifier).reedit());
        //Future.delayed(stateRefreshDuration, () => ref.read(rewardEditorLogic.notifier).reedit());
      } else if (next is RewardEditorSucceed) {
        delayedStateRefresh(() => ref.read(rewardEditorLogic.notifier).reedit());
        ref.read(rewardsLogic(next.program).notifier).reset();
        //ref.read(rewardEditorLogic.notifier).reedit();
        //ref.read(rewardsLogic.notifier).addOrUpdateRewardInList(next.reward);
        dismissUnsaved(notificationsTag);
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
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildPoints()),
            ],
          ),
          const MoleculeItemSpace(),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImage(),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildDescription()),
              ],
            ),
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Expanded(child: _buildValidFrom()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildValidTo()),
            ],
          ),
        ],
      );

  Widget _desktopLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildName()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildPoints()),
            ],
          ),
          const MoleculeItemSpace(),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildImage(),
                const MoleculeItemHorizontalSpace(),
                Expanded(child: _buildDescription()),
              ],
            ),
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Expanded(child: _buildValidFrom()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildValidTo()),
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
        onChanged: (_) => notifyUnsaved(notificationsTag),
      );

  Widget _buildPoints() {
    final locale = context.locale.languageCode;
    return MoleculeInput(
      // localize to slovak, english, spanish
      title: LangKeys.labelRewardPoints.tr(),
      hint: _digits.format(100, locale),
      controller: _pointsController,
      maxLines: 1,
      validator: (value) => !((_digits.parse(value, locale) ?? -1) >= 1) ? LangKeys.validationValueInvalid.tr() : null,
      onChanged: (_) => notifyUnsaved(notificationsTag),
    );
  }

  Widget _buildCount() => MoleculeInput(
        enabled: _limitedCount,
        controller: _countController,
        maxLines: 1,
        validator: (value) {
          if ((value?.length ?? 0) == 0) return null;
          return !isInt(value!, max: 999) ? LangKeys.validationValueInvalid.tr() : null;
        },
        onChanged: (_) => notifyUnsaved(notificationsTag),
      );

  Widget _buildDescription() => MoleculeInput(
        title: LangKeys.labelDescription.tr(),
        controller: _descriptionController,
        maxLines: 5,
        onChanged: (_) => notifyUnsaved(notificationsTag),
      );

  Widget _buildValidFrom() => MoleculeDatePicker(
        title: LangKeys.labelValidFrom.tr(),
        hint: LangKeys.hintValidFrom.tr(),
        initialValue: _validFrom.toDate(),
        onChanged: (selectedDate) {
          _validFrom = IntDate.fromDate(selectedDate);
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

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 1 / 1,
      child: GestureDetector(
        onTap: () => _pickFile(),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          child: Container(
            color: ref.scheme.paperBold,
            child: IndexedStack(
              index: _loadingImage ? 0 : 1,
              alignment: Alignment.center,
              children: [
                const CenteredWaitIndicator(),
                _newImage != null
                    ? Image.memory(Uint8List.fromList(_newImage!), fit: BoxFit.cover)
                    : _image != null
                        ? Image.network(_image!, fit: BoxFit.cover)
                        : Center(child: LangKeys.hintClickToSetImage.tr().text.alignCenter),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickFile() async {
    setState(() => _loadingImage = true);
    final image = await ImagePicker().pickImage(width: 512, height: 512);
    if (image == null) return setState(() => _loadingImage = false);
    _newImage = image.toList();
    setState(() => _loadingImage = false);
    notifyUnsaved(notificationsTag);
  }

  Widget _buildSaveButton() {
    final state = ref.watch(rewardEditorLogic);
    return MoleculeActionButton(
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: state.buttonState,
      onPressed: () async {
        final editing = cast<RewardEditorEditing>(state);
        if (editing == null) return;
        if (!_formKey.currentState!.validate()) return;
        if (!isValidFromTo(ref, _validFrom, _validTo)) return;
        if (editing.isNew && _newImage == null) return toastError(LangKeys.toastValidationImageRequired.tr());
        ref.read(rewardEditorLogic.notifier).set(
              name: _nameController.text,
              description: _descriptionController.text,
              validFrom: _validFrom,
              validTo: _validTo,
              point: _digits.parse(_pointsController.text),
              count: tryParseInt(_countController.text),
            );
        await ref.read(rewardEditorLogic.notifier).save(newImage: _newImage);
      },
    );
  }
}

// eof
