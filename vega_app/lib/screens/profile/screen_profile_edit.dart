import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/strings.dart";

import "../../states/account/delete.dart";
import "../../states/providers.dart";
import "../../widgets/user_identity.dart";
import "../screen_app.dart";
import "../startup/screen_splash.dart";
import "screen_change_password.dart";

class EditProfileScreen extends AppScreen {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends AppScreenState<EditProfileScreen> {
  final _focusNodeName = FocusNode();
  final _focusNodeEmail = FocusNode();

  final _nameController = TextEditingController();
  final _genderController = TextEditingController();
  final _yearController = TextEditingController();

  late final String? _email;
  String? _name;
  int? _yob;
  Gender? _gender;

  int _confirmAccountDeletion = 0;

  @override
  void initState() {
    super.initState();
    final device = ref.read(deviceRepository);
    final user = device.get(DeviceKey.user) as User;
    _email = user.email;
    _name = user.nick;
    _yob = user.yob;
    _gender = user.gender;
    _updateNameController();
    _updateYearController();
    _updateGenderController();
    Future.microtask(() {
      ref.read(userUpdateLogic.notifier).reset();
      ref.read(deleteAccountLogic.notifier).reset();
    });
  }

  @override
  void dispose() {
    _focusNodeName.dispose();
    _focusNodeEmail.dispose();
    _genderController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenProfileTitle.tr(),
        cancel: true,
      );

  void _listenToDeleteAccountLogic(BuildContext context) {
    ref.listen<DeleteAccountState>(deleteAccountLogic, (previous, next) {
      if (next is DeleteAccountSucceed) {
        ref.read(toastLogic.notifier).info(LangKeys.operationSuccessful.tr());
        ref.read(deleteAccountLogic.notifier).reset();
        context.replace(const SplashScreen(), popAll: true);
      } else if (next is DeleteAccountFailed) {
        context.pop();
        ref.read(toastLogic.notifier).error(LangKeys.operationFailed.tr());
        Future.delayed(stateRefreshDuration, () => ref.read(deleteAccountLogic.notifier).reset());
      }
    });
  }

  void _listenToUserUpdateLogic(BuildContext context) {
    ref.listen(userUpdateLogic, (previous, next) {
      if (next is UserUpdateSucceed) {
        Future.delayed(stateRefreshDuration, () => ref.read(userUpdateLogic.notifier).reset());
      } else if (next is UserUpdateFailed) {
        ref.read(toastLogic.notifier).error(LangKeys.operationFailed.tr());
        Future.delayed(stateRefreshDuration, () => ref.read(userUpdateLogic.notifier).reset());
      }
    });
  }

