import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/locations.dart";
import "../../states/providers.dart";
import "../../widgets/state_error.dart";

class LocationsMapWidget extends ConsumerWidget {
  const LocationsMapWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationsLogic);
    if (state is LocationsSucceed || state is LocationsRefreshing) return const _MapWidget();
    if (state is LocationsFailed)
      return StateErrorWidget(
        locationsLogic,
        onReload: () => ref.read(locationsLogic.notifier).refresh(),
      );
    return const CenteredWaitIndicator();
  }
}

class _MapWidget extends ConsumerWidget {
  const _MapWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(locationsLogic) as LocationsSucceed;
    final locations = succeed.locations;
    return MapWidget<Location>(
      objects: locations,
      getGeoPoint: (object) => (object as Location).geoPoint,
      showMapControls: true,
    );
  }
}

// eof
