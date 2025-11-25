import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/strings.dart";

import "../../states/providers.dart";
import "screen_location.dart";

class LocationRow extends ConsumerStatefulWidget {
  const LocationRow({super.key});

  @override
  createState() => _LocationRowState();
}

class _LocationRowState extends ConsumerState<LocationRow> {
  @override
  Widget build(BuildContext context) {
    ref.watch(userLocationLogic);
    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    final autoDisabled = user.metaLocationAutoDisabled;
    return MoleculeItemBasic(
      icon: "navigation",
      title: LangKeys.menuLocation.tr(),
      actionIcon: AtomIcons.chevronRight,
      // translate to slovak, english and spanish
      label: autoDisabled ? LangKeys.locationManual.tr() : LangKeys.locationAutomatic.tr(),
      onAction: () => context.push(const LocationScreen()),
    );
  }
}

// eof
