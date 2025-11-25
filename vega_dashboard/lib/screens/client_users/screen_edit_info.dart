import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/client_user.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/notifications.dart";
import "../../widgets/state_error.dart";
import "../screen_app.dart";

class EditClientUserInfoScreen extends VegaScreen {
  static final notificationsTag = "9a6d99dc-8f05-43ec-af68-ec497a7aee2c";
  final String userId;

  const EditClientUserInfoScreen({super.key, required this.userId});

  @override
  createState() => _EditState();
}

class _EditState extends VegaScreenState<EditClientUserInfoScreen> with SingleTickerProviderStateMixin {
  final notificationsTag = EditClientUserInfoScreen.notificationsTag;

  final _formKey = GlobalKey<FormState>();

  String get _userId => widget.userId;

  final _displayName = TextEditingController();
  final _id1 = TextEditingController();
  final _id2 = TextEditingController();
  final _id3 = TextEditingController();
  final _name = TextEditingController();
  final _firstName = TextEditingController();
  final _secondName = TextEditingController();
  final _thirdName = TextEditingController();
  final _lastName = TextEditingController();
  final _addressLine1 = TextEditingController();
  final _addressLine2 = TextEditingController();
  final _zip = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _country = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();

  String? _clientId;

  String getClientId() {
    return _clientId ??= (ref.read(deviceRepository).get(DeviceKey.client) as Client).clientId;
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(clientUserLogic(_userId).notifier).reload();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _displayName.dispose();
    _id1.dispose();
    _id2.dispose();
    _id3.dispose();
    _name.dispose();
    _firstName.dispose();
    _secondName.dispose();
    _thirdName.dispose();
    _lastName.dispose();
    _addressLine1.dispose();
    _addressLine2.dispose();
    _zip.dispose();
    _city.dispose();
    _state.dispose();
    _country.dispose();
    _email.dispose();
    _phone.dispose();
    _notes.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenClienEditUserInfoTitle.tr();

  void _listenToLogics(BuildContext context) async {
    ref.listen<ClientUserState>(clientUserLogic(_userId), (previous, next) async {
      if (next is ClientUserSucceed) {
        final userData = next.user.getClientData(getClientId());
        setState(() {
          _displayName.text = userData.displayName ?? "";
          _id1.text = userData.id1 ?? "";
          _id2.text = userData.id2 ?? "";
          _id3.text = userData.id3 ?? "";
          _name.text = userData.name ?? "";
          _firstName.text = userData.firstName ?? "";
          _secondName.text = userData.secondName ?? "";
          _thirdName.text = userData.thirdName ?? "";
          _lastName.text = userData.lastName ?? "";
          _addressLine1.text = userData.addressLine1 ?? "";
          _addressLine2.text = userData.addressLine2 ?? "";
          _zip.text = userData.zip ?? "";
          _city.text = userData.city ?? "";
          _state.text = userData.state ?? "";
          _country.text = userData.country ?? "";
          _email.text = userData.email ?? "";
          _phone.text = userData.phone ?? "";
          _notes.text = userData.notes ?? "";
        });
      }
    });
    ref.listen<ClientUserState>(clientUserLogic(_userId), (previous, next) async {
      final failed = cast<ClientUserSavingFailed>(next);
      final saved = cast<ClientUserSavedSuccess>(next);
      if (saved != null) dismissUnsaved(notificationsTag);
      if (failed != null) toastCoreError(failed.error);
      /*if (saved != null || failed != null) {
        Future.delayed(stateRefreshDuration, () => ref.read(clientUserEditorLogic.notifier).reset());
      }*/
    });
  }

  @override
  List<Widget>? buildAppBarActions() {
    return [
      Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: NotificationsWidget(),
      ),
      Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: _buildSaveButton(),
      ),
    ];
  }

  @override
  bool onBack(WidgetRef ref) {
    dismissUnsaved(notificationsTag);
    return super.onBack(ref);
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final isMobile = ref.watch(layoutLogic).isMobile;
    final state = ref.watch(clientUserLogic(_userId));
    if (state is ClientUserFailed)
      return StateErrorWidget(
        clientUserLogic(_userId),
        onReload: () => ref.read(clientUserLogic(_userId).notifier).reload(),
      );
    else if (state is ClientUserSucceed)
      return Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: isMobile ? _mobileLayout() : _defaultLayout(),
          ),
        ),
      );
    else
      return const CenteredWaitIndicator();
  }

  // TODO: Mobile layout
  Widget _mobileLayout() => _defaultLayout();

  Widget _defaultLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildDisplayName()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildId1()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildId2()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildId3()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildName()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildFirstName()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildSecondName()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildThirdName()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildLastName()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildAddressLine1()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildAddressLine2()),
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
              Flexible(child: _buildState()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildCountry()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildEmail()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildPhone()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildNotes()),
            ],
          ),
        ],
      );

  Widget _buildDisplayName() => MoleculeInput(
        title: LangKeys.labelUserDataDisplayName.tr(),
        controller: _displayName,
        maxLines: 1,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => (value?.length ?? 0) < 1 ? LangKeys.validationDisplayNameRequired.tr() : null,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildId1() => MoleculeInput(
        title: LangKeys.labelUserDataId1.tr(),
        controller: _id1,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildId2() => MoleculeInput(
        title: LangKeys.labelUserDataId2.tr(),
        controller: _id2,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildId3() => MoleculeInput(
        title: LangKeys.labelUserDataId3.tr(),
        controller: _id3,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildName() => MoleculeInput(
        title: LangKeys.labelCompanyName.tr(),
        controller: _name,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildFirstName() => MoleculeInput(
        title: LangKeys.labelUserDataFirstName.tr(),
        controller: _firstName,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildSecondName() => MoleculeInput(
        title: LangKeys.labelUserDataSecondName.tr(),
        controller: _secondName,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildThirdName() => MoleculeInput(
        title: LangKeys.labelUserDataThirdName.tr(),
        controller: _thirdName,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildLastName() => MoleculeInput(
        title: LangKeys.labelUserDataLastName.tr(),
        controller: _lastName,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildAddressLine1() => MoleculeInput(
        title: LangKeys.labelAddressLine1.tr(),
        controller: _addressLine1,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildAddressLine2() => MoleculeInput(
        title: LangKeys.labelAddressLine2.tr(),
        controller: _addressLine2,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildZip() => MoleculeInput(
        title: LangKeys.labelZip.tr(),
        controller: _zip,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildCity() => MoleculeInput(
        title: LangKeys.labelCity.tr(),
        controller: _city,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildState() => MoleculeInput(
        title: LangKeys.labelState.tr(),
        controller: _state,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildCountry() => MoleculeInput(
        title: LangKeys.labelCountry.tr(),
        controller: _country,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildEmail() => MoleculeInput(
        title: LangKeys.labelEmail.tr(),
        controller: _email,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildPhone() => MoleculeInput(
        title: LangKeys.labelPhone.tr(),
        controller: _phone,
        maxLines: 1,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildNotes() => MoleculeInput(
        title: LangKeys.labelNotes.tr(),
        controller: _notes,
        maxLines: 3,
        onChanged: (value) => notifyUnsaved(notificationsTag),
      );

  Widget _buildSaveButton() {
    final editorState = ref.watch(clientUserLogic(_userId));
    if (cast<ClientUserSucceed>(editorState) == null) return Container();
    return MoleculeActionButton(
      maxWidth: 200,
      minWidth: 100,
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: editorState.buttonState,
      onPressed: () {
        if (!_formKey.currentState!.validate()) return;
        ref.read(clientUserLogic(_userId).notifier).save(
              (editorState as ClientUserSucceed).user,
              getClientId(),
              displayName: _displayName.text,
              id1: _id1.text,
              id2: _id2.text,
              id3: _id3.text,
              name: _name.text,
              firstName: _firstName.text,
              secondName: _secondName.text,
              thirdName: _thirdName.text,
              lastName: _lastName.text,
              addressLine1: _addressLine1.text,
              addressLine2: _addressLine2.text,
              zip: _zip.text,
              city: _city.text,
              userState: _state.text,
              country: _country.text,
              email: _email.text,
              phone: _phone.text,
              notes: _notes.text,
            );
      },
    );
  }
}

// eof
