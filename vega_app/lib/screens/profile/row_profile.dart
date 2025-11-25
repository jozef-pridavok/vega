import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "../startup/screen_account.dart";
import "screen_profile_edit.dart";

class ProfileRow extends ConsumerStatefulWidget {
  const ProfileRow({super.key});

  @override
  createState() => _ProfileRowState();
}

class _ProfileRowState extends ConsumerState<ProfileRow> {
  late String title;
  late String label;

  @override
  void initState() {
    super.initState();
    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    final isAnonymous = user.isAnonymous;
    title = isAnonymous ? LangKeys.accountNotRegistered.tr() : (user.nick ?? "No name");
    label = isAnonymous ? (LangKeys.loggedAsGuest.tr()) : (user.email ?? LangKeys.noEmail.tr());
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(loginLogic);
    ref.watch(registerLogic);
    ref.watch(logoutLogic);
    ref.watch(userUpdateLogic);
    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    final isAnonymous = user.isAnonymous;
    label = isAnonymous ? (LangKeys.loggedAsGuest.tr()) : (user.email ?? LangKeys.noEmail.tr());
    title = isAnonymous ? LangKeys.accountNotRegistered.tr() : (user.nick ?? "No name");
    return MoleculeItemBasic(
      icon: AtomIcons.user,
      title: title,
      label: label,
      avatarColor: isAnonymous ? ref.scheme.negative : ref.scheme.primary,
      actionIcon: AtomIcons.itemDetail,
      onAction: () {
        final device = ref.read(deviceRepository);
        final user = device.get(DeviceKey.user) as User;
        final isAnonymous = user.isAnonymous;
        context.slideUp(
          isAnonymous ? const AccountScreen(closable: true) : const EditProfileScreen(),
        );
      },
    );
  }
}

// eof
