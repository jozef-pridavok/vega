import "dart:typed_data";

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/widgets/molecule_picker_color.dart";

import "../../extensions/select_item.dart";
import "../../states/client_card_editor.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../utils/image_picker.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/notifications.dart";
import "../screen_app.dart";

class EditClientCard extends VegaScreen {
  const EditClientCard({super.key});

  @override
  createState() => _EditState();
}

class _EditState extends VegaScreenState<EditClientCard> {
  final notificationsTag = "de68bce4-021c-401f-bd67-8945aaec530f";

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _colorController = TextEditingController();

  Color? _color;
  List<Country>? _countries;
  List<Country>? _clientCountries;

  String? _oldLogo;
  bool _loadingImage = false;
  List<int>? _newImage;

  @override
  void initState() {
    super.initState();

    final client = ref.read(deviceRepository).get(DeviceKey.client) as Client;
    _clientCountries = client.countries;

    final card = (ref.read(clientCardEditorLogic) as ClientCardEditorEditing).card;
    _color = card.color;
    _oldLogo = card.logo;

    Future.microtask(() {
      _nameController.text = card.name;
      _colorController.text = card.color.toHex();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenClientCardEditTitle.tr();

  @override
  bool onBack(WidgetRef ref) {
    dismissUnsaved(notificationsTag);
    return true;
  }

  @override
  List<Widget>? buildAppBarActions() {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: moleculeScreenPadding / 2),
        child: NotificationsWidget(),
      ),
      const MoleculeItemHorizontalSpace(),
      if (!isMobile) ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: moleculeScreenPadding / 2),
          child: _buildSaveButton(),
        ),
        const MoleculeItemHorizontalSpace(),
      ],
    ];
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<ClientCardEditorState>(clientCardEditorLogic, (previous, next) {
      if (next is ClientCardEditorFailed) {
        toastCoreError(next.error);
        Future.delayed(stateRefreshDuration, () => ref.read(clientCardEditorLogic.notifier).reedit());
      } else if (next is ClientCardEditorSucceed) {
        dismissUnsaved(notificationsTag);
        final key = ref.read(activeClientCardsLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
        delayedStateRefresh(() => ref.read(clientCardEditorLogic.notifier).reedit());
      }
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: PullToRefresh(
        onRefresh: () async {},
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: isMobile ? _mobileLayout(context) : _defaultLayout(context),
          ),
        ),
      ),
    );
  }

  Widget _mobileLayout(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildName(),
          const MoleculeItemSpace(),
          _buildColor(),
          const MoleculeItemSpace(),
          _buildCountries(),
          const MoleculeItemSpace(),
          _buildImage(),
          const MoleculeItemSpace(),
          _buildSaveButton(),
        ],
      );

  Widget _defaultLayout(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _buildName()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildColor()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: _buildCountries()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildImage()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: Container()),
              const MoleculeItemHorizontalSpace(),
              Expanded(child: Container()),
            ],
          ),
        ],
      );

  Widget _buildName() => MoleculeInput(
        title: LangKeys.labelName.tr(),
        controller: _nameController,
        validator: (value) => value!.isEmpty ? LangKeys.validationNameRequired.tr() : null,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildColor() {
    return MoleculeColorPicker(
        title: LangKeys.labelColor.tr(),
        hint: LangKeys.hintPickColor.tr(),
        initialValue: _color,
        onChanged: (newColor) {
          if (newColor == null) return;
          _color = newColor;
          _colorController.text = newColor.toHex();
          setState(() => _color = newColor);
          notifyUnsaved(notificationsTag);
        });
  }

  Widget _buildCountries() {
    return MoleculeMultiSelect(
      title: LangKeys.labelCountries.tr(),
      hint: LangKeys.locationEverywhere.tr(),
      items: (_clientCountries ?? []).toSelectItems(),
      maxSelectedItems: 2,
      selectedItems: _countries?.toSelectItems() ?? [],
      clearable: true,
      onChanged: (selectedItems) {
        _countries = selectedItems.map((e) => CountryCode.fromCode(e.value)).toList();
        notifyUnsaved(notificationsTag);
      },
    );
  }

  Widget _buildImage() {
    return GestureDetector(
      onTap: () => _pickFile(),
      child: Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 4),
        child: MoleculusCardGrid4(
          detailText: _nameController.text,
          backgroundColor: _color?.toMaterial() ?? Colors.white,
          image: IndexedStack(
            index: _loadingImage ? 0 : 1,
            alignment: Alignment.center,
            children: [
              const CenteredWaitIndicator(),
              _newImage != null
                  ? Image.memory(Uint8List.fromList(_newImage!), fit: BoxFit.contain)
                  : _oldLogo != null
                      ? Image.network(_oldLogo!, fit: BoxFit.contain)
                      : Center(child: LangKeys.hintClickToSetImage.tr().text.alignCenter),
            ],
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
    final state = ref.watch(clientCardEditorLogic);
    return MoleculeActionButton(
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: state.buttonState,
      onPressed: () {
        final editing = cast<ClientCardEditorEditing>(state);
        if (editing == null) return;
        if (!_formKey.currentState!.validate()) return;
        if (editing.isNew && _newImage == null) return toastError(LangKeys.toastValidationImageRequired.tr());
        ref.read(clientCardEditorLogic.notifier).save(
              name: _nameController.text,
              color: _color,
              countries: _countries,
              newImage: _newImage,
            );
      },
    );
  }
}

// eof
