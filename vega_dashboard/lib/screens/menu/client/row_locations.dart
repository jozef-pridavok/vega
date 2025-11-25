import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../../strings.dart";
import "../../client_locations/screen_locations.dart";

class LocationsRow extends ConsumerStatefulWidget {
  const LocationsRow({super.key});

  @override
  createState() => _ClientLocationsRowState();
}

class _ClientLocationsRowState extends ConsumerState<LocationsRow> {
  @override
  Widget build(BuildContext context) {
    //final client = ref.read(deviceRepository).get(DeviceKey.client) as Client?;
    return MoleculeItemBasic(
      icon: AtomIcons.location,
      title: LangKeys.menuClientLocations.tr(),
      label: LangKeys.menuClientLocationsDescription.tr(),
      //onAction: () =>
      //    client != null ? context.replace(ClientLocationsScreen()) : context.toastError(LangKeys.operationFailed.tr()),
      onAction: () => context.replace(const ClientLocationsScreen(showDrawer: true)),
    );
  }
}

// eof
