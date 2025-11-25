import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/strings.dart";

import "../../states/providers.dart";
import "screen_country.dart";

class CountryRow extends ConsumerStatefulWidget {
  const CountryRow({super.key});

  @override
  createState() => _CountryRowState();
}

class _CountryRowState extends ConsumerState<CountryRow> {
  @override
  Widget build(BuildContext context) {
    ref.watch(userUpdateLogic);
    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    final country = CountryCode.fromCode(user.country);
    return MoleculeItemBasic(
      icon: AtomIcons.flag,
      title: LangKeys.menuRegion.tr(),
      actionIcon: AtomIcons.chevronRight,
      label: country.localizedName,
      onAction: () => context.push(const CountryScreen()),
    );
  }
}

// eof
