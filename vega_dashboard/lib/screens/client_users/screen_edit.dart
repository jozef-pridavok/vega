import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/src/consumer.dart";

import "../../extensions/select_item.dart";
import "../../states/client_user_editor.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/molecule_picker.dart";
import "../screen_app.dart";

class EditClientUserScreen extends VegaScreen {
  final Client client;
  final bool isNew;
  final User user;

  const EditClientUserScreen({super.key, required this.client, required this.user, this.isNew = false});

  @override
  createState() => _EditState();
}

class _EditState extends VegaScreenState<EditClientUserScreen> with SingleTickerProviderStateMixin {
  Client get _client => widget.client;
  User get _user => widget.user;
  final _formKey = GlobalKey<FormState>();

  late bool _isNew;
  final _login = TextEditingController();
  final _nick = TextEditingController();
  final _password = TextEditingController();
  final _clientNote = TextEditingController();
  late List<UserRole> _roles = [];

  static const _eligibleRoles = [UserRole.admin, UserRole.pos];

  @override
  void initState() {
    super.initState();
    _isNew = widget.isNew;
    _login.text = _user.login ?? "";
    if (_login.text.startsWith("${_client.accountPrefix}.")) {
      _login.text = _login.text.substring(_client.accountPrefix.length + 1);
    }
    _nick.text = _user.nick ?? "";
    _roles = _user.roles;
    _password.text = "";
    _clientNote.text = _user.metaClientNote;
  }

  @override
  void dispose() {
    super.dispose();
    _login.dispose();
    _nick.dispose();
    _password.dispose();
    _clientNote.dispose();
  }

  @override
  String? getTitle() => _user.nick;

  @override
  List<Widget>? buildAppBarActions() {
    return [
      Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: _buildSaveButton(),
      ),
    ];
  }

  @override
  bool onBack(WidgetRef ref) {
    ref.read(clientUsersLogic(_client.clientId).notifier).reload();
    return super.onBack(ref);
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Form(
        key: _formKey,
        child: isMobile ? _mobileLayout() : _defaultLayout(),
      ),
    );
  }

  void _listenToLogics(BuildContext context) async {
    super.listenToLogics(context);
    ref.listen<ClientUserEditorState>(clientUserEditorLogic, (previous, next) async {
      final failed = cast<ClientUserEditorFailed>(next);
      final saved = cast<ClientUserSaved>(next);
      if (saved != null || failed != null) {
        if (next is ClientUserSaved) {
          setState(() {
            _password.text = "";
            _isNew = false;
          });
        }
        if (failed != null) toastCoreError(failed.error);
        Future.delayed(stateRefreshDuration, () => ref.read(clientUserEditorLogic.notifier).reset());
      }
    });
  }

  // TODO: Mobile layout
  Widget _mobileLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildLogin()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildPassword()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Flexible(child: _buildNick()),
            const MoleculeItemHorizontalSpace(),
            Flexible(child: _buildRoles()),
          ]),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Flexible(child: _inputDescription())],
          ),
        ],
      );

  Widget _defaultLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildLogin()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildPassword()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Flexible(child: _buildNick()),
            const MoleculeItemHorizontalSpace(),
            Flexible(child: _buildRoles()),
          ]),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Flexible(child: _inputDescription())],
          ),
        ],
      );

  Widget _buildLogin() => MoleculeInput(
        title: LangKeys.labelLogin.tr(),
        prefixText: "${_client.accountPrefix}.",
        controller: _login,
        maxLines: 1,
      );

  Widget _buildNick() => MoleculeInput(
        title: LangKeys.labelNick.tr(),
        controller: _nick,
        maxLines: 1,
      );

  Widget _buildPassword() => MoleculeInput(
        title: LangKeys.labelPassword.tr(),
        hint: _isNew ? LangKeys.hintSetInitialPassword.tr() : LangKeys.hintLeaveEmptyToKeepPassword.tr(),
        controller: _password,
        inputType: TextInputType.visiblePassword,
        maxLines: 1,
        validator: (p) {
          final minPasswordLength = 6;
          if (_isNew) {
            if ((p?.isEmpty ?? true)) return LangKeys.validationPasswordRequired.tr();
            if ((p?.length ?? 0) < minPasswordLength)
              return LangKeys.validationPasswordLengthRequired.tr(args: [minPasswordLength.toString()]);
          } else {
            if ((p?.isNotEmpty ?? false) && (p?.length ?? 0) < minPasswordLength)
              return LangKeys.validationPasswordLengthRequired.tr(args: [minPasswordLength.toString()]);
          }
          return null;
        },
      );

  Widget _buildRoles() => MoleculeMultiSelect(
        title: LangKeys.labelRoles.tr(),
        hint: "",
        items: _eligibleRoles.toSelectItems(),
        maxSelectedItems: 3,
        selectedItems: _roles.toSelectItems(),
        onChanged: (selectedItems) {
          _roles = selectedItems.map((item) {
            return UserRole.values.firstWhere(
              (e) => e.code.toString() == item.value,
            );
          }).toList();
        },
      );

  Widget _inputDescription() => MoleculeInput(
        title: LangKeys.labelDescription.tr(),
        controller: _clientNote,
        maxLines: 3,
      );

  Widget _buildSaveButton() {
    final editorState = ref.watch(clientUserEditorLogic);
    return MoleculeActionButton(
      maxWidth: 200,
      minWidth: 100,
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: editorState.buttonState,
      onPressed: () {
        if (!(_formKey.currentState?.validate() ?? false)) return;

        _user.login = "${_client.accountPrefix}.${_login.text}";
        _user.nick = _nick.text;
        _user.roles = _roles;
        _user.setMetaClient(note: _clientNote.text);

        if (_isNew)
          ref.read(clientUserEditorLogic.notifier).create(_user, _password.text);
        else
          ref.read(clientUserEditorLogic.notifier).save(_user, _password.text);
      },
    );
  }
}

// eof