  @override
  Widget buildBody(BuildContext context) {
    final device = ref.read(deviceRepository);
    final user = device.get(DeviceKey.user) as User;
    _listenToDeleteAccountLogic(context);
    _listenToUserUpdateLogic(context);
    final userUpdateState = ref.watch(userUpdateLogic);
    return SingleChildScrollView(
      physics: vegaScrollPhysic,
      child: Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const MoleculeItemSpace(),
            LangKeys.screenProfileDescription.tr().text.color(ref.scheme.content),
            const MoleculeItemSpace(),
            MoleculeInput(
              title: LangKeys.screenProfileInputName.tr(),
              controller: _nameController,
              focusNode: _focusNodeName,
              inputAction: TextInputAction.done,
              capitalization: TextCapitalization.words,
              inputType: TextInputType.text,
              autocorrect: false,
              enableSuggestions: false,
              hint: LangKeys.hintFirstName.tr(),
              onChanged: (value) => _name = value,
            ),
            const MoleculeItemSpace(),
            MoleculeInput(
              title: LangKeys.screenProfileInputEmail.tr(),
              focusNode: _focusNodeEmail,
              inputAction: TextInputAction.done,
              capitalization: TextCapitalization.none,
              inputType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              hint: LangKeys.hintEmail.tr(),
              readOnly: true,
              initialValue: _email,
            ),
            const MoleculeItemSpace(),
            Row(
              children: [
                Flexible(
                  child: MoleculeInput(
                    title: LangKeys.screenProfileInputBirthYear.tr(),
                    controller: _yearController,
                    suffixIcon: const VegaIcon(name: AtomIcons.chevronDown),
                    inputAction: TextInputAction.done,
                    enableSuggestions: false,
                    hint: "1984",
                    readOnly: true,
                    maxLines: 1,
                    enableInteractiveSelection: false,
                    onTap: () => _showAgeBottomSheet(context, user),
                  ),
                ),
                const MoleculeItemHorizontalSpace(),
                Flexible(
                  child: MoleculeInput(
                    title: LangKeys.screenProfileGender.tr(),
                    controller: _genderController,
                    suffixIcon: const VegaIcon(name: AtomIcons.chevronDown),
                    inputAction: TextInputAction.done,
                    enableSuggestions: false,
                    hint: LangKeys.hintEmail.tr(),
                    readOnly: true,
                    maxLines: 1,
                    enableInteractiveSelection: false,
                    onTap: () => _showGenderBottomSheet(context, user),
                  ),
                ),
              ],
            ),
            const MoleculeItemSpace(),
            MoleculeActionButton(
              title: LangKeys.buttonConfirm.tr(),
              successTitle: LangKeys.operationSuccessful.tr(),
              failTitle: LangKeys.operationFailed.tr(),
              buttonState: userUpdateState.buttonState,
              onPressed: () => ref.read(userUpdateLogic.notifier).update(nick: _name, yob: _yob, gender: _gender),
            ),
            const MoleculeItemSpace(),
            const MoleculeItemSeparator(),
            const MoleculeItemSpace(),
            LangKeys.screenProfileDescription.tr().text.color(ref.scheme.content),
            const MoleculeItemSpace(),
            MoleculeSecondaryButton(
              titleText: LangKeys.buttonShowMyUserIdentity.tr(),
              onTap: () => showUserIdentity(context, ref),
            ),
            const MoleculeItemSpace(),
            MoleculeSecondaryButton(
              titleText: LangKeys.buttonChangePassword.tr(),
              onTap: () => context.slideUp(ChangePasswordScreen(email: _email)),
            ),
            const MoleculeItemSpace(),
            MoleculeSecondaryButton(
              titleText: LangKeys.buttonDeleteAccount.tr(),
              onTap: () => _askToDeleteAccount(context),
              color: ref.scheme.negative,
            ),
          ],
        ),
      ),
    );
  }

  void _showAgeBottomSheet(BuildContext context, User user) {
    final maxYear = (DateTime.now().year - 12);
    final minYear = maxYear - 99;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: moleculeBottomSheetBorder,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.66,
              minChildSize: 0.66,
              maxChildSize: 0.90,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const MoleculeItemSpace(),
                      MoleculeItemTitle(header: LangKeys.hintBirthYear.tr()),
                      const MoleculeItemSpace(),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollController,
                          itemCount: maxYear - minYear,
                          itemBuilder: (context, index) => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _setYob(context, maxYear - index),
                            child: MoleculeItemBasic(
                              title: "${maxYear - index}",
                              actionIcon: _yob == (maxYear - index) ? "check" : null,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
        );
      },
    );

    return;
  }

  void _showGenderBottomSheet(BuildContext context, User user) {
    modalBottomSheet(
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.screenProfileGender.tr()),
          const MoleculeItemSpace(),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              MoleculeItemBasic(
                title: LangKeys.genderNotSet.tr(),
                actionIcon: _gender == null ? "check" : null,
                onAction: () => _setGender(context, null),
              ),
              MoleculeItemBasic(
                title: LangKeys.genderFemale.tr(),
                actionIcon: _gender == Gender.woman ? "check" : null,
                onAction: () => _setGender(context, Gender.woman),
              ),
              MoleculeItemBasic(
                title: LangKeys.genderMale.tr(),
                actionIcon: _gender == Gender.man ? "check" : null,
                onAction: () => _setGender(context, Gender.man),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _setYob(BuildContext context, int yob) {
    context.pop();
    _yob = yob;
    _updateYearController();
  }

  void _setGender(BuildContext context, Gender? gender) {
    context.pop();
    _gender = gender;
    _updateGenderController();
  }

  void _updateNameController() => _nameController.text = _name ?? "";

  void _updateYearController() => _yearController.text = _yob?.toString() ?? "";

  void _updateGenderController() => _genderController.text = _gender?.display ?? LangKeys.genderNotSet.tr();

  void _askToDeleteAccount(BuildContext context) {
    modalBottomSheet(
      context,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: LangKeys.dialogDeleteAccountTitle.tr()),
          const MoleculeItemSpace(),
          LangKeys.dialogDeleteAccountMessage.tr().text.color(ref.scheme.content),
          const MoleculeItemSpace(),
          ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              Consumer(
                builder: (BuildContext _, WidgetRef ref, Widget? child) {
                  return MoleculeActionButton(
                    title: LangKeys.buttonDeleteAccount.tr(),
                    onPressed: () => _deleteAccount(context),
                    color: ref.scheme.negative,
                    successTitle: LangKeys.operationSuccessful.tr(),
                    failTitle: LangKeys.operationFailed.tr(),
                    buttonState: ref.watch(deleteAccountLogic).buttonState,
                  );
                },
              ),
              const MoleculeItemSpace(),
              MoleculeSecondaryButton(
                titleText: LangKeys.buttonClose.tr(),
                onTap: () {
                  _confirmAccountDeletion = 0;
                  context.pop();
                },
              ),
              const MoleculeItemSpace(),
            ],
          ),
        ],
      ),
    );
  }

  void _deleteAccount(BuildContext context) {
    if (_confirmAccountDeletion < 1) {
      ref.read(toastLogic.notifier).error(LangKeys.toastConfirmDeleteAccount.tr());
      hapticHeavy();
      context.pop();
      Future.delayed(hapticDelay, () {
        _askToDeleteAccount(context);
        Future.delayed(hapticDelay, () => hapticHeavy());
      });
      _confirmAccountDeletion++;
      return;
    }

    ref.read(deleteAccountLogic.notifier).delete();
  }
}

// eof
