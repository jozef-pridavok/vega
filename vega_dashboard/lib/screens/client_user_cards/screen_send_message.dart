import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../../states/providers.dart";
import "../../states/send_client_message_to_user.dart";
import "../../strings.dart";
import "../screen_app.dart";

class SendMessageScreen extends VegaScreen {
  final String userId;
  final String userName;
  const SendMessageScreen(this.userId, this.userName, {super.key});

  @override
  createState() => _SendMessageState();
}

class _SendMessageState extends VegaScreenState<SendMessageScreen> {
  String get _userId => widget.userId;
  String get _userName => widget.userName;
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _sendInApp = true;
  bool _sendPushNotification = true;
  bool _sendEmail = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenSendMessage.tr();

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildTo(),
            const MoleculeItemSpace(),
            _buildSubject(),
            const MoleculeItemSpace(),
            _buildBody(),
            const MoleculeItemSpace(),
            _buildSendInApp(),
            _buildSendPushNotification(),
            _buildSendEmail(),
            const MoleculeItemSpace(),
            _buildSendMessage(),
          ],
        ),
      ),
    );
  }

  void _listenToLogics(BuildContext context) {
    ref.listen(sendMessageToUserLogic, (previous, next) {
      if (next is SendClientMessageToUserSucceed) {
        Future.delayed(stateRefreshDuration, () => ref.read(sendMessageToUserLogic.notifier).reset());
        toastInfo(LangKeys.toastMessageSent.tr());
        _subjectController.clear();
        _bodyController.clear();
      } else if (next is SendClientMessageToUserFailed) {
        Future.delayed(stateRefreshDuration, () => ref.read(sendMessageToUserLogic.notifier).reset());
        toastError(LangKeys.toastMessageFailed.tr());
      }
    });
  }

  MoleculeInput _buildTo() {
    return MoleculeInput(
      title: LangKeys.labelTo.tr(),
      readOnly: true,
      initialValue: _userName,
    );
  }

  MoleculeInput _buildSubject() {
    return MoleculeInput(
      title: LangKeys.labelSubject.tr(),
      hint: LangKeys.hintSubject.tr(),
      controller: _subjectController,
      inputType: TextInputType.text,
      capitalization: TextCapitalization.sentences,
    );
  }

  MoleculeInput _buildBody() {
    return MoleculeInput(
      title: LangKeys.labelBody.tr(),
      hint: LangKeys.hintBody.tr(),
      controller: _bodyController,
      inputType: TextInputType.text,
      capitalization: TextCapitalization.sentences,
      maxLines: 3,
    );
  }

  MoleculeItemToggle _buildSendInApp() => MoleculeItemToggle(
        title: LangKeys.labelSendInApp.tr(),
        on: _sendInApp,
        onChanged: (on) => setState(() => _sendInApp = on),
      );

  MoleculeItemToggle _buildSendPushNotification() {
    return MoleculeItemToggle(
      title: LangKeys.labelSendPushNotification.tr(),
      on: _sendPushNotification,
      onChanged: (on) => setState(() => _sendPushNotification = on),
    );
  }

  MoleculeItemToggle _buildSendEmail() {
    return MoleculeItemToggle(
      title: LangKeys.labelSendEmail.tr(),
      on: _sendEmail,
      onChanged: (on) => setState(() => _sendEmail = on),
    );
  }

  MoleculeActionButton _buildSendMessage() {
    final state = ref.watch(sendMessageToUserLogic);
    return MoleculeActionButton(
      title: LangKeys.buttonSend.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: state.buttonState,
      onPressed: () => ref.read(sendMessageToUserLogic.notifier).send(
        _userId,
        subject: _subjectController.text,
        body: _bodyController.text,
        messageTypes: [
          if (_sendInApp) MessageType.inApp,
          if (_sendPushNotification) MessageType.pushNotification,
          if (_sendEmail) MessageType.email,
        ],
      ),
    );
  }
}

// eof
