import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";

import "../../states/providers.dart";
import "../../states/user/editor.dart";
import "../../strings.dart";
import "../screen_app.dart";

class EditNoteScreen extends AppScreen {
  final UserCard userCard;
  final bool isNew;
  const EditNoteScreen(this.userCard, this.isNew, {super.key});

  @override
  createState() => _EditNoteState();
}

class _EditNoteState extends AppScreenState<EditNoteScreen> {
  UserCard get _userCard => widget.userCard;
  final _notesController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _notesController.text = _userCard.notes ?? "";
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenEditYourCardNote.tr(),
      );

  void _listenToUserCardUpdateLogic() {
    ref.listen<EditUserCardState>(userCardUpdateLogic(_userCard), (previous, next) {
      if (next is EditUserCardSucceed) {
        ref.read(userCardUpdateLogic(_userCard).notifier).reset();
        ref.read(userCardLogic(_userCard.userCardId).notifier).updateCard(next.userCard);
        ref.read(userCardsLogic.notifier).updateCard(next.userCard);
        context.pop();
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
                title: LangKeys.labelNote.tr(),
                hint: LangKeys.hintNoteCard.tr(),
                controller: _notesController,
                maxLines: 5,
                validator: (val) => val?.isEmpty ?? true ? LangKeys.validationNameRequired.tr() : null,
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
                  ref.read(userCardUpdateLogic(_userCard).notifier).save(widget.isNew, notes: _notesController.text);
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
