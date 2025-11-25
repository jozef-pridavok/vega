import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";

import "../../states/providers.dart";
import "../../states/user/editor.dart";
import "../../strings.dart";
import "../screen_app.dart";

class EditDetailScreen extends AppScreen {
  final UserCard userCard;
  final bool isNew;
  final bool popAllOnDone;
  const EditDetailScreen(this.userCard, this.isNew, {this.popAllOnDone = false, super.key});

  @override
  createState() => _EditDetailState();
}

class _EditDetailState extends AppScreenState<EditDetailScreen> {
  UserCard get _userCard => widget.userCard;
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController.text = _userCard.name ?? "";
    _numberController.text = _userCard.number ?? "";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenEditYourCardTitle.tr(),
        cancel: true,
      );

  void _listenToUserCardUpdateLogic() {
    ref.listen<EditUserCardState>(userCardUpdateLogic(_userCard), (previous, next) {
      if (next is EditUserCardSucceed) {
        ref.read(userCardUpdateLogic(_userCard).notifier).reset();
        ref.read(userCardLogic(_userCard.userCardId).notifier).updateCard(next.userCard);
        ref.read(userCardsLogic.notifier).updateCard(next.userCard);
        if (mounted) widget.popAllOnDone ? context.popAll() : context.pop();
      } else if (next is EditUserCardFailed) {
        toastError(LangKeys.operationFailed.tr());
        delayedStateRefresh(() => ref.read(userCardUpdateLogic(_userCard).notifier).reset());
      }
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToUserCardUpdateLogic();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LangKeys.screenEditYourCardDescription.tr().text.color(ref.scheme.content),
              const MoleculeItemSpace(),
              MoleculeInput(
                title: LangKeys.screenEditYourCardNameLabel.tr(),
                hint: LangKeys.screenEditYourCardNameHint.tr(),
                controller: _nameController,
                validator: (val) => val?.isEmpty ?? true ? LangKeys.validationNameRequired.tr() : null,
              ),
              const MoleculeItemSpace(),
              MoleculeInput(
                title: LangKeys.screenEditYourCardNumberLabel.tr(),
                hint: LangKeys.screenEditYourCardNumberHint.tr(),
                controller: _numberController,
              ),
              const MoleculeItemSpace(),
              MoleculeActionButton(
                title: LangKeys.buttonConfirm.tr(),
                successTitle: LangKeys.operationSuccessful.tr(),
                failTitle: LangKeys.operationFailed.tr(),
                buttonState: ref.watch(userCardUpdateLogic(_userCard)).buttonState,
                onPressed: () {
                  if (!(_formKey.currentState?.validate() ?? false))
                    return ref.read(toastLogic.notifier).warning(LangKeys.operationFailed.tr());
                  ref.read(userCardUpdateLogic(_userCard).notifier).save(
                        widget.isNew,
                        name: _nameController.text,
                        number: _numberController.text,
                      );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// eof
