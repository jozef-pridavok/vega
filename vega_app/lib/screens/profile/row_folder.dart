import "dart:math";

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/states/providers.dart";
import "package:vega_app/strings.dart";

import "../../extensions/folder.dart";
import "screen_folders.dart";

class FoldersRow extends ConsumerStatefulWidget {
  const FoldersRow({super.key});

  @override
  createState() => _FoldersRowState();
}

class _FoldersRowState extends ConsumerState<FoldersRow> {
  @override
  Widget build(BuildContext context) {
    ref.watch(userUpdateLogic);
    final device = ref.read(deviceRepository);
    final user = device.get(DeviceKey.user) as User;
    final folders = user.folders.list;
    return MoleculeItemBasic(
      icon: "folders",
      title: LangKeys.menuFolders.tr(),
      actionIcon: "chevron_right",
      label: _foldersName(folders),
      onAction: () => context.push(const FoldersScreen()),
    );
  }

  String _foldersName(List<Folder> folders) {
    var len = folders.length;
    final head = folders.sublist(0, min(len, 3));
    len -= head.length;
    return "${head.map((x) => x.localizedName).join(', ')}${len > 0 ? ' + $len' : ''}";
  }
}

// eof
